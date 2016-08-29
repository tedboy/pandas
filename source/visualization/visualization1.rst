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

.. _visualization.basic:

Basic Plotting: ``plot``
------------------------

See the :ref:`cookbook<cookbook.plotting>` for some advanced strategies

The ``plot`` method on Series and DataFrame is just a simple wrapper around
:meth:`plt.plot() <matplotlib.axes.Axes.plot>`:

.. ipython:: python
   :suppress:

   np.random.seed(123456)

.. ipython:: python

   ts = pd.Series(np.random.randn(1000), index=pd.date_range('1/1/2000', periods=1000))
   ts = ts.cumsum()

   @savefig series_plot_basic.png
   ts.plot()

If the index consists of dates, it calls :meth:`gcf().autofmt_xdate() <matplotlib.figure.Figure.autofmt_xdate>`
to try to format the x-axis nicely as per above.

On DataFrame, :meth:`~DataFrame.plot` is a convenience to plot all of the columns with labels:

.. ipython:: python
   :suppress:

   plt.close('all')
   np.random.seed(123456)

.. ipython:: python

   df = pd.DataFrame(np.random.randn(1000, 4), index=ts.index, columns=list('ABCD'))
   df = df.cumsum()

   @savefig frame_plot_basic.png
   plt.figure(); df.plot();

You can plot one column versus another using the `x` and `y` keywords in
:meth:`~DataFrame.plot`:

.. ipython:: python
   :suppress:

   plt.close('all')
   plt.figure()
   np.random.seed(123456)

.. ipython:: python

   df3 = pd.DataFrame(np.random.randn(1000, 2), columns=['B', 'C']).cumsum()
   df3['A'] = pd.Series(list(range(len(df))))

   @savefig df_plot_xy.png
   df3.plot(x='A', y='B')

.. note::

   For more formatting and styling options, see :ref:`below <visualization.formatting>`.

.. ipython:: python
    :suppress:

    plt.close('all')