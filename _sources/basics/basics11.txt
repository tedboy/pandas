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

.. _basics.sorting:

Sorting
-------

.. warning::

   The sorting API is substantially changed in 0.17.0, see :ref:`here <whatsnew_0170.api_breaking.sorting>` for these changes.
   In particular, all sorting methods now return a new object by default, and **DO NOT** operate in-place (except by passing ``inplace=True``).

There are two obvious kinds of sorting that you may be interested in: sorting
by label and sorting by actual values.

By Index
~~~~~~~~

The primary method for sorting axis
labels (indexes) are the ``Series.sort_index()`` and the ``DataFrame.sort_index()`` methods.

.. ipython:: python

   df
   unsorted_df = df.reindex(index=['a', 'd', 'c', 'b'],
                            columns=['three', 'two', 'one'])

   # DataFrame
   unsorted_df.sort_index()
   unsorted_df.sort_index(ascending=False)
   unsorted_df.sort_index(axis=1)

   # Series
   unsorted_df['three'].sort_index()

By Values
~~~~~~~~~

The :meth:`Series.sort_values` and :meth:`DataFrame.sort_values` are the entry points for **value** sorting (that is the values in a column or row).
:meth:`DataFrame.sort_values` can accept an optional ``by`` argument for ``axis=0``
which will use an arbitrary vector or a column name of the DataFrame to
determine the sort order:

.. ipython:: python

   df1 = pd.DataFrame({'one':[2,1,1,1],'two':[1,3,2,4],'three':[5,4,3,2]})
   df1.sort_values(by='two')

The ``by`` argument can take a list of column names, e.g.:

.. ipython:: python

   df1[['one', 'two', 'three']].sort_values(by=['one','two'])

These methods have special treatment of NA values via the ``na_position``
argument:

.. ipython:: python

   s[2] = np.nan
   s.sort_values()
   s.sort_values(na_position='first')


.. _basics.searchsorted:

searchsorted
~~~~~~~~~~~~

Series has the :meth:`~Series.searchsorted` method, which works similar to
:meth:`numpy.ndarray.searchsorted`.

.. ipython:: python

   ser = pd.Series([1, 2, 3])
   ser.searchsorted([0, 3])
   ser.searchsorted([0, 4])
   ser.searchsorted([1, 3], side='right')
   ser.searchsorted([1, 3], side='left')
   ser = pd.Series([3, 1, 2])
   ser.searchsorted([0, 3], sorter=np.argsort(ser))

.. _basics.nsorted:

smallest / largest values
~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.14.0

``Series`` has the :meth:`~Series.nsmallest` and :meth:`~Series.nlargest` methods which return the
smallest or largest :math:`n` values. For a large ``Series`` this can be much
faster than sorting the entire Series and calling ``head(n)`` on the result.

.. ipython:: python

   s = pd.Series(np.random.permutation(10))
   s
   s.sort_values()
   s.nsmallest(3)
   s.nlargest(3)

.. versionadded:: 0.17.0

``DataFrame`` also has the ``nlargest`` and ``nsmallest`` methods.

.. ipython:: python

   df = pd.DataFrame({'a': [-2, -1, 1, 10, 8, 11, -1],
                      'b': list('abdceff'),
                      'c': [1.0, 2.0, 4.0, 3.2, np.nan, 3.0, 4.0]})
   df.nlargest(3, 'a')
   df.nlargest(5, ['a', 'c'])
   df.nsmallest(3, 'a')
   df.nsmallest(5, ['a', 'c'])


.. _basics.multi-index_sorting:

Sorting by a multi-index column
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You must be explicit about sorting when the column is a multi-index, and fully specify
all levels to ``by``.

.. ipython:: python

   df1.columns = pd.MultiIndex.from_tuples([('a','one'),('a','two'),('b','three')])
   df1.sort_values(by=('a','two'))
