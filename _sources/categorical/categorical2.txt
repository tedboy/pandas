.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Object Creation
---------------

Categorical `Series` or columns in a `DataFrame` can be created in several ways:

By specifying ``dtype="category"`` when constructing a `Series`:

.. ipython:: python

    s = pd.Series(["a","b","c","a"], dtype="category")
    s

By converting an existing `Series` or column to a ``category`` dtype:

.. ipython:: python

    df = pd.DataFrame({"A":["a","b","c","a"]})
    df["B"] = df["A"].astype('category')
    df

By using some special functions:

.. ipython:: python

    df = pd.DataFrame({'value': np.random.randint(0, 100, 20)})
    labels = [ "{0} - {1}".format(i, i + 9) for i in range(0, 100, 10) ]

    df['group'] = pd.cut(df.value, range(0, 105, 10), right=False, labels=labels)
    df.head(10)

See :ref:`documentation <reshaping.tile.cut>` for :func:`~pandas.cut`.

By passing a :class:`pandas.Categorical` object to a `Series` or assigning it to a `DataFrame`.

.. ipython:: python

    raw_cat = pd.Categorical(["a","b","c","a"], categories=["b","c","d"],
                             ordered=False)
    s = pd.Series(raw_cat)
    s
    df = pd.DataFrame({"A":["a","b","c","a"]})
    df["B"] = raw_cat
    df

You can also specify differently ordered categories or make the resulting data ordered, by passing these arguments to ``astype()``:

.. ipython:: python

    s = pd.Series(["a","b","c","a"])
    s_cat = s.astype("category", categories=["b","c","d"], ordered=False)
    s_cat

Categorical data has a specific ``category`` :ref:`dtype <basics.dtypes>`:

.. ipython:: python

    df.dtypes

.. note::

    In contrast to R's `factor` function, categorical data is not converting input values to
    strings and categories will end up the same data type as the original values.

.. note::

    In contrast to R's `factor` function, there is currently no way to assign/change labels at
    creation time. Use `categories` to change the categories after creation time.

To get back to the original Series or `numpy` array, use ``Series.astype(original_dtype)`` or
``np.asarray(categorical)``:

.. ipython:: python

    s = pd.Series(["a","b","c","a"])
    s
    s2 = s.astype('category')
    s2
    s3 = s2.astype('string')
    s3
    np.asarray(s2)

If you have already `codes` and `categories`, you can use the :func:`~pandas.Categorical.from_codes`
constructor to save the factorize step during normal constructor mode:

.. ipython:: python

    splitter = np.random.choice([0,1], 5, p=[0.5,0.5])
    s = pd.Series(pd.Categorical.from_codes(splitter, categories=["train", "test"]))