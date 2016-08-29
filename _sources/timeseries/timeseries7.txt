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

.. _timeseries.datetimeindex:

DatetimeIndex
-------------

One of the main uses for ``DatetimeIndex`` is as an index for pandas objects.
The ``DatetimeIndex`` class contains many timeseries related optimizations:

  - A large range of dates for various offsets are pre-computed and cached
    under the hood in order to make generating subsequent date ranges very fast
    (just have to grab a slice)
  - Fast shifting using the ``shift`` and ``tshift`` method on pandas objects
  - Unioning of overlapping DatetimeIndex objects with the same frequency is
    very fast (important for fast data alignment)
  - Quick access to date fields via properties such as ``year``, ``month``, etc.
  - Regularization functions like ``snap`` and very fast ``asof`` logic

DatetimeIndex objects has all the basic functionality of regular Index objects
and a smorgasbord of advanced timeseries-specific methods for easy frequency
processing.

.. seealso::
    :ref:`Reindexing methods <basics.reindexing>`

.. note::

    While pandas does not force you to have a sorted date index, some of these
    methods may have unexpected or incorrect behavior if the dates are
    unsorted. So please be careful.

``DatetimeIndex`` can be used like a regular index and offers all of its
intelligent functionality like selection, slicing, etc.

.. ipython:: python

   rng = pd.date_range(start, end, freq='BM')
   ts = pd.Series(np.random.randn(len(rng)), index=rng)
   ts.index
   ts[:5].index
   ts[::2].index

.. _timeseries.partialindexing:

DatetimeIndex Partial String Indexing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can pass in dates and strings that parse to dates as indexing parameters:

.. ipython:: python

   ts['1/31/2011']

   ts[datetime(2011, 12, 25):]

   ts['10/31/2011':'12/31/2011']

To provide convenience for accessing longer time series, you can also pass in
the year or year and month as strings:

.. ipython:: python

   ts['2011']

   ts['2011-6']

This type of slicing will work on a DataFrame with a ``DateTimeIndex`` as well. Since the
partial string selection is a form of label slicing, the endpoints **will be** included. This
would include matching times on an included date. Here's an example:

.. ipython:: python

   dft = pd.DataFrame(randn(100000,1),
                      columns=['A'],
                      index=pd.date_range('20130101',periods=100000,freq='T'))
   dft
   dft['2013']

This starts on the very first time in the month, and includes the last date & time for the month

.. ipython:: python

   dft['2013-1':'2013-2']

This specifies a stop time **that includes all of the times on the last day**

.. ipython:: python

   dft['2013-1':'2013-2-28']

This specifies an **exact** stop time (and is not the same as the above)

.. ipython:: python

   dft['2013-1':'2013-2-28 00:00:00']

We are stopping on the included end-point as it is part of the index

.. ipython:: python

   dft['2013-1-15':'2013-1-15 12:30:00']

.. warning::

   The following selection will raise a ``KeyError``; otherwise this selection methodology
   would be inconsistent with other selection methods in pandas (as this is not a *slice*, nor does it
   resolve to one)

   .. code-block:: python

      dft['2013-1-15 12:30:00']

   To select a single row, use ``.loc``

   .. ipython:: python

      dft.loc['2013-1-15 12:30:00']

.. versionadded:: 0.18.0

DatetimeIndex Partial String Indexing also works on DataFrames with a ``MultiIndex``. For example:

.. ipython:: python

   dft2 = pd.DataFrame(np.random.randn(20, 1),
                       columns=['A'],
                       index=pd.MultiIndex.from_product([pd.date_range('20130101',
                                                                       periods=10,
                                                                       freq='12H'),
                                                        ['a', 'b']]))
   dft2
   dft2.loc['2013-01-05']
   idx = pd.IndexSlice
   dft2 = dft2.swaplevel(0, 1).sort_index()
   dft2.loc[idx[:, '2013-01-05'], :]

Datetime Indexing
~~~~~~~~~~~~~~~~~

Indexing a ``DateTimeIndex`` with a partial string depends on the "accuracy" of the period, in other words how specific the interval is in relation to the frequency of the index. In contrast, indexing with datetime objects is exact, because the objects have exact meaning. These also follow the semantics of *including both endpoints*.

These ``datetime`` objects  are specific ``hours, minutes,`` and ``seconds`` even though they were not explicitly specified (they are ``0``).

.. ipython:: python

   dft[datetime(2013, 1, 1):datetime(2013,2,28)]

With no defaults.

.. ipython:: python

   dft[datetime(2013, 1, 1, 10, 12, 0):datetime(2013, 2, 28, 10, 12, 0)]


Truncating & Fancy Indexing
~~~~~~~~~~~~~~~~~~~~~~~~~~~

A ``truncate`` convenience function is provided that is equivalent to slicing:

.. ipython:: python

   ts.truncate(before='10/31/2011', after='12/31/2011')

Even complicated fancy indexing that breaks the DatetimeIndex's frequency
regularity will result in a ``DatetimeIndex`` (but frequency is lost):

.. ipython:: python

   ts[[0, 2, 6]].index

.. _timeseries.offsets:

Time/Date Components
~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are several time/date properties that one can access from ``Timestamp`` or a collection of timestamps like a ``DateTimeIndex``.

.. csv-table::
    :header: "Property", "Description"
    :widths: 15, 65

    year, "The year of the datetime"
    month,"The month of the datetime"
    day,"The days of the datetime"
    hour,"The hour of the datetime"
    minute,"The minutes of the datetime"
    second,"The seconds of the datetime"
    microsecond,"The microseconds of the datetime"
    nanosecond,"The nanoseconds of the datetime"
    date,"Returns datetime.date (does not contain timezone information)"
    time,"Returns datetime.time (does not contain timezone information)"
    dayofyear,"The ordinal day of year"
    weekofyear,"The week ordinal of the year"
    week,"The week ordinal of the year"
    dayofweek,"The numer of the day of the week with Monday=0, Sunday=6"
    weekday,"The number of the day of the week with Monday=0, Sunday=6"
    weekday_name,"The name of the day in a week (ex: Friday)"
    quarter,"Quarter of the date: Jan=Mar = 1, Apr-Jun = 2, etc."
    days_in_month,"The number of days in the month of the datetime"
    is_month_start,"Logical indicating if first day of month (defined by frequency)"
    is_month_end,"Logical indicating if last day of month (defined by frequency)"
    is_quarter_start,"Logical indicating if first day of quarter (defined by frequency)"
    is_quarter_end,"Logical indicating if last day of quarter (defined by frequency)"
    is_year_start,"Logical indicating if first day of year (defined by frequency)"
    is_year_end,"Logical indicating if last day of year (defined by frequency)"
    is_leap_year,"Logical indicating if the date belongs to a leap year"

Furthermore, if you have a ``Series`` with datetimelike values, then you can access these properties via the ``.dt`` accessor, see the :ref:`docs <basics.dt_accessors>`