.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(1234567)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. ipython:: python

   index = pd.MultiIndex.from_product([range(3), ['one', 'two']], names=['first', 'second'])

.. _indexing.query:

The :meth:`~pandas.DataFrame.query` Method (Experimental)
---------------------------------------------------------

.. versionadded:: 0.13

:class:`~pandas.DataFrame` objects have a :meth:`~pandas.DataFrame.query`
method that allows selection using an expression.

You can get the value of the frame where column ``b`` has values
between the values of columns ``a`` and ``c``. For example:

.. ipython:: python

   n = 10
   df = pd.DataFrame(np.random.rand(n, 3), columns=list('abc'))
   df

   # pure python
   df[(df.a < df.b) & (df.b < df.c)]

   # query
   df.query('(a < b) & (b < c)')

Do the same thing but fall back on a named index if there is no column
with the name ``a``.

.. ipython:: python

   df = pd.DataFrame(np.random.randint(n / 2, size=(n, 2)), columns=list('bc'))
   df.index.name = 'a'
   df
   df.query('a < b and b < c')

If instead you don't want to or cannot name your index, you can use the name
``index`` in your query expression:

.. ipython:: python
   :suppress:

   old_index = index
   del index

.. ipython:: python

   df = pd.DataFrame(np.random.randint(n, size=(n, 2)), columns=list('bc'))
   df
   df.query('index < b < c')

.. ipython:: python
   :suppress:

   index = old_index
   del old_index


.. note::

   If the name of your index overlaps with a column name, the column name is
   given precedence. For example,

   .. ipython:: python

      df = pd.DataFrame({'a': np.random.randint(5, size=5)})
      df.index.name = 'a'
      df.query('a > 2') # uses the column 'a', not the index

   You can still use the index in a query expression by using the special
   identifier 'index':

   .. ipython:: python

      df.query('index > 2')

   If for some reason you have a column named ``index``, then you can refer to
   the index as ``ilevel_0`` as well, but at this point you should consider
   renaming your columns to something less ambiguous.


:class:`~pandas.MultiIndex` :meth:`~pandas.DataFrame.query` Syntax
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can also use the levels of a ``DataFrame`` with a
:class:`~pandas.MultiIndex` as if they were columns in the frame:

.. ipython:: python

   n = 10
   colors = np.random.choice(['red', 'green'], size=n)
   foods = np.random.choice(['eggs', 'ham'], size=n)
   colors
   foods

   index = pd.MultiIndex.from_arrays([colors, foods], names=['color', 'food'])
   df = pd.DataFrame(np.random.randn(n, 2), index=index)
   df
   df.query('color == "red"')

If the levels of the ``MultiIndex`` are unnamed, you can refer to them using
special names:

.. ipython:: python

   df.index.names = [None, None]
   df
   df.query('ilevel_0 == "red"')


The convention is ``ilevel_0``, which means "index level 0" for the 0th level
of the ``index``.


:meth:`~pandas.DataFrame.query` Use Cases
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A use case for :meth:`~pandas.DataFrame.query` is when you have a collection of
:class:`~pandas.DataFrame` objects that have a subset of column names (or index
levels/names) in common. You can pass the same query to both frames *without*
having to specify which frame you're interested in querying

.. ipython:: python

   df = pd.DataFrame(np.random.rand(n, 3), columns=list('abc'))
   df
   df2 = pd.DataFrame(np.random.rand(n + 2, 3), columns=df.columns)
   df2
   expr = '0.0 <= a <= c <= 0.5'
   map(lambda frame: frame.query(expr), [df, df2])

:meth:`~pandas.DataFrame.query` Python versus pandas Syntax Comparison
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Full numpy-like syntax

.. ipython:: python

   df = pd.DataFrame(np.random.randint(n, size=(n, 3)), columns=list('abc'))
   df
   df.query('(a < b) & (b < c)')
   df[(df.a < df.b) & (df.b < df.c)]

Slightly nicer by removing the parentheses (by binding making comparison
operators bind tighter than ``&``/``|``)

.. ipython:: python

   df.query('a < b & b < c')

Use English instead of symbols

.. ipython:: python

   df.query('a < b and b < c')

Pretty close to how you might write it on paper

.. ipython:: python

   df.query('a < b < c')

The ``in`` and ``not in`` operators
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:meth:`~pandas.DataFrame.query` also supports special use of Python's ``in`` and
``not in`` comparison operators, providing a succinct syntax for calling the
``isin`` method of a ``Series`` or ``DataFrame``.

.. ipython:: python
   :suppress:

   try:
       old_d = d
       del d
   except NameError:
       pass

.. ipython:: python

   # get all rows where columns "a" and "b" have overlapping values
   df = pd.DataFrame({'a': list('aabbccddeeff'), 'b': list('aaaabbbbcccc'),
                      'c': np.random.randint(5, size=12),
                      'd': np.random.randint(9, size=12)})
   df
   df.query('a in b')

   # How you'd do it in pure Python
   df[df.a.isin(df.b)]

   df.query('a not in b')

   # pure Python
   df[~df.a.isin(df.b)]


You can combine this with other expressions for very succinct queries:


.. ipython:: python

   # rows where cols a and b have overlapping values and col c's values are less than col d's
   df.query('a in b and c < d')

   # pure Python
   df[df.b.isin(df.a) & (df.c < df.d)]


.. note::

   Note that ``in`` and ``not in`` are evaluated in Python, since ``numexpr``
   has no equivalent of this operation. However, **only the** ``in``/``not in``
   **expression itself** is evaluated in vanilla Python. For example, in the
   expression

   .. code-block:: python

      df.query('a in b + c + d')

   ``(b + c + d)`` is evaluated by ``numexpr`` and *then* the ``in``
   operation is evaluated in plain Python. In general, any operations that can
   be evaluated using ``numexpr`` will be.

Special use of the ``==`` operator with ``list`` objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Comparing a ``list`` of values to a column using ``==``/``!=`` works similarly
to ``in``/``not in``

.. ipython:: python

   df.query('b == ["a", "b", "c"]')

   # pure Python
   df[df.b.isin(["a", "b", "c"])]

   df.query('c == [1, 2]')

   df.query('c != [1, 2]')

   # using in/not in
   df.query('[1, 2] in c')

   df.query('[1, 2] not in c')

   # pure Python
   df[df.c.isin([1, 2])]


Boolean Operators
~~~~~~~~~~~~~~~~~

You can negate boolean expressions with the word ``not`` or the ``~`` operator.

.. ipython:: python

   df = pd.DataFrame(np.random.rand(n, 3), columns=list('abc'))
   df['bools'] = np.random.rand(len(df)) > 0.5
   df.query('~bools')
   df.query('not bools')
   df.query('not bools') == df[~df.bools]

Of course, expressions can be arbitrarily complex too

.. ipython:: python

   # short query syntax
   shorter = df.query('a < b < c and (not bools) or bools > 2')

   # equivalent in pure Python
   longer = df[(df.a < df.b) & (df.b < df.c) & (~df.bools) | (df.bools > 2)]

   shorter
   longer

   shorter == longer

.. ipython:: python
   :suppress:

   try:
       d = old_d
       del old_d
   except NameError:
       pass


Performance of :meth:`~pandas.DataFrame.query`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``DataFrame.query()`` using ``numexpr`` is slightly faster than Python for
large frames

.. image:: ../_static/query-perf.png

.. note::

   You will only see the performance benefits of using the ``numexpr`` engine
   with ``DataFrame.query()`` if your frame has more than approximately 200,000
   rows

      .. image:: ../_static/query-perf-small.png

This plot was created using a ``DataFrame`` with 3 columns each containing
floating point values generated using ``numpy.random.randn()``.

.. ipython:: python
   :suppress:

   df = pd.DataFrame(np.random.randn(8, 4), index=dates, columns=['A', 'B', 'C', 'D'])
   df2 = df.copy()