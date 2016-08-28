.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   import pandas as pd
   pd.options.display.max_rows=8
   np.set_printoptions(precision=4, suppress=True)

Pivot tables
------------

.. _reshaping.pivot:

The function ``pandas.pivot_table`` can be used to create spreadsheet-style pivot
tables. See the :ref:`cookbook<cookbook.pivot>` for some advanced strategies

It takes a number of arguments

- ``data``: A DataFrame object
- ``values``: a column or a list of columns to aggregate
- ``index``: a column, Grouper, array which has the same length as data, or list of them.
  Keys to group by on the pivot table index. If an array is passed, it is being used as the same manner as column values.
- ``columns``: a column, Grouper, array which has the same length as data, or list of them.
  Keys to group by on the pivot table column. If an array is passed, it is being used as the same manner as column values.
- ``aggfunc``: function to use for aggregation, defaulting to ``numpy.mean``

Consider a data set like this:

.. ipython:: python

   import datetime
   df = pd.DataFrame({'A': ['one', 'one', 'two', 'three'] * 6,
                      'B': ['A', 'B', 'C'] * 8,
                      'C': ['foo', 'foo', 'foo', 'bar', 'bar', 'bar'] * 4,
                      'D': np.random.randn(24),
                      'E': np.random.randn(24),
                      'F': [datetime.datetime(2013, i, 1) for i in range(1, 13)] +
                           [datetime.datetime(2013, i, 15) for i in range(1, 13)]})
   df

We can produce pivot tables from this data very easily:

.. ipython:: python

   pd.pivot_table(df, values='D', index=['A', 'B'], columns=['C'])
   pd.pivot_table(df, values='D', index=['B'], columns=['A', 'C'], aggfunc=np.sum)
   pd.pivot_table(df, values=['D','E'], index=['B'], columns=['A', 'C'], aggfunc=np.sum)

The result object is a DataFrame having potentially hierarchical indexes on the
rows and columns. If the ``values`` column name is not given, the pivot table
will include all of the data that can be aggregated in an additional level of
hierarchy in the columns:

.. ipython:: python

   df.head()
   pd.pivot_table(df, index=['A', 'B'], columns=['C'])

Also, you can use ``Grouper`` for ``index`` and ``columns`` keywords. For detail of ``Grouper``, see :ref:`Grouping with a Grouper specification <groupby.specify>`.

.. ipython:: python

   df.head()
   pd.pivot_table(df, values='D', index=pd.Grouper(freq='M', key='F'), columns='C')

You can render a nice output of the table omitting the missing values by
calling ``to_string`` if you wish:

.. ipython:: python

   df.head()
   table = pd.pivot_table(df, index=['A', 'B'], columns=['C'])
   table
   print(table.to_string(na_rep=''))

Note that ``pivot_table`` is also available as an instance method on DataFrame.

.. _reshaping.pivot.margins:

Adding margins
~~~~~~~~~~~~~~

If you pass ``margins=True`` to ``pivot_table``, special ``All`` columns and
rows will be added with partial group aggregates across the categories on the
rows and columns:

.. ipython:: python
   
   df.head()
   df.pivot_table(index=['A', 'B'], columns='C', margins=True, aggfunc=np.std)
