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

.. _timeseries.timezone:

Time Zone Handling
------------------

Pandas provides rich support for working with timestamps in different time zones using ``pytz`` and ``dateutil`` libraries.
``dateutil`` support is new in 0.14.1 and currently only supported for fixed offset and tzfile zones. The default library is ``pytz``.
Support for ``dateutil`` is provided for compatibility with other applications e.g. if you use ``dateutil`` in other python packages.

Working with Time Zones
~~~~~~~~~~~~~~~~~~~~~~~

By default, pandas objects are time zone unaware:

.. ipython:: python

   rng = pd.date_range('3/6/2012 00:00', periods=15, freq='D')
   rng.tz is None

To supply the time zone, you can use the ``tz`` keyword to ``date_range`` and
other functions. Dateutil time zone strings are distinguished from ``pytz``
time zones by starting with ``dateutil/``.

- In ``pytz`` you can find a list of common (and less common) time zones using
  ``from pytz import common_timezones, all_timezones``.
- ``dateutil`` uses the OS timezones so there isn't a fixed list available. For
  common zones, the names are the same as ``pytz``.

.. ipython:: python

   # pytz
   rng_pytz = pd.date_range('3/6/2012 00:00', periods=10, freq='D',
                            tz='Europe/London')
   rng_pytz.tz

   # dateutil
   rng_dateutil = pd.date_range('3/6/2012 00:00', periods=10, freq='D',
                                tz='dateutil/Europe/London')
   rng_dateutil.tz

   # dateutil - utc special case
   rng_utc = pd.date_range('3/6/2012 00:00', periods=10, freq='D',
                           tz=dateutil.tz.tzutc())
   rng_utc.tz

Note that the ``UTC`` timezone is a special case in ``dateutil`` and should be constructed explicitly
as an instance of ``dateutil.tz.tzutc``. You can also construct other timezones explicitly first,
which gives you more control over which time zone is used:

.. ipython:: python

   # pytz
   tz_pytz = pytz.timezone('Europe/London')
   rng_pytz = pd.date_range('3/6/2012 00:00', periods=10, freq='D',
                            tz=tz_pytz)
   rng_pytz.tz == tz_pytz

   # dateutil
   tz_dateutil = dateutil.tz.gettz('Europe/London')
   rng_dateutil = pd.date_range('3/6/2012 00:00', periods=10, freq='D',
                                tz=tz_dateutil)
   rng_dateutil.tz == tz_dateutil

Timestamps, like Python's ``datetime.datetime`` object can be either time zone
naive or time zone aware. Naive time series and DatetimeIndex objects can be
*localized* using ``tz_localize``:

.. ipython:: python

   ts = pd.Series(np.random.randn(len(rng)), rng)

   ts_utc = ts.tz_localize('UTC')
   ts_utc

Again, you can explicitly construct the timezone object first.
You can use the ``tz_convert`` method to convert pandas objects to convert
tz-aware data to another time zone:

.. ipython:: python

   ts_utc.tz_convert('US/Eastern')

.. warning::

    Be wary of conversions between libraries. For some zones ``pytz`` and ``dateutil`` have different
    definitions of the zone. This is more of a problem for unusual timezones than for
    'standard' zones like ``US/Eastern``.

.. warning::

       Be aware that a timezone definition across versions of timezone libraries may not
       be considered equal.  This may cause problems when working with stored data that
       is localized using one version and operated on with a different version.
       See :ref:`here<io.hdf5-notes>` for how to handle such a situation.

.. warning::

       It is incorrect to pass a timezone directly into the ``datetime.datetime`` constructor (e.g.,
       ``datetime.datetime(2011, 1, 1, tz=timezone('US/Eastern'))``.  Instead, the datetime
       needs to be localized using the the localize method on the timezone.

Under the hood, all timestamps are stored in UTC. Scalar values from a
``DatetimeIndex`` with a time zone will have their fields (day, hour, minute)
localized to the time zone. However, timestamps with the same UTC value are
still considered to be equal even if they are in different time zones:

.. ipython:: python

   rng_eastern = rng_utc.tz_convert('US/Eastern')
   rng_berlin = rng_utc.tz_convert('Europe/Berlin')

   rng_eastern[5]
   rng_berlin[5]
   rng_eastern[5] == rng_berlin[5]

Like ``Series``, ``DataFrame``, and ``DatetimeIndex``, ``Timestamp``s can be converted to other
time zones using ``tz_convert``:

.. ipython:: python

   rng_eastern[5]
   rng_berlin[5]
   rng_eastern[5].tz_convert('Europe/Berlin')

Localization of ``Timestamp`` functions just like ``DatetimeIndex`` and ``Series``:

.. ipython:: python

   rng[5]
   rng[5].tz_localize('Asia/Shanghai')


Operations between Series in different time zones will yield UTC
Series, aligning the data on the UTC timestamps:

.. ipython:: python

   eastern = ts_utc.tz_convert('US/Eastern')
   berlin = ts_utc.tz_convert('Europe/Berlin')
   result = eastern + berlin
   result
   result.index

To remove timezone from tz-aware ``DatetimeIndex``, use ``tz_localize(None)`` or ``tz_convert(None)``.
``tz_localize(None)`` will remove timezone holding local time representations.
``tz_convert(None)`` will remove timezone after converting to UTC time.

.. ipython:: python

   didx = pd.DatetimeIndex(start='2014-08-01 09:00', freq='H', periods=10, tz='US/Eastern')
   didx
   didx.tz_localize(None)
   didx.tz_convert(None)

   # tz_convert(None) is identical with tz_convert('UTC').tz_localize(None)
   didx.tz_convert('UCT').tz_localize(None)

.. _timeseries.timezone_ambiguous:

Ambiguous Times when Localizing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In some cases, localize cannot determine the DST and non-DST hours when there are
duplicates.  This often happens when reading files or database records that simply
duplicate the hours.  Passing ``ambiguous='infer'`` (``infer_dst`` argument in prior
releases) into ``tz_localize`` will attempt to determine the right offset.  Below
the top example will fail as it contains ambiguous times and the bottom will
infer the right offset.

.. ipython:: python

   rng_hourly = pd.DatetimeIndex(['11/06/2011 00:00', '11/06/2011 01:00',
                                  '11/06/2011 01:00', '11/06/2011 02:00',
                                  '11/06/2011 03:00'])

This will fail as there are ambiguous times

.. code-block:: ipython

   In [2]: rng_hourly.tz_localize('US/Eastern')
   AmbiguousTimeError: Cannot infer dst time from Timestamp('2011-11-06 01:00:00'), try using the 'ambiguous' argument

Infer the ambiguous times

.. ipython:: python

   rng_hourly_eastern = rng_hourly.tz_localize('US/Eastern', ambiguous='infer')
   rng_hourly_eastern.tolist()

In addition to 'infer', there are several other arguments supported.  Passing
an array-like of bools or 0s/1s where True represents a DST hour and False a
non-DST hour, allows for distinguishing more than one DST
transition (e.g., if you have multiple records in a database each with their
own DST transition).  Or passing 'NaT' will fill in transition times
with not-a-time values.  These methods are available in the ``DatetimeIndex``
constructor as well as ``tz_localize``.

.. ipython:: python

   rng_hourly_dst = np.array([1, 1, 0, 0, 0])
   rng_hourly.tz_localize('US/Eastern', ambiguous=rng_hourly_dst).tolist()
   rng_hourly.tz_localize('US/Eastern', ambiguous='NaT').tolist()

   didx = pd.DatetimeIndex(start='2014-08-01 09:00', freq='H', periods=10, tz='US/Eastern')
   didx
   didx.tz_localize(None)
   didx.tz_convert(None)

   # tz_convert(None) is identical with tz_convert('UTC').tz_localize(None)
   didx.tz_convert('UCT').tz_localize(None)

.. _timeseries.timezone_series:

TZ aware Dtypes
~~~~~~~~~~~~~~~

.. versionadded:: 0.17.0

``Series/DatetimeIndex`` with a timezone **naive** value are represented with a dtype of ``datetime64[ns]``.

.. ipython:: python

   s_naive = pd.Series(pd.date_range('20130101',periods=3))
   s_naive

``Series/DatetimeIndex`` with a timezone **aware** value are represented with a dtype of ``datetime64[ns, tz]``.

.. ipython:: python

   s_aware = pd.Series(pd.date_range('20130101',periods=3,tz='US/Eastern'))
   s_aware

Both of these ``Series`` can be manipulated via the ``.dt`` accessor, see :ref:`here <basics.dt_accessors>`.

For example, to localize and convert a naive stamp to timezone aware.

.. ipython:: python

   s_naive.dt.tz_localize('UTC').dt.tz_convert('US/Eastern')


Further more you can ``.astype(...)`` timezone aware (and naive). This operation is effectively a localize AND convert on a naive stamp, and
a convert on an aware stamp.

.. ipython:: python

   # localize and convert a naive timezone
   s_naive.astype('datetime64[ns, US/Eastern]')

   # make an aware tz naive
   s_aware.astype('datetime64[ns]')

   # convert to a new timezone
   s_aware.astype('datetime64[ns, CET]')

.. note::

   Using the ``.values`` accessor on a ``Series``, returns an numpy array of the data.
   These values are converted to UTC, as numpy does not currently support timezones (even though it is *printing* in the local timezone!).

   .. ipython:: python

      s_naive.values
      s_aware.values

   Further note that once converted to a numpy array these would lose the tz tenor.

   .. ipython:: python

      pd.Series(s_aware.values)

   However, these can be easily converted

   .. ipython:: python

      pd.Series(s_aware.values).dt.tz_localize('UTC').dt.tz_convert('US/Eastern')
