.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(0)
   pd.options.display.max_rows=15
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   df = pd.DataFrame(np.random.randn(5, 3), index=['a', 'c', 'e', 'f', 'h'],
                     columns=['one', 'two', 'three'])
   df['four'] = 'bar'
   df['five'] = df['one'] > 0

Datetimes
---------

For datetime64[ns] types, ``NaT`` represents missing values. This is a pseudo-native
sentinel value that can be represented by numpy in a singular dtype (datetime64[ns]).
pandas objects provide intercompatibility between ``NaT`` and ``NaN``.

.. ipython:: python

   df2 = df.copy()
   df2
   df2['timestamp'] = pd.Timestamp('20120101')
   df2
   df2.ix[['a','c','h'],['one','timestamp']] = np.nan
   df2
   df2.get_dtype_counts()

