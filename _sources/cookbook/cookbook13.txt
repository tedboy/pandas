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

Creating Example Data
---------------------

To create a dataframe from every combination of some given values, like R's ``expand.grid()``
function, we can create a dict where the keys are column names and the values are lists
of the data values:

.. ipython:: python


   def expand_grid(data_dict):
      rows = itertools.product(*data_dict.values())
      return pd.DataFrame.from_records(rows, columns=data_dict.keys())

   df = expand_grid(
      {'height': [60, 70],
       'weight': [100, 140, 180],
       'sex': ['Male', 'Female']})
   df
