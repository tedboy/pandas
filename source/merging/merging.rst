.. _merging:

****************************
Merge, join, and concatenate
****************************

pandas provides various facilities for easily combining together Series,
DataFrame, and Panel objects with various kinds of set logic for the indexes
and relational algebra functionality in the case of join / merge-type
operations.

.. toctree::
    :maxdepth: 1
    :caption: Contents
    :name: merging

    merging1
    merging2
    merging3

.. currentmodule:: pandas

.. ipython:: python

   import numpy as np
   np.random.seed(123456)
   import pandas as pd
   pd.options.display.max_rows=15
   randn = np.random.randn
   np.set_printoptions(precision=4, suppress=True)

   import matplotlib.pyplot as plt
   plt.close('all')
   import pandas.util.doctools as doctools
   p = doctools.TablePlotter()
