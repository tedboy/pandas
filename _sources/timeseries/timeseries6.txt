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

.. _timeseries.timestamp-limits:

Timestamp limitations
---------------------

Since pandas represents timestamps in nanosecond resolution, the timespan that
can be represented using a 64-bit integer is limited to approximately 584 years:

.. ipython:: python

   pd.Timestamp.min
   pd.Timestamp.max

See :ref:`here <timeseries.oob>` for ways to represent data outside these bound.
