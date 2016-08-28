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

Timeseries
----------

`Between times
<http://stackoverflow.com/questions/14539992/pandas-drop-rows-outside-of-time-range>`__

`Using indexer between time
<http://stackoverflow.com/questions/17559885/pandas-dataframe-mask-based-on-index>`__

`Constructing a datetime range that excludes weekends and includes only certain times
<http://stackoverflow.com/questions/24010830/pandas-generate-sequential-timestamp-with-jump/24014440#24014440?>`__

`Vectorized Lookup
<http://stackoverflow.com/questions/13893227/vectorized-look-up-of-values-in-pandas-dataframe>`__

`Aggregation and plotting time series
<http://nipunbatra.github.io/2015/06/timeseries/>`__

Turn a matrix with hours in columns and days in rows into a continuous row sequence in the form of a time series.
`How to rearrange a python pandas DataFrame?
<http://stackoverflow.com/questions/15432659/how-to-rearrange-a-python-pandas-dataframe>`__

`Dealing with duplicates when reindexing a timeseries to a specified frequency
<http://stackoverflow.com/questions/22244383/pandas-df-refill-adding-two-columns-of-different-shape>`__

Calculate the first day of the month for each entry in a DatetimeIndex

.. ipython:: python

   dates = pd.date_range('2000-01-01', periods=5)
   dates.to_period(freq='M').to_timestamp()

.. _cookbook.resample:

Resampling
**********

The :ref:`Resample <timeseries.resampling>` docs.

`TimeGrouping of values grouped across time
<http://stackoverflow.com/questions/15297053/how-can-i-divide-single-values-of-a-dataframe-by-monthly-averages>`__

`TimeGrouping #2
<http://stackoverflow.com/questions/14569223/timegrouper-pandas>`__

`Using TimeGrouper and another grouping to create subgroups, then apply a custom function
<https://github.com/pydata/pandas/issues/3791>`__

`Resampling with custom periods
<http://stackoverflow.com/questions/15408156/resampling-with-custom-periods>`__

`Resample intraday frame without adding new days
<http://stackoverflow.com/questions/14898574/resample-intrday-pandas-dataframe-without-add-new-days>`__

`Resample minute data
<http://stackoverflow.com/questions/14861023/resampling-minute-data>`__

`Resample with groupby <http://stackoverflow.com/q/18677271/564538>`__