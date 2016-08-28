.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Comparisons
-----------

Comparing categorical data with other objects is possible in three cases:

 * comparing equality (``==`` and ``!=``) to a list-like object (list, Series, array,
   ...) of the same length as the categorical data.
 * all comparisons (``==``, ``!=``, ``>``, ``>=``, ``<``, and ``<=``) of categorical data to
   another categorical Series, when ``ordered==True`` and the `categories` are the same.
 * all comparisons of a categorical data to a scalar.

All other comparisons, especially "non-equality" comparisons of two categoricals with different
categories or a categorical with any list-like object, will raise a TypeError.

.. note::

    Any "non-equality" comparisons of categorical data with a `Series`, `np.array`, `list` or
    categorical data with different categories or ordering will raise an `TypeError` because custom
    categories ordering could be interpreted in two ways: one with taking into account the
    ordering and one without.

.. ipython:: python

    cat = pd.Series([1,2,3]).astype("category", categories=[3,2,1], ordered=True)
    cat_base = pd.Series([2,2,2]).astype("category", categories=[3,2,1], ordered=True)
    cat_base2 = pd.Series([2,2,2]).astype("category", ordered=True)

    cat
    cat_base
    cat_base2

Comparing to a categorical with the same categories and ordering or to a scalar works:

.. ipython:: python

    cat > cat_base
    cat > 2

Equality comparisons work with any list-like object of same length and scalars:

.. ipython:: python

    cat == cat_base
    cat == np.array([1,2,3])
    cat == 2

This doesn't work because the categories are not the same:

.. ipython:: python

    try:
        cat > cat_base2
    except TypeError as e:
         print("TypeError: " + str(e))

If you want to do a "non-equality" comparison of a categorical series with a list-like object
which is not categorical data, you need to be explicit and convert the categorical data back to
the original values:

.. ipython:: python

    base = np.array([1,2,3])

    try:
        cat > base
    except TypeError as e:
         print("TypeError: " + str(e))

    np.asarray(cat) > base