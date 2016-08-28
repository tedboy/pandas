.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   import pandas as pd
   pd.options.display.max_rows=8
   np.set_printoptions(precision=4, suppress=True)

.. _reshaping.dummies:

Computing indicator / dummy variables
-------------------------------------

To convert a categorical variable into a "dummy" or "indicator" DataFrame, for example
a column in a DataFrame (a Series) which has ``k`` distinct values, can derive a DataFrame
containing ``k`` columns of 1s and 0s:

.. ipython:: python

   df = pd.DataFrame({'key': list('bbacab'), 'data1': range(6)})
   df
   pd.get_dummies(df['key'])

Sometimes it's useful to prefix the column names, for example when merging the result
with the original DataFrame:

.. ipython:: python

   dummies = pd.get_dummies(df['key'], prefix='key')
   dummies


   df[['data1']].join(dummies)

This function is often used along with discretization functions like ``cut``:

.. ipython:: python

   values = np.random.randn(10)
   values


   bins = [0, 0.2, 0.4, 0.6, 0.8, 1]


   pd.get_dummies(pd.cut(values, bins))

See also :func:`Series.str.get_dummies <pandas.Series.str.get_dummies>`.

.. versionadded:: 0.15.0

:func:`get_dummies` also accepts a DataFrame. By default all categorical
variables (categorical in the statistical sense,
those with `object` or `categorical` dtype) are encoded as dummy variables.


.. ipython:: python

    df = pd.DataFrame({'A': ['a', 'b', 'a'], 'B': ['c', 'c', 'b'],
                       'C': [1, 2, 3]})
    df
    pd.get_dummies(df)

All non-object columns are included untouched in the output.

You can control the columns that are encoded with the ``columns`` keyword.

.. ipython:: python

    pd.get_dummies(df, columns=['A'])

Notice that the ``B`` column is still included in the output, it just hasn't
been encoded. You can drop ``B`` before calling ``get_dummies`` if you don't
want to include it in the output.

As with the Series version, you can pass values for the ``prefix`` and
``prefix_sep``. By default the column name is used as the prefix, and '_' as
the prefix separator. You can specify ``prefix`` and ``prefix_sep`` in 3 ways

- string: Use the same value for ``prefix`` or ``prefix_sep`` for each column
  to be encoded
- list: Must be the same length as the number of columns being encoded.
- dict: Mapping column name to prefix

.. ipython:: python

    simple = pd.get_dummies(df, prefix='new_prefix')
    simple
    from_list = pd.get_dummies(df, prefix=['from_A', 'from_B'])
    from_list
    from_dict = pd.get_dummies(df, prefix={'B': 'from_B', 'A': 'from_A'})
    from_dict

.. versionadded:: 0.18.0

Sometimes it will be useful to only keep k-1 levels of a categorical
variable to avoid collinearity when feeding the result to statistical models.
You can switch to this mode by turn on ``drop_first``.

.. ipython:: python

    s = pd.Series(list('abcaa'))
    s
    pd.get_dummies(s)

    pd.get_dummies(s, drop_first=True)

When a column contains only one level, it will be omitted in the result.

.. ipython:: python

    df = pd.DataFrame({'A':list('aaaaa'),'B':list('ababc')})
    df

    pd.get_dummies(df)

    pd.get_dummies(df, drop_first=True)