.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

Setting With Enlargement
------------------------

.. versionadded:: 0.13

The ``.loc/.ix/[]`` operations can perform enlargement when setting a non-existant key for that axis.

In the ``Series`` case this is effectively an appending operation

.. ipython:: python

   se = pd.Series([1,2,3])
   se
   se[5] = 5.
   se

A ``DataFrame`` can be enlarged on either axis via ``.loc``

.. ipython:: python

   dfi = pd.DataFrame(np.arange(6).reshape(3,2),
                   columns=['A','B'])
   dfi
   dfi.loc[:,'C'] = dfi.loc[:,'A']
   dfi

This is like an ``append`` operation on the ``DataFrame``.

.. ipython:: python

   dfi.loc[3] = 5
   dfi