.. _timeseries:

********************************
Time Series / Date functionality
********************************

.. toctree::
   :maxdepth: 1
   :numbered:
   :caption: timeseries

   timeseries1
   timeseries2
   timeseries3
   timeseries4
   timeseries5
   timeseries6
   timeseries7
   timeseries8
   timeseries9
   timeseries10
   timeseries11
   timeseries12
   timeseries13
   timeseries14

.. currentmodule:: pandas

.. ipython:: python

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