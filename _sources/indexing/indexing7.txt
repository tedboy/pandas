.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. _indexing.callable:

Selection By Callable
---------------------

.. versionadded:: 0.18.1

``.loc``, ``.iloc``, ``.ix`` and also ``[]`` indexing can accept a ``callable`` as indexer.
The ``callable`` must be a function with one argument (the calling Series, DataFrame or Panel) and that returns valid output for indexing.

.. ipython:: python

   df1 = pd.DataFrame(np.random.randn(6, 4),
                      index=list('abcdef'),
                      columns=list('ABCD'))
   df1

   df1.loc[lambda df: df.A > 0, :]
   df1.loc[:, lambda df: ['A', 'B']]

   df1.iloc[:, lambda df: [0, 1]]

   df1[lambda df: df.columns[0]]


You can use callable indexing in ``Series``.

.. ipython:: python

   df1.A.loc[lambda s: s > 0]

Using these methods / indexers, you can chain data selection operations
without using temporary variable.

.. ipython:: python

   bb = pd.read_csv('https://raw.githubusercontent.com/pydata/pandas/master/doc/data/baseball.csv', 
       index_col='id')
   bb.head()
   (bb.groupby(['year', 'team']).sum()
      .loc[lambda df: df.r > 100])