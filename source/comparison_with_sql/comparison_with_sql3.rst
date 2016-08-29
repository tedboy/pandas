.. ipython:: python
    :suppress:

    import pandas as pd
    import numpy as np
    url = 'https://raw.github.com/pydata/pandas/master/pandas/tests/data/tips.csv'
    tips = pd.read_csv(url)

.. ipython:: python

    tips.head()

GROUP BY
--------
In pandas, SQL's GROUP BY operations are performed using the similarly named
:meth:`~pandas.DataFrame.groupby` method. :meth:`~pandas.DataFrame.groupby` typically refers to a
process where we'd like to split a dataset into groups, apply some function (typically aggregation)
, and then combine the groups together.

A common SQL operation would be getting the count of records in each group throughout a dataset.
For instance, a query getting us the number of tips left by sex:

.. code-block:: sql

    SELECT sex, count(*)
    FROM tips
    GROUP BY sex;
    /*
    Female     87
    Male      157
    */


The pandas equivalent would be:

.. ipython:: python

    tips.groupby('sex').size()

Notice that in the pandas code we used :meth:`~pandas.core.groupby.DataFrameGroupBy.size` and not
:meth:`~pandas.core.groupby.DataFrameGroupBy.count`. This is because
:meth:`~pandas.core.groupby.DataFrameGroupBy.count` applies the function to each column, returning
the number of ``not null`` records within each.

.. ipython:: python

    tips.groupby('sex').count()

Alternatively, we could have applied the :meth:`~pandas.core.groupby.DataFrameGroupBy.count` method
to an individual column:

.. ipython:: python

    tips.groupby('sex')['total_bill'].count()

Multiple functions can also be applied at once. For instance, say we'd like to see how tip amount
differs by day of the week - :meth:`~pandas.core.groupby.DataFrameGroupBy.agg` allows you to pass a dictionary
to your grouped DataFrame, indicating which functions to apply to specific columns.

.. code-block:: sql

    SELECT day, AVG(tip), COUNT(*)
    FROM tips
    GROUP BY day;
    /*
    Fri   2.734737   19
    Sat   2.993103   87
    Sun   3.255132   76
    Thur  2.771452   62
    */

.. ipython:: python

    tips.groupby('day').agg({'tip': np.mean, 'day': np.size})

Grouping by more than one column is done by passing a list of columns to the
:meth:`~pandas.DataFrame.groupby` method.

.. code-block:: sql

    SELECT smoker, day, COUNT(*), AVG(tip)
    FROM tips
    GROUP BY smoker, day;
    /*
    smoker day
    No     Fri      4  2.812500
           Sat     45  3.102889
           Sun     57  3.167895
           Thur    45  2.673778
    Yes    Fri     15  2.714000
           Sat     42  2.875476
           Sun     19  3.516842
           Thur    17  3.030000
    */

.. ipython:: python

    tips.groupby(['smoker', 'day']).agg({'tip': [np.size, np.mean]})