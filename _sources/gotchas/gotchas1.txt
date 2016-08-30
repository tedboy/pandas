.. ipython:: python
   :suppress:

   import numpy as np
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. _gotchas.truth:

Using If/Truth Statements with pandas
-------------------------------------

pandas follows the numpy convention of raising an error when you try to convert something to a ``bool``.
This happens in a ``if`` or when using the boolean operations, ``and``, ``or``, or ``not``.  It is not clear
what the result of

.. code-block:: python

    >>> if pd.Series([False, True, False]):
         ...

should be. Should it be ``True`` because it's not zero-length? ``False`` because there are ``False`` values?
It is unclear, so instead, pandas raises a ``ValueError``:

.. code-block:: python

    >>> if pd.Series([False, True, False]):
        print("I was true")
    Traceback
        ...
    ValueError: The truth value of an array is ambiguous. Use a.empty, a.any() or a.all().


If you see that, you need to explicitly choose what you want to do with it (e.g., use `any()`, `all()` or `empty`).
or, you might want to compare if the pandas object is ``None``

.. code-block:: python

    >>> if pd.Series([False, True, False]) is not None:
           print("I was not None")
    >>> I was not None


or return if ``any`` value is ``True``.

.. code-block:: python

    >>> if pd.Series([False, True, False]).any():
           print("I am any")
    >>> I am any

To evaluate single-element pandas objects in a boolean context, use the method ``.bool()``:

.. ipython:: python

   pd.Series([True]).bool()
   pd.Series([False]).bool()
   pd.DataFrame([[True]]).bool()
   pd.DataFrame([[False]]).bool()

Bitwise boolean
~~~~~~~~~~~~~~~

Bitwise boolean operators like ``==`` and ``!=`` will return a boolean ``Series``,
which is almost always what you want anyways.

.. code-block:: python

   >>> s = pd.Series(range(5))
   >>> s == 4
   0    False
   1    False
   2    False
   3    False
   4     True
   dtype: bool

See :ref:`boolean comparisons<basics.compare>` for more examples.

Using the ``in`` operator
~~~~~~~~~~~~~~~~~~~~~~~~~

Using the Python ``in`` operator on a Series tests for membership in the
index, not membership among the values.

.. ipython::

    s = pd.Series(range(5), index=list('abcde'))
    2 in s
    'b' in s

If this behavior is surprising, keep in mind that using ``in`` on a Python
dictionary tests keys, not values, and Series are dict-like.
To test for membership in the values, use the method :func:`~pandas.Series.isin`:

.. ipython::

    s.isin([2])
    s.isin([2]).any()

For DataFrames, likewise, ``in`` applies to the column axis,
testing for membership in the list of column names.