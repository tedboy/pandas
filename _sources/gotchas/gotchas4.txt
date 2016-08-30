.. ipython:: python
   :suppress:

   import numpy as np
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

Label-based slicing conventions
-------------------------------

Non-monotonic indexes require exact matches
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the index of a ``Series`` or ``DataFrame`` is monotonically increasing or decreasing, then the bounds
of a label-based slice can be outside the range of the index, much like slice indexing a
normal Python ``list``. Monotonicity of an index can be tested with the ``is_monotonic_increasing`` and
``is_monotonic_decreasing`` attributes.

.. ipython:: python

    df = pd.DataFrame(index=[2,3,3,4,5], columns=['data'], data=range(5))
    df.index.is_monotonic_increasing

    # no rows 0 or 1, but still returns rows 2, 3 (both of them), and 4:
    df.loc[0:4, :]

    # slice is are outside the index, so empty DataFrame is returned
    df.loc[13:15, :]

On the other hand, if the index is not monotonic, then both slice bounds must be
*unique* members of the index.

.. ipython:: python

    df = pd.DataFrame(index=[2,3,1,4,3,5], columns=['data'], data=range(6))
    df.index.is_monotonic_increasing

    # OK because 2 and 4 are in the index
    df.loc[2:4, :]

.. code-block:: python

    # 0 is not in the index
    In [9]: df.loc[0:4, :]
    KeyError: 0

    # 3 is not a unique label
    In [11]: df.loc[2:3, :]
    KeyError: 'Cannot get right slice bound for non-unique label: 3'


Endpoints are inclusive
~~~~~~~~~~~~~~~~~~~~~~~

Compared with standard Python sequence slicing in which the slice endpoint is
not inclusive, label-based slicing in pandas **is inclusive**. The primary
reason for this is that it is often not possible to easily determine the
"successor" or next element after a particular label in an index. For example,
consider the following Series:

.. ipython:: python

   s = pd.Series(np.random.randn(6), index=list('abcdef'))
   s

Suppose we wished to slice from ``c`` to ``e``, using integers this would be

.. ipython:: python

   s[2:5]

However, if you only had ``c`` and ``e``, determining the next element in the
index can be somewhat complicated. For example, the following does not work:

::

    s.ix['c':'e'+1]

A very common use case is to limit a time series to start and end at two
specific dates. To enable this, we made the design design to make label-based
slicing include both endpoints:

.. ipython:: python

    s.ix['c':'e']

This is most definitely a "practicality beats purity" sort of thing, but it is
something to watch out for if you expect label-based slicing to behave exactly
in the way that standard Python integer slicing works.