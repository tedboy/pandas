.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Operations
----------

Apart from ``Series.min()``, ``Series.max()`` and ``Series.mode()``, the following operations are
possible with categorical data:

`Series` methods like `Series.value_counts()` will use all categories, even if some categories are not
present in the data:

.. ipython:: python

    s = pd.Series(pd.Categorical(["a","b","c","c"], categories=["c","a","b","d"]))
    s.value_counts()

Groupby will also show "unused" categories:

.. ipython:: python

    cats = pd.Categorical(["a","b","b","b","c","c","c"], categories=["a","b","c","d"])
    df = pd.DataFrame({"cats":cats,"values":[1,2,2,2,3,4,5]})
    df.groupby("cats").mean()

    cats2 = pd.Categorical(["a","a","b","b"], categories=["a","b","c"])
    df2 = pd.DataFrame({"cats":cats2,"B":["c","d","c","d"], "values":[1,2,3,4]})
    df2.groupby(["cats","B"]).mean()


Pivot tables:

.. ipython:: python

    raw_cat = pd.Categorical(["a","a","b","b"], categories=["a","b","c"])
    df = pd.DataFrame({"A":raw_cat,"B":["c","d","c","d"], "values":[1,2,3,4]})
    pd.pivot_table(df, values='values', index=['A', 'B'])