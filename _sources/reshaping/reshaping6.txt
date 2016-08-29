.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   import pandas as pd
   pd.options.display.max_rows=8
   np.set_printoptions(precision=4, suppress=True)

.. _reshaping.crosstabulations:

Cross tabulations
-----------------

Use the ``crosstab`` function to compute a cross-tabulation of two (or more)
factors. By default ``crosstab`` computes a frequency table of the factors
unless an array of values and an aggregation function are passed.

It takes a number of arguments

- ``index``: array-like, values to group by in the rows
- ``columns``: array-like, values to group by in the columns
- ``values``: array-like, optional, array of values to aggregate according to
  the factors
- ``aggfunc``: function, optional, If no values array is passed, computes a
  frequency table
- ``rownames``: sequence, default ``None``, must match number of row arrays passed
- ``colnames``: sequence, default ``None``, if passed, must match number of column
  arrays passed
- ``margins``: boolean, default ``False``, Add row/column margins (subtotals)
- ``normalize``: boolean, {'all', 'index', 'columns'}, or {0,1}, default ``False``.
  Normalize by dividing all values by the sum of values.


Any Series passed will have their name attributes used unless row or column
names for the cross-tabulation are specified

For example:

.. ipython:: python

    foo, bar, dull, shiny, one, two = 'foo', 'bar', 'dull', 'shiny', 'one', 'two'
    a = np.array([foo, foo, bar, bar, foo, foo], dtype=object)
    b = np.array([one, one, two, one, two, one], dtype=object)
    c = np.array([dull, dull, shiny, dull, dull, shiny], dtype=object)
    pd.crosstab(a, [b, c], rownames=['a'], colnames=['b', 'c'])


If ``crosstab`` receives only two Series, it will provide a frequency table.

.. ipython:: python

    df = pd.DataFrame({'A': [1, 2, 2, 2, 2], 'B': [3, 3, 4, 4, 4],
                       'C': [1, 1, np.nan, 1, 1]})
    df

    pd.crosstab(df.A, df.B)

Any input passed containing ``Categorical`` data will have **all** of its
categories included in the cross-tabulation, even if the actual data does
not contain any instances of a particular category.

.. ipython:: python

    foo = pd.Categorical(['a', 'b'], categories=['a', 'b', 'c'])
    bar = pd.Categorical(['d', 'e'], categories=['d', 'e', 'f'])
    pd.crosstab(foo, bar)

Normalization
~~~~~~~~~~~~~

.. versionadded:: 0.18.1

Frequency tables can also be normalized to show percentages rather than counts
using the ``normalize`` argument:

.. ipython:: python

   pd.crosstab(df.A, df.B, normalize=True)

``normalize`` can also normalize values within each row or within each column:

.. ipython:: python

   pd.crosstab(df.A, df.B, normalize='columns')

``crosstab`` can also be passed a third Series and an aggregation function
(``aggfunc``) that will be applied to the values of the third Series within each
group defined by the first two Series:

.. ipython:: python

   pd.crosstab(df.A, df.B, values=df.C, aggfunc=np.sum)

Adding Margins
~~~~~~~~~~~~~~

Finally, one can also add margins or normalize this output.

.. ipython:: python

   pd.crosstab(df.A, df.B, values=df.C, aggfunc=np.sum, normalize=True,
               margins=True)