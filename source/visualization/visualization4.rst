.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')

.. ipython:: python

   import matplotlib as mpl
   #mpl.rcParams['legend.fontsize']=20.0
   #print mpl.matplotlib_fname() # location of the rc file
   #print mpl.rcParams # current config
   print mpl.get_backend()

.. _visualization.tools:

Plotting Tools
--------------

These functions can be imported from ``pandas.tools.plotting``
and take a :class:`Series` or :class:`DataFrame` as an argument.

.. _visualization.scatter_matrix:

Scatter Matrix Plot
~~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.7.3

You can create a scatter plot matrix using the
``scatter_matrix`` method in ``pandas.tools.plotting``:

.. ipython:: python
   :suppress:

   np.random.seed(123456)

.. ipython:: python

   from pandas.tools.plotting import scatter_matrix
   df = pd.DataFrame(np.random.randn(1000, 4), columns=['a', 'b', 'c', 'd'])

   @savefig scatter_matrix_kde.png
   scatter_matrix(df, alpha=0.2, figsize=(6, 6), diagonal='kde')

.. ipython:: python
   :suppress:

   plt.close('all')

.. _visualization.kde:

Density Plot
~~~~~~~~~~~~

.. versionadded:: 0.8.0

You can create density plots using the :meth:`Series.plot.kde` and :meth:`DataFrame.plot.kde` methods.

.. ipython:: python
   :suppress:

   plt.figure()
   np.random.seed(123456)

.. ipython:: python

   ser = pd.Series(np.random.randn(1000))

   @savefig kde_plot.png
   ser.plot.kde()

.. ipython:: python
   :suppress:

   plt.close('all')

.. _visualization.andrews_curves:

Andrews Curves
~~~~~~~~~~~~~~

Andrews curves allow one to plot multivariate data as a large number
of curves that are created using the attributes of samples as coefficients
for Fourier series. By coloring these curves differently for each class
it is possible to visualize data clustering. Curves belonging to samples
of the same class will usually be closer together and form larger structures.

**Note**: The "Iris" dataset is available `here <https://raw.github.com/pydata/pandas/master/pandas/tests/data/iris.csv>`__.

.. ipython:: python

   from pandas.tools.plotting import andrews_curves

   url = 'https://raw.githubusercontent.com/pydata/pandas/master/doc/data/iris.data'
   data = pd.read_csv(url)

   plt.figure()

   @savefig andrews_curves.png
   andrews_curves(data, 'Name')

.. _visualization.parallel_coordinates:

Parallel Coordinates
~~~~~~~~~~~~~~~~~~~~

Parallel coordinates is a plotting technique for plotting multivariate data.
It allows one to see clusters in data and to estimate other statistics visually.
Using parallel coordinates points are represented as connected line segments.
Each vertical line represents one attribute. One set of connected line segments
represents one data point. Points that tend to cluster will appear closer together.

.. ipython:: python

   from pandas.tools.plotting import parallel_coordinates

   data = pd.read_csv(url)

   plt.figure()

   @savefig parallel_coordinates.png
   parallel_coordinates(data, 'Name')

.. ipython:: python
   :suppress:

   plt.close('all')

.. _visualization.lag:

Lag Plot
~~~~~~~~

Lag plots are used to check if a data set or time series is random. Random
data should not exhibit any structure in the lag plot. Non-random structure
implies that the underlying data are not random.

.. ipython:: python
   :suppress:

   np.random.seed(123456)

.. ipython:: python

   from pandas.tools.plotting import lag_plot

   plt.figure()

   data = pd.Series(0.1 * np.random.rand(1000) +
       0.9 * np.sin(np.linspace(-99 * np.pi, 99 * np.pi, num=1000)))

   @savefig lag_plot.png
   lag_plot(data)

.. ipython:: python
   :suppress:

   plt.close('all')

.. _visualization.autocorrelation:

Autocorrelation Plot
~~~~~~~~~~~~~~~~~~~~

Autocorrelation plots are often used for checking randomness in time series.
This is done by computing autocorrelations for data values at varying time lags.
If time series is random, such autocorrelations should be near zero for any and
all time-lag separations. If time series is non-random then one or more of the
autocorrelations will be significantly non-zero. The horizontal lines displayed
in the plot correspond to 95% and 99% confidence bands. The dashed line is 99%
confidence band.

.. ipython:: python
   :suppress:

   np.random.seed(123456)

.. ipython:: python

   from pandas.tools.plotting import autocorrelation_plot

   plt.figure()

   data = pd.Series(0.7 * np.random.rand(1000) +
      0.3 * np.sin(np.linspace(-9 * np.pi, 9 * np.pi, num=1000)))

   @savefig autocorrelation_plot.png
   autocorrelation_plot(data)

.. ipython:: python
   :suppress:

   plt.close('all')

.. _visualization.bootstrap:

Bootstrap Plot
~~~~~~~~~~~~~~

Bootstrap plots are used to visually assess the uncertainty of a statistic, such
as mean, median, midrange, etc. A random subset of a specified size is selected
from a data set, the statistic in question is computed for this subset and the
process is repeated a specified number of times. Resulting plots and histograms
are what constitutes the bootstrap plot.

.. ipython:: python
   :suppress:

   np.random.seed(123456)

.. ipython:: python

   from pandas.tools.plotting import bootstrap_plot

   data = pd.Series(np.random.rand(1000))

   @savefig bootstrap_plot.png
   bootstrap_plot(data, size=50, samples=500, color='grey')

.. ipython:: python
   :suppress:

    plt.close('all')

.. _visualization.radviz:

RadViz
~~~~~~

RadViz is a way of visualizing multi-variate data. It is based on a simple
spring tension minimization algorithm. Basically you set up a bunch of points in
a plane. In our case they are equally spaced on a unit circle. Each point
represents a single attribute. You then pretend that each sample in the data set
is attached to each of these points by a spring, the stiffness of which is
proportional to the numerical value of that attribute (they are normalized to
unit interval). The point in the plane, where our sample settles to (where the
forces acting on our sample are at an equilibrium) is where a dot representing
our sample will be drawn. Depending on which class that sample belongs it will
be colored differently.

**Note**: The "Iris" dataset is available `here <https://raw.github.com/pydata/pandas/master/pandas/tests/data/iris.csv>`__.

.. ipython:: python

   from pandas.tools.plotting import radviz

   data = pd.read_csv(url)

   plt.figure()

   @savefig radviz.png
   radviz(data, 'Name')

.. ipython:: python
   :suppress:

   plt.close('all')