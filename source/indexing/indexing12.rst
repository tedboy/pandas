.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. _indexing.basics.indexing_isin:

Indexing with isin
------------------

Consider the ``isin`` method of Series, which returns a boolean vector that is
true wherever the Series elements exist in the passed list. This allows you to
select rows where one or more columns have values you want:

.. ipython:: python

   s = pd.Series(np.arange(5), index=np.arange(5)[::-1], dtype='int64')
   s
   s.isin([2, 4, 6])
   s[s.isin([2, 4, 6])]

The same method is available for ``Index`` objects and is useful for the cases
when you don't know which of the sought labels are in fact present:

.. ipython:: python

   s[s.index.isin([2, 4, 6])]

   # compare it to the following
   s[[2, 4, 6]]

In addition to that, ``MultiIndex`` allows selecting a separate level to use
in the membership check:

.. ipython:: python

   s_mi = pd.Series(np.arange(6),
                    index=pd.MultiIndex.from_product([[0, 1], ['a', 'b', 'c']]))
   s_mi
   s_mi.iloc[s_mi.index.isin([(1, 'a'), (2, 'b'), (0, 'c')])]
   s_mi.iloc[s_mi.index.isin(['a', 'c', 'e'], level=1)]

DataFrame also has an ``isin`` method.  When calling ``isin``, pass a set of
values as either an array or dict.  If values is an array, ``isin`` returns
a DataFrame of booleans that is the same shape as the original DataFrame, with True
wherever the element is in the sequence of values.

.. ipython:: python

   df = pd.DataFrame({'vals': [1, 2, 3, 4], 'ids': ['a', 'b', 'f', 'n'],
                      'ids2': ['a', 'n', 'c', 'n']})
   df
   values = ['a', 'b', 1, 3]

   df.isin(values)

Oftentimes you'll want to match certain values with certain columns.
Just make values a ``dict`` where the key is the column, and the value is
a list of items you want to check for.

.. ipython:: python

   values = {'ids': ['a', 'b'], 'vals': [1, 3]}

   df.isin(values)

Combine DataFrame's ``isin`` with the ``any()`` and ``all()`` methods to
quickly select subsets of your data that meet a given criteria.
To select a row where each column meets its own criterion:

.. ipython:: python

  values = {'ids': ['a', 'b'], 'ids2': ['a', 'c'], 'vals': [1, 3]}

  row_mask = df.isin(values).all(1)
  df
  row_mask
  df[row_mask]