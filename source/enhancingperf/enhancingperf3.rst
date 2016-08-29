.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

   import os
   import csv

.. _enhancingperf.eval:

Expression Evaluation via :func:`~pandas.eval` (Experimental)
-------------------------------------------------------------

.. versionadded:: 0.13

The top-level function :func:`pandas.eval` implements expression evaluation of
:class:`~pandas.Series` and :class:`~pandas.DataFrame` objects.

.. note::

   To benefit from using :func:`~pandas.eval` you need to
   install ``numexpr``. See the :ref:`recommended dependencies section
   <install.recommended_dependencies>` for more details.

The point of using :func:`~pandas.eval` for expression evaluation rather than
plain Python is two-fold: 1) large :class:`~pandas.DataFrame` objects are
evaluated more efficiently and 2) large arithmetic and boolean expressions are
evaluated all at once by the underlying engine (by default ``numexpr`` is used
for evaluation).

.. note::

   You should not use :func:`~pandas.eval` for simple
   expressions or for expressions involving small DataFrames. In fact,
   :func:`~pandas.eval` is many orders of magnitude slower for
   smaller expressions/objects than plain ol' Python. A good rule of thumb is
   to only use :func:`~pandas.eval` when you have a
   :class:`~pandas.core.frame.DataFrame` with more than 10,000 rows.


:func:`~pandas.eval` supports all arithmetic expressions supported by the
engine in addition to some extensions available only in pandas.

.. note::

   The larger the frame and the larger the expression the more speedup you will
   see from using :func:`~pandas.eval`.

Supported Syntax
~~~~~~~~~~~~~~~~

These operations are supported by :func:`pandas.eval`:

- Arithmetic operations except for the left shift (``<<``) and right shift
  (``>>``) operators, e.g., ``df + 2 * pi / s ** 4 % 42 - the_golden_ratio``
- Comparison operations, including chained comparisons, e.g., ``2 < df < df2``
- Boolean operations, e.g., ``df < df2 and df3 < df4 or not df_bool``
- ``list`` and ``tuple`` literals, e.g., ``[1, 2]`` or ``(1, 2)``
- Attribute access, e.g., ``df.a``
- Subscript expressions, e.g., ``df[0]``
- Simple variable evaluation, e.g., ``pd.eval('df')`` (this is not very useful)
- Math functions, `sin`, `cos`, `exp`, `log`, `expm1`, `log1p`,
  `sqrt`, `sinh`, `cosh`, `tanh`, `arcsin`, `arccos`, `arctan`, `arccosh`,
  `arcsinh`, `arctanh`, `abs` and `arctan2`.

This Python syntax is **not** allowed:

* Expressions

  - Function calls other than math functions.
  - ``is``/``is not`` operations
  - ``if`` expressions
  - ``lambda`` expressions
  - ``list``/``set``/``dict`` comprehensions
  - Literal ``dict`` and ``set`` expressions
  - ``yield`` expressions
  - Generator expressions
  - Boolean expressions consisting of only scalar values

* Statements

  - Neither `simple <http://docs.python.org/2/reference/simple_stmts.html>`__
    nor `compound <http://docs.python.org/2/reference/compound_stmts.html>`__
    statements are allowed. This includes things like ``for``, ``while``, and
    ``if``.



:func:`~pandas.eval` Examples
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:func:`pandas.eval` works well with expressions containing large arrays.

First let's create a few decent-sized arrays to play with:

.. ipython:: python

   nrows, ncols = 20000, 100
   df1, df2, df3, df4 = [pd.DataFrame(np.random.randn(nrows, ncols)) for _ in range(4)]


Now let's compare adding them together using plain ol' Python versus
:func:`~pandas.eval`:

.. ipython:: python

   %timeit df1 + df2 + df3 + df4

.. ipython:: python

   %timeit pd.eval('df1 + df2 + df3 + df4')


Now let's do the same thing but with comparisons:

.. ipython:: python

   %timeit (df1 > 0) & (df2 > 0) & (df3 > 0) & (df4 > 0)

.. ipython:: python

   %timeit pd.eval('(df1 > 0) & (df2 > 0) & (df3 > 0) & (df4 > 0)')


:func:`~pandas.eval` also works with unaligned pandas objects:

.. ipython:: python

   s = pd.Series(np.random.randn(50))
   %timeit df1 + df2 + df3 + df4 + s

.. ipython:: python

   %timeit pd.eval('df1 + df2 + df3 + df4 + s')

.. note::

   Operations such as

      .. code-block:: python

         1 and 2  # would parse to 1 & 2, but should evaluate to 2
         3 or 4  # would parse to 3 | 4, but should evaluate to 3
         ~1  # this is okay, but slower when using eval

   should be performed in Python. An exception will be raised if you try to
   perform any boolean/bitwise operations with scalar operands that are not
   of type ``bool`` or ``np.bool_``. Again, you should perform these kinds of
   operations in plain Python.

The ``DataFrame.eval`` method (Experimental)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.13

In addition to the top level :func:`pandas.eval` function you can also
evaluate an expression in the "context" of a :class:`~pandas.DataFrame`.

.. ipython:: python
   :suppress:

   try:
      del a
   except NameError:
      pass

   try:
      del b
   except NameError:
      pass

.. ipython:: python

   df = pd.DataFrame(np.random.randn(5, 2), columns=['a', 'b'])
   df.eval('a + b')

Any expression that is a valid :func:`pandas.eval` expression is also a valid
:meth:`DataFrame.eval` expression, with the added benefit that you don't have to
prefix the name of the :class:`~pandas.DataFrame` to the column(s) you're
interested in evaluating.

In addition, you can perform assignment of columns within an expression.
This allows for *formulaic evaluation*.  The assignment target can be a
new column name or an existing column name, and it must be a valid Python
identifier.

.. versionadded:: 0.18.0

The ``inplace`` keyword determines whether this assignment will performed
on the original ``DataFrame`` or return a copy with the new column.

.. warning::

   For backwards compatability, ``inplace`` defaults to ``True`` if not
   specified. This will change in a future version of pandas - if your
   code depends on an inplace assignment you should update to explicitly
   set ``inplace=True``

.. ipython:: python

   df = pd.DataFrame(dict(a=range(5), b=range(5, 10)))
   df.eval('c = a + b', inplace=True)
   df.eval('d = a + b + c', inplace=True)
   df.eval('a = 1', inplace=True)
   df

When ``inplace`` is set to ``False``, a copy of the ``DataFrame`` with the
new or modified columns is returned and the original frame is unchanged.

.. ipython:: python

   df
   df.eval('e = a - c', inplace=False)
   df

.. versionadded:: 0.18.0

As a convenience, multiple assignments can be performed by using a
multi-line string.

.. ipython:: python

   df.eval("""
   c = a + b
   d = a + b + c
   a = 1""", inplace=False)

The equivalent in standard Python would be

.. ipython:: python

   df = pd.DataFrame(dict(a=range(5), b=range(5, 10)))
   df['c'] = df.a + df.b
   df['d'] = df.a + df.b + df.c
   df['a'] = 1
   df

.. versionadded:: 0.18.0

The ``query`` method gained the ``inplace`` keyword which determines
whether the query modifies the original frame.

.. ipython:: python

   df = pd.DataFrame(dict(a=range(5), b=range(5, 10)))
   df.query('a > 2')
   df.query('a > 2', inplace=True)
   df

.. warning::

   Unlike with ``eval``, the default value for ``inplace`` for ``query``
   is ``False``.  This is consistent with prior versions of pandas.

Local Variables
~~~~~~~~~~~~~~~

In pandas version 0.14 the local variable API has changed. In pandas 0.13.x,
you could refer to local variables the same way you would in standard Python.
For example,

.. code-block:: python

   df = pd.DataFrame(np.random.randn(5, 2), columns=['a', 'b'])
   newcol = np.random.randn(len(df))
   df.eval('b + newcol')

   UndefinedVariableError: name 'newcol' is not defined

As you can see from the exception generated, this syntax is no longer allowed.
You must *explicitly reference* any local variable that you want to use in an
expression by placing the ``@`` character in front of the name. For example,

.. ipython:: python

   df = pd.DataFrame(np.random.randn(5, 2), columns=list('ab'))
   newcol = np.random.randn(len(df))
   df.eval('b + @newcol')
   df.query('b < @newcol')

If you don't prefix the local variable with ``@``, pandas will raise an
exception telling you the variable is undefined.

When using :meth:`DataFrame.eval` and :meth:`DataFrame.query`, this allows you
to have a local variable and a :class:`~pandas.DataFrame` column with the same
name in an expression.


.. ipython:: python

   a = np.random.randn()
   df.query('@a < a')
   df.loc[a < df.a]  # same as the previous expression

With :func:`pandas.eval` you cannot use the ``@`` prefix *at all*, because it
isn't defined in that context. ``pandas`` will let you know this if you try to
use ``@`` in a top-level call to :func:`pandas.eval`. For example,

.. ipython:: python
   :okexcept:

   a, b = 1, 2
   pd.eval('@a + b')

In this case, you should simply refer to the variables like you would in
standard Python.

.. ipython:: python

   pd.eval('a + b')


:func:`pandas.eval` Parsers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are two different parsers and two different engines you can use as
the backend.

The default ``'pandas'`` parser allows a more intuitive syntax for expressing
query-like operations (comparisons, conjunctions and disjunctions). In
particular, the precedence of the ``&`` and ``|`` operators is made equal to
the precedence of the corresponding boolean operations ``and`` and ``or``.

For example, the above conjunction can be written without parentheses.
Alternatively, you can use the ``'python'`` parser to enforce strict Python
semantics.

.. ipython:: python

   expr = '(df1 > 0) & (df2 > 0) & (df3 > 0) & (df4 > 0)'
   x = pd.eval(expr, parser='python')
   expr_no_parens = 'df1 > 0 & df2 > 0 & df3 > 0 & df4 > 0'
   y = pd.eval(expr_no_parens, parser='pandas')
   np.all(x == y)


The same expression can be "anded" together with the word :keyword:`and` as
well:

.. ipython:: python

   expr = '(df1 > 0) & (df2 > 0) & (df3 > 0) & (df4 > 0)'
   x = pd.eval(expr, parser='python')
   expr_with_ands = 'df1 > 0 and df2 > 0 and df3 > 0 and df4 > 0'
   y = pd.eval(expr_with_ands, parser='pandas')
   np.all(x == y)


The ``and`` and ``or`` operators here have the same precedence that they would
in vanilla Python.


:func:`pandas.eval` Backends
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There's also the option to make :func:`~pandas.eval` operate identical to plain
ol' Python.

.. note::

   Using the ``'python'`` engine is generally *not* useful, except for testing
   other evaluation engines against it. You will achieve **no** performance
   benefits using :func:`~pandas.eval` with ``engine='python'`` and in fact may
   incur a performance hit.

You can see this by using :func:`pandas.eval` with the ``'python'`` engine. It
is a bit slower (not by much) than evaluating the same expression in Python

.. ipython:: python

   %timeit df1 + df2 + df3 + df4

.. ipython:: python

   %timeit pd.eval('df1 + df2 + df3 + df4', engine='python')


:func:`pandas.eval` Performance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:func:`~pandas.eval` is intended to speed up certain kinds of operations. In
particular, those operations involving complex expressions with large
:class:`~pandas.DataFrame`/:class:`~pandas.Series` objects should see a
significant performance benefit.  Here is a plot showing the running time of
:func:`pandas.eval` as function of the size of the frame involved in the
computation. The two lines are two different engines.


.. image:: _static/eval-perf.png


.. note::

   Operations with smallish objects (around 15k-20k rows) are faster using
   plain Python:

       .. image:: _static/eval-perf-small.png


This plot was created using a ``DataFrame`` with 3 columns each containing
floating point values generated using ``numpy.random.randn()``.

Technical Minutia Regarding Expression Evaluation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Expressions that would result in an object dtype or involve datetime operations
(because of ``NaT``) must be evaluated in Python space. The main reason for
this behavior is to maintain backwards compatibility with versions of numpy <
1.7. In those versions of ``numpy`` a call to ``ndarray.astype(str)`` will
truncate any strings that are more than 60 characters in length. Second, we
can't pass ``object`` arrays to ``numexpr`` thus string comparisons must be
evaluated in Python space.

The upshot is that this *only* applies to object-dtype'd expressions. So, if
you have an expression--for example

.. ipython:: python

   df = pd.DataFrame({'strings': np.repeat(list('cba'), 3),
                      'nums': np.repeat(range(3), 3)})
   df
   df.query('strings == "a" and nums == 1')

the numeric part of the comparison (``nums == 1``) will be evaluated by
``numexpr``.

In general, :meth:`DataFrame.query`/:func:`pandas.eval` will
evaluate the subexpressions that *can* be evaluated by ``numexpr`` and those
that must be evaluated in Python space transparently to the user. This is done
by inferring the result type of an expression from its arguments and operators.