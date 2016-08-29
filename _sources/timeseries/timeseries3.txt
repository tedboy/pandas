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

.. _timeseries.representation:

Time Stamps vs. Time Spans
--------------------------

Time-stamped data is the most basic type of timeseries data that associates
values with points in time. For pandas objects it means using the points in
time.

.. ipython:: python

   pd.Timestamp(datetime(2012, 5, 1))
   pd.Timestamp('2012-05-01')
   pd.Timestamp(2012, 5, 1)

However, in many cases it is more natural to associate things like change
variables with a time span instead. The span represented by ``Period`` can be
specified explicitly, or inferred from datetime string format.

For example:

.. ipython:: python

   pd.Period('2011-01')

   pd.Period('2012-05', freq='D')

``Timestamp`` and ``Period`` can be the index. Lists of ``Timestamp`` and
``Period`` are automatically coerce to ``DatetimeIndex`` and ``PeriodIndex``
respectively.

.. ipython:: python

   dates = [pd.Timestamp('2012-05-01'), pd.Timestamp('2012-05-02'), pd.Timestamp('2012-05-03')]
   ts = pd.Series(np.random.randn(3), dates)

   type(ts.index)
   ts.index

   ts

   periods = [pd.Period('2012-01'), pd.Period('2012-02'), pd.Period('2012-03')]

   ts = pd.Series(np.random.randn(3), periods)

   type(ts.index)
   ts.index

   ts

pandas allows you to capture both representations and
convert between them. Under the hood, pandas represents timestamps using
instances of ``Timestamp`` and sequences of timestamps using instances of
``DatetimeIndex``. For regular time spans, pandas uses ``Period`` objects for
scalar values and ``PeriodIndex`` for sequences of spans. Better support for
irregular intervals with arbitrary start and end points are forth-coming in
future releases.