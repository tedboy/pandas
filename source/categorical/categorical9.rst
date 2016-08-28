.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Getting Data In/Out
-------------------

.. versionadded:: 0.15.2

Writing data (`Series`, `Frames`) to a HDF store that contains a ``category`` dtype was implemented
in 0.15.2. See :ref:`here <io.hdf5-categorical>` for an example and caveats.

Writing data to and reading data from *Stata* format files was implemented in
0.15.2. See :ref:`here <io.stata-categorical>` for an example and caveats.

Writing to a CSV file will convert the data, effectively removing any information about the
categorical (categories and ordering). So if you read back the CSV file you have to convert the
relevant columns back to `category` and assign the right categories and categories ordering.

.. ipython:: python
    :suppress:

    from pandas.compat import StringIO

.. ipython:: python

    s = pd.Series(pd.Categorical(['a', 'b', 'b', 'a', 'a', 'd']))
    # rename the categories
    s.cat.categories = ["very good", "good", "bad"]
    # reorder the categories and add missing categories
    s = s.cat.set_categories(["very bad", "bad", "medium", "good", "very good"])
    df = pd.DataFrame({"cats":s, "vals":[1,2,3,4,5,6]})
    csv = StringIO()
    df.to_csv(csv)
    df2 = pd.read_csv(StringIO(csv.getvalue()))
    df2.dtypes
    df2["cats"]
    # Redo the category
    df2["cats"] = df2["cats"].astype("category")
    df2["cats"].cat.set_categories(["very bad", "bad", "medium", "good", "very good"],
                                   inplace=True)
    df2.dtypes
    df2["cats"]

The same holds for writing to a SQL database with ``to_sql``.