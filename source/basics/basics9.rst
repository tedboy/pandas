.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

.. _basics.dt_accessors:

.dt accessor
------------

``Series`` has an accessor to succinctly return datetime like properties for the
*values* of the Series, if it is a datetime/period like Series.
This will return a Series, indexed like the existing Series.

.. ipython:: python

   # datetime
   s = pd.Series(pd.date_range('20130101 09:10:12', periods=4))
   s
   s.dt.hour
   s.dt.second
   s.dt.day

This enables nice expressions like this:

.. ipython:: python

   s[s.dt.day==2]

You can easily produces tz aware transformations:

.. ipython:: python

   stz = s.dt.tz_localize('US/Eastern')
   stz
   stz.dt.tz

You can also chain these types of operations:

.. ipython:: python

   s.dt.tz_localize('UTC').dt.tz_convert('US/Eastern')

You can also format datetime values as strings with :meth:`Series.dt.strftime` which
supports the same format as the standard :meth:`~datetime.datetime.strftime`.

.. ipython:: python

   # DatetimeIndex
   s = pd.Series(pd.date_range('20130101', periods=4))
   s
   s.dt.strftime('%Y/%m/%d')

.. ipython:: python

   # PeriodIndex
   s = pd.Series(pd.period_range('20130101', periods=4))
   s
   s.dt.strftime('%Y/%m/%d')

The ``.dt`` accessor works for period and timedelta dtypes.

.. ipython:: python

   # period
   s = pd.Series(pd.period_range('20130101', periods=4, freq='D'))
   s
   s.dt.year
   s.dt.day

.. ipython:: python

   # timedelta
   s = pd.Series(pd.timedelta_range('1 day 00:00:05', periods=4, freq='s'))
   s
   s.dt.days
   s.dt.seconds
   s.dt.components

.. note::

   ``Series.dt`` will raise a ``TypeError`` if you access with a non-datetimelike values