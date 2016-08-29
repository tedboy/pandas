.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   import pandas as pd
   pd.options.display.max_rows=8
   np.set_printoptions(precision=4, suppress=True)

.. _reshaping.tile:
.. _reshaping.tile.cut:

Tiling
------

The ``cut`` function computes groupings for the values of the input array and
is often used to transform continuous variables to discrete or categorical
variables:

.. ipython:: python

   ages = np.array([10, 15, 13, 12, 23, 25, 28, 59, 60])

   pd.cut(ages, bins=3)

If the ``bins`` keyword is an integer, then equal-width bins are formed.
Alternatively we can specify custom bin-edges:

.. ipython:: python

   pd.cut(ages, bins=[0, 18, 35, 70])