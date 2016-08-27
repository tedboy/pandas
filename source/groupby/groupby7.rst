.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows = 15
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')
   from collections import OrderedDict
   df = pd.DataFrame({'A' : ['foo', 'bar', 'foo', 'bar',
                             'foo', 'bar', 'foo', 'foo'],
                      'B' : ['one', 'one', 'two', 'three',
                             'two', 'two', 'one', 'three'],
                      'C' : np.random.randn(8),
                      'D' : np.random.randn(8)})   

.. _groupby.dispatch:

Dispatching to instance methods
-------------------------------

When doing an aggregation or transformation, you might just want to call an
instance method on each data group. This is pretty easy to do by passing lambda
functions:

.. ipython:: python

   df
   grouped = df.groupby('A')
   grouped.agg(lambda x: x.std())

But, it's rather verbose and can be untidy if you need to pass additional
arguments. Using a bit of metaprogramming cleverness, GroupBy now has the
ability to "dispatch" method calls to the groups:

.. ipython:: python

   grouped.std()

What is actually happening here is that a function wrapper is being
generated. When invoked, it takes any passed arguments and invokes the function
with any arguments on each group (in the above example, the ``std``
function). The results are then combined together much in the style of ``agg``
and ``transform`` (it actually uses ``apply`` to infer the gluing, documented
next). This enables some operations to be carried out rather succinctly:

.. ipython:: python

   tsdf = pd.DataFrame(np.random.randn(1000, 3),
                       index=pd.date_range('1/1/2000', periods=1000),
                       columns=['A', 'B', 'C'])
   tsdf.ix[::2] = np.nan
   grouped = tsdf.groupby(lambda x: x.year)
   grouped.fillna(method='pad')

In this example, we chopped the collection of time series into yearly chunks
then independently called :ref:`fillna <missing_data.fillna>` on the
groups.

.. versionadded:: 0.14.1

The ``nlargest`` and ``nsmallest`` methods work on ``Series`` style groupbys:

.. ipython:: python

   s = pd.Series([9, 8, 7, 5, 19, 1, 4.2, 3.3])
   g = pd.Series(list('abababab'))
   gb = s.groupby(g)
   gb.nlargest(3)
   gb.nsmallest(3)