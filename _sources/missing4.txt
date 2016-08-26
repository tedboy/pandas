.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   pd.options.display.max_rows=15
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   df = pd.DataFrame(np.random.randn(5, 3), index=['a', 'c', 'e', 'f', 'h'],
                     columns=['one', 'two', 'three'])
   df['four'] = 'bar'
   df['five'] = df['one'] > 0
   df2 = df.copy()
   df2['timestamp'] = pd.Timestamp('20120101')
   df2.ix[['a','c','h'],['one','timestamp']] = np.nan
   df2.get_dtype_counts()

Calculations with missing data
------------------------------

Missing values propagate naturally through arithmetic operations between pandas
objects.

.. ipython:: python
   :suppress:

   df = df2.ix[:, ['one', 'two', 'three']]
   a = df2.ix[:5, ['one', 'two']].fillna(method='pad')
   b = df2.ix[:5, ['one', 'two', 'three']]

.. ipython:: python

   a
   b
   a + b

The descriptive statistics and computational methods discussed in the
:ref:`data structure overview <basics.stats>` (and listed :ref:`here
<api.series.stats>` and :ref:`here <api.dataframe.stats>`) are all written to
account for missing data. For example:

* When summing data, NA (missing) values will be treated as zero
* If the data are all NA, the result will be NA
* Methods like **cumsum** and **cumprod** ignore NA values, but preserve them
  in the resulting arrays

.. ipython:: python

   df
   df['one'].sum()
   df.mean(1)
   df.cumsum()

NA values in GroupBy
~~~~~~~~~~~~~~~~~~~~

NA groups in GroupBy are automatically excluded. This behavior is consistent
with R, for example:

.. ipython:: python

    df
    df.groupby('one').mean()

See the groupby section :ref:`here <groupby.missing>` for more information.