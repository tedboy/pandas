.. ipython:: python
   :suppress:

   import numpy as np
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.set_option('display.precision', 4, 'display.max_columns', 8)
   pd.options.display.max_rows = 8

   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')

.. _basics.series:

Series
------

.. warning::

   In 0.13.0 ``Series`` has internally been refactored to no longer sub-class ``ndarray``
   but instead subclass ``NDFrame``, similarly to the rest of the pandas containers. This should be
   a transparent change with only very limited API implications (See the :ref:`Internal Refactoring<whatsnew_0130.refactoring>`)

:class:`Series` is a one-dimensional labeled array capable of holding any data
type (integers, strings, floating point numbers, Python objects, etc.). The axis
labels are collectively referred to as the **index**. The basic method to create a Series is to call:

::

    >>> s = pd.Series(data, index=index)

Here, ``data`` can be many different things:

 - a Python dict
 - an ndarray
 - a scalar value (like 5)

The passed **index** is a list of axis labels. Thus, this separates into a few
cases depending on what **data is**:

**From ndarray**

If ``data`` is an ndarray, **index** must be the same length as **data**. If no
index is passed, one will be created having values ``[0, ..., len(data) - 1]``.

.. ipython:: python

   s = pd.Series(np.random.randn(5), index=['a', 'b', 'c', 'd', 'e'])
   s
   s.index

   pd.Series(np.random.randn(5))

.. note::

    Starting in v0.8.0, pandas supports non-unique index values. If an operation
    that does not support duplicate index values is attempted, an exception
    will be raised at that time. The reason for being lazy is nearly all performance-based
    (there are many instances in computations, like parts of GroupBy, where the index
    is not used).

**From dict**

If ``data`` is a dict, if **index** is passed the values in data corresponding
to the labels in the index will be pulled out. Otherwise, an index will be
constructed from the sorted keys of the dict, if possible.

.. ipython:: python

   d = {'a' : 0., 'b' : 1., 'c' : 2.}
   pd.Series(d)
   pd.Series(d, index=['b', 'c', 'd', 'a'])

.. note::

    NaN (not a number) is the standard missing data marker used in pandas

**From scalar value** If ``data`` is a scalar value, an index must be
provided. The value will be repeated to match the length of **index**

.. ipython:: python

   pd.Series(5., index=['a', 'b', 'c', 'd', 'e'])

Series is ndarray-like
~~~~~~~~~~~~~~~~~~~~~~

``Series`` acts very similarly to a ``ndarray``, and is a valid argument to most NumPy functions.
However, things like slicing also slice the index.

.. ipython :: python

    s[0]
    s[:3]
    s[s > s.median()]
    s[[4, 3, 1]]
    np.exp(s)

We will address array-based indexing in a separate :ref:`section <indexing>`.

Series is dict-like
~~~~~~~~~~~~~~~~~~~

A Series is like a fixed-size dict in that you can get and set values by index
label:

.. ipython :: python

    s['a']
    s['e'] = 12.
    s
    'e' in s
    'f' in s

If a label is not contained, an exception is raised:

.. code-block:: python

    >>> s['f']
    KeyError: 'f'

Using the ``get`` method, a missing label will return None or specified default:

.. ipython:: python

   s.get('f')

   s.get('f', np.nan)

See also the :ref:`section on attribute access<indexing.attribute_access>`.

Vectorized operations and label alignment with Series
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When doing data analysis, as with raw NumPy arrays looping through Series
value-by-value is usually not necessary. Series can be also be passed into most
NumPy methods expecting an ndarray.


.. ipython:: python

    s + s
    s * 2
    np.exp(s)

A key difference between Series and ndarray is that operations between Series
automatically align the data based on label. Thus, you can write computations
without giving consideration to whether the Series involved have the same
labels.

.. ipython:: python

    s[1:] + s[:-1]

The result of an operation between unaligned Series will have the **union** of
the indexes involved. If a label is not found in one Series or the other, the
result will be marked as missing ``NaN``. Being able to write code without doing
any explicit data alignment grants immense freedom and flexibility in
interactive data analysis and research. The integrated data alignment features
of the pandas data structures set pandas apart from the majority of related
tools for working with labeled data.

.. note::

    In general, we chose to make the default result of operations between
    differently indexed objects yield the **union** of the indexes in order to
    avoid loss of information. Having an index label, though the data is
    missing, is typically important information as part of a computation. You
    of course have the option of dropping labels with missing data via the
    **dropna** function.

Name attribute
~~~~~~~~~~~~~~

.. _dsintro.name_attribute:

Series can also have a ``name`` attribute:

.. ipython:: python

   s = pd.Series(np.random.randn(5), name='something')
   s
   s.name

The Series ``name`` will be assigned automatically in many cases, in particular
when taking 1D slices of DataFrame as you will see below.

.. versionadded:: 0.18.0

You can rename a Series with the :meth:`pandas.Series.rename` method.

.. ipython:: python

   s2 = s.rename("different")
   s2.name

Note that ``s`` and ``s2`` refer to different objects.   