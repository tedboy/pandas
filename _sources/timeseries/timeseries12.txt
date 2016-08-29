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

.. _timeseries.interchange:

Converting between Representations
----------------------------------

Timestamped data can be converted to PeriodIndex-ed data using ``to_period``
and vice-versa using ``to_timestamp``:

.. ipython:: python

   rng = pd.date_range('1/1/2012', periods=5, freq='M')

   ts = pd.Series(np.random.randn(len(rng)), index=rng)

   ts

   ps = ts.to_period()

   ps

   ps.to_timestamp()

Remember that 's' and 'e' can be used to return the timestamps at the start or
end of the period:

.. ipython:: python

   ps.to_timestamp('D', how='s')

Converting between period and timestamp enables some convenient arithmetic
functions to be used. In the following example, we convert a quarterly
frequency with year ending in November to 9am of the end of the month following
the quarter end:

.. ipython:: python

   prng = pd.period_range('1990Q1', '2000Q4', freq='Q-NOV')

   ts = pd.Series(np.random.randn(len(prng)), prng)

   ts.index = (prng.asfreq('M', 'e') + 1).asfreq('H', 's') + 9

   ts.head()