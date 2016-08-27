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

Examples
--------

Regrouping by factor
~~~~~~~~~~~~~~~~~~~~

Regroup columns of a DataFrame according to their sum, and sum the aggregated ones.

.. ipython:: python

   df = pd.DataFrame({'a':[1,0,0], 'b':[0,1,0], 'c':[1,0,0], 'd':[2,3,4]})
   df
   df.groupby(df.sum(), axis=1).sum()

Groupby by Indexer to 'resample' data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Resampling produces new hypothetical samples(resamples) from already existing observed data or from a model that generates data. These new samples are similar to the pre-existing samples.

In order to resample to work on indices that are non-datetimelike , the following procedure can be utilized.

In the following examples, **df.index // 5** returns a binary array which is used to determine what get's selected for the groupby operation.

.. note:: The below example shows how we can downsample by consolidation of samples into fewer samples. Here by using **df.index // 5**, we are aggregating the samples in bins. By applying **std()** function, we aggregate the information contained in many samples into a small subset of values which is their standard deviation thereby reducing the number of samples.

.. ipython:: python

   df = pd.DataFrame(np.random.randn(10,2))
   df
   df.index // 5
   df.groupby(df.index // 5).std()

Returning a Series to propagate names
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Group DataFrame columns, compute a set of metrics and return a named Series.
The Series name is used as the name for the column index. This is especially
useful in conjunction with reshaping operations such as stacking in which the
column index name will be used as the name of the inserted column:

.. ipython:: python

   df = pd.DataFrame({
            'a':  [0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2],
            'b':  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1],
            'c':  [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
            'd':  [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
            })

   def compute_metrics(x):
       result = {'b_sum': x['b'].sum(), 'c_mean': x['c'].mean()}
       return pd.Series(result, name='metrics')

   result = df.groupby('a').apply(compute_metrics)

   result

   result.stack()