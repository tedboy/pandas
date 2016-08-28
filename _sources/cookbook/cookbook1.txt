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

.. _cookbook.idioms:

Idioms
------


These are some neat pandas ``idioms``

`if-then/if-then-else on one column, and assignment to another one or more columns:
<http://stackoverflow.com/questions/17128302/python-pandas-idiom-for-if-then-else>`__

.. ipython:: python

   df = pd.DataFrame(
        {'AAA' : [4,5,6,7], 'BBB' : [10,20,30,40],'CCC' : [100,50,-30,-50]}); df



if-then...
**********

An if-then on one column

.. ipython:: python

   df.ix[df.AAA >= 5,'BBB'] = -1; df

An if-then with assignment to 2 columns:

.. ipython:: python

   df.ix[df.AAA >= 5,['BBB','CCC']] = 555; df

Add another line with different logic, to do the -else

.. ipython:: python

   df.ix[df.AAA < 5,['BBB','CCC']] = 2000; df

Or use pandas where after you've set up a mask

.. ipython:: python

   df_mask = pd.DataFrame({'AAA' : [True] * 4, 'BBB' : [False] * 4,'CCC' : [True,False] * 2})
   df.where(df_mask,-1000)

`if-then-else using numpy's where()
<http://stackoverflow.com/questions/19913659/pandas-conditional-creation-of-a-series-dataframe-column>`__

.. ipython:: python

   df = pd.DataFrame(
        {'AAA' : [4,5,6,7], 'BBB' : [10,20,30,40],'CCC' : [100,50,-30,-50]}); df

   df['logic'] = np.where(df['AAA'] > 5,'high','low'); df

Splitting
*********

`Split a frame with a boolean criterion
<http://stackoverflow.com/questions/14957116/how-to-split-a-dataframe-according-to-a-boolean-criterion>`__

.. ipython:: python

   df = pd.DataFrame(
        {'AAA' : [4,5,6,7], 'BBB' : [10,20,30,40],'CCC' : [100,50,-30,-50]}); df

   dflow = df[df.AAA <= 5]
   dfhigh = df[df.AAA > 5]

   dflow; dfhigh

Building Criteria
*****************

`Select with multi-column criteria
<http://stackoverflow.com/questions/15315452/selecting-with-complex-criteria-from-pandas-dataframe>`__

.. ipython:: python

   df = pd.DataFrame(
        {'AAA' : [4,5,6,7], 'BBB' : [10,20,30,40],'CCC' : [100,50,-30,-50]}); df

...and (without assignment returns a Series)

.. ipython:: python

   newseries = df.loc[(df['BBB'] < 25) & (df['CCC'] >= -40), 'AAA']; newseries

...or (without assignment returns a Series)

.. ipython:: python

   newseries = df.loc[(df['BBB'] > 25) | (df['CCC'] >= -40), 'AAA']; newseries;

...or (with assignment modifies the DataFrame.)

.. ipython:: python

   df.loc[(df['BBB'] > 25) | (df['CCC'] >= 75), 'AAA'] = 0.1; df

`Select rows with data closest to certain value using argsort
<http://stackoverflow.com/questions/17758023/return-rows-in-a-dataframe-closest-to-a-user-defined-number>`__

.. ipython:: python

   df = pd.DataFrame(
        {'AAA' : [4,5,6,7], 'BBB' : [10,20,30,40],'CCC' : [100,50,-30,-50]}); df

   aValue = 43.0
   df.ix[(df.CCC-aValue).abs().argsort()]

`Dynamically reduce a list of criteria using a binary operators
<http://stackoverflow.com/questions/21058254/pandas-boolean-operation-in-a-python-list/21058331>`__

.. ipython:: python

   df = pd.DataFrame(
        {'AAA' : [4,5,6,7], 'BBB' : [10,20,30,40],'CCC' : [100,50,-30,-50]}); df

   Crit1 = df.AAA <= 5.5
   Crit2 = df.BBB == 10.0
   Crit3 = df.CCC > -40.0

One could hard code:

.. ipython:: python

   AllCrit = Crit1 & Crit2 & Crit3

...Or it can be done with a list of dynamically built criteria

.. ipython:: python

   CritList = [Crit1,Crit2,Crit3]
   AllCrit = functools.reduce(lambda x,y: x & y, CritList)

   df[AllCrit]        