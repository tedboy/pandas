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

.. _cookbook.grouping:

Grouping
--------

The :ref:`grouping <groupby>` docs.

`Basic grouping with apply
<http://stackoverflow.com/questions/15322632/python-pandas-df-groupy-agg-column-reference-in-agg>`__

Unlike agg, apply's callable is passed a sub-DataFrame which gives you access to all the columns

.. ipython:: python

   df = pd.DataFrame({'animal': 'cat dog cat fish dog cat cat'.split(),
                      'size': list('SSMMMLL'),
                      'weight': [8, 10, 11, 1, 20, 12, 12],
                      'adult' : [False] * 5 + [True] * 2}); df

   #List the size of the animals with the highest weight.
   df.groupby('animal').apply(lambda subf: subf['size'][subf['weight'].idxmax()])

`Using get_group
<http://stackoverflow.com/questions/14734533/how-to-access-pandas-groupby-dataframe-by-key>`__

.. ipython:: python

   gb = df.groupby(['animal'])

   gb.get_group('cat')

`Apply to different items in a group
<http://stackoverflow.com/questions/15262134/apply-different-functions-to-different-items-in-group-object-python-pandas>`__

.. ipython:: python

   def GrowUp(x):
      avg_weight =  sum(x[x['size'] == 'S'].weight * 1.5)
      avg_weight += sum(x[x['size'] == 'M'].weight * 1.25)
      avg_weight += sum(x[x['size'] == 'L'].weight)
      avg_weight /= len(x)
      return pd.Series(['L',avg_weight,True], index=['size', 'weight', 'adult'])

   expected_df = gb.apply(GrowUp)

   expected_df

`Expanding Apply
<http://stackoverflow.com/questions/14542145/reductions-down-a-column-in-pandas>`__

.. ipython:: python

   S = pd.Series([i / 100.0 for i in range(1,11)])

   def CumRet(x,y):
      return x * (1 + y)

   def Red(x):
      return functools.reduce(CumRet,x,1.0)

   S.expanding().apply(Red)


`Replacing some values with mean of the rest of a group
<http://stackoverflow.com/questions/14760757/replacing-values-with-groupby-means>`__

.. ipython:: python

   df = pd.DataFrame({'A' : [1, 1, 2, 2], 'B' : [1, -1, 1, 2]})

   gb = df.groupby('A')

   def replace(g):
      mask = g < 0
      g.loc[mask] = g[~mask].mean()
      return g

   gb.transform(replace)

`Sort groups by aggregated data
<http://stackoverflow.com/questions/14941366/pandas-sort-by-group-aggregate-and-column>`__

.. ipython:: python

   df = pd.DataFrame({'code': ['foo', 'bar', 'baz'] * 2,
                      'data': [0.16, -0.21, 0.33, 0.45, -0.59, 0.62],
                      'flag': [False, True] * 3})

   code_groups = df.groupby('code')

   agg_n_sort_order = code_groups[['data']].transform(sum).sort_values(by='data')

   sorted_df = df.ix[agg_n_sort_order.index]

   sorted_df

`Create multiple aggregated columns
<http://stackoverflow.com/questions/14897100/create-multiple-columns-in-pandas-aggregation-function>`__

.. ipython:: python

   rng = pd.date_range(start="2014-10-07",periods=10,freq='2min')
   ts = pd.Series(data = list(range(10)), index = rng)

   def MyCust(x):
      if len(x) > 2:
         return x[1] * 1.234
      return pd.NaT

   mhc = {'Mean' : np.mean, 'Max' : np.max, 'Custom' : MyCust}
   ts.resample("5min").apply(mhc)
   ts

`Create a value counts column and reassign back to the DataFrame
<http://stackoverflow.com/questions/17709270/i-want-to-create-a-column-of-value-counts-in-my-pandas-dataframe>`__

.. ipython:: python

   df = pd.DataFrame({'Color': 'Red Red Red Blue'.split(),
                      'Value': [100, 150, 50, 50]}); df
   df['Counts'] = df.groupby(['Color']).transform(len)
   df

`Shift groups of the values in a column based on the index
<http://stackoverflow.com/q/23198053/190597>`__

.. ipython:: python

   df = pd.DataFrame(
      {u'line_race': [10, 10, 8, 10, 10, 8],
       u'beyer': [99, 102, 103, 103, 88, 100]},
       index=[u'Last Gunfighter', u'Last Gunfighter', u'Last Gunfighter',
              u'Paynter', u'Paynter', u'Paynter']); df
   df['beyer_shifted'] = df.groupby(level=0)['beyer'].shift(1)
   df

`Select row with maximum value from each group
<http://stackoverflow.com/q/26701849/190597>`__

.. ipython:: python

   df = pd.DataFrame({'host':['other','other','that','this','this'],
                      'service':['mail','web','mail','mail','web'],
                      'no':[1, 2, 1, 2, 1]}).set_index(['host', 'service'])
   mask = df.groupby(level=0).agg('idxmax')
   df_count = df.loc[mask['no']].reset_index()
   df_count

`Grouping like Python's itertools.groupby
<http://stackoverflow.com/q/29142487/846892>`__

.. ipython:: python

   df = pd.DataFrame([0, 1, 0, 1, 1, 1, 0, 1, 1], columns=['A'])
   df.A.groupby((df.A != df.A.shift()).cumsum()).groups
   df.A.groupby((df.A != df.A.shift()).cumsum()).cumsum()

Expanding Data
**************

`Alignment and to-date
<http://stackoverflow.com/questions/15489011/python-time-series-alignment-and-to-date-functions>`__

`Rolling Computation window based on values instead of counts
<http://stackoverflow.com/questions/14300768/pandas-rolling-computation-with-window-based-on-values-instead-of-counts>`__

`Rolling Mean by Time Interval
<http://stackoverflow.com/questions/15771472/pandas-rolling-mean-by-time-interval>`__

Splitting
*********

`Splitting a frame
<http://stackoverflow.com/questions/13353233/best-way-to-split-a-dataframe-given-an-edge/15449992#15449992>`__

Create a list of dataframes, split using a delineation based on logic included in rows.

.. ipython:: python

   df = pd.DataFrame(data={'Case' : ['A','A','A','B','A','A','B','A','A'],
                           'Data' : np.random.randn(9)})

   dfs = list(zip(*df.groupby((1*(df['Case']=='B')).cumsum().rolling(window=3,min_periods=1).median())))[-1]

   dfs[0]
   dfs[1]
   dfs[2]

.. _cookbook.pivot:

Pivot
*****
The :ref:`Pivot <reshaping.pivot>` docs.

`Partial sums and subtotals
<http://stackoverflow.com/questions/15570099/pandas-pivot-tables-row-subtotals/15574875#15574875>`__

.. ipython:: python

   df = pd.DataFrame(data={'Province' : ['ON','QC','BC','AL','AL','MN','ON'],
                            'City' : ['Toronto','Montreal','Vancouver','Calgary','Edmonton','Winnipeg','Windsor'],
                            'Sales' : [13,6,16,8,4,3,1]})
   table = pd.pivot_table(df,values=['Sales'],index=['Province'],columns=['City'],aggfunc=np.sum,margins=True)
   table.stack('City')

`Frequency table like plyr in R
<http://stackoverflow.com/questions/15589354/frequency-tables-in-pandas-like-plyr-in-r>`__

.. ipython:: python

   grades = [48,99,75,80,42,80,72,68,36,78]
   df = pd.DataFrame( {'ID': ["x%d" % r for r in range(10)],
                       'Gender' : ['F', 'M', 'F', 'M', 'F', 'M', 'F', 'M', 'M', 'M'],
                       'ExamYear': ['2007','2007','2007','2008','2008','2008','2008','2009','2009','2009'],
                       'Class': ['algebra', 'stats', 'bio', 'algebra', 'algebra', 'stats', 'stats', 'algebra', 'bio', 'bio'],
                       'Participated': ['yes','yes','yes','yes','no','yes','yes','yes','yes','yes'],
                       'Passed': ['yes' if x > 50 else 'no' for x in grades],
                       'Employed': [True,True,True,False,False,False,False,True,True,False],
                       'Grade': grades})

   df.groupby('ExamYear').agg({'Participated': lambda x: x.value_counts()['yes'],
                       'Passed': lambda x: sum(x == 'yes'),
                       'Employed' : lambda x : sum(x),
                       'Grade' : lambda x : sum(x) / len(x)})

`Plot pandas DataFrame with year over year data
<http://stackoverflow.com/questions/30379789/plot-pandas-data-frame-with-year-over-year-data>`__

To create year and month crosstabulation:

.. ipython:: python

   df = pd.DataFrame({'value': np.random.randn(36)},
                     index=pd.date_range('2011-01-01', freq='M', periods=36))

   pd.pivot_table(df, index=df.index.month, columns=df.index.year,
                  values='value', aggfunc='sum')

Apply
*****

`Rolling Apply to Organize - Turning embedded lists into a multi-index frame
<http://stackoverflow.com/questions/17349981/converting-pandas-dataframe-with-categorical-values-into-binary-values>`__

.. ipython:: python

   df = pd.DataFrame(data={'A' : [[2,4,8,16],[100,200],[10,20,30]], 'B' : [['a','b','c'],['jj','kk'],['ccc']]},index=['I','II','III'])

   def SeriesFromSubList(aList):
      return pd.Series(aList)

   df_orgz = pd.concat(dict([ (ind,row.apply(SeriesFromSubList)) for ind,row in df.iterrows() ]))

`Rolling Apply with a DataFrame returning a Series
<http://stackoverflow.com/questions/19121854/using-rolling-apply-on-a-dataframe-object>`__

Rolling Apply to multiple columns where function calculates a Series before a Scalar from the Series is returned

.. ipython:: python

   df = pd.DataFrame(data=np.random.randn(2000,2)/10000,
                     index=pd.date_range('2001-01-01',periods=2000),
                     columns=['A','B']); df

   def gm(aDF,Const):
      v = ((((aDF.A+aDF.B)+1).cumprod())-1)*Const
      return (aDF.index[0],v.iloc[-1])

   S = pd.Series(dict([ gm(df.iloc[i:min(i+51,len(df)-1)],5) for i in range(len(df)-50) ])); S

`Rolling apply with a DataFrame returning a Scalar
<http://stackoverflow.com/questions/21040766/python-pandas-rolling-apply-two-column-input-into-function/21045831#21045831>`__

Rolling Apply to multiple columns where function returns a Scalar (Volume Weighted Average Price)

.. ipython:: python

   rng = pd.date_range(start = '2014-01-01',periods = 100)
   df = pd.DataFrame({'Open' : np.random.randn(len(rng)),
                      'Close' : np.random.randn(len(rng)),
                      'Volume' : np.random.randint(100,2000,len(rng))}, index=rng); df

   def vwap(bars): return ((bars.Close*bars.Volume).sum()/bars.Volume.sum())
   window = 5
   s = pd.concat([ (pd.Series(vwap(df.iloc[i:i+window]), index=[df.index[i+window]])) for i in range(len(df)-window) ]);
   s.round(2)