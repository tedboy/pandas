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

.. _stats.moments.exponentially_weighted:

Exponentially Weighted Windows
------------------------------

A related set of functions are exponentially weighted versions of several of
the above statistics. A similar interface to ``.rolling`` and ``.expanding`` is accessed
thru the ``.ewm`` method to receive an :class:`~pandas.core.window.EWM` object.
A number of expanding EW (exponentially weighted)
methods are provided:

.. currentmodule:: pandas.core.window

.. csv-table::
    :header: "Function", "Description"
    :widths: 20, 80

    :meth:`~EWM.mean`, EW moving average
    :meth:`~EWM.var`, EW moving variance
    :meth:`~EWM.std`, EW moving standard deviation
    :meth:`~EWM.corr`, EW moving correlation
    :meth:`~EWM.cov`, EW moving covariance

In general, a weighted moving average is calculated as

.. math::

    y_t = \frac{\sum_{i=0}^t w_i x_{t-i}}{\sum_{i=0}^t w_i},

where :math:`x_t` is the input and :math:`y_t` is the result.

The EW functions support two variants of exponential weights.
The default, ``adjust=True``, uses the weights :math:`w_i = (1 - \alpha)^i`
which gives

.. math::

    y_t = \frac{x_t + (1 - \alpha)x_{t-1} + (1 - \alpha)^2 x_{t-2} + ...
    + (1 - \alpha)^t x_{0}}{1 + (1 - \alpha) + (1 - \alpha)^2 + ...
    + (1 - \alpha)^t}

When ``adjust=False`` is specified, moving averages are calculated as

.. math::

    y_0 &= x_0 \\
    y_t &= (1 - \alpha) y_{t-1} + \alpha x_t,

which is equivalent to using weights

.. math::

    w_i = \begin{cases}
        \alpha (1 - \alpha)^i & \text{if } i < t \\
        (1 - \alpha)^i        & \text{if } i = t.
    \end{cases}

.. note::

   These equations are sometimes written in terms of :math:`\alpha' = 1 - \alpha`, e.g.

   .. math::

      y_t = \alpha' y_{t-1} + (1 - \alpha') x_t.

The difference between the above two variants arises because we are
dealing with series which have finite history. Consider a series of infinite
history:

.. math::

    y_t = \frac{x_t + (1 - \alpha)x_{t-1} + (1 - \alpha)^2 x_{t-2} + ...}
    {1 + (1 - \alpha) + (1 - \alpha)^2 + ...}

Noting that the denominator is a geometric series with initial term equal to 1
and a ratio of :math:`1 - \alpha` we have

.. math::

    y_t &= \frac{x_t + (1 - \alpha)x_{t-1} + (1 - \alpha)^2 x_{t-2} + ...}
    {\frac{1}{1 - (1 - \alpha)}}\\
    &= [x_t + (1 - \alpha)x_{t-1} + (1 - \alpha)^2 x_{t-2} + ...] \alpha \\
    &= \alpha x_t + [(1-\alpha)x_{t-1} + (1 - \alpha)^2 x_{t-2} + ...]\alpha \\
    &= \alpha x_t + (1 - \alpha)[x_{t-1} + (1 - \alpha) x_{t-2} + ...]\alpha\\
    &= \alpha x_t + (1 - \alpha) y_{t-1}

which shows the equivalence of the above two variants for infinite series.
When ``adjust=True`` we have :math:`y_0 = x_0` and from the last
representation above we have :math:`y_t = \alpha x_t + (1 - \alpha) y_{t-1}`,
therefore there is an assumption that :math:`x_0` is not an ordinary value
but rather an exponentially weighted moment of the infinite series up to that
point.

One must have :math:`0 < \alpha \leq 1`, and while since version 0.18.0
it has been possible to pass :math:`\alpha` directly, it's often easier
to think about either the **span**, **center of mass (com)** or **half-life**
of an EW moment:

.. math::

   \alpha =
    \begin{cases}
        \frac{2}{s + 1},               & \text{for span}\ s \geq 1\\
        \frac{1}{1 + c},               & \text{for center of mass}\ c \geq 0\\
        1 - \exp^{\frac{\log 0.5}{h}}, & \text{for half-life}\ h > 0
    \end{cases}

One must specify precisely one of **span**, **center of mass**, **half-life**
and **alpha** to the EW functions:

- **Span** corresponds to what is commonly called an "N-day EW moving average".
- **Center of mass** has a more physical interpretation and can be thought of
  in terms of span: :math:`c = (s - 1) / 2`.
- **Half-life** is the period of time for the exponential weight to reduce to
  one half.
- **Alpha** specifies the smoothing factor directly.

Here is an example for a univariate time series:

.. ipython:: python

   s.plot(style='k--')

   @savefig ewma_ex.png
   s.ewm(span=20).mean().plot(style='k')

EWM has a ``min_periods`` argument, which has the same
meaning it does for all the ``.expanding`` and ``.rolling`` methods:
no output values will be set until at least ``min_periods`` non-null values
are encountered in the (expanding) window.
(This is a change from versions prior to 0.15.0, in which the ``min_periods``
argument affected only the ``min_periods`` consecutive entries starting at the
first non-null value.)

EWM also has an ``ignore_na`` argument, which deterines how
intermediate null values affect the calculation of the weights.
When ``ignore_na=False`` (the default), weights are calculated based on absolute
positions, so that intermediate null values affect the result.
When ``ignore_na=True`` (which reproduces the behavior in versions prior to 0.15.0),
weights are calculated by ignoring intermediate null values.
For example, assuming ``adjust=True``, if ``ignore_na=False``, the weighted
average of ``3, NaN, 5`` would be calculated as

.. math::

  \frac{(1-\alpha)^2 \cdot 3 + 1 \cdot 5}{(1-\alpha)^2 + 1}

Whereas if ``ignore_na=True``, the weighted average would be calculated as

.. math::

  \frac{(1-\alpha) \cdot 3 + 1 \cdot 5}{(1-\alpha) + 1}.

The :meth:`~Ewm.var`, :meth:`~Ewm.std`, and :meth:`~Ewm.cov` functions have a ``bias`` argument,
specifying whether the result should contain biased or unbiased statistics.
For example, if ``bias=True``, ``ewmvar(x)`` is calculated as
``ewmvar(x) = ewma(x**2) - ewma(x)**2``;
whereas if ``bias=False`` (the default), the biased variance statistics
are scaled by debiasing factors

.. math::

    \frac{\left(\sum_{i=0}^t w_i\right)^2}{\left(\sum_{i=0}^t w_i\right)^2 - \sum_{i=0}^t w_i^2}.

(For :math:`w_i = 1`, this reduces to the usual :math:`N / (N - 1)` factor,
with :math:`N = t + 1`.)
See `Weighted Sample Variance <http://en.wikipedia.org/wiki/Weighted_arithmetic_mean#Weighted_sample_variance>`__
for further details.
