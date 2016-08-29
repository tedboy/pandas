.. ipython:: python
    :suppress:

    import pandas as pd
    import numpy as np
    url = 'https://raw.github.com/pydata/pandas/master/pandas/tests/data/tips.csv'
    tips = pd.read_csv(url)

Pandas equivalents for some SQL analytic and aggregate functions
----------------------------------------------------------------

.. ipython:: python

    tips.head()
    
Top N rows with offset
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: sql

    -- MySQL
    SELECT * FROM tips
    ORDER BY tip DESC
    LIMIT 10 OFFSET 5;

.. ipython:: python

    tips.nlargest(10+5, columns='tip').tail(10)

Top N rows per group
~~~~~~~~~~~~~~~~~~~~

.. code-block:: sql

    -- Oracle's ROW_NUMBER() analytic function
    SELECT * FROM (
      SELECT
        t.*,
        ROW_NUMBER() OVER(PARTITION BY day ORDER BY total_bill DESC) AS rn
      FROM tips t
    )
    WHERE rn < 3
    ORDER BY day, rn;


.. ipython:: python

    (tips.assign(rn=tips.sort_values(['total_bill'], ascending=False)
                        .groupby(['day'])
                        .cumcount() + 1)
         .query('rn < 3')
         .sort_values(['day','rn'])
    )

the same using `rank(method='first')` function

.. ipython:: python

    (tips.assign(rnk=tips.groupby(['day'])['total_bill']
                         .rank(method='first', ascending=False))
         .query('rnk < 3')
         .sort_values(['day','rnk'])
    )

.. code-block:: sql

    -- Oracle's RANK() analytic function
    SELECT * FROM (
      SELECT
        t.*,
        RANK() OVER(PARTITION BY sex ORDER BY tip) AS rnk
      FROM tips t
      WHERE tip < 2
    )
    WHERE rnk < 3
    ORDER BY sex, rnk;

Let's find tips with (rank < 3) per gender group for (tips < 2).
Notice that when using ``rank(method='min')`` function
`rnk_min` remains the same for the same `tip`
(as Oracle's RANK() function)

.. ipython:: python

    (tips[tips['tip'] < 2]
         .assign(rnk_min=tips.groupby(['sex'])['tip']
                             .rank(method='min'))
         .query('rnk_min < 3')
         .sort_values(['sex','rnk_min'])
    )