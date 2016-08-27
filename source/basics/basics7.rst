.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8
   df = pd.DataFrame({'one' : pd.Series(np.random.randn(3), index=['a', 'b', 'c']),
                      'two' : pd.Series(np.random.randn(4), index=['a', 'b', 'c', 'd']),
                      'three' : pd.Series(np.random.randn(3), index=['b', 'c', 'd'])})
   
.. _basics.reindexing:

Reindexing and altering labels
------------------------------

:meth:`~Series.reindex` is the fundamental data alignment method in pandas.
It is used to implement nearly all other features relying on label-alignment
functionality. To *reindex* means to conform the data to match a given set of
labels along a particular axis. This accomplishes several things:

  * Reorders the existing data to match a new set of labels
  * Inserts missing value (NA) markers in label locations where no data for
    that label existed
  * If specified, **fill** data for missing labels using logic (highly relevant
    to working with time series data)

Here is a simple example:

.. ipython:: python

   s = pd.Series(np.random.randn(5), index=['a', 'b', 'c', 'd', 'e'])
   s
   s.reindex(['e', 'b', 'f', 'd'])

Here, the ``f`` label was not contained in the Series and hence appears as
``NaN`` in the result.

With a DataFrame, you can simultaneously reindex the index and columns:

.. ipython:: python

   df
   df.reindex(index=['c', 'f', 'b'], columns=['three', 'two', 'one'])

For convenience, you may utilize the :meth:`~Series.reindex_axis` method, which
takes the labels and a keyword ``axis`` parameter.

Note that the ``Index`` objects containing the actual axis labels can be
**shared** between objects. So if we have a Series and a DataFrame, the
following can be done:

.. ipython:: python

   rs = s.reindex(df.index)
   rs
   rs.index is df.index

This means that the reindexed Series's index is the same Python object as the
DataFrame's index.


.. seealso::

   :ref:`MultiIndex / Advanced Indexing <advanced>` is an even more concise way of
   doing reindexing.

.. note::

    When writing performance-sensitive code, there is a good reason to spend
    some time becoming a reindexing ninja: **many operations are faster on
    pre-aligned data**. Adding two unaligned DataFrames internally triggers a
    reindexing step. For exploratory analysis you will hardly notice the
    difference (because ``reindex`` has been heavily optimized), but when CPU
    cycles matter sprinkling a few explicit ``reindex`` calls here and there can
    have an impact.

.. _basics.reindex_like:

Reindexing to align with another object
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You may wish to take an object and reindex its axes to be labeled the same as
another object. While the syntax for this is straightforward albeit verbose, it
is a common enough operation that the :meth:`~DataFrame.reindex_like` method is
available to make this simpler:

.. ipython:: python
   :suppress:

   df2 = df.reindex(['a', 'b', 'c'], columns=['one', 'two'])
   df3 = df2 - df2.mean()


.. ipython:: python

   df2
   df3
   df.reindex_like(df2)

.. _basics.align:

Aligning objects with each other with ``align``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :meth:`~Series.align` method is the fastest way to simultaneously align two objects. It
supports a ``join`` argument (related to :ref:`joining and merging <merging>`):

  - ``join='outer'``: take the union of the indexes (default)
  - ``join='left'``: use the calling object's index
  - ``join='right'``: use the passed object's index
  - ``join='inner'``: intersect the indexes

It returns a tuple with both of the reindexed Series:

.. ipython:: python

   s = pd.Series(np.random.randn(5), index=['a', 'b', 'c', 'd', 'e'])
   s1 = s[:4]
   s2 = s[1:]
   s1.align(s2)
   s1.align(s2, join='inner')
   s1.align(s2, join='left')

.. _basics.df_join:

For DataFrames, the join method will be applied to both the index and the
columns by default:

.. ipython:: python

   df.align(df2, join='inner')

You can also pass an ``axis`` option to only align on the specified axis:

.. ipython:: python

   df.align(df2, join='inner', axis=0)

.. _basics.align.frame.series:

If you pass a Series to :meth:`DataFrame.align`, you can choose to align both
objects either on the DataFrame's index or columns using the ``axis`` argument:

.. ipython:: python

   df.align(df2.ix[0], axis=1)

.. _basics.reindex_fill:

Filling while reindexing
~~~~~~~~~~~~~~~~~~~~~~~~

:meth:`~Series.reindex` takes an optional parameter ``method`` which is a
filling method chosen from the following table:

.. csv-table::
    :header: "Method", "Action"
    :widths: 30, 50

    pad / ffill, Fill values forward
    bfill / backfill, Fill values backward
    nearest, Fill from the nearest index value

We illustrate these fill methods on a simple Series:

.. ipython:: python

   rng = pd.date_range('1/3/2000', periods=8)
   ts = pd.Series(np.random.randn(8), index=rng)
   ts2 = ts[[0, 3, 6]]
   ts
   ts2

   ts2.reindex(ts.index)
   ts2.reindex(ts.index, method='ffill')
   ts2.reindex(ts.index, method='bfill')
   ts2.reindex(ts.index, method='nearest')

These methods require that the indexes are **ordered** increasing or
decreasing.

Note that the same result could have been achieved using
:ref:`fillna <missing_data.fillna>` (except for ``method='nearest'``) or
:ref:`interpolate <missing_data.interpolate>`:

.. ipython:: python

   ts2.reindex(ts.index).fillna(method='ffill')

:meth:`~Series.reindex` will raise a ValueError if the index is not monotonic
increasing or decreasing. :meth:`~Series.fillna` and :meth:`~Series.interpolate`
will not make any checks on the order of the index.

.. _basics.limits_on_reindex_fill:

Limits on filling while reindexing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``limit`` and ``tolerance`` arguments provide additional control over
filling while reindexing. Limit specifies the maximum count of consecutive
matches:

.. ipython:: python

   ts2.reindex(ts.index, method='ffill', limit=1)

In contrast, tolerance specifies the maximum distance between the index and
indexer values:

.. ipython:: python

   ts2.reindex(ts.index, method='ffill', tolerance='1 day')

Notice that when used on a ``DatetimeIndex``, ``TimedeltaIndex`` or
``PeriodIndex``, ``tolerance`` will coerced into a ``Timedelta`` if possible.
This allows you to specify tolerance with appropriate strings.

.. _basics.drop:

Dropping labels from an axis
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A method closely related to ``reindex`` is the :meth:`~DataFrame.drop` function.
It removes a set of labels from an axis:

.. ipython:: python

   df
   df.drop(['a', 'd'], axis=0)
   df.drop(['one'], axis=1)

Note that the following also works, but is a bit less obvious / clean:

.. ipython:: python

   df.reindex(df.index.difference(['a', 'd']))

.. _basics.rename:

Renaming / mapping labels
~~~~~~~~~~~~~~~~~~~~~~~~~

The :meth:`~DataFrame.rename` method allows you to relabel an axis based on some
mapping (a dict or Series) or an arbitrary function.

.. ipython:: python

   s
   s.rename(str.upper)

If you pass a function, it must return a value when called with any of the
labels (and must produce a set of unique values). A dict or
Series can also be used:

.. ipython:: python

   df.rename(columns={'one' : 'foo', 'two' : 'bar'},
             index={'a' : 'apple', 'b' : 'banana', 'd' : 'durian'})

If the mapping doesn't include a column/index label, it isn't renamed. Also
extra labels in the mapping don't throw an error.

The :meth:`~DataFrame.rename` method also provides an ``inplace`` named
parameter that is by default ``False`` and copies the underlying data. Pass
``inplace=True`` to rename the data in place.

.. versionadded:: 0.18.0

Finally, :meth:`~Series.rename` also accepts a scalar or list-like
for altering the ``Series.name`` attribute.

.. ipython:: python

   s.rename("scalar-name")

.. _basics.rename_axis:

The Panel class has a related :meth:`~Panel.rename_axis` class which can rename
any of its three axes.
