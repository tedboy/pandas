.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(0)
   pd.options.display.max_rows=15
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   df = pd.DataFrame(np.random.randn(5, 3), index=['a', 'c', 'e', 'f', 'h'],
                     columns=['one', 'two', 'three'])
   df['four'] = 'bar'
   df['five'] = df['one'] > 0
   df2 = df.copy()
   df2['timestamp'] = pd.Timestamp('20120101')
   df2.ix[['a','c','h'],['one','timestamp']] = np.nan
   df2.get_dtype_counts()
   df = df2.ix[:, ['one', 'two', 'three']]

Cleaning / filling missing data
--------------------------------

pandas objects are equipped with various data manipulation methods for dealing
with missing data.

.. _missing_data.fillna:

Filling missing values: fillna
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The **fillna** function can "fill in" NA values with non-null data in a couple
of ways, which we illustrate:

**Replace NA with a scalar value**

.. ipython:: python

   df2
   df2.fillna(0)
   df2['four'].fillna('missing')

**Fill gaps forward or backward**

Using the same filling arguments as :ref:`reindexing <basics.reindexing>`, we
can propagate non-null values forward or backward:

.. ipython:: python

   df
   df.fillna(method='pad')

.. _missing_data.fillna.limit:

**Limit the amount of filling**

If we only want consecutive gaps filled up to a certain number of data points,
we can use the `limit` keyword:

.. ipython:: python
   :suppress:

   df.ix[2:4, :] = np.nan

.. ipython:: python

   df
   df.fillna(method='pad', limit=1)

To remind you, these are the available filling methods:

.. csv-table::
    :header: "Method", "Action"
    :widths: 30, 50

    pad / ffill, Fill values forward
    bfill / backfill, Fill values backward

With time series data, using pad/ffill is extremely common so that the "last
known value" is available at every time point.

The ``ffill()`` function is equivalent to ``fillna(method='ffill')``
and ``bfill()`` is equivalent to ``fillna(method='bfill')``

.. _missing_data.PandasObject:

Filling with a PandasObject
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.12

You can also fillna using a dict or Series that is alignable. The labels of the dict or index of the Series
must match the columns of the frame you wish to fill. The
use case of this is to fill a DataFrame with the mean of that column.

.. ipython:: python

        dff = pd.DataFrame(np.random.randn(10,3), columns=list('ABC'))
        dff.iloc[3:5,0] = np.nan
        dff.iloc[4:6,1] = np.nan
        dff.iloc[5:8,2] = np.nan
        dff

        dff.fillna(dff.mean())
        dff.fillna(dff.mean()['B':'C'])

.. versionadded:: 0.13

Same result as above, but is aligning the 'fill' value which is
a Series in this case.

.. ipython:: python

        dff.where(pd.notnull(dff), dff.mean(), axis='columns')


.. _missing_data.dropna:

Dropping axis labels with missing data: dropna
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You may wish to simply exclude labels from a data set which refer to missing
data. To do this, use the **dropna** method:

.. ipython:: python
   :suppress:

   df['two'] = df['two'].fillna(0)
   df['three'] = df['three'].fillna(0)

.. ipython:: python

   df
   df.dropna(axis=0)
   df.dropna(axis=1)
   df['one'].dropna()

Series.dropna is a simpler method as it only has one axis to consider.
DataFrame.dropna has considerably more options than Series.dropna, which can be
examined :ref:`in the API <api.dataframe.missing>`.

.. _missing_data.interpolate:

Interpolation
~~~~~~~~~~~~~

.. versionadded:: 0.13.0

  :meth:`~pandas.DataFrame.interpolate`, and :meth:`~pandas.Series.interpolate` have
  revamped interpolation methods and functionality.

.. versionadded:: 0.17.0

  The ``limit_direction`` keyword argument was added.

Both Series and Dataframe objects have an ``interpolate`` method that, by default,
performs linear interpolation at missing datapoints.

.. ipython:: python
   :suppress:

   np.random.seed(123456)
   idx = pd.date_range('1/1/2000', periods=100, freq='BM')
   ts = pd.Series(np.random.randn(100), index=idx)
   ts[1:20] = np.nan
   ts[60:80] = np.nan
   ts = ts.cumsum()

.. ipython:: python

   ts
   ts.count()
   ts.interpolate().count()

   @savefig series_interpolate.png
   ts.interpolate().plot()

Index aware interpolation is available via the ``method`` keyword:

.. ipython:: python
   :suppress:

   ts2 = ts[[0, 1, 30, 60, 99]]

.. ipython:: python

   ts2
   ts2.interpolate()
   ts2.interpolate(method='time')

For a floating-point index, use ``method='values'``:

.. ipython:: python
   :suppress:

   idx = [0., 1., 10.]
   ser = pd.Series([0., np.nan, 10.], idx)

.. ipython:: python

   ser
   ser.interpolate()
   ser.interpolate(method='values')

You can also interpolate with a DataFrame:

.. ipython:: python

   df = pd.DataFrame({'A': [1, 2.1, np.nan, 4.7, 5.6, 6.8],
                      'B': [.25, np.nan, np.nan, 4, 12.2, 14.4]})
   df
   df.interpolate()

The ``method`` argument gives access to fancier interpolation methods.
If you have scipy_ installed, you can set pass the name of a 1-d interpolation routine to ``method``.
You'll want to consult the full scipy interpolation documentation_ and reference guide_ for details.
The appropriate interpolation method will depend on the type of data you are working with.

* If you are dealing with a time series that is growing at an increasing rate,
  ``method='quadratic'`` may be appropriate.
* If you have values approximating a cumulative distribution function,
  then ``method='pchip'`` should work well.
* To fill missing values with goal of smooth plotting, use ``method='akima'``.

.. warning::

   These methods require ``scipy``.

.. ipython:: python

   df.interpolate(method='barycentric')

   df.interpolate(method='pchip')

   df.interpolate(method='akima')

When interpolating via a polynomial or spline approximation, you must also specify
the degree or order of the approximation:

.. ipython:: python

   df.interpolate(method='spline', order=2)

   df.interpolate(method='polynomial', order=2)

Compare several methods:

.. ipython:: python

   np.random.seed(2)

   ser = pd.Series(np.arange(1, 10.1, .25)**2 + np.random.randn(37))
   bad = np.array([4, 13, 14, 15, 16, 17, 18, 20, 29])
   ser[bad] = np.nan
   methods = ['linear', 'quadratic', 'cubic']

   df = pd.DataFrame({m: ser.interpolate(method=m) for m in methods})
   @savefig compare_interpolations.png
   df.plot()

Another use case is interpolation at *new* values.
Suppose you have 100 observations from some distribution. And let's suppose
that you're particularly interested in what's happening around the middle.
You can mix pandas' ``reindex`` and ``interpolate`` methods to interpolate
at the new values.

.. ipython:: python

   ser = pd.Series(np.sort(np.random.uniform(size=100)))

   # interpolate at new_index
   new_index = ser.index | pd.Index([49.25, 49.5, 49.75, 50.25, 50.5, 50.75])
   interp_s = ser.reindex(new_index).interpolate(method='pchip')
   interp_s[49:51]

.. _scipy: http://www.scipy.org
.. _documentation: http://docs.scipy.org/doc/scipy/reference/interpolate.html#univariate-interpolation
.. _guide: http://docs.scipy.org/doc/scipy/reference/tutorial/interpolate.html

Interpolation Limits
^^^^^^^^^^^^^^^^^^^^

Like other pandas fill methods, ``interpolate`` accepts a ``limit`` keyword
argument. Use this argument to limit the number of consecutive interpolations,
keeping ``NaN`` values for interpolations that are too far from the last valid
observation:

.. ipython:: python

   ser = pd.Series([np.nan, np.nan, 5, np.nan, np.nan, np.nan, 13])
   ser.interpolate(limit=2)

By default, ``limit`` applies in a forward direction, so that only ``NaN``
values after a non-``NaN`` value can be filled. If you provide ``'backward'`` or
``'both'`` for the ``limit_direction`` keyword argument, you can fill ``NaN``
values before non-``NaN`` values, or both before and after non-``NaN`` values,
respectively:

.. ipython:: python

   ser.interpolate(limit=1)  # limit_direction == 'forward'

   ser.interpolate(limit=1, limit_direction='backward')

   ser.interpolate(limit=1, limit_direction='both')

.. _missing_data.replace:

Replacing Generic Values
~~~~~~~~~~~~~~~~~~~~~~~~
Often times we want to replace arbitrary values with other values. New in v0.8
is the ``replace`` method in Series/DataFrame that provides an efficient yet
flexible way to perform such replacements.

For a Series, you can replace a single value or a list of values by another
value:

.. ipython:: python

   ser = pd.Series([0., 1., 2., 3., 4.])

   ser.replace(0, 5)

You can replace a list of values by a list of other values:

.. ipython:: python

   ser.replace([0, 1, 2, 3, 4], [4, 3, 2, 1, 0])

You can also specify a mapping dict:

.. ipython:: python

   ser.replace({0: 10, 1: 100})

For a DataFrame, you can specify individual values by column:

.. ipython:: python

   df = pd.DataFrame({'a': [0, 1, 2, 3, 4], 'b': [5, 6, 7, 8, 9]})

   df.replace({'a': 0, 'b': 5}, 100)

Instead of replacing with specified values, you can treat all given values as
missing and interpolate over them:

.. ipython:: python

   ser.replace([1, 2, 3], method='pad')

.. _missing_data.replace_expression:

String/Regular Expression Replacement
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   Python strings prefixed with the ``r`` character such as ``r'hello world'``
   are so-called "raw" strings. They have different semantics regarding
   backslashes than strings without this prefix. Backslashes in raw strings
   will be interpreted as an escaped backslash, e.g., ``r'\' == '\\'``. You
   should `read about them
   <http://docs.python.org/2/reference/lexical_analysis.html#string-literals>`__
   if this is unclear.

Replace the '.' with ``nan`` (str -> str)

.. ipython:: python

   d = {'a': list(range(4)), 'b': list('ab..'), 'c': ['a', 'b', np.nan, 'd']}
   df = pd.DataFrame(d)
   df.replace('.', np.nan)

Now do it with a regular expression that removes surrounding whitespace
(regex -> regex)

.. ipython:: python

   df.replace(r'\s*\.\s*', np.nan, regex=True)

Replace a few different values (list -> list)

.. ipython:: python

   df.replace(['a', '.'], ['b', np.nan])

list of regex -> list of regex

.. ipython:: python

   df.replace([r'\.', r'(a)'], ['dot', '\1stuff'], regex=True)

Only search in column ``'b'`` (dict -> dict)

.. ipython:: python

   df.replace({'b': '.'}, {'b': np.nan})

Same as the previous example, but use a regular expression for
searching instead (dict of regex -> dict)

.. ipython:: python

   df.replace({'b': r'\s*\.\s*'}, {'b': np.nan}, regex=True)

You can pass nested dictionaries of regular expressions that use ``regex=True``

.. ipython:: python

   df.replace({'b': {'b': r''}}, regex=True)

or you can pass the nested dictionary like so

.. ipython:: python

   df.replace(regex={'b': {r'\s*\.\s*': np.nan}})

You can also use the group of a regular expression match when replacing (dict
of regex -> dict of regex), this works for lists as well

.. ipython:: python

   df.replace({'b': r'\s*(\.)\s*'}, {'b': r'\1ty'}, regex=True)

You can pass a list of regular expressions, of which those that match
will be replaced with a scalar (list of regex -> regex)

.. ipython:: python

   df.replace([r'\s*\.\s*', r'a|b'], np.nan, regex=True)

All of the regular expression examples can also be passed with the
``to_replace`` argument as the ``regex`` argument. In this case the ``value``
argument must be passed explicitly by name or ``regex`` must be a nested
dictionary. The previous example, in this case, would then be

.. ipython:: python

   df.replace(regex=[r'\s*\.\s*', r'a|b'], value=np.nan)

This can be convenient if you do not want to pass ``regex=True`` every time you
want to use a regular expression.

.. note::

   Anywhere in the above ``replace`` examples that you see a regular expression
   a compiled regular expression is valid as well.

Numeric Replacement
~~~~~~~~~~~~~~~~~~~

Similar to ``DataFrame.fillna``

.. ipython:: python

   df = pd.DataFrame(np.random.randn(10, 2))
   df[np.random.rand(df.shape[0]) > 0.5] = 1.5
   df.replace(1.5, np.nan)

Replacing more than one value via lists works as well

.. ipython:: python

   df00 = df.values[0, 0]
   df.replace([1.5, df00], [np.nan, 'a'])
   df[1].dtype

You can also operate on the DataFrame in place

.. ipython:: python

   df.replace(1.5, np.nan, inplace=True)

.. warning::

   When replacing multiple ``bool`` or ``datetime64`` objects, the first
   argument to ``replace`` (``to_replace``) must match the type of the value
   being replaced type. For example,

   .. code-block:: python

      s = pd.Series([True, False, True])
      s.replace({'a string': 'new value', True: False})  # raises

      TypeError: Cannot compare types 'ndarray(dtype=bool)' and 'str'

   will raise a ``TypeError`` because one of the ``dict`` keys is not of the
   correct type for replacement.

   However, when replacing a *single* object such as,

   .. ipython:: python

      s = pd.Series([True, False, True])
      s.replace('a string', 'another string')

   the original ``NDFrame`` object will be returned untouched. We're working on
   unifying this API, but for backwards compatibility reasons we cannot break
   the latter behavior. See :issue:`6354` for more details.   