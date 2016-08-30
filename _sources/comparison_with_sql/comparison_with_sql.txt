.. currentmodule:: pandas
.. _compare_with_sql:

.. ipython:: python
    :suppress:

    import pandas as pd
    import numpy as np


Comparison with SQL
********************
Since many potential pandas users have some familiarity with
`SQL <http://en.wikipedia.org/wiki/SQL>`_, this page is meant to provide some examples of how
various SQL operations would be performed using pandas.

Most of the examples will utilize the ``tips`` dataset found within pandas tests.  We'll read
the data into a DataFrame called `tips` and assume we have a database table of the same name and
structure.

.. ipython:: python

    url = 'https://raw.github.com/pydata/pandas/master/pandas/tests/data/tips.csv'
    tips = pd.read_csv(url)
    tips.head()

.. toctree::
    :maxdepth: 1
    :caption: Contents
    :name: comparison_with_sql

    comparison_with_sql1
    comparison_with_sql2
    comparison_with_sql3
    comparison_with_sql4
    comparison_with_sql5
    comparison_with_sql6
    comparison_with_sql7
    comparison_with_sql8