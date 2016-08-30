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

.. _visualization.missing_data:

Plotting with Missing Data
--------------------------

Pandas tries to be pragmatic about plotting DataFrames or Series
that contain missing data. Missing values are dropped, left out, or filled
depending on the plot type.

+----------------+--------------------------------------+
| Plot Type      | NaN Handling                         |
+================+======================================+
| Line           | Leave gaps at NaNs                   |
+----------------+--------------------------------------+
| Line (stacked) | Fill 0's                             |
+----------------+--------------------------------------+
| Bar            | Fill 0's                             |
+----------------+--------------------------------------+
| Scatter        | Drop NaNs                            |
+----------------+--------------------------------------+
| Histogram      | Drop NaNs (column-wise)              |
+----------------+--------------------------------------+
| Box            | Drop NaNs (column-wise)              |
+----------------+--------------------------------------+
| Area           | Fill 0's                             |
+----------------+--------------------------------------+
| KDE            | Drop NaNs (column-wise)              |
+----------------+--------------------------------------+
| Hexbin         | Drop NaNs                            |
+----------------+--------------------------------------+
| Pie            | Fill 0's                             |
+----------------+--------------------------------------+

If any of these defaults are not what you want, or if you want to be
explicit about how missing values are handled, consider using
:meth:`~pandas.DataFrame.fillna` or :meth:`~pandas.DataFrame.dropna`
before plotting.