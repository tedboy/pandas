.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(1234567)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. _indexing.dictionarylike:

Dictionary-like :meth:`~pandas.DataFrame.get` method
----------------------------------------------------

Each of Series, DataFrame, and Panel have a ``get`` method which can return a
default value.

.. ipython:: python

   s = pd.Series([1,2,3], index=['a','b','c'])
   s
   s.get('a')               # equivalent to s['a']
   s.get('x', default=-1)