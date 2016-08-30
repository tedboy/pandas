.. ipython:: python
    :suppress:

    import pandas as pd
    import numpy as np
    url = 'https://raw.github.com/pydata/pandas/master/pandas/tests/data/tips.csv'
    tips = pd.read_csv(url)

.. ipython:: python

    tips.head()

WHERE
-----
Filtering in SQL is done via a WHERE clause.

.. code-block:: sql

    SELECT *
    FROM tips
    WHERE time = 'Dinner'
    LIMIT 5;

DataFrames can be filtered in multiple ways; the most intuitive of which is using
`boolean indexing <http://pandas.pydata.org/pandas-docs/stable/indexing.html#boolean-indexing>`_.

.. ipython:: python

    tips[tips['time'] == 'Dinner'].head(5)

The above statement is simply passing a ``Series`` of True/False objects to the DataFrame,
returning all rows with True.

.. ipython:: python

    is_dinner = tips['time'] == 'Dinner'
    is_dinner.value_counts()
    tips[is_dinner].head(5)

Just like SQL's OR and AND, multiple conditions can be passed to a DataFrame using | (OR) and &
(AND).

.. include:: tips_content.rst

.. code-block:: sql

    -- tips of more than $5.00 at Dinner meals
    SELECT *
    FROM tips
    WHERE time = 'Dinner' AND tip > 5.00;

.. ipython:: python

    # tips of more than $5.00 at Dinner meals
    tips[(tips['time'] == 'Dinner') & (tips['tip'] > 5.00)]

.. code-block:: sql

    -- tips by parties of at least 5 diners OR bill total was more than $45
    SELECT *
    FROM tips
    WHERE size >= 5 OR total_bill > 45;

.. ipython:: python

    # tips by parties of at least 5 diners OR bill total was more than $45
    tips[(tips['size'] >= 5) | (tips['total_bill'] > 45)]

NULL checking is done using the :meth:`~pandas.Series.notnull` and :meth:`~pandas.Series.isnull`
methods.

.. ipython:: python

    frame = pd.DataFrame({'col1': ['A', 'B', np.NaN, 'C', 'D'],
                          'col2': ['F', np.NaN, 'G', 'H', 'I']})
    frame

Assume we have a table of the same structure as our DataFrame above. We can see only the records
where ``col2`` IS NULL with the following query:

.. code-block:: sql

    SELECT *
    FROM frame
    WHERE col2 IS NULL;

.. ipython:: python

    frame[frame['col2'].isnull()]

Getting items where ``col1`` IS NOT NULL can be done with :meth:`~pandas.Series.notnull`.

.. code-block:: sql

    SELECT *
    FROM frame
    WHERE col1 IS NOT NULL;

.. ipython:: python

    frame[frame['col1'].notnull()]