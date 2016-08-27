.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8


Selecting columns based on ``dtype``
------------------------------------

.. _basics.selectdtypes:

.. versionadded:: 0.14.1

The :meth:`~DataFrame.select_dtypes` method implements subsetting of columns
based on their ``dtype``.

First, let's create a :class:`DataFrame` with a slew of different
dtypes:

.. ipython:: python

   df = pd.DataFrame({'string': list('abc'),
                      'int64': list(range(1, 4)),
                      'uint8': np.arange(3, 6).astype('u1'),
                      'float64': np.arange(4.0, 7.0),
                      'bool1': [True, False, True],
                      'bool2': [False, True, False],
                      'dates': pd.date_range('now', periods=3).values,
                      'category': pd.Series(list("ABC")).astype('category')})
   df['tdeltas'] = df.dates.diff()
   df['uint64'] = np.arange(3, 6).astype('u8')
   df['other_dates'] = pd.date_range('20130101', periods=3).values
   df['tz_aware_dates'] = pd.date_range('20130101', periods=3, tz='US/Eastern')
   df

And the dtypes

.. ipython:: python

   df.dtypes

:meth:`~DataFrame.select_dtypes` has two parameters ``include`` and ``exclude`` that allow you to
say "give me the columns WITH these dtypes" (``include``) and/or "give the
columns WITHOUT these dtypes" (``exclude``).

For example, to select ``bool`` columns

.. ipython:: python

   df.select_dtypes(include=[bool])

You can also pass the name of a dtype in the `numpy dtype hierarchy
<http://docs.scipy.org/doc/numpy/reference/arrays.scalars.html>`__:

.. ipython:: python

   df.select_dtypes(include=['bool'])

:meth:`~pandas.DataFrame.select_dtypes` also works with generic dtypes as well.

For example, to select all numeric and boolean columns while excluding unsigned
integers

.. ipython:: python

   df.select_dtypes(include=['number', 'bool'], exclude=['unsignedinteger'])

To select string columns you must use the ``object`` dtype:

.. ipython:: python

   df.select_dtypes(include=['object'])

To see all the child dtypes of a generic ``dtype`` like ``numpy.number`` you
can define a function that returns a tree of child dtypes:

.. ipython:: python

   def subdtypes(dtype):
       subs = dtype.__subclasses__()
       if not subs:
           return dtype
       return [dtype, [subdtypes(dt) for dt in subs]]

All numpy dtypes are subclasses of ``numpy.generic``:

.. ipython:: python

    subdtypes(np.generic)

.. note::

    Pandas also defines the types ``category``, and ``datetime64[ns, tz]``, which are not integrated into the normal
    numpy hierarchy and wont show up with the above function.

.. note::

   The ``include`` and ``exclude`` parameters must be non-string sequences.
