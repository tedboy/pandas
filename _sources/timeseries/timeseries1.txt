.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   from datetime import datetime, timedelta, time
   import numpy as np
   import pandas as pd
   from pandas import datetools
   np.random.seed(123456)
   randn = np.random.randn
   randint = np.random.randint
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows=8
   import dateutil
   import pytz
   from dateutil.relativedelta import relativedelta

Introduction
------------
pandas has proven very successful as a tool for working with time series data,
especially in the financial data analysis space. Using the NumPy ``datetime64`` and ``timedelta64`` dtypes,
we have consolidated a large number of features from other Python libraries like ``scikits.timeseries`` as well as created
a tremendous amount of new functionality for manipulating time series data.

In working with time series data, we will frequently seek to:

  - generate sequences of fixed-frequency dates and time spans
  - conform or convert time series to a particular frequency
  - compute "relative" dates based on various non-standard time increments
    (e.g. 5 business days before the last business day of the year), or "roll"
    dates forward or backward

pandas provides a relatively compact and self-contained set of tools for
performing the above tasks.

Create a range of dates:

.. ipython:: python

   # 72 hours starting with midnight Jan 1st, 2011
   rng = pd.date_range('1/1/2011', periods=72, freq='H')
   rng[:5]

Index pandas objects with dates:

.. ipython:: python

   ts = pd.Series(np.random.randn(len(rng)), index=rng)
   ts.head()

Change frequency and fill gaps:

.. ipython:: python

   # to 45 minute frequency and forward fill
   converted = ts.asfreq('45Min', method='pad')
   converted.head()

Resample:

.. ipython:: python

   # Daily means
   ts.resample('D').mean()