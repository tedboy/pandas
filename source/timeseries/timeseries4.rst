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

.. _timeseries.converting:

Converting to Timestamps
------------------------

To convert a Series or list-like object of date-like objects e.g. strings,
epochs, or a mixture, you can use the ``to_datetime`` function. When passed
a Series, this returns a Series (with the same index), while a list-like
is converted to a DatetimeIndex:

.. ipython:: python

    pd.to_datetime(pd.Series(['Jul 31, 2009', '2010-01-10', None]))

    pd.to_datetime(['2005/11/23', '2010.12.31'])

If you use dates which start with the day first (i.e. European style),
you can pass the ``dayfirst`` flag:

.. ipython:: python

    pd.to_datetime(['04-01-2012 10:00'], dayfirst=True)

    pd.to_datetime(['14-01-2012', '01-14-2012'], dayfirst=True)

.. warning::

   You see in the above example that ``dayfirst`` isn't strict, so if a date
   can't be parsed with the day being first it will be parsed as if
   ``dayfirst`` were False.

.. note::
   Specifying a ``format`` argument will potentially speed up the conversion
   considerably and on versions later then 0.13.0 explicitly specifying
   a format string of '%Y%m%d' takes a faster path still.

If you pass a single string to ``to_datetime``, it returns single ``Timestamp``.
Also, ``Timestamp`` can accept the string input.
Note that ``Timestamp`` doesn't accept string parsing option like ``dayfirst``
or ``format``, use ``to_datetime`` if these are required.

.. ipython:: python

    pd.to_datetime('2010/11/12')

    pd.Timestamp('2010/11/12')

.. versionadded:: 0.18.1

You can also pass a ``DataFrame`` of integer or string columns to assemble into a ``Series`` of ``Timestamps``.

.. ipython:: python

   df = pd.DataFrame({'year': [2015, 2016],
                      'month': [2, 3],
                      'day': [4, 5],
                      'hour': [2, 3]})
   pd.to_datetime(df)


You can pass only the columns that you need to assemble.

.. ipython:: python

   pd.to_datetime(df[['year', 'month', 'day']])

``pd.to_datetime`` looks for standard designations of the datetime component in the column names, including:

- required: ``year``, ``month``, ``day``
- optional: ``hour``, ``minute``, ``second``, ``millisecond``, ``microsecond``, ``nanosecond``

Invalid Data
~~~~~~~~~~~~

.. note::

   In version 0.17.0, the default for ``to_datetime`` is now ``errors='raise'``, rather than ``errors='ignore'``. This means
   that invalid parsing will raise rather that return the original input as in previous versions.

Pass ``errors='coerce'`` to convert invalid data to ``NaT`` (not a time):

Raise when unparseable, this is the default

.. code-block:: ipython

    In [2]: pd.to_datetime(['2009/07/31', 'asd'], errors='raise')
    ValueError: Unknown string format

Return the original input when unparseable

.. code-block:: ipython

    In [4]: pd.to_datetime(['2009/07/31', 'asd'], errors='ignore')
    Out[4]: array(['2009/07/31', 'asd'], dtype=object)

Return NaT for input when unparseable

.. code-block:: ipython

    In [6]: pd.to_datetime(['2009/07/31', 'asd'], errors='coerce')
    Out[6]: DatetimeIndex(['2009-07-31', 'NaT'], dtype='datetime64[ns]', freq=None)


Epoch Timestamps
~~~~~~~~~~~~~~~~

It's also possible to convert integer or float epoch times. The default unit
for these is nanoseconds (since these are how ``Timestamp`` s are stored). However,
often epochs are stored in another ``unit`` which can be specified:

Typical epoch stored units

.. ipython:: python

   pd.to_datetime([1349720105, 1349806505, 1349892905,
                   1349979305, 1350065705], unit='s')

   pd.to_datetime([1349720105100, 1349720105200, 1349720105300,
                   1349720105400, 1349720105500 ], unit='ms')

These *work*, but the results may be unexpected.

.. ipython:: python

   pd.to_datetime([1])

   pd.to_datetime([1, 3.14], unit='s')

.. note::

   Epoch times will be rounded to the nearest nanosecond.