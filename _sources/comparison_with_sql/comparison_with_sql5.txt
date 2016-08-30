.. ipython:: python
    :suppress:

    import pandas as pd
    import numpy as np
    url = 'https://raw.github.com/pydata/pandas/master/pandas/tests/data/tips.csv'
    tips = pd.read_csv(url)


UNION
-----
UNION ALL can be performed using :meth:`~pandas.concat`.

.. ipython:: python

    df1 = pd.DataFrame({'city': ['Chicago', 'San Francisco', 'New York City'],
                        'rank': range(1, 4)})
    df2 = pd.DataFrame({'city': ['Chicago', 'Boston', 'Los Angeles'],
                        'rank': [1, 4, 5]})
    df1
    df2
    
.. code-block:: sql

    SELECT city, rank
    FROM df1
    UNION ALL
    SELECT city, rank
    FROM df2;
    /*
             city  rank
          Chicago     1
    San Francisco     2
    New York City     3
          Chicago     1
           Boston     4
      Los Angeles     5
    */

.. ipython:: python

    pd.concat([df1, df2])

SQL's UNION is similar to UNION ALL, however UNION will remove duplicate rows.

.. code-block:: sql

    SELECT city, rank
    FROM df1
    UNION
    SELECT city, rank
    FROM df2;
    -- notice that there is only one Chicago record this time
    /*
             city  rank
          Chicago     1
    San Francisco     2
    New York City     3
           Boston     4
      Los Angeles     5
    */

In pandas, you can use :meth:`~pandas.concat` in conjunction with
:meth:`~pandas.DataFrame.drop_duplicates`.

.. ipython:: python

    pd.concat([df1, df2]).drop_duplicates()