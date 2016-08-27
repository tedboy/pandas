.. ipython:: python
   :suppress:
   
   import pandas as pd
   import numpy as np

   import random
   import os
   import itertools
   import functools
   import datetime

   np.random.seed(123456)
   pd.options.display.max_rows=8
   import matplotlib
   matplotlib.style.use('ggplot')
   np.set_printoptions(precision=4, suppress=True)

.. _cookbook.plotting:

Plotting
--------

The :ref:`Plotting <visualization>` docs.

`Make Matplotlib look like R
<http://stackoverflow.com/questions/14349055/making-matplotlib-graphs-look-like-r-by-default>`__

`Setting x-axis major and minor labels
<http://stackoverflow.com/questions/12945971/pandas-timeseries-plot-setting-x-axis-major-and-minor-ticks-and-labels>`__

`Plotting multiple charts in an ipython notebook
<http://stackoverflow.com/questions/16392921/make-more-than-one-chart-in-same-ipython-notebook-cell>`__

`Creating a multi-line plot
<http://stackoverflow.com/questions/16568964/make-a-multiline-plot-from-csv-file-in-matplotlib>`__

`Plotting a heatmap
<http://stackoverflow.com/questions/17050202/plot-timeseries-of-histograms-in-python>`__

`Annotate a time-series plot
<http://stackoverflow.com/questions/11067368/annotate-time-series-plot-in-matplotlib>`__

`Annotate a time-series plot #2
<http://stackoverflow.com/questions/17891493/annotating-points-from-a-pandas-dataframe-in-matplotlib-plot>`__

`Generate Embedded plots in excel files using Pandas, Vincent and xlsxwriter
<http://pandas-xlsxwriter-charts.readthedocs.org/en/latest/introduction.html>`__

`Boxplot for each quartile of a stratifying variable
<http://stackoverflow.com/questions/23232989/boxplot-stratified-by-column-in-python-pandas>`__

.. ipython:: python

   df = pd.DataFrame(
        {u'stratifying_var': np.random.uniform(0, 100, 20),
         u'price': np.random.normal(100, 5, 20)})

   df[u'quartiles'] = pd.qcut(
       df[u'stratifying_var'],
       4,
       labels=[u'0-25%', u'25-50%', u'50-75%', u'75-100%'])

   @savefig quartile_boxplot.png
   df.boxplot(column=u'price', by=u'quartiles')