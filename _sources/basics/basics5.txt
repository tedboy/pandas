.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8
   index = pd.date_range('1/1/2000', periods=8)
   s = pd.Series(np.random.randn(5), index=['a', 'b', 'c', 'd', 'e'])
   df = pd.DataFrame({'one' : pd.Series(np.random.randn(3), index=['a', 'b', 'c']),
                      'two' : pd.Series(np.random.randn(4), index=['a', 'b', 'c', 'd']),
                      'three' : pd.Series(np.random.randn(3), index=['b', 'c', 'd'])})
   wp = pd.Panel(np.random.randn(2, 5, 4), items=['Item1', 'Item2'],
                 major_axis=pd.date_range('1/1/2000', periods=5),
                 minor_axis=['A', 'B', 'C', 'D'])   

.. _basics.stats:

Descriptive statistics
----------------------

A large number of methods for computing descriptive statistics and other related
operations on :ref:`Series <api.series.stats>`, :ref:`DataFrame
<api.dataframe.stats>`, and :ref:`Panel <api.panel.stats>`. Most of these
are aggregations (hence producing a lower-dimensional result) like
:meth:`~DataFrame.sum`, :meth:`~DataFrame.mean`, and :meth:`~DataFrame.quantile`,
but some of them, like :meth:`~DataFrame.cumsum` and :meth:`~DataFrame.cumprod`,
produce an object of the same size. Generally speaking, these methods take an
**axis** argument, just like *ndarray.{sum, std, ...}*, but the axis can be
specified by name or integer:

  - **Series**: no axis argument needed
  - **DataFrame**: "index" (axis=0, default), "columns" (axis=1)
  - **Panel**: "items" (axis=0), "major" (axis=1, default), "minor"
    (axis=2)

For example:

.. ipython:: python

   df
   df.mean(0)
   df.mean(1)

All such methods have a ``skipna`` option signaling whether to exclude missing
data (``True`` by default):

.. ipython:: python

   df.sum(0, skipna=False)
   df.sum(axis=1, skipna=True)

Combined with the broadcasting / arithmetic behavior, one can describe various
statistical procedures, like standardization (rendering data zero mean and
standard deviation 1), very concisely:

.. ipython:: python

   ts_stand = (df - df.mean()) / df.std()
   ts_stand.std()
   xs_stand = df.sub(df.mean(1), axis=0).div(df.std(1), axis=0)
   xs_stand.std(1)

Note that methods like :meth:`~DataFrame.cumsum` and :meth:`~DataFrame.cumprod`
preserve the location of NA values:

.. ipython:: python

   df.cumsum()

Here is a quick reference summary table of common functions. Each also takes an
optional ``level`` parameter which applies only if the object has a
:ref:`hierarchical index<advanced.hierarchical>`.

.. csv-table::
    :header: "Function", "Description"
    :widths: 20, 80

    ``count``, Number of non-null observations
    ``sum``, Sum of values
    ``mean``, Mean of values
    ``mad``, Mean absolute deviation
    ``median``, Arithmetic median of values
    ``min``, Minimum
    ``max``, Maximum
    ``mode``, Mode
    ``abs``, Absolute Value
    ``prod``, Product of values
    ``std``, Bessel-corrected sample standard deviation
    ``var``, Unbiased variance
    ``sem``, Standard error of the mean
    ``skew``, Sample skewness (3rd moment)
    ``kurt``, Sample kurtosis (4th moment)
    ``quantile``, Sample quantile (value at %)
    ``cumsum``, Cumulative sum
    ``cumprod``, Cumulative product
    ``cummax``, Cumulative maximum
    ``cummin``, Cumulative minimum

Note that by chance some NumPy methods, like ``mean``, ``std``, and ``sum``,
will exclude NAs on Series input by default:

.. ipython:: python

   np.mean(df['one'])
   np.mean(df['one'].values)

``Series`` also has a method :meth:`~Series.nunique` which will return the
number of unique non-null values:

.. ipython:: python

   series = pd.Series(np.random.randn(500))
   series[20:500] = np.nan
   series[10:20]  = 5
   series.nunique()

.. _basics.describe:

Summarizing data: describe
~~~~~~~~~~~~~~~~~~~~~~~~~~

There is a convenient :meth:`~DataFrame.describe` function which computes a variety of summary
statistics about a Series or the columns of a DataFrame (excluding NAs of
course):

.. ipython:: python

    series = pd.Series(np.random.randn(1000))
    series[::2] = np.nan
    series.describe()
    frame = pd.DataFrame(np.random.randn(1000, 5), columns=['a', 'b', 'c', 'd', 'e'])
    frame.ix[::2] = np.nan
    frame.describe()

You can select specific percentiles to include in the output:

.. ipython:: python

    series.describe(percentiles=[.05, .25, .75, .95])

By default, the median is always included.

For a non-numerical Series object, :meth:`~Series.describe` will give a simple
summary of the number of unique values and most frequently occurring values:

.. ipython:: python

   s = pd.Series(['a', 'a', 'b', 'b', 'a', 'a', np.nan, 'c', 'd', 'a'])
   s.describe()

Note that on a mixed-type DataFrame object, :meth:`~DataFrame.describe` will
restrict the summary to include only numerical columns or, if none are, only
categorical columns:

.. ipython:: python

    frame = pd.DataFrame({'a': ['Yes', 'Yes', 'No', 'No'], 'b': range(4)})
    frame.describe()

This behaviour can be controlled by providing a list of types as ``include``/``exclude``
arguments. The special value ``all`` can also be used:

.. ipython:: python

    frame.describe(include=['object'])
    frame.describe(include=['number'])
    frame.describe(include='all')

That feature relies on :ref:`select_dtypes <basics.selectdtypes>`. Refer to
there for details about accepted inputs.

.. _basics.idxmin:

Index of Min/Max Values
~~~~~~~~~~~~~~~~~~~~~~~

The :meth:`~DataFrame.idxmin` and :meth:`~DataFrame.idxmax` functions on Series
and DataFrame compute the index labels with the minimum and maximum
corresponding values:

.. ipython:: python

   s1 = pd.Series(np.random.randn(5))
   s1
   s1.idxmin(), s1.idxmax()

   df1 = pd.DataFrame(np.random.randn(5,3), columns=['A','B','C'])
   df1
   df1.idxmin(axis=0)
   df1.idxmax(axis=1)

When there are multiple rows (or columns) matching the minimum or maximum
value, :meth:`~DataFrame.idxmin` and :meth:`~DataFrame.idxmax` return the first
matching index:

.. ipython:: python

   df3 = pd.DataFrame([2, 1, 1, 3, np.nan], columns=['A'], index=list('edcba'))
   df3
   df3['A'].idxmin()

.. note::

   ``idxmin`` and ``idxmax`` are called ``argmin`` and ``argmax`` in NumPy.

.. _basics.discretization:

Value counts (histogramming) / Mode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :meth:`~Series.value_counts` Series method and top-level function computes a histogram
of a 1D array of values. It can also be used as a function on regular arrays:

.. ipython:: python

   data = np.random.randint(0, 7, size=50)
   data
   s = pd.Series(data)
   s.value_counts()
   pd.value_counts(data)

Similarly, you can get the most frequently occurring value(s) (the mode) of the values in a Series or DataFrame:

.. ipython:: python

    s5 = pd.Series([1, 1, 3, 3, 3, 5, 5, 7, 7, 7])
    s5.mode()
    df5 = pd.DataFrame({"A": np.random.randint(0, 7, size=50),
                        "B": np.random.randint(-10, 15, size=50)})
    df5.mode()


Discretization and quantiling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Continuous values can be discretized using the :func:`cut` (bins based on values)
and :func:`qcut` (bins based on sample quantiles) functions:

.. ipython:: python

   arr = np.random.randn(20)
   factor = pd.cut(arr, 4)
   factor

   factor = pd.cut(arr, [-5, -1, 0, 1, 5])
   factor

:func:`qcut` computes sample quantiles. For example, we could slice up some
normally distributed data into equal-size quartiles like so:

.. ipython:: python

   arr = np.random.randn(30)
   factor = pd.qcut(arr, [0, .25, .5, .75, 1])
   factor
   pd.value_counts(factor)

We can also pass infinite values to define the bins:

.. ipython:: python

   arr = np.random.randn(20)
   factor = pd.cut(arr, [-np.inf, 0, np.inf])
   factor