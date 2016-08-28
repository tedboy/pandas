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

.. _cookbook.selection:

Selection
---------

DataFrames
**********

The :ref:`indexing <indexing>` docs.

`Using both row labels and value conditionals
<http://stackoverflow.com/questions/14725068/pandas-using-row-labels-in-boolean-indexing>`__

.. ipython:: python

   df = pd.DataFrame(
        {'AAA' : [4,5,6,7], 'BBB' : [10,20,30,40],'CCC' : [100,50,-30,-50]}); df

   df[(df.AAA <= 6) & (df.index.isin([0,2,4]))]

`Use loc for label-oriented slicing and iloc positional slicing
<https://github.com/pydata/pandas/issues/2904>`__

.. ipython:: python

   data = {'AAA' : [4,5,6,7], 'BBB' : [10,20,30,40],'CCC' : [100,50,-30,-50]}
   df = pd.DataFrame(data=data,index=['foo','bar','boo','kar']); df

There are 2 explicit slicing methods, with a third general case

1. Positional-oriented (Python slicing style : exclusive of end)
2. Label-oriented (Non-Python slicing style : inclusive of end)
3. General (Either slicing style : depends on if the slice contains labels or positions)

.. ipython:: python
   df.iloc[0:3] #Positional

   df.loc['bar':'kar'] #Label

   #Generic
   df.ix[0:3] #Same as .iloc[0:3]
   df.ix['bar':'kar'] #Same as .loc['bar':'kar']

Ambiguity arises when an index consists of integers with a non-zero start or non-unit increment.

.. ipython:: python

   df2 = pd.DataFrame(data=data,index=[1,2,3,4]); #Note index starts at 1.

   df2.iloc[1:3] #Position-oriented

   df2.loc[1:3] #Label-oriented

   df2.ix[1:3] #General, will mimic loc (label-oriented)
   df2.ix[0:3] #General, will mimic iloc (position-oriented), as loc[0:3] would raise a KeyError

`Using inverse operator (~) to take the complement of a mask
<http://stackoverflow.com/questions/14986510/picking-out-elements-based-on-complement-of-indices-in-python-pandas>`__

.. ipython:: python

   df = pd.DataFrame(
        {'AAA' : [4,5,6,7], 'BBB' : [10,20,30,40], 'CCC' : [100,50,-30,-50]}); df

   df[~((df.AAA <= 6) & (df.index.isin([0,2,4])))]

Panels
******

`Extend a panel frame by transposing, adding a new dimension, and transposing back to the original dimensions
<http://stackoverflow.com/questions/15364050/extending-a-pandas-panel-frame-along-the-minor-axis>`__

.. ipython:: python

   rng = pd.date_range('1/1/2013',periods=100,freq='D')
   data = np.random.randn(100, 4)
   cols = ['A','B','C','D']
   df1, df2, df3 = pd.DataFrame(data, rng, cols), pd.DataFrame(data, rng, cols), pd.DataFrame(data, rng, cols)

   pf = pd.Panel({'df1':df1,'df2':df2,'df3':df3});pf

   #Assignment using Transpose  (pandas < 0.15)
   pf = pf.transpose(2,0,1)
   pf['E'] = pd.DataFrame(data, rng, cols)
   pf = pf.transpose(1,2,0);pf

   #Direct assignment (pandas > 0.15)
   pf.loc[:,:,'F'] = pd.DataFrame(data, rng, cols);pf

`Mask a panel by using np.where and then reconstructing the panel with the new masked values
<http://stackoverflow.com/questions/14650341/boolean-mask-in-pandas-panel>`__

New Columns
***********

`Efficiently and dynamically creating new columns using applymap
<http://stackoverflow.com/questions/16575868/efficiently-creating-additional-columns-in-a-pandas-dataframe-using-map>`__

.. ipython:: python

   df = pd.DataFrame(
        {'AAA' : [1,2,1,3], 'BBB' : [1,1,2,2], 'CCC' : [2,1,3,1]}); df

   source_cols = df.columns # or some subset would work too.
   new_cols = [str(x) + "_cat" for x in source_cols]
   categories = {1 : 'Alpha', 2 : 'Beta', 3 : 'Charlie' }

   df[new_cols] = df[source_cols].applymap(categories.get);df

`Keep other columns when using min() with groupby
<http://stackoverflow.com/questions/23394476/keep-other-columns-when-using-min-with-groupby>`__

.. ipython:: python

   df = pd.DataFrame(
        {'AAA' : [1,1,1,2,2,2,3,3], 'BBB' : [2,1,3,4,5,1,2,3]}); df

Method 1 : idxmin() to get the index of the mins

.. ipython:: python

   df.loc[df.groupby("AAA")["BBB"].idxmin()]

Method 2 : sort then take first of each

.. ipython:: python

   df.sort_values(by="BBB").groupby("AAA", as_index=False).first()

Notice the same results, with the exception of the index.