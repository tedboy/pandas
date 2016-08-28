.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   import pandas as pd
   pd.options.display.max_rows=8
   np.set_printoptions(precision=4, suppress=True)

.. _reshaping.stacking:

Reshaping by stacking and unstacking
------------------------------------

Closely related to the ``pivot`` function are the related ``stack`` and
``unstack`` functions currently available on Series and DataFrame. These
functions are designed to work together with ``MultiIndex`` objects (see the
section on :ref:`hierarchical indexing <advanced.hierarchical>`). Here are
essentially what these functions do:

  - ``stack``: "pivot" a level of the (possibly hierarchical) column labels,
    returning a DataFrame with an index with a new inner-most level of row
    labels.
  - ``unstack``: inverse operation from ``stack``: "pivot" a level of the
    (possibly hierarchical) row index to the column axis, producing a reshaped
    DataFrame with a new inner-most level of column labels.

The clearest way to explain is by example. Let's take a prior example data set
from the hierarchical indexing section:

.. ipython:: python

   tuples = list(zip(*[['bar', 'bar', 'baz', 'baz',
                        'foo', 'foo', 'qux', 'qux'],
                       ['one', 'two', 'one', 'two',
                        'one', 'two', 'one', 'two']]))
   index = pd.MultiIndex.from_tuples(tuples, names=['first', 'second'])
   df = pd.DataFrame(np.random.randn(8, 2), index=index, columns=['A', 'B'])
   df
   df2 = df[:4]
   df2

The ``stack`` function "compresses" a level in the DataFrame's columns to
produce either:

  - A Series, in the case of a simple column Index
  - A DataFrame, in the case of a ``MultiIndex`` in the columns

If the columns have a ``MultiIndex``, you can choose which level to stack. The
stacked level becomes the new lowest level in a ``MultiIndex`` on the columns:

.. ipython:: python

   stacked = df2.stack()
   stacked

With a "stacked" DataFrame or Series (having a ``MultiIndex`` as the
``index``), the inverse operation of ``stack`` is ``unstack``, which by default
unstacks the **last level**:

.. ipython:: python

   stacked.unstack()  # last level (default)

   stacked.unstack(1) # 2nd level

   stacked.unstack(0) # 1st level

.. _reshaping.unstack_by_name:

If the indexes have names, you can use the level names instead of specifying
the level numbers:

.. ipython:: python

   stacked
   stacked.unstack('second')

Notice that the ``stack`` and ``unstack`` methods implicitly sort the index
levels involved. Hence a call to ``stack`` and then ``unstack``, or viceversa,
will result in a **sorted** copy of the original DataFrame or Series:

.. ipython:: python

   index = pd.MultiIndex.from_product([[2,1], ['a', 'b']])
   df = pd.DataFrame(np.random.randn(4), index=index, columns=['A'])
   df
   all(df.unstack().stack() == df.sort_index())

while the above code will raise a ``TypeError`` if the call to ``sort_index`` is
removed.

.. _reshaping.stack_multiple:

Multiple Levels
~~~~~~~~~~~~~~~

You may also stack or unstack more than one level at a time by passing a list
of levels, in which case the end result is as if each level in the list were
processed individually.

.. ipython:: python

    columns = pd.MultiIndex.from_tuples([
            ('A', 'cat', 'long'), ('B', 'cat', 'long'),
            ('A', 'dog', 'short'), ('B', 'dog', 'short')
        ],
        names=['exp', 'animal', 'hair_length']
    )
    df = pd.DataFrame(np.random.randn(4, 4), columns=columns)
    df

    df.stack(level=['animal', 'hair_length'])

The list of levels can contain either level names or level numbers (but
not a mixture of the two).

.. ipython:: python

    # df.stack(level=['animal', 'hair_length'])
    # from above is equivalent to:
    df.stack(level=[1, 2])

Missing Data
~~~~~~~~~~~~

These functions are intelligent about handling missing data and do not expect
each subgroup within the hierarchical index to have the same set of labels.
They also can handle the index being unsorted (but you can make it sorted by
calling ``sort_index``, of course). Here is a more complex example:

.. ipython:: python

   columns = pd.MultiIndex.from_tuples([('A', 'cat'), ('B', 'dog'),
                                        ('B', 'cat'), ('A', 'dog')],
                                       names=['exp', 'animal'])
   index = pd.MultiIndex.from_product([('bar', 'baz', 'foo', 'qux'),
                                       ('one', 'two')],
                                      names=['first', 'second'])
   df = pd.DataFrame(np.random.randn(8, 4), index=index, columns=columns)
   df2 = df.ix[[0, 1, 2, 4, 5, 7]]
   df2

As mentioned above, ``stack`` can be called with a ``level`` argument to select
which level in the columns to stack:

.. ipython:: python

   df2.stack('exp')
   df2.stack('animal')

Unstacking can result in missing values if subgroups do not have the same
set of labels.  By default, missing values will be replaced with the default
fill value for that data type, ``NaN`` for float, ``NaT`` for datetimelike,
etc.  For integer types, by default data will converted to float and missing
values will be set to ``NaN``.

.. ipython:: python

   df3 = df.iloc[[0, 1, 4, 7], [1, 2]]
   df3
   df3.unstack()

.. versionadded: 0.18.0

Alternatively, unstack takes an optional ``fill_value`` argument, for specifying
the value of missing data.

.. ipython:: python

   df3.unstack(fill_value=-1e9)

With a MultiIndex
~~~~~~~~~~~~~~~~~

Unstacking when the columns are a ``MultiIndex`` is also careful about doing
the right thing:

.. ipython:: python

   df
   df[:3].unstack(0)

.. ipython:: python
   
   df2
   df2.unstack(1)