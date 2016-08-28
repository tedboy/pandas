.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. ipython:: python

   dates = pd.date_range('1/1/2000', periods=8)
   df = pd.DataFrame(np.random.randn(8, 4), index=dates, columns=['A', 'B', 'C', 'D'])
   s = df['A']

.. _indexing.basics.get_value:

Fast scalar value getting and setting
-------------------------------------

Since indexing with ``[]`` must handle a lot of cases (single-label access,
slicing, boolean indexing, etc.), it has a bit of overhead in order to figure
out what you're asking for. If you only want to access a scalar value, the
fastest way is to use the ``at`` and ``iat`` methods, which are implemented on
all of the data structures.

Similarly to ``loc``, ``at`` provides **label** based scalar lookups, while, ``iat`` provides **integer** based lookups analogously to ``iloc``

.. ipython:: python
   
   s
   s.iat[5]
   df
   dates
   df.at[dates[5], 'A']
   df.iat[3, 0]

You can also set using these same indexers.

.. ipython:: python

   df
   df.at[dates[5], 'E'] = 7
   df.iat[3, 0] = 7

``at`` may enlarge the object in-place as above if the indexer is missing.

.. ipython:: python

   df
   df.at[dates[-1]+1, 0] = 7
   df