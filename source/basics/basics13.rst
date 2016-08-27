.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8


.. _basics.dtypes:

dtypes
------

The main types stored in pandas objects are ``float``, ``int``, ``bool``,
``datetime64[ns]`` and ``datetime64[ns, tz]`` (in >= 0.17.0), ``timedelta[ns]``, ``category`` (in >= 0.15.0), and ``object``. In addition these dtypes
have item sizes, e.g. ``int64`` and ``int32``. See :ref:`Series with TZ <timeseries.timezone_series>` for more detail on ``datetime64[ns, tz]`` dtypes.

A convenient :attr:`~DataFrame.dtypes` attribute for DataFrames returns a Series with the data type of each column.

.. ipython:: python

   dft = pd.DataFrame(dict(A = np.random.rand(3),
                           B = 1,
                           C = 'foo',
                           D = pd.Timestamp('20010102'),
                           E = pd.Series([1.0]*3).astype('float32'),
                           F = False,
                           G = pd.Series([1]*3,dtype='int8')))
   dft
   dft.dtypes

On a ``Series`` use the :attr:`~Series.dtype` attribute.

.. ipython:: python

   dft['A'].dtype

If a pandas object contains data multiple dtypes *IN A SINGLE COLUMN*, the dtype of the
column will be chosen to accommodate all of the data types (``object`` is the most
general).

.. ipython:: python

   # these ints are coerced to floats
   pd.Series([1, 2, 3, 4, 5, 6.])

   # string data forces an ``object`` dtype
   pd.Series([1, 2, 3, 6., 'foo'])

The method :meth:`~DataFrame.get_dtype_counts` will return the number of columns of
each type in a ``DataFrame``:

.. ipython:: python

   dft.get_dtype_counts()

Numeric dtypes will propagate and can coexist in DataFrames (starting in v0.11.0).
If a dtype is passed (either directly via the ``dtype`` keyword, a passed ``ndarray``,
or a passed ``Series``, then it will be preserved in DataFrame operations. Furthermore,
different numeric dtypes will **NOT** be combined. The following example will give you a taste.

.. ipython:: python

   df1 = pd.DataFrame(np.random.randn(8, 1), columns=['A'], dtype='float32')
   df1
   df1.dtypes
   df2 = pd.DataFrame(dict( A = pd.Series(np.random.randn(8), dtype='float16'),
                           B = pd.Series(np.random.randn(8)),
                           C = pd.Series(np.array(np.random.randn(8), dtype='uint8')) ))
   df2
   df2.dtypes

defaults
~~~~~~~~

By default integer types are ``int64`` and float types are ``float64``,
*REGARDLESS* of platform (32-bit or 64-bit). The following will all result in ``int64`` dtypes.

.. ipython:: python

   pd.DataFrame([1, 2], columns=['a']).dtypes
   pd.DataFrame({'a': [1, 2]}).dtypes
   pd.DataFrame({'a': 1 }, index=list(range(2))).dtypes

Numpy, however will choose *platform-dependent* types when creating arrays.
The following **WILL** result in ``int32`` on 32-bit platform.

.. ipython:: python

   frame = pd.DataFrame(np.array([1, 2]))


upcasting
~~~~~~~~~

Types can potentially be *upcasted* when combined with other types, meaning they are promoted
from the current type (say ``int`` to ``float``)

.. ipython:: python

   df3 = df1.reindex_like(df2).fillna(value=0.0) + df2
   df3
   df3.dtypes

The ``values`` attribute on a DataFrame return the *lower-common-denominator* of the dtypes, meaning
the dtype that can accommodate **ALL** of the types in the resulting homogeneous dtyped numpy array. This can
force some *upcasting*.

.. ipython:: python

   df3.values.dtype

astype
~~~~~~

.. _basics.cast:

You can use the :meth:`~DataFrame.astype` method to explicitly convert dtypes from one to another. These will by default return a copy,
even if the dtype was unchanged (pass ``copy=False`` to change this behavior). In addition, they will raise an
exception if the astype operation is invalid.

Upcasting is always according to the **numpy** rules. If two different dtypes are involved in an operation,
then the more *general* one will be used as the result of the operation.

.. ipython:: python

   df3
   df3.dtypes

   # conversion of dtypes
   df3.astype('float32').dtypes

Convert a subset of columns to a specified type using :meth:`~DataFrame.astype`

.. ipython:: python

   dft = pd.DataFrame({'a': [1,2,3], 'b': [4,5,6], 'c': [7, 8, 9]})
   dft[['a','b']] = dft[['a','b']].astype(np.uint8)
   dft
   dft.dtypes

.. note::

    When trying to convert a subset of columns to a specified type using :meth:`~DataFrame.astype`  and :meth:`~DataFrame.loc`, upcasting occurs.

    :meth:`~DataFrame.loc` tries to fit in what we are assigning to the current dtypes, while ``[]`` will overwrite them taking the dtype from the right hand side. Therefore the following piece of code produces the unintended result.

    .. ipython:: python

       dft = pd.DataFrame({'a': [1,2,3], 'b': [4,5,6], 'c': [7, 8, 9]})
       dft.loc[:, ['a', 'b']].astype(np.uint8).dtypes
       dft.loc[:, ['a', 'b']] = dft.loc[:, ['a', 'b']].astype(np.uint8)
       dft.dtypes

.. _basics.object_conversion:

object conversion
~~~~~~~~~~~~~~~~~

pandas offers various functions to try to force conversion of types from the ``object`` dtype to other types.
The following functions are available for one dimensional object arrays or scalars:

- :meth:`~pandas.to_numeric` (conversion to numeric dtypes)

  .. ipython:: python

     m = ['1.1', 2, 3]
     pd.to_numeric(m)

- :meth:`~pandas.to_datetime` (conversion to datetime objects)

   .. ipython:: python

      import datetime
      m = ['2016-07-09', datetime.datetime(2016, 3, 2)]
      pd.to_datetime(m)

- :meth:`~pandas.to_timedelta` (conversion to timedelta objects)

   .. ipython:: python

      m = ['5us', pd.Timedelta('1day')]
      pd.to_timedelta(m)

To force a conversion, we can pass in an ``errors`` argument, which specifies how pandas should deal with elements
that cannot be converted to desired dtype or object. By default, ``errors='raise'``, meaning that any errors encountered
will be raised during the conversion process. However, if ``errors='coerce'``, these errors will be ignored and pandas
will convert problematic elements to ``pd.NaT`` (for datetime and timedelta) or ``np.nan`` (for numeric). This might be
useful if you are reading in data which is mostly of the desired dtype (e.g. numeric, datetime), but occasionally has
non-conforming elements intermixed that you want to represent as missing:

.. ipython:: python

    import datetime
    m = ['apple', datetime.datetime(2016, 3, 2)]
    pd.to_datetime(m, errors='coerce')

    m = ['apple', 2, 3]
    pd.to_numeric(m, errors='coerce')

    m = ['apple', pd.Timedelta('1day')]
    pd.to_timedelta(m, errors='coerce')

The ``errors`` parameter has a third option of ``errors='ignore'``, which will simply return the passed in data if it
encounters any errors with the conversion to a desired data type:

.. ipython:: python

    import datetime
    m = ['apple', datetime.datetime(2016, 3, 2)]
    pd.to_datetime(m, errors='ignore')

    m = ['apple', 2, 3]
    pd.to_numeric(m, errors='ignore')

    m = ['apple', pd.Timedelta('1day')]
    #pd.to_timedelta(m, errors='ignore') # <- raises ValueError

In addition to object conversion, :meth:`~pandas.to_numeric` provides another argument ``downcast``, which gives the
option of downcasting the newly (or already) numeric data to a smaller dtype, which can conserve memory:

.. ipython:: python

    m = ['1', 2, 3]
    pd.to_numeric(m, downcast='integer')   # smallest signed int dtype
    pd.to_numeric(m, downcast='signed')    # same as 'integer'
    pd.to_numeric(m, downcast='unsigned')  # smallest unsigned int dtype
    pd.to_numeric(m, downcast='float')     # smallest float dtype

As these methods apply only to one-dimensional arrays, lists or scalars; they cannot be used directly on multi-dimensional objects such
as DataFrames. However, with :meth:`~pandas.DataFrame.apply`, we can "apply" the function over each column efficiently:

.. ipython:: python

    import datetime
    df = pd.DataFrame([['2016-07-09', datetime.datetime(2016, 3, 2)]] * 2, dtype='O')
    df
    df.apply(pd.to_datetime)

    df = pd.DataFrame([['1.1', 2, 3]] * 2, dtype='O')
    df
    df.apply(pd.to_numeric)

    df = pd.DataFrame([['5us', pd.Timedelta('1day')]] * 2, dtype='O')
    df
    df.apply(pd.to_timedelta)

gotchas
~~~~~~~

Performing selection operations on ``integer`` type data can easily upcast the data to ``floating``.
The dtype of the input data will be preserved in cases where ``nans`` are not introduced (starting in 0.11.0)
See also :ref:`integer na gotchas <gotchas.intna>`

.. ipython:: python

   dfi = df3.astype('int32')
   dfi['E'] = 1
   dfi
   dfi.dtypes

   casted = dfi[dfi>0]
   casted
   casted.dtypes

While float dtypes are unchanged.

.. ipython:: python

   dfa = df3.copy()
   dfa['A'] = dfa['A'].astype('float32')
   dfa.dtypes

   casted = dfa[df2>0]
   casted
   casted.dtypes