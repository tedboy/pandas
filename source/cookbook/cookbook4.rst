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

.. _cookbook.missing_data:

Missing Data
------------

The :ref:`missing data<missing_data>` docs.

Fill forward a reversed timeseries

.. ipython:: python

   df = pd.DataFrame(np.random.randn(6,1), index=pd.date_range('2013-08-01', periods=6, freq='B'), columns=list('A'))
   df.ix[3,'A'] = np.nan
   df
   df.reindex(df.index[::-1]).ffill()

`cumsum reset at NaN values
<http://stackoverflow.com/questions/18196811/cumsum-reset-at-nan>`__

Replace
*******

`Using replace with backrefs
<http://stackoverflow.com/questions/16818871/extracting-value-and-creating-new-column-out-of-it>`__