.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. ipython:: python
   :suppress:

   dates = pd.date_range('1/1/2000', periods=8)
   df = pd.DataFrame(np.random.randn(8, 4), index=dates, columns=['A', 'B', 'C', 'D'])
   s = df['A']
   panel = pd.Panel({'one' : df, 'two' : df - df.mean()})

Slicing ranges
--------------

The most robust and consistent way of slicing ranges along arbitrary axes is
described in the :ref:`Selection by Position <indexing.integer>` section
detailing the ``.iloc`` method. For now, we explain the semantics of slicing using the ``[]`` operator.

With Series, the syntax works exactly as with an ndarray, returning a slice of
the values and the corresponding labels:

.. ipython:: python

   s
   s[:5]
   s[::2]
   s[::-1]

Note that setting works as well:

.. ipython:: python

   s2 = s.copy()
   s2[:5] = 0
   s2

With DataFrame, slicing inside of ``[]`` **slices the rows**. This is provided
largely as a convenience since it is such a common operation.

.. ipython:: python

   df
   df[:3]
   df[::-1]