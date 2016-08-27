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

.. _cookbook.multi_index:

MultiIndexing
-------------

The :ref:`multindexing <advanced.hierarchical>` docs.

`Creating a multi-index from a labeled frame
<http://stackoverflow.com/questions/14916358/reshaping-dataframes-in-pandas-based-on-column-labels>`__

.. ipython:: python

   df = pd.DataFrame({'row' : [0,1,2],
                      'One_X' : [1.1,1.1,1.1],
                      'One_Y' : [1.2,1.2,1.2],
                      'Two_X' : [1.11,1.11,1.11],
                      'Two_Y' : [1.22,1.22,1.22]}); df

   # As Labelled Index
   df = df.set_index('row');df
   # With Hierarchical Columns
   df.columns = pd.MultiIndex.from_tuples([tuple(c.split('_')) for c in df.columns]);df
   # Now stack & Reset
   df = df.stack(0).reset_index(1);df
   # And fix the labels (Notice the label 'level_1' got added automatically)
   df.columns = ['Sample','All_X','All_Y'];df

Arithmetic
**********

`Performing arithmetic with a multi-index that needs broadcasting
<http://stackoverflow.com/questions/19501510/divide-entire-pandas-multiindex-dataframe-by-dataframe-variable/19502176#19502176>`__

.. ipython:: python

   cols = pd.MultiIndex.from_tuples([ (x,y) for x in ['A','B','C'] for y in ['O','I']])
   df = pd.DataFrame(np.random.randn(2,6),index=['n','m'],columns=cols); df
   df = df.div(df['C'],level=1); df

Slicing
*******

`Slicing a multi-index with xs
<http://stackoverflow.com/questions/12590131/how-to-slice-multindex-columns-in-pandas-dataframes>`__

.. ipython:: python

   coords = [('AA','one'),('AA','six'),('BB','one'),('BB','two'),('BB','six')]
   index = pd.MultiIndex.from_tuples(coords)
   df = pd.DataFrame([11,22,33,44,55],index,['MyData']); df

To take the cross section of the 1st level and 1st axis the index:

.. ipython:: python

   df.xs('BB',level=0,axis=0)  #Note : level and axis are optional, and default to zero

...and now the 2nd level of the 1st axis.

.. ipython:: python

   df.xs('six',level=1,axis=0)

`Slicing a multi-index with xs, method #2
<http://stackoverflow.com/questions/14964493/multiindex-based-indexing-in-pandas>`__

.. ipython:: python

   index = list(itertools.product(['Ada','Quinn','Violet'],['Comp','Math','Sci']))
   headr = list(itertools.product(['Exams','Labs'],['I','II']))

   indx = pd.MultiIndex.from_tuples(index,names=['Student','Course'])
   cols = pd.MultiIndex.from_tuples(headr) #Notice these are un-named

   data = [[70+x+y+(x*y)%3 for x in range(4)] for y in range(9)]

   df = pd.DataFrame(data,indx,cols); df

   All = slice(None)

   df.loc['Violet']
   df.loc[(All,'Math'),All]
   df.loc[(slice('Ada','Quinn'),'Math'),All]
   df.loc[(All,'Math'),('Exams')]
   df.loc[(All,'Math'),(All,'II')]

`Setting portions of a multi-index with xs
<http://stackoverflow.com/questions/19319432/pandas-selecting-a-lower-level-in-a-dataframe-to-do-a-ffill>`__

Sorting
*******

`Sort by specific column or an ordered list of columns, with a multi-index
<http://stackoverflow.com/questions/14733871/mutli-index-sorting-in-pandas>`__

.. ipython:: python

   df.sort_values(by=('Labs', 'II'), ascending=False)

`Partial Selection, the need for sortedness;
<https://github.com/pydata/pandas/issues/2995>`__

Levels
******

`Prepending a level to a multiindex
<http://stackoverflow.com/questions/14744068/prepend-a-level-to-a-pandas-multiindex>`__

`Flatten Hierarchical columns
<http://stackoverflow.com/questions/14507794/python-pandas-how-to-flatten-a-hierarchical-index-in-columns>`__

panelnd
*******

The :ref:`panelnd<dsintro.panelnd>` docs.

`Construct a 5D panelnd
<http://stackoverflow.com/questions/18748598/why-my-panelnd-factory-throwing-a-keyerror>`__