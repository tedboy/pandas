.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   randn = np.random.randn
   np.set_printoptions(precision=4, suppress=True)
   from pandas.compat import lrange
   pd.options.display.max_rows=8
   
.. _text.string_methods:

Introduction
------------

Series and Index are equipped with a set of string processing methods
that make it easy to operate on each element of the array. Perhaps most
importantly, these methods exclude missing/NA values automatically. These are
accessed via the ``str`` attribute and generally have names matching
the equivalent (scalar) built-in string methods:

.. ipython:: python

   s = pd.Series(['A', 'B', 'C', 'Aaba', 'Baca', np.nan, 'CABA', 'dog', 'cat'])
   s.str.lower()
   s.str.upper()
   s.str.len()

.. ipython:: python

   idx = pd.Index([' jack', 'jill ', ' jesse ', 'frank'])
   idx.str.strip()
   idx.str.lstrip()
   idx.str.rstrip()

The string methods on Index are especially useful for cleaning up or
transforming DataFrame columns. For instance, you may have columns with
leading or trailing whitespace:

.. ipython:: python

   df = pd.DataFrame(randn(3, 2), columns=[' Column A ', ' Column B '],
                     index=range(3))
   df

Since ``df.columns`` is an Index object, we can use the ``.str`` accessor

.. ipython:: python

   df.columns.str.strip()
   df.columns.str.lower()

These string methods can then be used to clean up the columns as needed.
Here we are removing leading and trailing whitespaces, lowercasing all names,
and replacing any remaining whitespaces with underscores:

.. ipython:: python

   df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_')
   df

.. note::

    If you have a ``Series`` where lots of elements are repeated
    (i.e. the number of unique elements in the ``Series`` is a lot smaller than the length of the
    ``Series``), it can be faster to convert the original ``Series`` to one of type
    ``category`` and then use ``.str.<method>`` or ``.dt.<property>`` on that.
    The performance difference comes from the fact that, for ``Series`` of type ``category``, the
    string operations are done on the ``.categories`` and not on each element of the
    ``Series``.

    Please note that a ``Series`` of type ``category`` with string ``.categories`` has
    some limitations in comparison of ``Series`` of type string (e.g. you can't add strings to
    each other: ``s + " " + s`` won't work if ``s`` is a ``Series`` of type ``category``). Also,
    ``.str`` methods which operate on elements of type ``list`` are not available on such a
    ``Series``.