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

   ts = pd.Series(np.random.randn(1000), index=pd.date_range('1/1/2000', periods=1000))
   ts = ts.cumsum()

   from pandas.tools.plotting import parallel_coordinates
   from pandas.tools.plotting import andrews_curves
   url = 'https://raw.githubusercontent.com/pydata/pandas/master/doc/data/iris.data'
   data = pd.read_csv(url)

.. _visualization.formatting:

Plot Formatting
---------------

Most plotting methods have a set of keyword arguments that control the
layout and formatting of the returned plot:

.. ipython:: python

   @savefig series_plot_basic2.png
   plt.figure(); ts.plot(style='k--', label='Series');

.. ipython:: python
   :suppress:

   plt.close('all')

For each kind of plot (e.g. `line`, `bar`, `scatter`) any additional arguments
keywords are passed along to the corresponding matplotlib function
(:meth:`ax.plot() <matplotlib.axes.Axes.plot>`,
:meth:`ax.bar() <matplotlib.axes.Axes.bar>`,
:meth:`ax.scatter() <matplotlib.axes.Axes.scatter>`). These can be used
to control additional styling, beyond what pandas provides.

Controlling the Legend
~~~~~~~~~~~~~~~~~~~~~~

You may set the ``legend`` argument to ``False`` to hide the legend, which is
shown by default.

.. ipython:: python
   :suppress:

   np.random.seed(123456)

.. ipython:: python

   df = pd.DataFrame(np.random.randn(1000, 4), index=ts.index, columns=list('ABCD'))
   df = df.cumsum()

   @savefig frame_plot_basic_noleg.png
   df.plot(legend=False)

.. ipython:: python
   :suppress:

   plt.close('all')

Scales
~~~~~~

You may pass ``logy`` to get a log-scale Y axis.

.. ipython:: python
   :suppress:

   plt.figure()
   np.random.seed(123456)

.. ipython:: python

   ts = pd.Series(np.random.randn(1000), index=pd.date_range('1/1/2000', periods=1000))
   ts = np.exp(ts.cumsum())

   @savefig series_plot_logy.png
   ts.plot(logy=True)

.. ipython:: python
   :suppress:

   plt.close('all')

See also the ``logx`` and ``loglog`` keyword arguments.

Plotting on a Secondary Y-axis
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To plot data on a secondary y-axis, use the ``secondary_y`` keyword:

.. ipython:: python
   :suppress:

   plt.figure()

.. ipython:: python

   df.A.plot()

   @savefig series_plot_secondary_y.png
   df.B.plot(secondary_y=True, style='g')

.. ipython:: python
   :suppress:

   plt.close('all')

To plot some columns in a DataFrame, give the column names to the ``secondary_y``
keyword:

.. ipython:: python

   plt.figure()
   ax = df.plot(secondary_y=['A', 'B'])
   ax.set_ylabel('CD scale')
   @savefig frame_plot_secondary_y.png
   ax.right_ax.set_ylabel('AB scale')

.. ipython:: python
   :suppress:

   plt.close('all')

Note that the columns plotted on the secondary y-axis is automatically marked
with "(right)" in the legend. To turn off the automatic marking, use the
``mark_right=False`` keyword:

.. ipython:: python

   plt.figure()

   @savefig frame_plot_secondary_y_no_right.png
   df.plot(secondary_y=['A', 'B'], mark_right=False)

.. ipython:: python
   :suppress:

   plt.close('all')

Suppressing Tick Resolution Adjustment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pandas includes automatic tick resolution adjustment for regular frequency
time-series data. For limited cases where pandas cannot infer the frequency
information (e.g., in an externally created ``twinx``), you can choose to
suppress this behavior for alignment purposes.

Here is the default behavior, notice how the x-axis tick labelling is performed:

.. ipython:: python

   plt.figure()

   @savefig ser_plot_suppress.png
   df.A.plot()

.. ipython:: python
   :suppress:

   plt.close('all')

Using the ``x_compat`` parameter, you can suppress this behavior:

.. ipython:: python

   plt.figure()

   @savefig ser_plot_suppress_parm.png
   df.A.plot(x_compat=True)

.. ipython:: python
   :suppress:

   plt.close('all')

If you have more than one plot that needs to be suppressed, the ``use`` method
in ``pandas.plot_params`` can be used in a `with statement`:

.. ipython:: python

   plt.figure()

   @savefig ser_plot_suppress_context.png
   with pd.plot_params.use('x_compat', True):
       df.A.plot(color='r')
       df.B.plot(color='g')
       df.C.plot(color='b')

.. ipython:: python
   :suppress:

   plt.close('all')

Subplots
~~~~~~~~

Each Series in a DataFrame can be plotted on a different axis
with the ``subplots`` keyword:

.. ipython:: python

   @savefig frame_plot_subplots.png
   df.plot(subplots=True, figsize=(6, 6));

.. ipython:: python
   :suppress:

   plt.close('all')

Using Layout and Targeting Multiple Axes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The layout of subplots can be specified by ``layout`` keyword. It can accept
``(rows, columns)``. The ``layout`` keyword can be used in
``hist`` and ``boxplot`` also. If input is invalid, ``ValueError`` will be raised.

The number of axes which can be contained by rows x columns specified by ``layout`` must be
larger than the number of required subplots. If layout can contain more axes than required,
blank axes are not drawn. Similar to a numpy array's ``reshape`` method, you
can use ``-1`` for one dimension to automatically calculate the number of rows
or columns needed, given the other.

.. ipython:: python

   @savefig frame_plot_subplots_layout.png
   df.plot(subplots=True, layout=(2, 3), figsize=(6, 6), sharex=False);

.. ipython:: python
   :suppress:

   plt.close('all')

The above example is identical to using

.. ipython:: python

   df.plot(subplots=True, layout=(2, -1), figsize=(6, 6), sharex=False);

.. ipython:: python
   :suppress:

   plt.close('all')

The required number of columns (3) is inferred from the number of series to plot
and the given number of rows (2).

Also, you can pass multiple axes created beforehand as list-like via ``ax`` keyword.
This allows to use more complicated layout.
The passed axes must be the same number as the subplots being drawn.

When multiple axes are passed via ``ax`` keyword, ``layout``, ``sharex`` and ``sharey`` keywords
don't affect to the output. You should explicitly pass ``sharex=False`` and ``sharey=False``,
otherwise you will see a warning.

.. ipython:: python

   fig, axes = plt.subplots(4, 4, figsize=(6, 6));
   plt.subplots_adjust(wspace=0.5, hspace=0.5);
   target1 = [axes[0][0], axes[1][1], axes[2][2], axes[3][3]]
   target2 = [axes[3][0], axes[2][1], axes[1][2], axes[0][3]]

   df.plot(subplots=True, ax=target1, legend=False, sharex=False, sharey=False);
   @savefig frame_plot_subplots_multi_ax.png
   (-df).plot(subplots=True, ax=target2, legend=False, sharex=False, sharey=False);

.. ipython:: python
   :suppress:

   plt.close('all')

Another option is passing an ``ax`` argument to :meth:`Series.plot` to plot on a particular axis:

.. ipython:: python
   :suppress:

   np.random.seed(123456)
   ts = pd.Series(np.random.randn(1000), index=pd.date_range('1/1/2000', periods=1000))
   ts = ts.cumsum()

   df = pd.DataFrame(np.random.randn(1000, 4), index=ts.index, columns=list('ABCD'))
   df = df.cumsum()

.. ipython:: python
   :suppress:

   plt.close('all')

.. ipython:: python

   fig, axes = plt.subplots(nrows=2, ncols=2)
   df['A'].plot(ax=axes[0,0]); axes[0,0].set_title('A');
   df['B'].plot(ax=axes[0,1]); axes[0,1].set_title('B');
   df['C'].plot(ax=axes[1,0]); axes[1,0].set_title('C');

   @savefig series_plot_multi.png
   df['D'].plot(ax=axes[1,1]); axes[1,1].set_title('D');

.. ipython:: python
   :suppress:

    plt.close('all')

.. _visualization.errorbars:

Plotting With Error Bars
~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.14

Plotting with error bars is now supported in the :meth:`DataFrame.plot` and :meth:`Series.plot`

Horizontal and vertical errorbars can be supplied to the ``xerr`` and ``yerr`` keyword arguments to :meth:`~DataFrame.plot()`. The error values can be specified using a variety of formats.

- As a :class:`DataFrame` or ``dict`` of errors with column names matching the ``columns`` attribute of the plotting :class:`DataFrame` or matching the ``name`` attribute of the :class:`Series`
- As a ``str`` indicating which of the columns of plotting :class:`DataFrame` contain the error values
- As raw values (``list``, ``tuple``, or ``np.ndarray``). Must be the same length as the plotting :class:`DataFrame`/:class:`Series`

Asymmetrical error bars are also supported, however raw error values must be provided in this case. For a ``M`` length :class:`Series`, a ``Mx2`` array should be provided indicating lower and upper (or left and right) errors. For a ``MxN`` :class:`DataFrame`, asymmetrical errors should be in a ``Mx2xN`` array.

Here is an example of one way to easily plot group means with standard deviations from the raw data.

.. ipython:: python

   # Generate the data
   ix3 = pd.MultiIndex.from_arrays([['a', 'a', 'a', 'a', 'b', 'b', 'b', 'b'], ['foo', 'foo', 'bar', 'bar', 'foo', 'foo', 'bar', 'bar']], names=['letter', 'word'])
   df3 = pd.DataFrame({'data1': [3, 2, 4, 3, 2, 4, 3, 2], 'data2': [6, 5, 7, 5, 4, 5, 6, 5]}, index=ix3)

   # Group by index labels and take the means and standard deviations for each group
   gp3 = df3.groupby(level=('letter', 'word'))
   means = gp3.mean()
   errors = gp3.std()
   means
   errors

   # Plot
   fig, ax = plt.subplots()
   @savefig errorbar_example.png
   means.plot.bar(yerr=errors, ax=ax)

.. ipython:: python
   :suppress:

   plt.close('all')

.. _visualization.table:

Plotting Tables
~~~~~~~~~~~~~~~

.. versionadded:: 0.14

Plotting with matplotlib table is now supported in  :meth:`DataFrame.plot` and :meth:`Series.plot` with a ``table`` keyword. The ``table`` keyword can accept ``bool``, :class:`DataFrame` or :class:`Series`. The simple way to draw a table is to specify ``table=True``. Data will be transposed to meet matplotlib's default layout.

.. ipython:: python
   :suppress:

   np.random.seed(123456)

.. ipython:: python

   fig, ax = plt.subplots(1, 1)
   df = pd.DataFrame(np.random.rand(5, 3), columns=['a', 'b', 'c'])
   ax.get_xaxis().set_visible(False)   # Hide Ticks

   @savefig line_plot_table_true.png
   df.plot(table=True, ax=ax)

.. ipython:: python
   :suppress:

   plt.close('all')

Also, you can pass different :class:`DataFrame` or :class:`Series` for ``table`` keyword. The data will be drawn as displayed in print method (not transposed automatically). If required, it should be transposed manually as below example.

.. ipython:: python

   fig, ax = plt.subplots(1, 1)
   ax.get_xaxis().set_visible(False)   # Hide Ticks
   @savefig line_plot_table_data.png
   df.plot(table=np.round(df.T, 2), ax=ax)

.. ipython:: python
   :suppress:

   plt.close('all')

Finally, there is a helper function ``pandas.tools.plotting.table`` to create a table from :class:`DataFrame` and :class:`Series`, and add it to an ``matplotlib.Axes``. This function can accept keywords which matplotlib table has.

.. ipython:: python

   from pandas.tools.plotting import table
   fig, ax = plt.subplots(1, 1)

   table(ax, np.round(df.describe(), 2),
         loc='upper right', colWidths=[0.2, 0.2, 0.2])

   @savefig line_plot_table_describe.png
   df.plot(ax=ax, ylim=(0, 2), legend=None)

.. ipython:: python
   :suppress:

   plt.close('all')

**Note**: You can get table instances on the axes using ``axes.tables`` property for further decorations. See the `matplotlib table documentation <http://matplotlib.org/api/axes_api.html#matplotlib.axes.Axes.table>`__ for more.

.. _visualization.colormaps:

Colormaps
~~~~~~~~~

A potential issue when plotting a large number of columns is that it can be
difficult to distinguish some series due to repetition in the default colors. To
remedy this, DataFrame plotting supports the use of the ``colormap=`` argument,
which accepts either a Matplotlib `colormap <http://matplotlib.org/api/cm_api.html>`__
or a string that is a name of a colormap registered with Matplotlib. A
visualization of the default matplotlib colormaps is available `here
<http://wiki.scipy.org/Cookbook/Matplotlib/Show_colormaps>`__.

As matplotlib does not directly support colormaps for line-based plots, the
colors are selected based on an even spacing determined by the number of columns
in the DataFrame. There is no consideration made for background color, so some
colormaps will produce lines that are not easily visible.

To use the cubehelix colormap, we can simply pass ``'cubehelix'`` to ``colormap=``

.. ipython:: python
   :suppress:

   np.random.seed(123456)

.. ipython:: python

   df = pd.DataFrame(np.random.randn(1000, 10), index=ts.index)
   df = df.cumsum()

   plt.figure()

   @savefig cubehelix.png
   df.plot(colormap='cubehelix')

.. ipython:: python
   :suppress:

   plt.close('all')

or we can pass the colormap itself

.. ipython:: python

   from matplotlib import cm

   plt.figure()

   @savefig cubehelix_cm.png
   df.plot(colormap=cm.cubehelix)

.. ipython:: python
   :suppress:

   plt.close('all')

Colormaps can also be used other plot types, like bar charts:

.. ipython:: python
   :suppress:

   np.random.seed(123456)

.. ipython:: python

   dd = pd.DataFrame(np.random.randn(10, 10)).applymap(abs)
   dd = dd.cumsum()

   plt.figure()

   @savefig greens.png
   dd.plot.bar(colormap='Greens')

.. ipython:: python
   :suppress:

   plt.close('all')

Parallel coordinates charts:

.. ipython:: python

   plt.figure()

   @savefig parallel_gist_rainbow.png
   parallel_coordinates(data, 'Name', colormap='gist_rainbow')

.. ipython:: python
   :suppress:

   plt.close('all')

Andrews curves charts:

.. ipython:: python

   plt.figure()

   @savefig andrews_curve_winter.png
   andrews_curves(data, 'Name', colormap='winter')

.. ipython:: python
   :suppress:

   plt.close('all')

