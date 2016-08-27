.. _computation:

Computational tools
===================

.. toctree::
    :maxdepth: 2
    :caption: Contents
    :name: computation

    computation1
    computation2
    computation3
    computation4
    computation5

.. currentmodule:: pandas

.. ipython:: python

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')
   pd.options.display.max_rows=8