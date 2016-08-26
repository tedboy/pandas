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

Statistical Functions
---------------------

.. _computation.pct_change:

Percent Change
~~~~~~~~~~~~~~

``Series``, ``DataFrame``, and ``Panel`` all have a method ``pct_change`` to compute the
percent change over a given number of periods (using ``fill_method`` to fill
NA/null values *before* computing the percent change).

.. ipython:: python

   ser = pd.Series(np.random.randn(8))

   ser.pct_change()

.. ipython:: python

   df = pd.DataFrame(np.random.randn(10, 4))

   df.pct_change(periods=3)

.. _computation.covariance:

Covariance
~~~~~~~~~~

The ``Series`` object has a method ``cov`` to compute covariance between series
(excluding NA/null values).

.. ipython:: python

   s1 = pd.Series(np.random.randn(1000))
   s2 = pd.Series(np.random.randn(1000))
   s1.cov(s2)

Analogously, ``DataFrame`` has a method ``cov`` to compute pairwise covariances
among the series in the DataFrame, also excluding NA/null values.

.. _computation.covariance.caveats:

.. note::

    Assuming the missing data are missing at random this results in an estimate
    for the covariance matrix which is unbiased. However, for many applications
    this estimate may not be acceptable because the estimated covariance matrix
    is not guaranteed to be positive semi-definite. This could lead to
    estimated correlations having absolute values which are greater than one,
    and/or a non-invertible covariance matrix. See `Estimation of covariance
    matrices <http://en.wikipedia.org/w/index.php?title=Estimation_of_covariance_matrices>`_
    for more details.

.. ipython:: python

   frame = pd.DataFrame(np.random.randn(1000, 5), columns=['a', 'b', 'c', 'd', 'e'])
   frame.cov()

``DataFrame.cov`` also supports an optional ``min_periods`` keyword that
specifies the required minimum number of observations for each column pair
in order to have a valid result.

.. ipython:: python

   frame = pd.DataFrame(np.random.randn(20, 3), columns=['a', 'b', 'c'])
   frame.ix[:5, 'a'] = np.nan
   frame.ix[5:10, 'b'] = np.nan

   frame.cov()

   frame.cov(min_periods=12)


.. _computation.correlation:

Correlation
~~~~~~~~~~~

Several methods for computing correlations are provided:

.. csv-table::
    :header: "Method name", "Description"
    :widths: 20, 80

    ``pearson (default)``, Standard correlation coefficient
    ``kendall``, Kendall Tau correlation coefficient
    ``spearman``, Spearman rank correlation coefficient

.. \rho = \cov(x, y) / \sigma_x \sigma_y

All of these are currently computed using pairwise complete observations.

.. note::

    Please see the :ref:`caveats <computation.covariance.caveats>` associated
    with this method of calculating correlation matrices in the
    :ref:`covariance section <computation.covariance>`.

.. ipython:: python

   frame = pd.DataFrame(np.random.randn(1000, 5), columns=['a', 'b', 'c', 'd', 'e'])
   frame.ix[::2] = np.nan

   # Series with Series
   frame['a'].corr(frame['b'])
   frame['a'].corr(frame['b'], method='spearman')

   # Pairwise correlation of DataFrame columns
   frame.corr()

Note that non-numeric columns will be automatically excluded from the
correlation calculation.

Like ``cov``, ``corr`` also supports the optional ``min_periods`` keyword:

.. ipython:: python

   frame = pd.DataFrame(np.random.randn(20, 3), columns=['a', 'b', 'c'])
   frame.ix[:5, 'a'] = np.nan
   frame.ix[5:10, 'b'] = np.nan

   frame.corr()

   frame.corr(min_periods=12)


A related method ``corrwith`` is implemented on DataFrame to compute the
correlation between like-labeled Series contained in different DataFrame
objects.

.. ipython:: python

   index = ['a', 'b', 'c', 'd', 'e']
   columns = ['one', 'two', 'three', 'four']
   df1 = pd.DataFrame(np.random.randn(5, 4), index=index, columns=columns)
   df2 = pd.DataFrame(np.random.randn(4, 4), index=index[:4], columns=columns)
   df1.corrwith(df2)
   df2.corrwith(df1, axis=1)

.. _computation.ranking:

Data ranking
~~~~~~~~~~~~

The ``rank`` method produces a data ranking with ties being assigned the mean
of the ranks (by default) for the group:

.. ipython:: python

   s = pd.Series(np.random.np.random.randn(5), index=list('abcde'))
   s['d'] = s['b'] # so there's a tie
   s.rank()

``rank`` is also a DataFrame method and can rank either the rows (``axis=0``)
or the columns (``axis=1``). ``NaN`` values are excluded from the ranking.

.. ipython:: python

   df = pd.DataFrame(np.random.np.random.randn(10, 6))
   df[4] = df[2][:5] # some ties
   df
   df.rank(1)

``rank`` optionally takes a parameter ``ascending`` which by default is true;
when false, data is reverse-ranked, with larger values assigned a smaller rank.

``rank`` supports different tie-breaking methods, specified with the ``method``
parameter:

  - ``average`` : average rank of tied group
  - ``min`` : lowest rank in the group
  - ``max`` : highest rank in the group
  - ``first`` : ranks assigned in the order they appear in the array