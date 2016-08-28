.. ipython:: python
   :suppress:
   
   import pandas as pd
   import numpy as np

   import random
   import os
   import itertools
   import functools
   import datetime

   np.random.seed(123456)
   pd.options.display.max_rows=8
   import matplotlib
   matplotlib.style.use('ggplot')
   np.set_printoptions(precision=4, suppress=True)

.. _cookbook.merge:

Merge
-----

The :ref:`Concat <merging.concatenation>` docs. The :ref:`Join <merging.join>` docs.

`Append two dataframes with overlapping index (emulate R rbind)
<http://stackoverflow.com/questions/14988480/pandas-version-of-rbind>`__

.. ipython:: python

   rng = pd.date_range('2000-01-01', periods=6)
   df1 = pd.DataFrame(np.random.randn(6, 3), index=rng, columns=['A', 'B', 'C'])
   df2 = df1.copy()

ignore_index is needed in pandas < v0.13, and depending on df construction

.. ipython:: python

   df = df1.append(df2,ignore_index=True); df

`Self Join of a DataFrame
<https://github.com/pydata/pandas/issues/2996>`__

.. ipython:: python

   df = pd.DataFrame(data={'Area' : ['A'] * 5 + ['C'] * 2,
                           'Bins' : [110] * 2 + [160] * 3 + [40] * 2,
                           'Test_0' : [0, 1, 0, 1, 2, 0, 1],
                           'Data' : np.random.randn(7)});df

   df['Test_1'] = df['Test_0'] - 1

   pd.merge(df, df, left_on=['Bins', 'Area','Test_0'], right_on=['Bins', 'Area','Test_1'],suffixes=('_L','_R'))

`How to set the index and join
<http://stackoverflow.com/questions/14341805/pandas-merge-pd-merge-how-to-set-the-index-and-join>`__

`KDB like asof join
<http://stackoverflow.com/questions/12322289/kdb-like-asof-join-for-timeseries-data-in-pandas/12336039#12336039>`__

`Join with a criteria based on the values
<http://stackoverflow.com/questions/15581829/how-to-perform-an-inner-or-outer-join-of-dataframes-with-pandas-on-non-simplisti>`__

`Using searchsorted to merge based on values inside a range
<http://stackoverflow.com/questions/25125626/pandas-merge-with-logic/2512764>`__