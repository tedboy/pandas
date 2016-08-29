.. currentmodule:: pandas
.. _api.datetimeindex:

DatetimeIndex
-------------

.. autosummary::
   :toctree: generated/

   DatetimeIndex

Time/Date Components
~~~~~~~~~~~~~~~~~~~~

.. autosummary::
   :toctree: generated/

   DatetimeIndex.year
   DatetimeIndex.month
   DatetimeIndex.day
   DatetimeIndex.hour
   DatetimeIndex.minute
   DatetimeIndex.second
   DatetimeIndex.microsecond
   DatetimeIndex.nanosecond
   DatetimeIndex.date
   DatetimeIndex.time
   DatetimeIndex.dayofyear
   DatetimeIndex.weekofyear
   DatetimeIndex.week
   DatetimeIndex.dayofweek
   DatetimeIndex.weekday
   DatetimeIndex.weekday_name
   DatetimeIndex.quarter
   DatetimeIndex.tz
   DatetimeIndex.freq
   DatetimeIndex.freqstr
   DatetimeIndex.is_month_start
   DatetimeIndex.is_month_end
   DatetimeIndex.is_quarter_start
   DatetimeIndex.is_quarter_end
   DatetimeIndex.is_year_start
   DatetimeIndex.is_year_end
   DatetimeIndex.is_leap_year
   DatetimeIndex.inferred_freq

Selecting
~~~~~~~~~
.. autosummary::
   :toctree: generated/

   DatetimeIndex.indexer_at_time
   DatetimeIndex.indexer_between_time


Time-specific operations
~~~~~~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   DatetimeIndex.normalize
   DatetimeIndex.strftime
   DatetimeIndex.snap
   DatetimeIndex.tz_convert
   DatetimeIndex.tz_localize
   DatetimeIndex.round
   DatetimeIndex.floor
   DatetimeIndex.ceil

Conversion
~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   DatetimeIndex.to_datetime
   DatetimeIndex.to_period
   DatetimeIndex.to_perioddelta
   DatetimeIndex.to_pydatetime
   DatetimeIndex.to_series