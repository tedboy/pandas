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

.. _timeseries.advanced_datetime:

Time series-related instance methods
------------------------------------

Shifting / lagging
~~~~~~~~~~~~~~~~~~

One may want to *shift* or *lag* the values in a time series back and forward in
time. The method for this is ``shift``, which is available on all of the pandas
objects.

.. ipython:: python

   ts = ts[:5]
   ts.shift(1)

The shift method accepts an ``freq`` argument which can accept a
``DateOffset`` class or other ``timedelta``-like object or also a :ref:`offset alias <timeseries.alias>`:

.. ipython:: python

   ts.shift(5, freq=datetools.bday)
   ts.shift(5, freq='BM')

Rather than changing the alignment of the data and the index, ``DataFrame`` and
``Series`` objects also have a ``tshift`` convenience method that changes
all the dates in the index by a specified number of offsets:

.. ipython:: python

   ts.tshift(5, freq='D')

Note that with ``tshift``, the leading entry is no longer NaN because the data
is not being realigned.

Frequency conversion
~~~~~~~~~~~~~~~~~~~~

The primary function for changing frequencies is the ``asfreq`` function.
For a ``DatetimeIndex``, this is basically just a thin, but convenient wrapper
around ``reindex`` which generates a ``date_range`` and calls ``reindex``.

.. ipython:: python

   dr = pd.date_range('1/1/2010', periods=3, freq=3 * datetools.bday)
   ts = pd.Series(randn(3), index=dr)
   ts
   ts.asfreq(BDay())

``asfreq`` provides a further convenience so you can specify an interpolation
method for any gaps that may appear after the frequency conversion

.. ipython:: python

   ts.asfreq(BDay(), method='pad')

Filling forward / backward
~~~~~~~~~~~~~~~~~~~~~~~~~~

Related to ``asfreq`` and ``reindex`` is the ``fillna`` function documented in
the :ref:`missing data section <missing_data.fillna>`.

Converting to Python datetimes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``DatetimeIndex`` can be converted to an array of Python native datetime.datetime objects using the
``to_pydatetime`` method.