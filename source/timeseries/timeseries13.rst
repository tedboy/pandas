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

.. _timeseries.oob:

Representing out-of-bounds spans
--------------------------------

If you have data that is outside of the ``Timestamp`` bounds, see :ref:`Timestamp limitations <timeseries.timestamp-limits>`,
then you can use a ``PeriodIndex`` and/or ``Series`` of ``Periods`` to do computations.

.. ipython:: python

   span = pd.period_range('1215-01-01', '1381-01-01', freq='D')
   span

To convert from a ``int64`` based YYYYMMDD representation.

.. ipython:: python

   s = pd.Series([20121231, 20141130, 99991231])
   s

   def conv(x):
       return pd.Period(year = x // 10000, month = x//100 % 100, day = x%100, freq='D')

   s.apply(conv)
   s.apply(conv)[2]

These can easily be converted to a ``PeriodIndex``

.. ipython:: python

   span = pd.PeriodIndex(s.apply(conv))
   span