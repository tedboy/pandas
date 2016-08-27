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

Timedeltas
----------

The :ref:`Timedeltas <timedeltas.timedeltas>` docs.

`Using timedeltas
<http://github.com/pydata/pandas/pull/2899>`__

.. ipython:: python

   s  = pd.Series(pd.date_range('2012-1-1', periods=3, freq='D'))

   s - s.max()

   s.max() - s

   s - datetime.datetime(2011,1,1,3,5)

   s + datetime.timedelta(minutes=5)

   datetime.datetime(2011,1,1,3,5) - s

   datetime.timedelta(minutes=5) + s

`Adding and subtracting deltas and dates
<http://stackoverflow.com/questions/16385785/add-days-to-dates-in-dataframe>`__

.. ipython:: python

   deltas = pd.Series([ datetime.timedelta(days=i) for i in range(3) ])

   df = pd.DataFrame(dict(A = s, B = deltas)); df

   df['New Dates'] = df['A'] + df['B'];

   df['Delta'] = df['A'] - df['New Dates']; df

   df.dtypes

`Another example
<http://stackoverflow.com/questions/15683588/iterating-through-a-pandas-dataframe>`__

Values can be set to NaT using np.nan, similar to datetime

.. ipython:: python

   y = s - s.shift(); y

   y[1] = np.nan; y