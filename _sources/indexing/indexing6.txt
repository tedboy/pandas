.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. ipython:: python
   :suppress:

   dates = pd.date_range('1/1/2000', periods=8)
   df = pd.DataFrame(np.random.randn(8, 4), index=dates, columns=['A', 'B', 'C', 'D'])
   s = df['A']
   panel = pd.Panel({'one' : df, 'two' : df - df.mean()})

.. _indexing.integer:

Selection By Position
---------------------

.. warning::

   Whether a copy or a reference is returned for a setting operation, may depend on the context.
   This is sometimes called ``chained assignment`` and should be avoided.
   See :ref:`Returning a View versus Copy <indexing.view_versus_copy>`

pandas provides a suite of methods in order to get **purely integer based indexing**. The semantics follow closely python and numpy slicing. These are ``0-based`` indexing. When slicing, the start bounds is *included*, while the upper bound is *excluded*. Trying to use a non-integer, even a **valid** label will raise a ``IndexError``.

The ``.iloc`` attribute is the primary access method. The following are valid inputs:

- An integer e.g. ``5``
- A list or array of integers ``[4, 3, 0]``
- A slice object with ints ``1:7``
- A boolean array
- A ``callable``, see :ref:`Selection By Callable <indexing.callable>`

.. ipython:: python

   s1 = pd.Series(np.random.randn(5), index=list(range(0,10,2)))
   s1
   s1.iloc[:3]
   s1.iloc[3]

Note that setting works as well:

.. ipython:: python

   s1.iloc[:3] = 0
   s1

With a DataFrame

.. ipython:: python

   df1 = pd.DataFrame(np.random.randn(6,4),
                      index=list(range(0,12,2)),
                      columns=list(range(0,8,2)))
   df1

Select via integer slicing

.. ipython:: python

   df1.iloc[:3]
   df1.iloc[1:5, 2:4]

Select via integer list

.. ipython:: python

   df1.iloc[[1, 3, 5], [1, 3]]

.. ipython:: python

   df1.iloc[1:3, :]

.. ipython:: python

   df1.iloc[:, 1:3]

.. ipython:: python

   # this is also equivalent to ``df1.iat[1,1]``
   df1.iloc[1, 1]

For getting a cross section using an integer position (equiv to ``df.xs(1)``)

.. ipython:: python

   df1.iloc[1]

Out of range slice indexes are handled gracefully just as in Python/Numpy.

.. ipython:: python

    # these are allowed in python/numpy.
    # Only works in Pandas starting from v0.14.0.
    x = list('abcdef')
    x
    x[4:10]
    x[8:10]
    s = pd.Series(x)
    s
    s.iloc[4:10]
    s.iloc[8:10]

.. note::

    Prior to v0.14.0, ``iloc`` would not accept out of bounds indexers for
    slices, e.g. a value that exceeds the length of the object being indexed.


Note that this could result in an empty axis (e.g. an empty DataFrame being
returned)

.. ipython:: python

   dfl = pd.DataFrame(np.random.randn(5,2), columns=list('AB'))
   dfl
   dfl.iloc[:, 2:3]
   dfl.iloc[:, 1:3]
   dfl.iloc[4:6]

A single indexer that is out of bounds will raise an ``IndexError``.
A list of indexers where any element is out of bounds will raise an
``IndexError``

.. code-block:: python

   dfl.iloc[[4, 5, 6]]
   IndexError: positional indexers are out-of-bounds

   dfl.iloc[:, 4]
   IndexError: single positional indexer is out-of-bounds
