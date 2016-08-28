.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')
   pd.options.display.max_rows=8

.. _stats.moments:

Window Functions
----------------

.. currentmodule:: pandas.core.window

.. warning::

   Prior to version 0.18.0, ``pd.rolling_*``, ``pd.expanding_*``, and ``pd.ewm*`` were module level
   functions and are now deprecated. These are replaced by using the :class:`~pandas.core.window.Rolling`, :class:`~pandas.core.window.Expanding` and :class:`~pandas.core.window.EWM`. objects and a corresponding method call.

   The deprecation warning will show the new syntax, see an example :ref:`here <whatsnew_0180.window_deprecations>`
   You can view the previous documentation
   `here <http://pandas.pydata.org/pandas-docs/version/0.17.1/computation.html#moving-rolling-statistics-moments>`__

For working with data, a number of windows functions are provided for
computing common *window* or *rolling* statistics. Among these are count, sum,
mean, median, correlation, variance, covariance, standard deviation, skewness,
and kurtosis.

.. note::

   The API for window statistics is quite similar to the way one works with ``GroupBy`` objects, see the documentation :ref:`here <groupby>`

We work with ``rolling``, ``expanding`` and ``exponentially weighted`` data through the corresponding
objects, :class:`~pandas.core.window.Rolling`, :class:`~pandas.core.window.Expanding` and :class:`~pandas.core.window.EWM`.

.. ipython:: python

   s = pd.Series(np.random.randn(1000), index=pd.date_range('1/1/2000', periods=1000))
   s = s.cumsum()
   s

These are created from methods on ``Series`` and ``DataFrame``.

.. ipython:: python

   r = s.rolling(window=60)
   r

These object provide tab-completion of the avaible methods and properties.

.. code-block:: ipython

   In [14]: r.
   r.agg         r.apply       r.count       r.exclusions  r.max         r.median      r.name        r.skew        r.sum
   r.aggregate   r.corr        r.cov         r.kurt        r.mean        r.min         r.quantile    r.std         r.var

Generally these methods all have the same interface. They all
accept the following arguments:

- ``window``: size of moving window
- ``min_periods``: threshold of non-null data points to require (otherwise
  result is NA)
- ``center``: boolean, whether to set the labels at the center (default is False)

.. warning::

   The ``freq`` and ``how`` arguments were in the API prior to 0.18.0 changes. These are deprecated in the new API. You can simply resample the input prior to creating a window function.

   For example, instead of ``s.rolling(window=5,freq='D').max()`` to get the max value on a rolling 5 Day window, one could use ``s.resample('D').max().rolling(window=5).max()``, which first resamples the data to daily data, then provides a rolling 5 day window.

We can then call methods on these ``rolling`` objects. These return like-indexed objects:

.. ipython:: python

   r.mean()

.. ipython:: python

   s.plot(style='k--')

   @savefig rolling_mean_ex.png
   r.mean().plot(style='k')

.. ipython:: python
   :suppress:

   plt.close('all')

They can also be applied to DataFrame objects. This is really just syntactic
sugar for applying the moving window operator to all of the DataFrame's columns:

.. ipython:: python

   df = pd.DataFrame(np.random.randn(1000, 4),
                     index=pd.date_range('1/1/2000', periods=1000),
                     columns=['A', 'B', 'C', 'D'])
   df = df.cumsum()

   @savefig rolling_mean_frame.png
   df.rolling(window=60).sum().plot(subplots=True)

.. _stats.summary:

Method Summary
~~~~~~~~~~~~~~

We provide a number of the common statistical functions:

.. currentmodule:: pandas.core.window

.. csv-table::
    :header: "Method", "Description"
    :widths: 20, 80

    :meth:`~Rolling.count`, Number of non-null observations
    :meth:`~Rolling.sum`, Sum of values
    :meth:`~Rolling.mean`, Mean of values
    :meth:`~Rolling.median`, Arithmetic median of values
    :meth:`~Rolling.min`, Minimum
    :meth:`~Rolling.max`, Maximum
    :meth:`~Rolling.std`, Bessel-corrected sample standard deviation
    :meth:`~Rolling.var`, Unbiased variance
    :meth:`~Rolling.skew`, Sample skewness (3rd moment)
    :meth:`~Rolling.kurt`, Sample kurtosis (4th moment)
    :meth:`~Rolling.quantile`, Sample quantile (value at %)
    :meth:`~Rolling.apply`, Generic apply
    :meth:`~Rolling.cov`, Unbiased covariance (binary)
    :meth:`~Rolling.corr`, Correlation (binary)

The :meth:`~Rolling.apply` function takes an extra ``func`` argument and performs
generic rolling computations. The ``func`` argument should be a single function
that produces a single value from an ndarray input. Suppose we wanted to
compute the mean absolute deviation on a rolling basis:

.. ipython:: python

   mad = lambda x: np.fabs(x - x.mean()).mean()
   @savefig rolling_apply_ex.png
   s.rolling(window=60).apply(mad).plot(style='k')

.. _stats.rolling_window:

Rolling Windows
~~~~~~~~~~~~~~~

Passing ``win_type`` to ``.rolling`` generates a generic rolling window computation, that is weighted according the ``win_type``.
The following methods are available:

.. csv-table::
    :header: "Method", "Description"
    :widths: 20, 80

    :meth:`~Window.sum`, Sum of values
    :meth:`~Window.mean`, Mean of values

The weights used in the window are specified by the ``win_type`` keyword. The list of recognized types are:

- ``boxcar``
- ``triang``
- ``blackman``
- ``hamming``
- ``bartlett``
- ``parzen``
- ``bohman``
- ``blackmanharris``
- ``nuttall``
- ``barthann``
- ``kaiser`` (needs beta)
- ``gaussian`` (needs std)
- ``general_gaussian`` (needs power, width)
- ``slepian`` (needs width).

.. ipython:: python

   ser = pd.Series(np.random.randn(10), index=pd.date_range('1/1/2000', periods=10))

   ser.rolling(window=5, win_type='triang').mean()

Note that the ``boxcar`` window is equivalent to :meth:`~Rolling.mean`.

.. ipython:: python

   ser.rolling(window=5, win_type='boxcar').mean()
   ser.rolling(window=5).mean()

For some windowing functions, additional parameters must be specified:

.. ipython:: python

   ser.rolling(window=5, win_type='gaussian').mean(std=0.1)

.. _stats.moments.normalization:

.. note::

    For ``.sum()`` with a ``win_type``, there is no normalization done to the
    weights for the window. Passing custom weights of ``[1, 1, 1]`` will yield a different
    result than passing weights of ``[2, 2, 2]``, for example. When passing a
    ``win_type`` instead of explicitly specifying the weights, the weights are
    already normalized so that the largest weight is 1.

    In contrast, the nature of the ``.mean()`` calculation is
    such that the weights are normalized with respect to each other. Weights
    of ``[1, 1, 1]`` and ``[2, 2, 2]`` yield the same result.

.. _stats.moments.ts:

Time-aware Rolling
~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.19.0

New in version 0.19.0 are the ability to pass an offset (or convertible) to a ``.rolling()`` method and have it produce
variable sized windows based on the passed time window. For each time point, this includes all preceding values occurring
within the indicated time delta.

This can be particularly useful for a non-regular time frequency index.

.. ipython:: python

   dft = pd.DataFrame({'B': [0, 1, 2, np.nan, 4]},
                      index=pd.date_range('20130101 09:00:00', periods=5, freq='s'))
   dft

This is a regular frequency index. Using an integer window parameter works to roll along the window frequency.

.. ipython:: python

   dft.rolling(2).sum()
   dft.rolling(2, min_periods=1).sum()

Specifying an offset allows a more intuitive specification of the rolling frequency.

.. ipython:: python

   dft.rolling('2s').sum()

Using a non-regular, but still monotonic index, rolling with an integer window does not impart any special calculation.


.. ipython:: python

   dft = pd.DataFrame({'B': [0, 1, 2, np.nan, 4]},
                      index = pd.Index([pd.Timestamp('20130101 09:00:00'),
                                        pd.Timestamp('20130101 09:00:02'),
                                        pd.Timestamp('20130101 09:00:03'),
                                        pd.Timestamp('20130101 09:00:05'),
                                        pd.Timestamp('20130101 09:00:06')],
                                       name='foo'))
   dft
   dft.rolling(2).sum()


Using the time-specification generates variable windows for this sparse data.

.. ipython:: python

   dft.rolling('2s').sum()

Furthermore, we now allow an optional ``on`` parameter to specify a column (rather than the
default of the index) in a DataFrame.

.. ipython:: python

   dft = dft.reset_index()
   dft
   dft.rolling('2s', on='foo').sum()

.. _stats.moments.ts-versus-resampling:

Time-aware Rolling vs. Resampling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Using ``.rolling()`` with a time-based index is quite similar to :ref:`resampling <timeseries.resampling>`. They
both operate and perform reductive operations on time-indexed pandas objects.

When using ``.rolling()`` with an offset. The offset is a time-delta. Take a backwards-in-time looking window, and
aggregate all of the values in that window (including the end-point, but not the start-point). This is the new value
at that point in the result. These are variable sized windows in time-space for each point of the input. You will get
a same sized result as the input.

When using ``.resample()`` with an offset. Construct a new index that is the frequency of the offset. For each frequency
bin, aggregate points from the input within a backwards-in-time looking window that fall in that bin. The result of this
aggregation is the output for that frequency point. The windows are fixed size size in the frequency space. Your result
will have the shape of a regular frequency between the min and the max of the original input object.

To summarize, ``.rolling()`` is a time-based window operation, while ``.resample()`` is a frequency-based window operation.

Centering Windows
~~~~~~~~~~~~~~~~~

By default the labels are set to the right edge of the window, but a
``center`` keyword is available so the labels can be set at the center.

.. ipython:: python

   ser.rolling(window=5).mean()
   ser.rolling(window=5, center=True).mean()

.. _stats.moments.binary:

Binary Window Functions
~~~~~~~~~~~~~~~~~~~~~~~

:meth:`~Rolling.cov` and :meth:`~Rolling.corr` can compute moving window statistics about
two ``Series`` or any combination of ``DataFrame/Series`` or
``DataFrame/DataFrame``. Here is the behavior in each case:

- two ``Series``: compute the statistic for the pairing.
- ``DataFrame/Series``: compute the statistics for each column of the DataFrame
  with the passed Series, thus returning a DataFrame.
- ``DataFrame/DataFrame``: by default compute the statistic for matching column
  names, returning a DataFrame. If the keyword argument ``pairwise=True`` is
  passed then computes the statistic for each pair of columns, returning a
  ``Panel`` whose ``items`` are the dates in question (see :ref:`the next section
  <stats.moments.corr_pairwise>`).

For example:

.. ipython:: python

   df2 = df[:20]
   df2.rolling(window=5).corr(df2['B'])

.. _stats.moments.corr_pairwise:

Computing rolling pairwise covariances and correlations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In financial data analysis and other fields it's common to compute covariance
and correlation matrices for a collection of time series. Often one is also
interested in moving-window covariance and correlation matrices. This can be
done by passing the ``pairwise`` keyword argument, which in the case of
``DataFrame`` inputs will yield a ``Panel`` whose ``items`` are the dates in
question. In the case of a single DataFrame argument the ``pairwise`` argument
can even be omitted:

.. note::

    Missing values are ignored and each entry is computed using the pairwise
    complete observations.  Please see the :ref:`covariance section
    <computation.covariance>` for :ref:`caveats
    <computation.covariance.caveats>` associated with this method of
    calculating covariance and correlation matrices.

.. ipython:: python

   covs = df[['B','C','D']].rolling(window=50).cov(df[['A','B','C']], pairwise=True)
   covs[df.index[-50]]

.. ipython:: python

   correls = df.rolling(window=50).corr()
   correls[df.index[-50]]

You can efficiently retrieve the time series of correlations between two
columns using ``.loc`` indexing:

.. ipython:: python
   :suppress:

   plt.close('all')

.. ipython:: python

   @savefig rolling_corr_pairwise_ex.png
   correls.loc[:, 'A', 'C'].plot()