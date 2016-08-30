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

.. _rplot:


Trellis plotting interface
--------------------------

.. warning::

    The ``rplot`` trellis plotting interface has been **removed**. Please use
    external packages like `seaborn <https://github.com/mwaskom/seaborn>`_ for
    similar but more refined functionality and refer to our 0.18.1 documentation
    `here <http://pandas.pydata.org/pandas-docs/version/0.18.1/visualization.html>`__
    for how to convert to using it.
