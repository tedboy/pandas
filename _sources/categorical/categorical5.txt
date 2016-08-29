.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Sorting and Order
-----------------

.. _categorical.sort:

.. warning::

   The default for construction has changed in v0.16.0 to ``ordered=False``, from the prior implicit ``ordered=True``

If categorical data is ordered (``s.cat.ordered == True``), then the order of the categories has a
meaning and certain operations are possible. If the categorical is unordered, ``.min()/.max()`` will raise a `TypeError`.

.. ipython:: python

    s = pd.Series(pd.Categorical(["a","b","c","a"], ordered=False))
    s.sort_values(inplace=True)
    s = pd.Series(["a","b","c","a"]).astype('category', ordered=True)
    s.sort_values(inplace=True)
    s
    s.min(), s.max()

You can set categorical data to be ordered by using ``as_ordered()`` or unordered by using ``as_unordered()``. These will by
default return a *new* object.

.. ipython:: python

    s.cat.as_ordered()
    s.cat.as_unordered()

Sorting will use the order defined by categories, not any lexical order present on the data type.
This is even true for strings and numeric data:

.. ipython:: python

    s = pd.Series([1,2,3,1], dtype="category")
    s = s.cat.set_categories([2,3,1], ordered=True)
    s
    s.sort_values(inplace=True)
    s
    s.min(), s.max()


Reordering
~~~~~~~~~~

Reordering the categories is possible via the :func:`Categorical.reorder_categories` and
the :func:`Categorical.set_categories` methods. For :func:`Categorical.reorder_categories`, all
old categories must be included in the new categories and no new categories are allowed. This will
necessarily make the sort order the same as the categories order.

.. ipython:: python

    s = pd.Series([1,2,3,1], dtype="category")
    s = s.cat.reorder_categories([2,3,1], ordered=True)
    s
    s.sort_values(inplace=True)
    s
    s.min(), s.max()

.. note::

    Note the difference between assigning new categories and reordering the categories: the first
    renames categories and therefore the individual values in the `Series`, but if the first
    position was sorted last, the renamed value will still be sorted last. Reordering means that the
    way values are sorted is different afterwards, but not that individual values in the
    `Series` are changed.

.. note::

    If the `Categorical` is not ordered, ``Series.min()`` and ``Series.max()`` will raise
    ``TypeError``. Numeric operations like ``+``, ``-``, ``*``, ``/`` and operations based on them
    (e.g. ``Series.median()``, which would need to compute the mean between two values if the length
    of an array is even) do not work and raise a ``TypeError``.

Multi Column Sorting
~~~~~~~~~~~~~~~~~~~~

A categorical dtyped column will participate in a multi-column sort in a similar manner to other columns.
The ordering of the categorical is determined by the ``categories`` of that column.

.. ipython:: python

   dfs = pd.DataFrame({'A' : pd.Categorical(list('bbeebbaa'), categories=['e','a','b'], ordered=True),
                       'B' : [1,2,1,2,2,1,2,1] })
   dfs.sort_values(by=['A', 'B'])

Reordering the ``categories`` changes a future sort.

.. ipython:: python

   dfs['A'] = dfs['A'].cat.reorder_categories(['a','b','e'])
   dfs.sort_values(by=['A','B'])