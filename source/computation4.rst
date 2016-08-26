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

.. _stats.moments.expanding:

Expanding Windows
-----------------

A common alternative to rolling statistics is to use an *expanding* window,
which yields the value of the statistic with all the data available up to that
point in time.

These follow a similar interface to ``.rolling``, with the ``.expanding`` method
returning an :class:`~pandas.core.window.Expanding` object.

As these calculations are a special case of rolling statistics,
they are implemented in pandas such that the following two calls are equivalent:

.. ipython:: python

   df.rolling(window=len(df), min_periods=1).mean()[:5]

   df.expanding(min_periods=1).mean()[:5]

These have a similar set of methods to ``.rolling`` methods.

Method Summary
~~~~~~~~~~~~~~

.. currentmodule:: pandas.core.window

.. csv-table::
    :header: "Function", "Description"
    :widths: 20, 80

    :meth:`~Expanding.count`, Number of non-null observations
    :meth:`~Expanding.sum`, Sum of values
    :meth:`~Expanding.mean`, Mean of values
    :meth:`~Expanding.median`, Arithmetic median of values
    :meth:`~Expanding.min`, Minimum
    :meth:`~Expanding.max`, Maximum
    :meth:`~Expanding.std`, Unbiased standard deviation
    :meth:`~Expanding.var`, Unbiased variance
    :meth:`~Expanding.skew`, Unbiased skewness (3rd moment)
    :meth:`~Expanding.kurt`, Unbiased kurtosis (4th moment)
    :meth:`~Expanding.quantile`, Sample quantile (value at %)
    :meth:`~Expanding.apply`, Generic apply
    :meth:`~Expanding.cov`, Unbiased covariance (binary)
    :meth:`~Expanding.corr`, Correlation (binary)

Aside from not having a ``window`` parameter, these functions have the same
interfaces as their ``.rolling`` counterparts. Like above, the parameters they
all accept are:

- ``min_periods``: threshold of non-null data points to require. Defaults to
  minimum needed to compute statistic. No ``NaNs`` will be output once
  ``min_periods`` non-null data points have been seen.
- ``center``: boolean, whether to set the labels at the center (default is False)

.. note::

   The output of the ``.rolling`` and ``.expanding`` methods do not return a
   ``NaN`` if there are at least ``min_periods`` non-null values in the current
   window. This differs from ``cumsum``, ``cumprod``, ``cummax``, and
   ``cummin``, which return ``NaN`` in the output wherever a ``NaN`` is
   encountered in the input.

An expanding window statistic will be more stable (and less responsive) than
its rolling window counterpart as the increasing window size decreases the
relative impact of an individual data point. As an example, here is the
:meth:`~Expanding.mean` output for the previous time series dataset:

.. ipython:: python
   :suppress:

   plt.close('all')

.. ipython:: python

   s.plot(style='k--')

   @savefig expanding_mean_frame.png
   s.expanding().mean().plot(style='k')
