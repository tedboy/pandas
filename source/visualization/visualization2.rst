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

.. _visualization.other:

Other Plots
-----------

Plotting methods allow for a handful of plot styles other than the
default Line plot. These methods can be provided as the ``kind``
keyword argument to :meth:`~DataFrame.plot`.
These include:

* :ref:`'bar' <visualization.barplot>` or :ref:`'barh' <visualization.barplot>` for bar plots
* :ref:`'hist' <visualization.hist>` for histogram
* :ref:`'box' <visualization.box>` for boxplot
* :ref:`'kde' <visualization.kde>` or ``'density'`` for density plots
* :ref:`'area' <visualization.area_plot>` for area plots
* :ref:`'scatter' <visualization.scatter>` for scatter plots
* :ref:`'hexbin' <visualization.hexbin>` for hexagonal bin plots
* :ref:`'pie' <visualization.pie>` for pie plots

For example, a bar plot can be created the following way:

.. ipython:: python

   plt.figure();

   @savefig bar_plot_ex.png
   df.ix[5].plot(kind='bar'); plt.axhline(0, color='k')

.. versionadded:: 0.17.0

You can also create these other plots using the methods ``DataFrame.plot.<kind>`` instead of providing the ``kind`` keyword argument. This makes it easier to discover plot methods and the specific arguments they use:

.. ipython::
    :verbatim:

    In [14]: df = pd.DataFrame()

    In [15]: df.plot.<TAB>
    df.plot.area     df.plot.barh     df.plot.density  df.plot.hist     df.plot.line     df.plot.scatter
    df.plot.bar      df.plot.box      df.plot.hexbin   df.plot.kde      df.plot.pie

In addition to these ``kind`` s, there are  the :ref:`DataFrame.hist() <visualization.hist>`,
and :ref:`DataFrame.boxplot() <visualization.box>` methods, which use a separate interface.

Finally, there are several :ref:`plotting functions <visualization.tools>` in ``pandas.tools.plotting``
that take a :class:`Series` or :class:`DataFrame` as an argument. These
include

* :ref:`Scatter Matrix <visualization.scatter_matrix>`
* :ref:`Andrews Curves <visualization.andrews_curves>`
* :ref:`Parallel Coordinates <visualization.parallel_coordinates>`
* :ref:`Lag Plot <visualization.lag>`
* :ref:`Autocorrelation Plot <visualization.autocorrelation>`
* :ref:`Bootstrap Plot <visualization.bootstrap>`
* :ref:`RadViz <visualization.radviz>`

Plots may also be adorned with :ref:`errorbars <visualization.errorbars>`
or :ref:`tables <visualization.table>`.

.. _visualization.barplot:

Bar plots
~~~~~~~~~

For labeled, non-time series data, you may wish to produce a bar plot:

.. ipython:: python

   plt.figure();

   @savefig bar_plot_ex.png
   df.ix[5].plot.bar(); plt.axhline(0, color='k')

Calling a DataFrame's :meth:`plot.bar() <DataFrame.plot.bar>` method produces a multiple
bar plot:

.. ipython:: python
   :suppress:

   plt.close('all')
   plt.figure()
   np.random.seed(123456)

.. ipython:: python

   df2 = pd.DataFrame(np.random.rand(10, 4), columns=['a', 'b', 'c', 'd'])

   @savefig bar_plot_multi_ex.png
   df2.plot.bar();

To produce a stacked bar plot, pass ``stacked=True``:

.. ipython:: python
   :suppress:

   plt.close('all')
   plt.figure()

.. ipython:: python

   @savefig bar_plot_stacked_ex.png
   df2.plot.bar(stacked=True);

To get horizontal bar plots, use the ``barh`` method:

.. ipython:: python
   :suppress:

   plt.close('all')
   plt.figure()

.. ipython:: python

   @savefig barh_plot_stacked_ex.png
   df2.plot.barh(stacked=True);

.. _visualization.hist:

Histograms
~~~~~~~~~~

.. versionadded:: 0.15.0

Histogram can be drawn by using the :meth:`DataFrame.plot.hist` and :meth:`Series.plot.hist` methods.

.. ipython:: python

   df4 = pd.DataFrame({'a': np.random.randn(1000) + 1, 'b': np.random.randn(1000),
                       'c': np.random.randn(1000) - 1}, columns=['a', 'b', 'c'])

   plt.figure();

   @savefig hist_new.png
   df4.plot.hist(alpha=0.5)


.. ipython:: python
   :suppress:

   plt.close('all')

Histogram can be stacked by ``stacked=True``. Bin size can be changed by ``bins`` keyword.

.. ipython:: python

   plt.figure();

   @savefig hist_new_stacked.png
   df4.plot.hist(stacked=True, bins=20)

.. ipython:: python
   :suppress:

   plt.close('all')

You can pass other keywords supported by matplotlib ``hist``. For example, horizontal and cumulative histgram can be drawn by ``orientation='horizontal'`` and ``cumulative='True'``.

.. ipython:: python

   plt.figure();

   @savefig hist_new_kwargs.png
   df4['a'].plot.hist(orientation='horizontal', cumulative=True)

.. ipython:: python
   :suppress:

   plt.close('all')

See the :meth:`hist <matplotlib.axes.Axes.hist>` method and the
`matplotlib hist documentation <http://matplotlib.org/api/pyplot_api.html#matplotlib.pyplot.hist>`__ for more.


The existing interface ``DataFrame.hist`` to plot histogram still can be used.

.. ipython:: python

   plt.figure();

   @savefig hist_plot_ex.png
   df['A'].diff().hist()

.. ipython:: python
   :suppress:

   plt.close('all')

:meth:`DataFrame.hist` plots the histograms of the columns on multiple
subplots:

.. ipython:: python

   plt.figure()

   @savefig frame_hist_ex.png
   df.diff().hist(color='k', alpha=0.5, bins=50)


.. versionadded:: 0.10.0

The ``by`` keyword can be specified to plot grouped histograms:

.. ipython:: python
   :suppress:

   plt.close('all')
   plt.figure()
   np.random.seed(123456)

.. ipython:: python

   data = pd.Series(np.random.randn(1000))

   @savefig grouped_hist.png
   data.hist(by=np.random.randint(0, 4, 1000), figsize=(6, 4))


.. _visualization.box:

Box Plots
~~~~~~~~~

.. versionadded:: 0.15.0

Boxplot can be drawn calling :meth:`Series.plot.box` and :meth:`DataFrame.plot.box`,
or :meth:`DataFrame.boxplot` to visualize the distribution of values within each column.

For instance, here is a boxplot representing five trials of 10 observations of
a uniform random variable on [0,1).

.. ipython:: python
   :suppress:

   plt.close('all')
   np.random.seed(123456)

.. ipython:: python

   df = pd.DataFrame(np.random.rand(10, 5), columns=['A', 'B', 'C', 'D', 'E'])

   @savefig box_plot_new.png
   df.plot.box()

Boxplot can be colorized by passing ``color`` keyword. You can pass a ``dict``
whose keys are ``boxes``, ``whiskers``, ``medians`` and ``caps``.
If some keys are missing in the ``dict``, default colors are used
for the corresponding artists. Also, boxplot has ``sym`` keyword to specify fliers style.

When you pass other type of arguments via ``color`` keyword, it will be directly
passed to matplotlib for all the ``boxes``, ``whiskers``, ``medians`` and ``caps``
colorization.

The colors are applied to every boxes to be drawn. If you want
more complicated colorization, you can get each drawn artists by passing
:ref:`return_type <visualization.box.return>`.

.. ipython:: python

   color = dict(boxes='DarkGreen', whiskers='DarkOrange',
                medians='DarkBlue', caps='Gray')

   @savefig box_new_colorize.png
   df.plot.box(color=color, sym='r+')

.. ipython:: python
   :suppress:

   plt.close('all')

Also, you can pass other keywords supported by matplotlib ``boxplot``.
For example, horizontal and custom-positioned boxplot can be drawn by
``vert=False`` and ``positions`` keywords.

.. ipython:: python

   @savefig box_new_kwargs.png
   df.plot.box(vert=False, positions=[1, 4, 5, 6, 8])


See the :meth:`boxplot <matplotlib.axes.Axes.boxplot>` method and the
`matplotlib boxplot documentation <http://matplotlib.org/api/pyplot_api.html#matplotlib.pyplot.boxplot>`__ for more.


The existing interface ``DataFrame.boxplot`` to plot boxplot still can be used.

.. ipython:: python
   :suppress:

   plt.close('all')
   np.random.seed(123456)

.. ipython:: python
   :okwarning:

   df = pd.DataFrame(np.random.rand(10,5))
   plt.figure();

   @savefig box_plot_ex.png
   bp = df.boxplot()

You can create a stratified boxplot using the ``by`` keyword argument to create
groupings.  For instance,

.. ipython:: python
   :suppress:

   plt.close('all')
   np.random.seed(123456)

.. ipython:: python
   :okwarning:

   df = pd.DataFrame(np.random.rand(10,2), columns=['Col1', 'Col2'] )
   df['X'] = pd.Series(['A','A','A','A','A','B','B','B','B','B'])

   plt.figure();

   @savefig box_plot_ex2.png
   bp = df.boxplot(by='X')

You can also pass a subset of columns to plot, as well as group by multiple
columns:

.. ipython:: python
   :suppress:

   plt.close('all')
   np.random.seed(123456)

.. ipython:: python
   :okwarning:

   df = pd.DataFrame(np.random.rand(10,3), columns=['Col1', 'Col2', 'Col3'])
   df['X'] = pd.Series(['A','A','A','A','A','B','B','B','B','B'])
   df['Y'] = pd.Series(['A','B','A','B','A','B','A','B','A','B'])

   plt.figure();

   @savefig box_plot_ex3.png
   bp = df.boxplot(column=['Col1','Col2'], by=['X','Y'])

.. ipython:: python
   :suppress:

    plt.close('all')

.. _visualization.box.return:

Basically, plot functions return :class:`matplotlib Axes <matplotlib.axes.Axes>` as a return value.
In ``boxplot``, the return type can be changed by argument ``return_type``, and whether the subplots is enabled (``subplots=True`` in ``plot`` or ``by`` is specified in ``boxplot``).

When ``subplots=False`` / ``by`` is ``None``:

* if ``return_type`` is ``'dict'``, a dictionary containing the :class:`matplotlib Lines <matplotlib.lines.Line2D>` is returned. The keys are "boxes", "caps", "fliers", "medians", and "whiskers".
   This is the default of ``boxplot`` in historical reason.
   Note that ``plot.box()`` returns ``Axes`` by default same as other plots.
* if ``return_type`` is ``'axes'``, a :class:`matplotlib Axes <matplotlib.axes.Axes>` containing the boxplot is returned.
* if ``return_type`` is ``'both'`` a namedtuple containing the :class:`matplotlib Axes <matplotlib.axes.Axes>`
   and :class:`matplotlib Lines <matplotlib.lines.Line2D>` is returned

When ``subplots=True`` / ``by`` is some column of the DataFrame:

* A dict of ``return_type`` is returned, where the keys are the columns
  of the DataFrame. The plot has a facet for each column of
  the DataFrame, with a separate box for each value of ``by``.

Finally, when calling boxplot on a :class:`Groupby` object, a dict of ``return_type``
is returned, where the keys are the same as the Groupby object. The plot has a
facet for each key, with each facet containing a box for each column of the
DataFrame.

.. ipython:: python
   :okwarning:

   np.random.seed(1234)
   df_box = pd.DataFrame(np.random.randn(50, 2))
   df_box['g'] = np.random.choice(['A', 'B'], size=50)
   df_box.loc[df_box['g'] == 'B', 1] += 3

   @savefig boxplot_groupby.png
   bp = df_box.boxplot(by='g')

.. ipython:: python
   :suppress:

   plt.close('all')

Compare to:

.. ipython:: python
   :okwarning:

   @savefig groupby_boxplot_vis.png
   bp = df_box.groupby('g').boxplot()

.. ipython:: python
   :suppress:

   plt.close('all')

.. _visualization.area_plot:

Area Plot
~~~~~~~~~

.. versionadded:: 0.14

You can create area plots with :meth:`Series.plot.area` and :meth:`DataFrame.plot.area`.
Area plots are stacked by default. To produce stacked area plot, each column must be either all positive or all negative values.

When input data contains `NaN`, it will be automatically filled by 0. If you want to drop or fill by different values, use :func:`dataframe.dropna` or :func:`dataframe.fillna` before calling `plot`.

.. ipython:: python
   :suppress:

   np.random.seed(123456)
   plt.figure()

.. ipython:: python

   df = pd.DataFrame(np.random.rand(10, 4), columns=['a', 'b', 'c', 'd'])

   @savefig area_plot_stacked.png
   df.plot.area();

To produce an unstacked plot, pass ``stacked=False``. Alpha value is set to 0.5 unless otherwise specified:

.. ipython:: python
   :suppress:

   plt.close('all')
   plt.figure()

.. ipython:: python

   @savefig area_plot_unstacked.png
   df.plot.area(stacked=False);

.. _visualization.scatter:

Scatter Plot
~~~~~~~~~~~~

.. versionadded:: 0.13

Scatter plot can be drawn by using the :meth:`DataFrame.plot.scatter` method.
Scatter plot requires numeric columns for x and y axis.
These can be specified by ``x`` and ``y`` keywords each.

.. ipython:: python
   :suppress:

   np.random.seed(123456)
   plt.close('all')
   plt.figure()

.. ipython:: python

   df = pd.DataFrame(np.random.rand(50, 4), columns=['a', 'b', 'c', 'd'])

   @savefig scatter_plot.png
   df.plot.scatter(x='a', y='b');

To plot multiple column groups in a single axes, repeat ``plot`` method specifying target ``ax``.
It is recommended to specify ``color`` and ``label`` keywords to distinguish each groups.

.. ipython:: python

   ax = df.plot.scatter(x='a', y='b', color='DarkBlue', label='Group 1');
   @savefig scatter_plot_repeated.png
   df.plot.scatter(x='c', y='d', color='DarkGreen', label='Group 2', ax=ax);

.. ipython:: python
   :suppress:

   plt.close('all')

The keyword ``c`` may be given as the name of a column to provide colors for
each point:

.. ipython:: python

   @savefig scatter_plot_colored.png
   df.plot.scatter(x='a', y='b', c='c', s=50);


.. ipython:: python
   :suppress:

   plt.close('all')

You can pass other keywords supported by matplotlib ``scatter``.
Below example shows a bubble chart using a dataframe column values as bubble size.

.. ipython:: python

   @savefig scatter_plot_bubble.png
   df.plot.scatter(x='a', y='b', s=df['c']*200);

.. ipython:: python
   :suppress:

   plt.close('all')

See the :meth:`scatter <matplotlib.axes.Axes.scatter>` method and the
`matplotlib scatter documentation <http://matplotlib.org/api/pyplot_api.html#matplotlib.pyplot.scatter>`__ for more.

.. _visualization.hexbin:

Hexagonal Bin Plot
~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.14

You can create hexagonal bin plots with :meth:`DataFrame.plot.hexbin`.
Hexbin plots can be a useful alternative to scatter plots if your data are
too dense to plot each point individually.

.. ipython:: python
   :suppress:

   plt.figure()
   np.random.seed(123456)

.. ipython:: python

   df = pd.DataFrame(np.random.randn(1000, 2), columns=['a', 'b'])
   df['b'] = df['b'] + np.arange(1000)

   @savefig hexbin_plot.png
   df.plot.hexbin(x='a', y='b', gridsize=25)


A useful keyword argument is ``gridsize``; it controls the number of hexagons
in the x-direction, and defaults to 100. A larger ``gridsize`` means more, smaller
bins.

By default, a histogram of the counts around each ``(x, y)`` point is computed.
You can specify alternative aggregations by passing values to the ``C`` and
``reduce_C_function`` arguments. ``C`` specifies the value at each ``(x, y)`` point
and ``reduce_C_function`` is a function of one argument that reduces all the
values in a bin to a single number (e.g. ``mean``, ``max``, ``sum``, ``std``).  In this
example the positions are given by columns ``a`` and ``b``, while the value is
given by column ``z``. The bins are aggregated with numpy's ``max`` function.

.. ipython:: python
   :suppress:

   plt.close('all')
   plt.figure()
   np.random.seed(123456)

.. ipython:: python

   df = pd.DataFrame(np.random.randn(1000, 2), columns=['a', 'b'])
   df['b'] = df['b'] = df['b'] + np.arange(1000)
   df['z'] = np.random.uniform(0, 3, 1000)

   @savefig hexbin_plot_agg.png
   df.plot.hexbin(x='a', y='b', C='z', reduce_C_function=np.max,
           gridsize=25)

.. ipython:: python
   :suppress:

   plt.close('all')

See the :meth:`hexbin <matplotlib.axes.Axes.hexbin>` method and the
`matplotlib hexbin documentation <http://matplotlib.org/api/pyplot_api.html#matplotlib.pyplot.hexbin>`__ for more.

.. _visualization.pie:

Pie plot
~~~~~~~~

.. versionadded:: 0.14

You can create a pie plot with :meth:`DataFrame.plot.pie` or :meth:`Series.plot.pie`.
If your data includes any ``NaN``, they will be automatically filled with 0.
A ``ValueError`` will be raised if there are any negative values in your data.

.. ipython:: python
   :suppress:

   np.random.seed(123456)
   plt.figure()

.. ipython:: python

   series = pd.Series(3 * np.random.rand(4), index=['a', 'b', 'c', 'd'], name='series')

   @savefig series_pie_plot.png
   series.plot.pie(figsize=(6, 6))

.. ipython:: python
   :suppress:

   plt.close('all')

For pie plots it's best to use square figures, one's with an equal aspect ratio. You can create the
figure with equal width and height, or force the aspect ratio to be equal after plotting by
calling ``ax.set_aspect('equal')`` on the returned ``axes`` object.

Note that pie plot with :class:`DataFrame` requires that you either specify a target column by the ``y``
argument or ``subplots=True``. When ``y`` is specified, pie plot of selected column
will be drawn. If ``subplots=True`` is specified, pie plots for each column are drawn as subplots.
A legend will be drawn in each pie plots by default; specify ``legend=False`` to hide it.

.. ipython:: python
   :suppress:

   np.random.seed(123456)
   plt.figure()

.. ipython:: python

   df = pd.DataFrame(3 * np.random.rand(4, 2), index=['a', 'b', 'c', 'd'], columns=['x', 'y'])

   @savefig df_pie_plot.png
   df.plot.pie(subplots=True, figsize=(8, 4))

.. ipython:: python
   :suppress:

   plt.close('all')

You can use the ``labels`` and ``colors`` keywords to specify the labels and colors of each wedge.

.. warning::

   Most pandas plots use the the ``label`` and ``color`` arguments (note the lack of "s" on those).
   To be consistent with :func:`matplotlib.pyplot.pie` you must use ``labels`` and ``colors``.

If you want to hide wedge labels, specify ``labels=None``.
If ``fontsize`` is specified, the value will be applied to wedge labels.
Also, other keywords supported by :func:`matplotlib.pyplot.pie` can be used.


.. ipython:: python
   :suppress:

   plt.figure()

.. ipython:: python

   @savefig series_pie_plot_options.png
   series.plot.pie(labels=['AA', 'BB', 'CC', 'DD'], colors=['r', 'g', 'b', 'c'],
                   autopct='%.2f', fontsize=20, figsize=(6, 6))

If you pass values whose sum total is less than 1.0, matplotlib draws a semicircle.

.. ipython:: python
   :suppress:

   plt.close('all')
   plt.figure()

.. ipython:: python

   series = pd.Series([0.1] * 4, index=['a', 'b', 'c', 'd'], name='series2')

   @savefig series_pie_plot_semi.png
   series.plot.pie(figsize=(6, 6))

See the `matplotlib pie documentation <http://matplotlib.org/api/pyplot_api.html#matplotlib.pyplot.pie>`__ for more.

.. ipython:: python
    :suppress:

    plt.close('all')