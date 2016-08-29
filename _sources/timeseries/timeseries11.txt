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

.. _timeseries.periods:

Time Span Representation
------------------------

Regular intervals of time are represented by ``Period`` objects in pandas while
sequences of ``Period`` objects are collected in a ``PeriodIndex``, which can
be created with the convenience function ``period_range``.

Period
~~~~~~

A ``Period`` represents a span of time (e.g., a day, a month, a quarter, etc).
You can specify the span via ``freq`` keyword using a frequency alias like below.
Because ``freq`` represents a span of ``Period``, it cannot be negative like "-3D".

.. ipython:: python

   pd.Period('2012', freq='A-DEC')

   pd.Period('2012-1-1', freq='D')

   pd.Period('2012-1-1 19:00', freq='H')

   pd.Period('2012-1-1 19:00', freq='5H')

Adding and subtracting integers from periods shifts the period by its own
frequency. Arithmetic is not allowed between ``Period`` with different ``freq`` (span).

.. ipython:: python

   p = pd.Period('2012', freq='A-DEC')
   p + 1
   p - 3
   p = pd.Period('2012-01', freq='2M')
   p + 2
   p - 1
   @okexcept
   p == pd.Period('2012-01', freq='3M')


If ``Period`` freq is daily or higher (``D``, ``H``, ``T``, ``S``, ``L``, ``U``, ``N``), ``offsets`` and ``timedelta``-like can be added if the result can have the same freq. Otherwise, ``ValueError`` will be raised.

.. ipython:: python

   p = pd.Period('2014-07-01 09:00', freq='H')
   p + Hour(2)
   p + timedelta(minutes=120)
   p + np.timedelta64(7200, 's')

.. code-block:: ipython

   In [1]: p + Minute(5)
   Traceback
      ...
   ValueError: Input has different freq from Period(freq=H)

If ``Period`` has other freqs, only the same ``offsets`` can be added. Otherwise, ``ValueError`` will be raised.

.. ipython:: python

   p = pd.Period('2014-07', freq='M')
   p + MonthEnd(3)

.. code-block:: ipython

   In [1]: p + MonthBegin(3)
   Traceback
      ...
   ValueError: Input has different freq from Period(freq=M)

Taking the difference of ``Period`` instances with the same frequency will
return the number of frequency units between them:

.. ipython:: python

   pd.Period('2012', freq='A-DEC') - pd.Period('2002', freq='A-DEC')

PeriodIndex and period_range
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Regular sequences of ``Period`` objects can be collected in a ``PeriodIndex``,
which can be constructed using the ``period_range`` convenience function:

.. ipython:: python

   prng = pd.period_range('1/1/2011', '1/1/2012', freq='M')
   prng

The ``PeriodIndex`` constructor can also be used directly:

.. ipython:: python

   pd.PeriodIndex(['2011-1', '2011-2', '2011-3'], freq='M')

Passing multiplied frequency outputs a sequence of ``Period`` which
has multiplied span.

.. ipython:: python

   pd.PeriodIndex(start='2014-01', freq='3M', periods=4)

Just like ``DatetimeIndex``, a ``PeriodIndex`` can also be used to index pandas
objects:

.. ipython:: python

   ps = pd.Series(np.random.randn(len(prng)), prng)
   ps

``PeriodIndex`` supports addition and subtraction with the same rule as ``Period``.

.. ipython:: python

   idx = pd.period_range('2014-07-01 09:00', periods=5, freq='H')
   idx
   idx + Hour(2)

   idx = pd.period_range('2014-07', periods=5, freq='M')
   idx
   idx + MonthEnd(3)

``PeriodIndex`` has its own dtype named ``period``, refer to :ref:`Period Dtypes <timeseries.period_dtype>`.

.. _timeseries.period_dtype:

Period Dtypes
~~~~~~~~~~~~~

.. versionadded:: 0.19.0

``PeriodIndex`` has a custom ``period`` dtype. This is a pandas extension
dtype similar to the :ref:`timezone aware dtype <timeseries.timezone_series>` (``datetime64[ns, tz]``).

.. _timeseries.timezone_series:

The ``period`` dtype holds the ``freq`` attribute and is represented with
``period[freq]`` like ``period[D]`` or ``period[M]``, using :ref:`frequency strings <timeseries.offset_aliases>`.

.. ipython:: python

   pi = pd.period_range('2016-01-01', periods=3, freq='M')
   pi
   pi.dtype

The ``period`` dtype can be used in ``.astype(...)``. It allows one to change the
``freq`` of a ``PeriodIndex`` like ``.asfreq()`` and convert a
``DatetimeIndex`` to ``PeriodIndex`` like ``to_period()``:

.. ipython:: python

   # change monthly freq to daily freq
   #pi.astype('period[D]') #<-raises TypeError
   #TypeError: data type "period[D]" not understood

   # convert to DatetimeIndex
   #pi.astype('datetime64[ns]')
   #ValueError: Cannot cast PeriodIndex to dtype datetime64[ns]

   # convert to PeriodIndex
   dti = pd.date_range('2011-01-01', freq='M', periods=3)
   dti
   #dti.astype('period[M]')
   #TypeError: data type "period[M]" not understood

PeriodIndex Partial String Indexing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can pass in dates and strings to ``Series`` and ``DataFrame`` with ``PeriodIndex``, in the same manner as ``DatetimeIndex``. For details, refer to :ref:`DatetimeIndex Partial String Indexing <timeseries.partialindexing>`.

.. ipython:: python

   ps['2011-01']

   ps[datetime(2011, 12, 25):]

   ps['10/31/2011':'12/31/2011']

Passing a string representing a lower frequency than ``PeriodIndex`` returns partial sliced data.

.. ipython:: python

   ps['2011']

   dfp = pd.DataFrame(np.random.randn(600,1),
                      columns=['A'],
                      index=pd.period_range('2013-01-01 9:00', periods=600, freq='T'))
   dfp
   dfp['2013-01-01 10H']

As with ``DatetimeIndex``, the endpoints will be included in the result. The example below slices data starting from 10:00 to 11:59.

.. ipython:: python

   dfp['2013-01-01 10H':'2013-01-01 11H']

Frequency Conversion and Resampling with PeriodIndex
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The frequency of ``Period`` and ``PeriodIndex`` can be converted via the ``asfreq``
method. Let's start with the fiscal year 2011, ending in December:

.. ipython:: python

   p = pd.Period('2011', freq='A-DEC')
   p

We can convert it to a monthly frequency. Using the ``how`` parameter, we can
specify whether to return the starting or ending month:

.. ipython:: python

   p.asfreq('M', how='start')

   p.asfreq('M', how='end')

The shorthands 's' and 'e' are provided for convenience:

.. ipython:: python

   p.asfreq('M', 's')
   p.asfreq('M', 'e')

Converting to a "super-period" (e.g., annual frequency is a super-period of
quarterly frequency) automatically returns the super-period that includes the
input period:

.. ipython:: python

   p = pd.Period('2011-12', freq='M')

   p.asfreq('A-NOV')

Note that since we converted to an annual frequency that ends the year in
November, the monthly period of December 2011 is actually in the 2012 A-NOV
period.

.. _timeseries.quarterly:

Period conversions with anchored frequencies are particularly useful for
working with various quarterly data common to economics, business, and other
fields. Many organizations define quarters relative to the month in which their
fiscal year starts and ends. Thus, first quarter of 2011 could start in 2010 or
a few months into 2011. Via anchored frequencies, pandas works for all quarterly
frequencies ``Q-JAN`` through ``Q-DEC``.

``Q-DEC`` define regular calendar quarters:

.. ipython:: python

   p = pd.Period('2012Q1', freq='Q-DEC')

   p.asfreq('D', 's')

   p.asfreq('D', 'e')

``Q-MAR`` defines fiscal year end in March:

.. ipython:: python

   p = pd.Period('2011Q4', freq='Q-MAR')

   p.asfreq('D', 's')

   p.asfreq('D', 'e')
