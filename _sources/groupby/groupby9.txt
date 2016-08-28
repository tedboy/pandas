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

Other useful features
---------------------

Automatic exclusion of "nuisance" columns
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Again consider the example DataFrame we've been looking at:

.. ipython:: python

   df

Suppose we wish to compute the standard deviation grouped by the ``A``
column. There is a slight problem, namely that we don't care about the data in
column ``B``. We refer to this as a "nuisance" column. If the passed
aggregation function can't be applied to some columns, the troublesome columns
will be (silently) dropped. Thus, this does not pose any problems:

.. ipython:: python

   df.groupby('A').std()

.. _groupby.missing:

NA and NaT group handling
~~~~~~~~~~~~~~~~~~~~~~~~~

If there are any NaN or NaT values in the grouping key, these will be automatically
excluded. So there will never be an "NA group" or "NaT group". This was not the case in older
versions of pandas, but users were generally discarding the NA group anyway
(and supporting it was an implementation headache).

Grouping with ordered factors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Categorical variables represented as instance of pandas's ``Categorical`` class
can be used as group keys. If so, the order of the levels will be preserved:

.. ipython:: python

   data = pd.Series(np.random.randn(100))

   factor = pd.qcut(data, [0, .25, .5, .75, 1.])

   data.groupby(factor).mean()

.. _groupby.specify:

Grouping with a Grouper specification
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You may need to specify a bit more data to properly group. You can
use the ``pd.Grouper`` to provide this local control.

.. ipython:: python

   import datetime

   df = pd.DataFrame({
            'Branch' : 'A A A A A A A B'.split(),
            'Buyer': 'Carl Mark Carl Carl Joe Joe Joe Carl'.split(),
            'Quantity': [1,3,5,1,8,1,9,3],
            'Date' : [
                datetime.datetime(2013,1,1,13,0),
                datetime.datetime(2013,1,1,13,5),
                datetime.datetime(2013,10,1,20,0),
                datetime.datetime(2013,10,2,10,0),
                datetime.datetime(2013,10,1,20,0),
                datetime.datetime(2013,10,2,10,0),
                datetime.datetime(2013,12,2,12,0),
                datetime.datetime(2013,12,2,14,0),
                ]
            })

   df

Groupby a specific column with the desired frequency. This is like resampling.

.. ipython:: python

   df.groupby([pd.Grouper(freq='1M',key='Date'),'Buyer']).sum()

You have an ambiguous specification in that you have a named index and a column
that could be potential groupers.

.. ipython:: python

   df = df.set_index('Date')
   df['Date'] = df.index + pd.offsets.MonthEnd(2)
   df.groupby([pd.Grouper(freq='6M',key='Date'),'Buyer']).sum()

   df.groupby([pd.Grouper(freq='6M',level='Date'),'Buyer']).sum()


Taking the first rows of each group
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Just like for a DataFrame or Series you can call head and tail on a groupby:

.. ipython:: python

   df = pd.DataFrame([[1, 2], [1, 4], [5, 6]], columns=['A', 'B'])
   df

   g = df.groupby('A')
   g.head(1)

   g.tail(1)

This shows the first or last n rows from each group.

.. warning::

   Before 0.14.0 this was implemented with a fall-through apply,
   so the result would incorrectly respect the as_index flag:

   .. code-block:: python

       >>> g.head(1):  # was equivalent to g.apply(lambda x: x.head(1))
             A  B
        A
        1 0  1  2
        5 2  5  6

.. _groupby.nth:

Taking the nth row of each group
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To select from a DataFrame or Series the nth item, use the nth method. This is a reduction method, and will return a single row (or no row) per group if you pass an int for n:

.. ipython:: python

   df = pd.DataFrame([[1, np.nan], [1, 4], [5, 6]], columns=['A', 'B'])
   g = df.groupby('A')

   g.nth(0)
   g.nth(-1)
   g.nth(1)

If you want to select the nth not-null item, use the ``dropna`` kwarg. For a DataFrame this should be either ``'any'`` or ``'all'`` just like you would pass to dropna, for a Series this just needs to be truthy.

.. ipython:: python

   # nth(0) is the same as g.first()
   g.nth(0, dropna='any')
   g.first()

   # nth(-1) is the same as g.last()
   g.nth(-1, dropna='any')  # NaNs denote group exhausted when using dropna
   g.last()

   g.B.nth(0, dropna=True)

As with other methods, passing ``as_index=False``, will achieve a filtration, which returns the grouped row.

.. ipython:: python

   df = pd.DataFrame([[1, np.nan], [1, 4], [5, 6]], columns=['A', 'B'])
   g = df.groupby('A',as_index=False)

   g.nth(0)
   g.nth(-1)

You can also select multiple rows from each group by specifying multiple nth values as a list of ints.

.. ipython:: python

   business_dates = pd.date_range(start='4/1/2014', end='6/30/2014', freq='B')
   df = pd.DataFrame(1, index=business_dates, columns=['a', 'b'])
   # get the first, 4th, and last date index for each month
   df.groupby((df.index.year, df.index.month)).nth([0, 3, -1])

Enumerate group items
~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.13.0

To see the order in which each row appears within its group, use the
``cumcount`` method:

.. ipython:: python

   df = pd.DataFrame(list('aaabba'), columns=['A'])
   df

   df.groupby('A').cumcount()

   df.groupby('A').cumcount(ascending=False)  # kwarg only

Plotting
~~~~~~~~

Groupby also works with some plotting methods.  For example, suppose we
suspect that some features in a DataFrame may differ by group, in this case,
the values in column 1 where the group is "B" are 3 higher on average.

.. ipython:: python

   np.random.seed(1234)
   df = pd.DataFrame(np.random.randn(50, 2))
   df['g'] = np.random.choice(['A', 'B'], size=50)
   df.loc[df['g'] == 'B', 1] += 3

We can easily visualize this with a boxplot:

.. ipython:: python
   :okwarning:

   @savefig groupby_boxplot.png
   df.groupby('g').boxplot()

The result of calling ``boxplot`` is a dictionary whose keys are the values
of our grouping column ``g`` ("A" and "B"). The values of the resulting dictionary
can be controlled by the ``return_type`` keyword of ``boxplot``.
See the :ref:`visualization documentation<visualization.box>` for more.

.. warning::

  For historical reasons, ``df.groupby("g").boxplot()`` is not equivalent
  to ``df.boxplot(by="g")``. See :ref:`here<visualization.box.return>` for
  an explanation.