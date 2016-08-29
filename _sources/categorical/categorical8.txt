.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Data munging
------------

The optimized pandas data access methods  ``.loc``, ``.iloc``, ``.ix`` ``.at``, and ``.iat``,
work as normal. The only difference is the return type (for getting) and
that only values already in `categories` can be assigned.

Getting
~~~~~~~

If the slicing operation returns either a `DataFrame` or a column of type `Series`,
the ``category`` dtype is preserved.

.. ipython:: python

    idx = pd.Index(["h","i","j","k","l","m","n",])
    cats = pd.Series(["a","b","b","b","c","c","c"], dtype="category", index=idx)
    values= [1,2,2,2,3,4,5]
    df = pd.DataFrame({"cats":cats,"values":values}, index=idx)
    df.iloc[2:4,:]
    df.iloc[2:4,:].dtypes
    df.loc["h":"j","cats"]
    df.ix["h":"j",0:1]
    df[df["cats"] == "b"]

An example where the category type is not preserved is if you take one single row: the
resulting `Series` is of dtype ``object``:

.. ipython:: python

    # get the complete "h" row as a Series
    df.loc["h", :]

Returning a single item from categorical data will also return the value, not a categorical
of length "1".

.. ipython:: python

    df.iat[0,0]
    df["cats"].cat.categories = ["x","y","z"]
    df.at["h","cats"] # returns a string

.. note::
    This is a difference to R's `factor` function, where ``factor(c(1,2,3))[1]``
    returns a single value `factor`.

To get a single value `Series` of type ``category`` pass in a list with a single value:

.. ipython:: python

    df.loc[["h"],"cats"]

String and datetime accessors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.17.1

The accessors  ``.dt`` and ``.str`` will work if the ``s.cat.categories`` are of an appropriate
type:


.. ipython:: python

    str_s = pd.Series(list('aabb'))
    str_cat = str_s.astype('category')
    str_cat
    str_cat.str.contains("a")

    date_s = pd.Series(pd.date_range('1/1/2015', periods=5))
    date_cat = date_s.astype('category')
    date_cat
    date_cat.dt.day

.. note::

    The returned ``Series`` (or ``DataFrame``) is of the same type as if you used the
    ``.str.<method>`` / ``.dt.<method>`` on a ``Series`` of that type (and not of
    type ``category``!).

That means, that the returned values from methods and properties on the accessors of a
``Series`` and the returned values from methods and properties on the accessors of this
``Series`` transformed to one of type `category` will be equal:

.. ipython:: python

    ret_s = str_s.str.contains("a")
    ret_cat = str_cat.str.contains("a")
    ret_s.dtype == ret_cat.dtype
    ret_s == ret_cat

.. note::

    The work is done on the ``categories`` and then a new ``Series`` is constructed. This has
    some performance implication if you have a ``Series`` of type string, where lots of elements
    are repeated (i.e. the number of unique elements in the ``Series`` is a lot smaller than the
    length of the ``Series``). In this case it can be faster to convert the original ``Series``
    to one of type ``category`` and use ``.str.<method>`` or ``.dt.<property>`` on that.

Setting
~~~~~~~

Setting values in a categorical column (or `Series`) works as long as the value is included in the
`categories`:

.. ipython:: python

    idx = pd.Index(["h","i","j","k","l","m","n"])
    cats = pd.Categorical(["a","a","a","a","a","a","a"], categories=["a","b"])
    values = [1,1,1,1,1,1,1]
    df = pd.DataFrame({"cats":cats,"values":values}, index=idx)

    df.iloc[2:4,:] = [["b",2],["b",2]]
    df
    try:
        df.iloc[2:4,:] = [["c",3],["c",3]]
    except ValueError as e:
        print("ValueError: " + str(e))

Setting values by assigning categorical data will also check that the `categories` match:

.. ipython:: python

    df.loc["j":"k","cats"] = pd.Categorical(["a","a"], categories=["a","b"])
    df
    try:
        df.loc["j":"k","cats"] = pd.Categorical(["b","b"], categories=["a","b","c"])
    except ValueError as e:
        print("ValueError: " + str(e))

Assigning a `Categorical` to parts of a column of other types will use the values:

.. ipython:: python

    df = pd.DataFrame({"a":[1,1,1,1,1], "b":["a","a","a","a","a"]})
    df.loc[1:2,"a"] = pd.Categorical(["b","b"], categories=["a","b"])
    df.loc[2:3,"b"] = pd.Categorical(["b","b"], categories=["a","b"])
    df
    df.dtypes


Merging
~~~~~~~

You can concat two `DataFrames` containing categorical data together,
but the categories of these categoricals need to be the same:

.. ipython:: python

    cat = pd.Series(["a","b"], dtype="category")
    vals = [1,2]
    df = pd.DataFrame({"cats":cat, "vals":vals})
    res = pd.concat([df,df])
    res
    res.dtypes

In this case the categories are not the same and so an error is raised:

.. ipython:: python

    df_different = df.copy()
    df_different["cats"].cat.categories = ["c","d"]
    try:
        pd.concat([df,df_different])
    except ValueError as e:
        print("ValueError: " + str(e))

The same applies to ``df.append(df_different)``.

.. _categorical.union:

Unioning
~~~~~~~~

.. versionadded:: 0.19.0

If you want to combine categoricals that do not necessarily have
the same categories, the ``union_categoricals`` function will
combine a list-like of categoricals. The new categories
will be the union of the categories being combined.

.. ipython:: python

    from pandas.types.concat import union_categoricals
    a = pd.Categorical(["b", "c"])
    b = pd.Categorical(["a", "b"])
    union_categoricals([a, b])

By default, the resulting categories will be ordered as
they appear in the data. If you want the categories to
be lexsorted, use ``sort_categories=True`` argument.

.. ipython:: python

    union_categoricals([a, b], sort_categories=True)

.. note::

   In addition to the "easy" case of combining two categoricals of the same
   categories and order information (e.g. what you could also ``append`` for),
   ``union_categoricals`` only works with unordered categoricals and will
   raise if any are ordered.