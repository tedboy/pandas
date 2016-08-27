.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows = 15
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')
   from collections import OrderedDict

.. _groupby.transform:

Transformation
--------------

The ``transform`` method returns an object that is indexed the same (same size)
as the one being grouped. Thus, the passed transform function should return a
result that is the same size as the group chunk. For example, suppose we wished
to standardize the data within each group:

.. ipython:: python

   index = pd.date_range('10/1/1999', periods=1100)
   ts = pd.Series(np.random.normal(0.5, 2, 1100), index)
   ts = ts.rolling(window=100,min_periods=100).mean().dropna()

   ts.head()
   ts.tail()
   key = lambda x: x.year
   zscore = lambda x: (x - x.mean()) / x.std()
   transformed = ts.groupby(key).transform(zscore)

We would expect the result to now have mean 0 and standard deviation 1 within
each group, which we can easily check:

.. ipython:: python

   # Original Data
   grouped = ts.groupby(key)
   grouped.mean()
   grouped.std()

   # Transformed Data
   grouped_trans = transformed.groupby(key)
   grouped_trans.mean()
   grouped_trans.std()

We can also visually compare the original and transformed data sets.

.. ipython:: python

   compare = pd.DataFrame({'Original': ts, 'Transformed': transformed})

   @savefig groupby_transform_plot.png
   compare.plot()

Another common data transform is to replace missing data with the group mean.

.. ipython:: python
   :suppress:

   cols = ['A', 'B', 'C']
   values = np.random.randn(1000, 3)
   values[np.random.randint(0, 1000, 100), 0] = np.nan
   values[np.random.randint(0, 1000, 50), 1] = np.nan
   values[np.random.randint(0, 1000, 200), 2] = np.nan
   data_df = pd.DataFrame(values, columns=cols)

.. ipython:: python

   data_df

   countries = np.array(['US', 'UK', 'GR', 'JP'])
   key = countries[np.random.randint(0, 4, 1000)]

   grouped = data_df.groupby(key)

   # Non-NA count in each group
   grouped.count()

   f = lambda x: x.fillna(x.mean())

   transformed = grouped.transform(f)

We can verify that the group means have not changed in the transformed data
and that the transformed data contains no NAs.

.. ipython:: python

   grouped_trans = transformed.groupby(key)

   grouped.mean() # original group means
   grouped_trans.mean() # transformation did not change group means

   grouped.count() # original has some missing data points
   grouped_trans.count() # counts after transformation
   grouped_trans.size() # Verify non-NA count equals group size

.. note::

   Some functions when applied to a groupby object will automatically transform the input, returning
   an object of the same shape as the original. Passing ``as_index=False`` will not affect these transformation methods.

   For example: ``fillna, ffill, bfill, shift``.

   .. ipython:: python

      grouped.ffill()