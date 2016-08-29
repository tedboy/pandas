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

.. _timeseries.daterange:

Generating Ranges of Timestamps
-------------------------------

To generate an index with time stamps, you can use either the DatetimeIndex or
Index constructor and pass in a list of datetime objects:

.. ipython:: python

   dates = [datetime(2012, 5, 1), datetime(2012, 5, 2), datetime(2012, 5, 3)]

   # Note the frequency information
   index = pd.DatetimeIndex(dates)
   index

   # Automatically converted to DatetimeIndex
   index = pd.Index(dates)
   index

Practically, this becomes very cumbersome because we often need a very long
index with a large number of timestamps. If we need timestamps on a regular
frequency, we can use the pandas functions ``date_range`` and ``bdate_range``
to create timestamp indexes.

.. ipython:: python

   index = pd.date_range('2000-1-1', periods=1000, freq='M')
   index

   index = pd.bdate_range('2012-1-1', periods=250)
   index

Convenience functions like ``date_range`` and ``bdate_range`` utilize a
variety of frequency aliases. The default frequency for ``date_range`` is a
**calendar day** while the default for ``bdate_range`` is a **business day**

.. ipython:: python

   start = datetime(2011, 1, 1)
   end = datetime(2012, 1, 1)

   rng = pd.date_range(start, end)
   rng

   rng = pd.bdate_range(start, end)
   rng

``date_range`` and ``bdate_range`` make it easy to generate a range of dates
using various combinations of parameters like ``start``, ``end``,
``periods``, and ``freq``:

.. ipython:: python

   pd.date_range(start, end, freq='BM')

   pd.date_range(start, end, freq='W')

   pd.bdate_range(end=end, periods=20)

   pd.bdate_range(start=start, periods=20)

The start and end dates are strictly inclusive. So it will not generate any
dates outside of those dates if specified.