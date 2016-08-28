.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(1234567)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8


.. _indexing.class:

Index objects
-------------

The pandas :class:`~pandas.Index` class and its subclasses can be viewed as
implementing an *ordered multiset*. Duplicates are allowed. However, if you try
to convert an :class:`~pandas.Index` object with duplicate entries into a
``set``, an exception will be raised.

:class:`~pandas.Index` also provides the infrastructure necessary for
lookups, data alignment, and reindexing. The easiest way to create an
:class:`~pandas.Index` directly is to pass a ``list`` or other sequence to
:class:`~pandas.Index`:

.. ipython:: python

   index = pd.Index(['e', 'd', 'a', 'b'])
   index
   'd' in index

You can also pass a ``name`` to be stored in the index:


.. ipython:: python

   index = pd.Index(['e', 'd', 'a', 'b'], name='something')
   index
   index.name

The name, if set, will be shown in the console display:

.. ipython:: python

   index = pd.Index(list(range(5)), name='rows')
   columns = pd.Index(['A', 'B', 'C'], name='cols')
   df = pd.DataFrame(np.random.randn(5, 3), index=index, columns=columns)
   df
   df['A']

.. _indexing.set_metadata:

Setting metadata
~~~~~~~~~~~~~~~~

.. versionadded:: 0.13.0

Indexes are "mostly immutable", but it is possible to set and change their
metadata, like the index ``name`` (or, for ``MultiIndex``, ``levels`` and
``labels``).

You can use the ``rename``, ``set_names``, ``set_levels``, and ``set_labels``
to set these attributes directly. They default to returning a copy; however,
you can specify ``inplace=True`` to have the data change in place.

See :ref:`Advanced Indexing <advanced>` for usage of MultiIndexes.

.. ipython:: python

  ind = pd.Index([1, 2, 3])
  ind
  ind.rename("apple")
  ind
  ind.set_names(["apple"], inplace=True)
  ind.name = "bob"
  ind

.. versionadded:: 0.15.0

``set_names``, ``set_levels``, and ``set_labels`` also take an optional
`level`` argument

.. ipython:: python

  index = pd.MultiIndex.from_product([range(3), ['one', 'two']], names=['first', 'second'])
  index
  index.levels[1]
  index.set_levels(["a", "b"], level=1)

Set operations on Index objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _indexing.set_ops:

.. warning::

   In 0.15.0. the set operations ``+`` and ``-`` were deprecated in order to provide these for numeric type operations on certain
   index types. ``+`` can be replace by ``.union()`` or ``|``, and ``-`` by ``.difference()``.

The two main operations are ``union (|)``, ``intersection (&)``
These can be directly called as instance methods or used via overloaded
operators. Difference is provided via the ``.difference()`` method.

.. ipython:: python

   a = pd.Index(['c', 'b', 'a'])
   b = pd.Index(['c', 'e', 'd'])
   a
   b
   a | b
   a & b
   a.difference(b)

Also available is the ``symmetric_difference (^)`` operation, which returns elements
that appear in either ``idx1`` or ``idx2`` but not both. This is
equivalent to the Index created by ``idx1.difference(idx2).union(idx2.difference(idx1))``,
with duplicates dropped.

.. ipython:: python

   idx1 = pd.Index([1, 2, 3, 4])
   idx2 = pd.Index([2, 3, 4, 5])
   idx1.symmetric_difference(idx2)
   idx1 ^ idx2

Missing values
~~~~~~~~~~~~~~

.. _indexing.missing:

.. versionadded:: 0.17.1

.. important::

   Even though ``Index`` can hold missing values (``NaN``), it should be avoided
   if you do not want any unexpected results. For example, some operations
   exclude missing values implicitly.

``Index.fillna`` fills missing values with specified scalar value.

.. ipython:: python

   idx1 = pd.Index([1, np.nan, 3, 4])
   idx1
   idx1.fillna(2)

   idx2 = pd.DatetimeIndex([pd.Timestamp('2011-01-01'), pd.NaT, pd.Timestamp('2011-01-03')])
   idx2
   idx2.fillna(pd.Timestamp('2011-01-02'))   