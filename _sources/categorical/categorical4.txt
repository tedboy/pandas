.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Working with categories
-----------------------

Categorical data has a `categories` and a `ordered` property, which list their possible values and
whether the ordering matters or not. These properties are exposed as ``s.cat.categories`` and
``s.cat.ordered``. If you don't manually specify categories and ordering, they are inferred from the
passed in values.

.. ipython:: python

    s = pd.Series(["a","b","c","a"], dtype="category")
    s.cat.categories
    s.cat.ordered

It's also possible to pass in the categories in a specific order:

.. ipython:: python

    s = pd.Series(pd.Categorical(["a","b","c","a"], categories=["c","b","a"]))
    s.cat.categories
    s.cat.ordered

.. note::

    New categorical data are NOT automatically ordered. You must explicitly pass ``ordered=True`` to
    indicate an ordered ``Categorical``.


.. note::

    The result of ``Series.unique()`` is not always the same as ``Series.cat.categories``,
    because ``Series.unique()`` has a couple of guarantees, namely that it returns categories
    in the order of appearance, and it only includes values that are actually present.

    .. ipython:: python

         s = pd.Series(list('babc')).astype('category', categories=list('abcd'))
         s

         # categories
         s.cat.categories

         # uniques
         s.unique()

Renaming categories
~~~~~~~~~~~~~~~~~~~

Renaming categories is done by assigning new values to the ``Series.cat.categories`` property or
by using the :func:`Categorical.rename_categories` method:

.. ipython:: python

    s = pd.Series(["a","b","c","a"], dtype="category")
    s
    s.cat.categories = ["Group %s" % g for g in s.cat.categories]
    s
    s.cat.rename_categories([1,2,3])

.. note::

    In contrast to R's `factor`, categorical data can have categories of other types than string.

.. note::

    Be aware that assigning new categories is an inplace operations, while most other operation
    under ``Series.cat`` per default return a new Series of dtype `category`.

Categories must be unique or a `ValueError` is raised:

.. ipython:: python

    try:
        s.cat.categories = [1,1,1]
    except ValueError as e:
        print("ValueError: " + str(e))

Appending new categories
~~~~~~~~~~~~~~~~~~~~~~~~

Appending categories can be done by using the :func:`Categorical.add_categories` method:

.. ipython:: python

    s = s.cat.add_categories([4])
    s.cat.categories
    s

Removing categories
~~~~~~~~~~~~~~~~~~~

Removing categories can be done by using the :func:`Categorical.remove_categories` method. Values
which are removed are replaced by ``np.nan``.:

.. ipython:: python

    s = s.cat.remove_categories([4])
    s

Removing unused categories
~~~~~~~~~~~~~~~~~~~~~~~~~~

Removing unused categories can also be done:

.. ipython:: python

    s = pd.Series(pd.Categorical(["a","b","a"], categories=["a","b","c","d"]))
    s
    s.cat.remove_unused_categories()

Setting categories
~~~~~~~~~~~~~~~~~~

If you want to do remove and add new categories in one step (which has some speed advantage),
or simply set the categories to a predefined scale, use :func:`Categorical.set_categories`.

.. ipython:: python

    s = pd.Series(["one","two","four", "-"], dtype="category")
    s
    s = s.cat.set_categories(["one","two","three","four"])
    s

.. note::
    Be aware that :func:`Categorical.set_categories` cannot know whether some category is omitted
    intentionally or because it is misspelled or (under Python3) due to a type difference (e.g.,
    numpys S1 dtype and python strings). This can result in surprising behaviour!