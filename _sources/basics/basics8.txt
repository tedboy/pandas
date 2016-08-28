.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

.. _basics.iteration:

Iteration
---------

The behavior of basic iteration over pandas objects depends on the type.
When iterating over a Series, it is regarded as array-like, and basic iteration
produces the values. Other data structures, like DataFrame and Panel,
follow the dict-like convention of iterating over the "keys" of the
objects.

In short, basic iteration (``for i in object``) produces:

* **Series**: values
* **DataFrame**: column labels
* **Panel**: item labels

Thus, for example, iterating over a DataFrame gives you the column names:

.. ipython::

    In [0]: df = pd.DataFrame({'col1' : np.random.randn(3), 'col2' : np.random.randn(3)},
       ...:                   index=['a', 'b', 'c'])

    In [0]: for col in df:
       ...:     print(col)
       ...:

Pandas objects also have the dict-like :meth:`~DataFrame.iteritems` method to
iterate over the (key, value) pairs.

To iterate over the rows of a DataFrame, you can use the following methods:

* :meth:`~DataFrame.iterrows`: Iterate over the rows of a DataFrame as (index, Series) pairs.
  This converts the rows to Series objects, which can change the dtypes and has some
  performance implications.
* :meth:`~DataFrame.itertuples`: Iterate over the rows of a DataFrame
  as namedtuples of the values.  This is a lot faster than
  :meth:`~DataFrame.iterrows`, and is in most cases preferable to use
  to iterate over the values of a DataFrame.

.. warning::

  Iterating through pandas objects is generally **slow**. In many cases,
  iterating manually over the rows is not needed and can be avoided with
  one of the following approaches:

  * Look for a *vectorized* solution: many operations can be performed using
    built-in methods or numpy functions, (boolean) indexing, ...

  * When you have a function that cannot work on the full DataFrame/Series
    at once, it is better to use :meth:`~DataFrame.apply` instead of iterating
    over the values. See the docs on :ref:`function application <basics.apply>`.

  * If you need to do iterative manipulations on the values but performance is
    important, consider writing the inner loop using e.g. cython or numba.
    See the :ref:`enhancing performance <enhancingperf>` section for some
    examples of this approach.

.. warning::

  You should **never modify** something you are iterating over.
  This is not guaranteed to work in all cases. Depending on the
  data types, the iterator returns a copy and not a view, and writing
  to it will have no effect!

  For example, in the following case setting the value has no effect:

  .. ipython:: python

    df = pd.DataFrame({'a': [1, 2, 3], 'b': ['a', 'b', 'c']})

    for index, row in df.iterrows():
        row['a'] = 10

    df

iteritems
~~~~~~~~~

Consistent with the dict-like interface, :meth:`~DataFrame.iteritems` iterates
through key-value pairs:

* **Series**: (index, scalar value) pairs
* **DataFrame**: (column, Series) pairs
* **Panel**: (item, DataFrame) pairs

For example:

.. ipython::

   In [0]: for item, frame in wp.iteritems():
      ...:     print(item)
      ...:     print(frame)
      ...:

.. _basics.iterrows:

iterrows
~~~~~~~~

:meth:`~DataFrame.iterrows` allows you to iterate through the rows of a
DataFrame as Series objects. It returns an iterator yielding each
index value along with a Series containing the data in each row:

.. ipython::

   In [0]: for row_index, row in df.iterrows():
      ...:     print('%s\n%s' % (row_index, row))
      ...:

.. note::

   Because :meth:`~DataFrame.iterrows` returns a Series for each row,
   it does **not** preserve dtypes across the rows (dtypes are
   preserved across columns for DataFrames). For example,

   .. ipython:: python

      df_orig = pd.DataFrame([[1, 1.5]], columns=['int', 'float'])
      df_orig.dtypes
      row = next(df_orig.iterrows())[1]
      row

   All values in ``row``, returned as a Series, are now upcasted
   to floats, also the original integer value in column `x`:

   .. ipython:: python

      row['int'].dtype
      df_orig['int'].dtype

   To preserve dtypes while iterating over the rows, it is better
   to use :meth:`~DataFrame.itertuples` which returns namedtuples of the values
   and which is generally much faster as ``iterrows``.

For instance, a contrived way to transpose the DataFrame would be:

.. ipython:: python

   df2 = pd.DataFrame({'x': [1, 2, 3], 'y': [4, 5, 6]})
   print(df2)
   print(df2.T)

   df2_t = pd.DataFrame(dict((idx,values) for idx, values in df2.iterrows()))
   print(df2_t)

itertuples
~~~~~~~~~~

The :meth:`~DataFrame.itertuples` method will return an iterator
yielding a namedtuple for each row in the DataFrame. The first element
of the tuple will be the row's corresponding index value, while the
remaining values are the row values.

For instance,

.. ipython:: python

   for row in df.itertuples():
       print(row)

This method does not convert the row to a Series object but just
returns the values inside a namedtuple. Therefore,
:meth:`~DataFrame.itertuples` preserves the data type of the values
and is generally faster as :meth:`~DataFrame.iterrows`.

.. note::

   The column names will be renamed to positional names if they are
   invalid Python identifiers, repeated, or start with an underscore.
   With a large number of columns (>255), regular tuples are returned.
