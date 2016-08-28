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

DateOffset objects
------------------

In the preceding examples, we created DatetimeIndex objects at various
frequencies by passing in :ref:`frequency strings <timeseries.offset_aliases>`
like 'M', 'W', and 'BM to the ``freq`` keyword. Under the hood, these frequency
strings are being translated into an instance of pandas ``DateOffset``,
which represents a regular frequency increment. Specific offset logic like
"month", "business day", or "one hour" is represented in its various subclasses.

.. csv-table::
    :header: "Class name", "Description"
    :widths: 15, 65

    DateOffset, "Generic offset class, defaults to 1 calendar day"
    BDay, "business day (weekday)"
    CDay, "custom business day (experimental)"
    Week, "one week, optionally anchored on a day of the week"
    WeekOfMonth, "the x-th day of the y-th week of each month"
    LastWeekOfMonth, "the x-th day of the last week of each month"
    MonthEnd, "calendar month end"
    MonthBegin, "calendar month begin"
    BMonthEnd, "business month end"
    BMonthBegin, "business month begin"
    CBMonthEnd, "custom business month end"
    CBMonthBegin, "custom business month begin"
    SemiMonthEnd, "15th (or other day_of_month) and calendar month end"
    SemiMonthBegin, "15th (or other day_of_month) and calendar month begin"
    QuarterEnd, "calendar quarter end"
    QuarterBegin, "calendar quarter begin"
    BQuarterEnd, "business quarter end"
    BQuarterBegin, "business quarter begin"
    FY5253Quarter, "retail (aka 52-53 week) quarter"
    YearEnd, "calendar year end"
    YearBegin, "calendar year begin"
    BYearEnd, "business year end"
    BYearBegin, "business year begin"
    FY5253, "retail (aka 52-53 week) year"
    BusinessHour, "business hour"
    CustomBusinessHour, "custom business hour"
    Hour, "one hour"
    Minute, "one minute"
    Second, "one second"
    Milli, "one millisecond"
    Micro, "one microsecond"
    Nano, "one nanosecond"

The basic ``DateOffset`` takes the same arguments as
``dateutil.relativedelta``, which works like:

.. ipython:: python

   d = datetime(2008, 8, 18, 9, 0)
   d + relativedelta(months=4, days=5)

We could have done the same thing with ``DateOffset``:

.. ipython:: python

   from pandas.tseries.offsets import *
   d + DateOffset(months=4, days=5)

The key features of a ``DateOffset`` object are:

  - it can be added / subtracted to/from a datetime object to obtain a
    shifted date
  - it can be multiplied by an integer (positive or negative) so that the
    increment will be applied multiple times
  - it has ``rollforward`` and ``rollback`` methods for moving a date forward
    or backward to the next or previous "offset date"

Subclasses of ``DateOffset`` define the ``apply`` function which dictates
custom date increment logic, such as adding business days:

.. code-block:: python

    class BDay(DateOffset):
    """DateOffset increments between business days"""
        def apply(self, other):
            ...

.. ipython:: python

   d - 5 * BDay()
   d + BMonthEnd()

The ``rollforward`` and ``rollback`` methods do exactly what you would expect:

.. ipython:: python

   d
   offset = BMonthEnd()
   offset.rollforward(d)
   offset.rollback(d)

It's definitely worth exploring the ``pandas.tseries.offsets`` module and the
various docstrings for the classes.

These operations (``apply``, ``rollforward`` and ``rollback``) preserves time (hour, minute, etc) information by default. To reset time, use ``normalize=True`` keyword when creating the offset instance. If ``normalize=True``, result is normalized after the function is applied.


.. ipython:: python

   day = Day()
   day.apply(pd.Timestamp('2014-01-01 09:00'))

   day = Day(normalize=True)
   day.apply(pd.Timestamp('2014-01-01 09:00'))

   hour = Hour()
   hour.apply(pd.Timestamp('2014-01-01 22:00'))

   hour = Hour(normalize=True)
   hour.apply(pd.Timestamp('2014-01-01 22:00'))
   hour.apply(pd.Timestamp('2014-01-01 23:00'))


Parametric offsets
~~~~~~~~~~~~~~~~~~

Some of the offsets can be "parameterized" when created to result in different
behaviors. For example, the ``Week`` offset for generating weekly data accepts a
``weekday`` parameter which results in the generated dates always lying on a
particular day of the week:

.. ipython:: python

   d
   d + Week()
   d + Week(weekday=4)
   (d + Week(weekday=4)).weekday()

   d - Week()

``normalize`` option will be effective for addition and subtraction.

.. ipython:: python

   d + Week(normalize=True)
   d - Week(normalize=True)


Another example is parameterizing ``YearEnd`` with the specific ending month:

.. ipython:: python

   d + YearEnd()
   d + YearEnd(month=6)


.. _timeseries.offsetseries:

Using offsets with ``Series`` / ``DatetimeIndex``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Offsets can be used with either a ``Series`` or ``DatetimeIndex`` to
apply the offset to each element.

.. ipython:: python

   rng = pd.date_range('2012-01-01', '2012-01-03')
   s = pd.Series(rng)
   rng
   rng + DateOffset(months=2)
   s + DateOffset(months=2)
   s - DateOffset(months=2)

If the offset class maps directly to a ``Timedelta`` (``Day``, ``Hour``,
``Minute``, ``Second``, ``Micro``, ``Milli``, ``Nano``) it can be
used exactly like a ``Timedelta`` - see the
:ref:`Timedelta section<timedeltas.operations>` for more examples.

.. ipython:: python

   s - Day(2)
   td = s - pd.Series(pd.date_range('2011-12-29', '2011-12-31'))
   td
   td + Minute(15)

Note that some offsets (such as ``BQuarterEnd``) do not have a
vectorized implementation.  They can still be used but may
calculate significantly slower and will raise a ``PerformanceWarning``

.. ipython:: python
   :okwarning:

   rng + BQuarterEnd()


.. _timeseries.custombusinessdays:

Custom Business Days (Experimental)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``CDay`` or ``CustomBusinessDay`` class provides a parametric
``BusinessDay`` class which can be used to create customized business day
calendars which account for local holidays and local weekend conventions.

As an interesting example, let's look at Egypt where a Friday-Saturday weekend is observed.

.. ipython:: python

    from pandas.tseries.offsets import CustomBusinessDay
    weekmask_egypt = 'Sun Mon Tue Wed Thu'

    # They also observe International Workers' Day so let's
    # add that for a couple of years

    holidays = ['2012-05-01', datetime(2013, 5, 1), np.datetime64('2014-05-01')]
    bday_egypt = CustomBusinessDay(holidays=holidays, weekmask=weekmask_egypt)
    dt = datetime(2013, 4, 30)
    dt + 2 * bday_egypt

Let's map to the weekday names

.. ipython:: python

    dts = pd.date_range(dt, periods=5, freq=bday_egypt)

    pd.Series(dts.weekday, dts).map(pd.Series('Mon Tue Wed Thu Fri Sat Sun'.split()))

As of v0.14 holiday calendars can be used to provide the list of holidays.  See the
:ref:`holiday calendar<timeseries.holiday>` section for more information.

.. ipython:: python

    from pandas.tseries.holiday import USFederalHolidayCalendar

    bday_us = CustomBusinessDay(calendar=USFederalHolidayCalendar())

    # Friday before MLK Day
    dt = datetime(2014, 1, 17)

    # Tuesday after MLK Day (Monday is skipped because it's a holiday)
    dt + bday_us

Monthly offsets that respect a certain holiday calendar can be defined
in the usual way.

.. ipython:: python

    from pandas.tseries.offsets import CustomBusinessMonthBegin
    bmth_us = CustomBusinessMonthBegin(calendar=USFederalHolidayCalendar())

    # Skip new years
    dt = datetime(2013, 12, 17)
    dt + bmth_us

    # Define date index with custom offset
    pd.DatetimeIndex(start='20100101',end='20120101',freq=bmth_us)

.. note::

    The frequency string 'C' is used to indicate that a CustomBusinessDay
    DateOffset is used, it is important to note that since CustomBusinessDay is
    a parameterised type, instances of CustomBusinessDay may differ and this is
    not detectable from the 'C' frequency string. The user therefore needs to
    ensure that the 'C' frequency string is used consistently within the user's
    application.

.. _timeseries.businesshour:

Business Hour
~~~~~~~~~~~~~

The ``BusinessHour`` class provides a business hour representation on ``BusinessDay``,
allowing to use specific start and end times.

By default, ``BusinessHour`` uses 9:00 - 17:00 as business hours.
Adding ``BusinessHour`` will increment ``Timestamp`` by hourly.
If target ``Timestamp`` is out of business hours, move to the next business hour then increment it.
If the result exceeds the business hours end, remaining is added to the next business day.

.. ipython:: python

    bh = BusinessHour()
    bh

    # 2014-08-01 is Friday
    pd.Timestamp('2014-08-01 10:00').weekday()
    pd.Timestamp('2014-08-01 10:00') + bh

    # Below example is the same as: pd.Timestamp('2014-08-01 09:00') + bh
    pd.Timestamp('2014-08-01 08:00') + bh

    # If the results is on the end time, move to the next business day
    pd.Timestamp('2014-08-01 16:00') + bh

    # Remainings are added to the next day
    pd.Timestamp('2014-08-01 16:30') + bh

    # Adding 2 business hours
    pd.Timestamp('2014-08-01 10:00') + BusinessHour(2)

    # Subtracting 3 business hours
    pd.Timestamp('2014-08-01 10:00') + BusinessHour(-3)

Also, you can specify ``start`` and ``end`` time by keywords.
Argument must be ``str`` which has ``hour:minute`` representation or ``datetime.time`` instance.
Specifying seconds, microseconds and nanoseconds as business hour results in ``ValueError``.

.. ipython:: python

    bh = BusinessHour(start='11:00', end=time(20, 0))
    bh

    pd.Timestamp('2014-08-01 13:00') + bh
    pd.Timestamp('2014-08-01 09:00') + bh
    pd.Timestamp('2014-08-01 18:00') + bh

Passing ``start`` time later than ``end`` represents midnight business hour.
In this case, business hour exceeds midnight and overlap to the next day.
Valid business hours are distinguished by whether it started from valid ``BusinessDay``.

.. ipython:: python

    bh = BusinessHour(start='17:00', end='09:00')
    bh

    pd.Timestamp('2014-08-01 17:00') + bh
    pd.Timestamp('2014-08-01 23:00') + bh

    # Although 2014-08-02 is Satuaday,
    # it is valid because it starts from 08-01 (Friday).
    pd.Timestamp('2014-08-02 04:00') + bh

    # Although 2014-08-04 is Monday,
    # it is out of business hours because it starts from 08-03 (Sunday).
    pd.Timestamp('2014-08-04 04:00') + bh

Applying ``BusinessHour.rollforward`` and ``rollback`` to out of business hours results in
the next business hour start or previous day's end. Different from other offsets, ``BusinessHour.rollforward``
may output different results from ``apply`` by definition.

This is because one day's business hour end is equal to next day's business hour start. For example,
under the default business hours (9:00 - 17:00), there is no gap (0 minutes) between ``2014-08-01 17:00`` and
``2014-08-04 09:00``.

.. ipython:: python

    # This adjusts a Timestamp to business hour edge
    BusinessHour().rollback(pd.Timestamp('2014-08-02 15:00'))
    BusinessHour().rollforward(pd.Timestamp('2014-08-02 15:00'))

    # It is the same as BusinessHour().apply(pd.Timestamp('2014-08-01 17:00')).
    # And it is the same as BusinessHour().apply(pd.Timestamp('2014-08-04 09:00'))
    BusinessHour().apply(pd.Timestamp('2014-08-02 15:00'))

    # BusinessDay results (for reference)
    BusinessHour().rollforward(pd.Timestamp('2014-08-02'))

    # It is the same as BusinessDay().apply(pd.Timestamp('2014-08-01'))
    # The result is the same as rollworward because BusinessDay never overlap.
    BusinessHour().apply(pd.Timestamp('2014-08-02'))

``BusinessHour`` regards Saturday and Sunday as holidays. To use arbitrary holidays,
you can use ``CustomBusinessHour`` offset, see :ref:`Custom Business Hour <timeseries.custombusinesshour>`:

.. _timeseries.custombusinesshour:

Custom Business Hour
~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.18.1

The ``CustomBusinessHour`` is a mixture of ``BusinessHour`` and ``CustomBusinessDay`` which
allows you to specify arbitrary holidays. ``CustomBusinessHour`` works as the same
as ``BusinessHour`` except that it skips specified custom holidays.

.. ipython:: python

    from pandas.tseries.holiday import USFederalHolidayCalendar
    bhour_us = CustomBusinessHour(calendar=USFederalHolidayCalendar())
    # Friday before MLK Day
    dt = datetime(2014, 1, 17, 15)

    dt + bhour_us

    # Tuesday after MLK Day (Monday is skipped because it's a holiday)
    dt + bhour_us * 2

You can use keyword arguments suported by either ``BusinessHour`` and ``CustomBusinessDay``.

.. ipython:: python

    bhour_mon = CustomBusinessHour(start='10:00', weekmask='Tue Wed Thu Fri')

    # Monday is skipped because it's a holiday, business hour starts from 10:00
    dt + bhour_mon * 2

.. _timeseries.offset_aliases:

Offset Aliases
~~~~~~~~~~~~~~

A number of string aliases are given to useful common time series
frequencies. We will refer to these aliases as *offset aliases*
(referred to as *time rules* prior to v0.8.0).

.. csv-table::
    :header: "Alias", "Description"
    :widths: 15, 100

    "B", "business day frequency"
    "C", "custom business day frequency (experimental)"
    "D", "calendar day frequency"
    "W", "weekly frequency"
    "M", "month end frequency"
    "SM", "semi-month end frequency (15th and end of month)"
    "BM", "business month end frequency"
    "CBM", "custom business month end frequency"
    "MS", "month start frequency"
    "SMS", "semi-month start frequency (1st and 15th)"
    "BMS", "business month start frequency"
    "CBMS", "custom business month start frequency"
    "Q", "quarter end frequency"
    "BQ", "business quarter endfrequency"
    "QS", "quarter start frequency"
    "BQS", "business quarter start frequency"
    "A", "year end frequency"
    "BA", "business year end frequency"
    "AS", "year start frequency"
    "BAS", "business year start frequency"
    "BH", "business hour frequency"
    "H", "hourly frequency"
    "T, min", "minutely frequency"
    "S", "secondly frequency"
    "L, ms", "milliseconds"
    "U, us", "microseconds"
    "N", "nanoseconds"

Combining Aliases
~~~~~~~~~~~~~~~~~

As we have seen previously, the alias and the offset instance are fungible in
most functions:

.. ipython:: python

   pd.date_range(start, periods=5, freq='B')

   pd.date_range(start, periods=5, freq=BDay())

You can combine together day and intraday offsets:

.. ipython:: python

   pd.date_range(start, periods=10, freq='2h20min')

   pd.date_range(start, periods=10, freq='1D10U')

Anchored Offsets
~~~~~~~~~~~~~~~~

For some frequencies you can specify an anchoring suffix:

.. csv-table::
    :header: "Alias", "Description"
    :widths: 15, 100

    "W\-SUN", "weekly frequency (sundays). Same as 'W'"
    "W\-MON", "weekly frequency (mondays)"
    "W\-TUE", "weekly frequency (tuesdays)"
    "W\-WED", "weekly frequency (wednesdays)"
    "W\-THU", "weekly frequency (thursdays)"
    "W\-FRI", "weekly frequency (fridays)"
    "W\-SAT", "weekly frequency (saturdays)"
    "(B)Q(S)\-DEC", "quarterly frequency, year ends in December. Same as 'Q'"
    "(B)Q(S)\-JAN", "quarterly frequency, year ends in January"
    "(B)Q(S)\-FEB", "quarterly frequency, year ends in February"
    "(B)Q(S)\-MAR", "quarterly frequency, year ends in March"
    "(B)Q(S)\-APR", "quarterly frequency, year ends in April"
    "(B)Q(S)\-MAY", "quarterly frequency, year ends in May"
    "(B)Q(S)\-JUN", "quarterly frequency, year ends in June"
    "(B)Q(S)\-JUL", "quarterly frequency, year ends in July"
    "(B)Q(S)\-AUG", "quarterly frequency, year ends in August"
    "(B)Q(S)\-SEP", "quarterly frequency, year ends in September"
    "(B)Q(S)\-OCT", "quarterly frequency, year ends in October"
    "(B)Q(S)\-NOV", "quarterly frequency, year ends in November"
    "(B)A(S)\-DEC", "annual frequency, anchored end of December. Same as 'A'"
    "(B)A(S)\-JAN", "annual frequency, anchored end of January"
    "(B)A(S)\-FEB", "annual frequency, anchored end of February"
    "(B)A(S)\-MAR", "annual frequency, anchored end of March"
    "(B)A(S)\-APR", "annual frequency, anchored end of April"
    "(B)A(S)\-MAY", "annual frequency, anchored end of May"
    "(B)A(S)\-JUN", "annual frequency, anchored end of June"
    "(B)A(S)\-JUL", "annual frequency, anchored end of July"
    "(B)A(S)\-AUG", "annual frequency, anchored end of August"
    "(B)A(S)\-SEP", "annual frequency, anchored end of September"
    "(B)A(S)\-OCT", "annual frequency, anchored end of October"
    "(B)A(S)\-NOV", "annual frequency, anchored end of November"

These can be used as arguments to ``date_range``, ``bdate_range``, constructors
for ``DatetimeIndex``, as well as various other timeseries-related functions
in pandas.

Anchored Offset Semantics
~~~~~~~~~~~~~~~~~~~~~~~~~

For those offsets that are anchored to the start or end of specific
frequency (``MonthEnd``, ``MonthBegin``, ``WeekEnd``, etc) the following
rules apply to rolling forward and backwards.

When ``n`` is not 0, if the given date is not on an anchor point, it snapped to the next(previous)
anchor point, and moved ``|n|-1`` additional steps forwards or backwards.

.. ipython:: python

   pd.Timestamp('2014-01-02') + MonthBegin(n=1)
   pd.Timestamp('2014-01-02') + MonthEnd(n=1)

   pd.Timestamp('2014-01-02') - MonthBegin(n=1)
   pd.Timestamp('2014-01-02') - MonthEnd(n=1)

   pd.Timestamp('2014-01-02') + MonthBegin(n=4)
   pd.Timestamp('2014-01-02') - MonthBegin(n=4)

If the given date *is* on an anchor point, it is moved ``|n|`` points forwards
or backwards.

.. ipython:: python

   pd.Timestamp('2014-01-01') + MonthBegin(n=1)
   pd.Timestamp('2014-01-31') + MonthEnd(n=1)

   pd.Timestamp('2014-01-01') - MonthBegin(n=1)
   pd.Timestamp('2014-01-31') - MonthEnd(n=1)

   pd.Timestamp('2014-01-01') + MonthBegin(n=4)
   pd.Timestamp('2014-01-31') - MonthBegin(n=4)

For the case when ``n=0``, the date is not moved if on an anchor point, otherwise
it is rolled forward to the next anchor point.

.. ipython:: python

   pd.Timestamp('2014-01-02') + MonthBegin(n=0)
   pd.Timestamp('2014-01-02') + MonthEnd(n=0)

   pd.Timestamp('2014-01-01') + MonthBegin(n=0)
   pd.Timestamp('2014-01-31') + MonthEnd(n=0)

.. _timeseries.holiday:

Holidays / Holiday Calendars
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Holidays and calendars provide a simple way to define holiday rules to be used
with ``CustomBusinessDay`` or in other analysis that requires a predefined
set of holidays.  The ``AbstractHolidayCalendar`` class provides all the necessary
methods to return a list of holidays and only ``rules`` need to be defined
in a specific holiday calendar class.  Further, ``start_date`` and ``end_date``
class attributes determine over what date range holidays are generated.  These
should be overwritten on the ``AbstractHolidayCalendar`` class to have the range
apply to all calendar subclasses.  ``USFederalHolidayCalendar`` is the
only calendar that exists and primarily serves as an example for developing
other calendars.

For holidays that occur on fixed dates (e.g., US Memorial Day or July 4th) an
observance rule determines when that holiday is observed if it falls on a weekend
or some other non-observed day.  Defined observance rules are:

.. csv-table::
    :header: "Rule", "Description"
    :widths: 15, 70

    "nearest_workday", "move Saturday to Friday and Sunday to Monday"
    "sunday_to_monday", "move Sunday to following Monday"
    "next_monday_or_tuesday", "move Saturday to Monday and Sunday/Monday to Tuesday"
    "previous_friday", move Saturday and Sunday to previous Friday"
    "next_monday", "move Saturday and Sunday to following Monday"

An example of how holidays and holiday calendars are defined:

.. ipython:: python

    from pandas.tseries.holiday import Holiday, USMemorialDay,\
        AbstractHolidayCalendar, nearest_workday, MO
    class ExampleCalendar(AbstractHolidayCalendar):
        rules = [
            USMemorialDay,
            Holiday('July 4th', month=7, day=4, observance=nearest_workday),
            Holiday('Columbus Day', month=10, day=1,
                offset=DateOffset(weekday=MO(2))), #same as 2*Week(weekday=2)
            ]
    cal = ExampleCalendar()
    cal.holidays(datetime(2012, 1, 1), datetime(2012, 12, 31))

Using this calendar, creating an index or doing offset arithmetic skips weekends
and holidays (i.e., Memorial Day/July 4th).  For example, the below defines
a custom business day offset using the ``ExampleCalendar``.  Like any other offset,
it can be used to create a ``DatetimeIndex`` or added to ``datetime``
or ``Timestamp`` objects.

.. ipython:: python

    from pandas.tseries.offsets import CDay
    pd.DatetimeIndex(start='7/1/2012', end='7/10/2012',
        freq=CDay(calendar=cal)).to_pydatetime()
    offset = CustomBusinessDay(calendar=cal)
    datetime(2012, 5, 25) + offset
    datetime(2012, 7, 3) + offset
    datetime(2012, 7, 3) + 2 * offset
    datetime(2012, 7, 6) + offset

Ranges are defined by the ``start_date`` and ``end_date`` class attributes
of ``AbstractHolidayCalendar``.  The defaults are below.

.. ipython:: python

    AbstractHolidayCalendar.start_date
    AbstractHolidayCalendar.end_date

These dates can be overwritten by setting the attributes as
datetime/Timestamp/string.

.. ipython:: python

    AbstractHolidayCalendar.start_date = datetime(2012, 1, 1)
    AbstractHolidayCalendar.end_date = datetime(2012, 12, 31)
    cal.holidays()

Every calendar class is accessible by name using the ``get_calendar`` function
which returns a holiday class instance.  Any imported calendar class will
automatically be available by this function.  Also, ``HolidayCalendarFactory``
provides an easy interface to create calendars that are combinations of calendars
or calendars with additional rules.

.. ipython:: python

    from pandas.tseries.holiday import get_calendar, HolidayCalendarFactory,\
        USLaborDay
    cal = get_calendar('ExampleCalendar')
    cal.rules
    new_cal = HolidayCalendarFactory('NewExampleCalendar', cal, USLaborDay)
    new_cal.rules