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

.. _timeseries.overview:

Overview
--------

Following table shows the type of time-related classes pandas can handle and
how to create them.

=================  =============================== ==================================================
Class              Remarks                         How to create
=================  =============================== ==================================================
``Timestamp``      Represents a single time stamp   ``to_datetime``, ``Timestamp``
``DatetimeIndex``  Index of ``Timestamp``          ``to_datetime``, ``date_range``, ``DatetimeIndex``
``Period``         Represents a single time span   ``Period``
``PeriodIndex``    Index of ``Period``             ``period_range``, ``PeriodIndex``
=================  =============================== ==================================================