.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   import pandas as pd
   pd.options.display.max_rows=8
   np.set_printoptions(precision=4, suppress=True)

.. ipython::
  :suppress:

  In [28]: columns = pd.MultiIndex.from_tuples([('A', 'cat'), ('B', 'dog'),
     ....:                                      ('B', 'cat'), ('A', 'dog')],
     ....:                                     names=['exp', 'animal'])
     ....: 

  In [29]: index = pd.MultiIndex.from_product([('bar', 'baz', 'foo', 'qux'),
     ....:                                     ('one', 'two')],
     ....:                                    names=['first', 'second'])
     ....: 

  In [30]: df = pd.DataFrame(np.random.randn(8, 4), index=index, columns=columns)

>>> columns = pd.MultiIndex.from_tuples([('A', 'cat'), ('B', 'dog'),
...                                      ('B', 'cat'), ('A', 'dog')],
...                                     names=['exp', 'animal'])
>>> index = pd.MultiIndex.from_product([('bar', 'baz', 'foo', 'qux'),
...                                     ('one', 'two')],
...                                    names=['first', 'second'])
>>> df = pd.DataFrame(np.random.randn(8, 4), index=index, columns=columns)

Combining with stats and GroupBy
--------------------------------

It should be no shock that combining ``pivot`` / ``stack`` / ``unstack`` with
GroupBy and the basic Series and DataFrame statistical functions can produce
some very expressive and fast data manipulations.

.. ipython:: python

   df
   df.stack().mean(1).unstack()

.. ipython:: python

   # same result, another way
   df.groupby(level=1, axis=1).mean()

   df.stack().groupby(level=1).mean()

   df.mean().unstack(0)