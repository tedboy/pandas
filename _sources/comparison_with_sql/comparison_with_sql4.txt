.. ipython:: python
    :suppress:

    import pandas as pd
    import numpy as np
    url = 'https://raw.github.com/pydata/pandas/master/pandas/tests/data/tips.csv'
    tips = pd.read_csv(url)

.. _compare_with_sql.join:

JOIN
----
JOINs can be performed with :meth:`~pandas.DataFrame.join` or :meth:`~pandas.merge`. By default,
:meth:`~pandas.DataFrame.join` will join the DataFrames on their indices. Each method has
parameters allowing you to specify the type of join to perform (LEFT, RIGHT, INNER, FULL) or the
columns to join on (column names or indices).

.. ipython:: python

    df1 = pd.DataFrame({'key': ['A', 'B', 'C', 'D'],
                        'value': np.random.randn(4)})
    df2 = pd.DataFrame({'key': ['B', 'D', 'D', 'E'],
                        'value': np.random.randn(4)})
    df1
    df2
    
Assume we have two database tables of the same name and structure as our DataFrames.

Now let's go over the various types of JOINs.

INNER JOIN
~~~~~~~~~~
.. code-block:: sql

    SELECT *
    FROM df1
    INNER JOIN df2
      ON df1.key = df2.key;

.. ipython:: python

    # merge performs an INNER JOIN by default
    pd.merge(df1, df2, on='key')

:meth:`~pandas.merge` also offers parameters for cases when you'd like to join one DataFrame's
column with another DataFrame's index.

.. ipython:: python

    indexed_df2 = df2.set_index('key')
    pd.merge(df1, indexed_df2, left_on='key', right_index=True)

LEFT OUTER JOIN
~~~~~~~~~~~~~~~
.. code-block:: sql

    -- show all records from df1
    SELECT *
    FROM df1
    LEFT OUTER JOIN df2
      ON df1.key = df2.key;

.. ipython:: python

    # show all records from df1
    pd.merge(df1, df2, on='key', how='left')

RIGHT JOIN
~~~~~~~~~~
.. code-block:: sql

    -- show all records from df2
    SELECT *
    FROM df1
    RIGHT OUTER JOIN df2
      ON df1.key = df2.key;

.. ipython:: python

    # show all records from df2
    pd.merge(df1, df2, on='key', how='right')

FULL JOIN
~~~~~~~~~
pandas also allows for FULL JOINs, which display both sides of the dataset, whether or not the
joined columns find a match. As of writing, FULL JOINs are not supported in all RDBMS (MySQL).

.. code-block:: sql

    -- show all records from both tables
    SELECT *
    FROM df1
    FULL OUTER JOIN df2
      ON df1.key = df2.key;

.. ipython:: python

    # show all records from both frames
    pd.merge(df1, df2, on='key', how='outer')