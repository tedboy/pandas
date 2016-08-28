.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Gotchas
-------

.. _categorical.rfactor:

Memory Usage
~~~~~~~~~~~~

.. _categorical.memory:

The memory usage of a ``Categorical`` is proportional to the number of categories times the length of the data. In contrast,
an ``object`` dtype is a constant times the length of the data.

.. ipython:: python

   s = pd.Series(['foo','bar']*1000)

   # object dtype
   s.nbytes

   # category dtype
   s.astype('category').nbytes

.. note::

   If the number of categories approaches the length of the data, the ``Categorical`` will use nearly the same or
   more memory than an equivalent ``object`` dtype representation.

   .. ipython:: python

      s = pd.Series(['foo%04d' % i for i in range(2000)])

      # object dtype
      s.nbytes

      # category dtype
      s.astype('category').nbytes


Old style constructor usage
~~~~~~~~~~~~~~~~~~~~~~~~~~~

In earlier versions than pandas 0.15, a `Categorical` could be constructed by passing in precomputed
`codes` (called then `labels`) instead of values with categories. The `codes` were interpreted as
pointers to the categories with `-1` as `NaN`. This type of constructor usage is replaced by
the special constructor :func:`Categorical.from_codes`.

Unfortunately, in some special cases, using code which assumes the old style constructor usage
will work with the current pandas version, resulting in subtle bugs:

.. code-block:: python

    >>> cat = pd.Categorical([1,2], [1,2,3])
    >>> # old version
    >>> cat.get_values()
    array([2, 3], dtype=int64)
    >>> # new version
    >>> cat.get_values()
    array([1, 2], dtype=int64)

.. warning::
    If you used `Categoricals` with older versions of pandas, please audit your code before
    upgrading and change your code to use the :func:`~pandas.Categorical.from_codes`
    constructor.

`Categorical` is not a `numpy` array
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Currently, categorical data and the underlying `Categorical` is implemented as a python
object and not as a low-level `numpy` array dtype. This leads to some problems.

`numpy` itself doesn't know about the new `dtype`:

.. ipython:: python

    try:
        np.dtype("category")
    except TypeError as e:
        print("TypeError: " + str(e))

    dtype = pd.Categorical(["a"]).dtype
    try:
        np.dtype(dtype)
    except TypeError as e:
         print("TypeError: " + str(e))

Dtype comparisons work:

.. ipython:: python

    dtype == np.str_
    np.str_ == dtype

To check if a Series contains Categorical data, with pandas 0.16 or later, use
``hasattr(s, 'cat')``:

.. ipython:: python

    hasattr(pd.Series(['a'], dtype='category'), 'cat')
    hasattr(pd.Series(['a']), 'cat')

Using `numpy` functions on a `Series` of type ``category`` should not work as `Categoricals`
are not numeric data (even in the case that ``.categories`` is numeric).

.. ipython:: python

    s = pd.Series(pd.Categorical([1,2,3,4]))
    try:
        np.sum(s)
        #same with np.log(s),..
    except TypeError as e:
         print("TypeError: " + str(e))

.. note::
    If such a function works, please file a bug at https://github.com/pydata/pandas!

dtype in apply
~~~~~~~~~~~~~~

Pandas currently does not preserve the dtype in apply functions: If you apply along rows you get
a `Series` of ``object`` `dtype` (same as getting a row -> getting one element will return a
basic type) and applying along columns will also convert to object.

.. ipython:: python

    df = pd.DataFrame({"a":[1,2,3,4],
                       "b":["a","b","c","d"],
                       "cats":pd.Categorical([1,2,3,2])})
    df.apply(lambda row: type(row["cats"]), axis=1)
    df.apply(lambda col: col.dtype, axis=0)

Categorical Index
~~~~~~~~~~~~~~~~~

.. versionadded:: 0.16.1

A new ``CategoricalIndex`` index type is introduced in version 0.16.1. See the
:ref:`advanced indexing docs <indexing.categoricalindex>` for a more detailed
explanation.

Setting the index, will create create a ``CategoricalIndex``

.. ipython:: python

    cats = pd.Categorical([1,2,3,4], categories=[4,2,3,1])
    strings = ["a","b","c","d"]
    values = [4,2,3,1]
    df = pd.DataFrame({"strings":strings, "values":values}, index=cats)
    df.index
    # This now sorts by the categories order
    df.sort_index()

In previous versions (<0.16.1) there is no index of type ``category``, so
setting the index to categorical column will convert the categorical data to a
"normal" dtype first and therefore remove any custom ordering of the categories.

Side Effects
~~~~~~~~~~~~

Constructing a `Series` from a `Categorical` will not copy the input `Categorical`. This
means that changes to the `Series` will in most cases change the original `Categorical`:

.. ipython:: python

    cat = pd.Categorical([1,2,3,10], categories=[1,2,3,4,10])
    s = pd.Series(cat, name="cat")
    cat
    s.iloc[0:2] = 10
    cat
    df = pd.DataFrame(s)
    df["cat"].cat.categories = [1,2,3,4,5]
    cat

Use ``copy=True`` to prevent such a behaviour or simply don't reuse `Categoricals`:

.. ipython:: python

    cat = pd.Categorical([1,2,3,10], categories=[1,2,3,4,10])
    s = pd.Series(cat, name="cat", copy=True)
    cat
    s.iloc[0:2] = 10
    cat

.. note::
    This also happens in some cases when you supply a `numpy` array instead of a `Categorical`:
    using an int array (e.g. ``np.array([1,2,3,4])``) will exhibit the same behaviour, while using
    a string array (e.g. ``np.array(["a","b","c","a"])``) will not.
