.. ipython:: python
    :suppress:
    
    import pandas as pd
    import numpy as np
    url = 'https://raw.github.com/pydata/pandas/master/pandas/tests/data/tips.csv'
    tips = pd.read_csv(url)
    tips.head()

.. ipython:: python

    tips.head()

SELECT
------
In SQL, selection is done using a comma-separated list of columns you'd like to select (or a ``*``
to select all columns):

.. code-block:: sql

    SELECT total_bill, tip, smoker, time
    FROM tips
    LIMIT 5;

With pandas, column selection is done by passing a list of column names to your DataFrame:

.. ipython:: python

    tips[['total_bill', 'tip', 'smoker', 'time']].head(5)

Calling the DataFrame without the list of column names would display all columns (akin to SQL's
``*``).