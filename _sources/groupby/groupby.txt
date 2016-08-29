.. currentmodule:: pandas
.. _groupby:

*****************************
Group By: split-apply-combine
*****************************
.. toctree::
    :maxdepth: 1
    :caption: Contents
    :name: groubpy

    groupby1
    groupby2
    groupby3
    groupby4
    groupby5
    groupby6
    groupby7
    groupby8
    groupby9
    groupby10

.. ipython:: python

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows = 8
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')
   from collections import OrderedDict