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

.. _enhancingperf.numba:

Using numba
-----------

A recent alternative to statically compiling cython code, is to use a *dynamic jit-compiler*, ``numba``.

Numba gives you the power to speed up your applications with high performance functions written directly in Python. With a few annotations, array-oriented and math-heavy Python code can be just-in-time compiled to native machine instructions, similar in performance to C, C++ and Fortran, without having to switch languages or Python interpreters.

Numba works by generating optimized machine code using the LLVM compiler infrastructure at import time, runtime, or statically (using the included pycc tool). Numba supports compilation of Python to run on either CPU or GPU hardware, and is designed to integrate with the Python scientific software stack.

.. note::

    You will need to install ``numba``. This is easy with ``conda``, by using: ``conda install numba``, see :ref:`installing using miniconda<install.miniconda>`.

.. note::

    As of ``numba`` version 0.20, pandas objects cannot be passed directly to numba-compiled functions. Instead, one must pass the ``numpy`` array underlying the ``pandas`` object to the numba-compiled function as demonstrated below.

Jit
~~~

Using ``numba`` to just-in-time compile your code. We simply take the plain python code from above and annotate with the ``@jit`` decorator.

.. code-block:: python

    import numba

    @numba.jit
    def f_plain(x):
       return x * (x - 1)

    @numba.jit
    def integrate_f_numba(a, b, N):
       s = 0
       dx = (b - a) / N
       for i in range(N):
           s += f_plain(a + i * dx)
       return s * dx

    @numba.jit
    def apply_integrate_f_numba(col_a, col_b, col_N):
       n = len(col_N)
       result = np.empty(n, dtype='float64')
       assert len(col_a) == len(col_b) == n
       for i in range(n):
          result[i] = integrate_f_numba(col_a[i], col_b[i], col_N[i])
       return result

    def compute_numba(df):
       result = apply_integrate_f_numba(df['a'].values, df['b'].values, df['N'].values)
       return pd.Series(result, index=df.index, name='result')

Note that we directly pass ``numpy`` arrays to the numba function. ``compute_numba`` is just a wrapper that provides a nicer interface by passing/returning pandas objects.

.. code-block:: ipython

    In [4]: %timeit compute_numba(df)
    1000 loops, best of 3: 798 us per loop

Vectorize
~~~~~~~~~

``numba`` can also be used to write vectorized functions that do not require the user to explicitly
loop over the observations of a vector; a vectorized function will be applied to each row automatically.
Consider the following toy example of doubling each observation:

.. code-block:: python

    import numba

    def double_every_value_nonumba(x):
        return x*2

    @numba.vectorize
    def double_every_value_withnumba(x):
        return x*2


    # Custom function without numba
    In [5]: %timeit df['col1_doubled'] = df.a.apply(double_every_value_nonumba)
    1000 loops, best of 3: 797 us per loop

    # Standard implementation (faster than a custom function)
    In [6]: %timeit df['col1_doubled'] = df.a*2
    1000 loops, best of 3: 233 us per loop

    # Custom function with numba
    In [7]: %timeit df['col1_doubled'] = double_every_value_withnumba(df.a.values)
    1000 loops, best of 3: 145 us per loop

Caveats
~~~~~~~

.. note::

    ``numba`` will execute on any function, but can only accelerate certain classes of functions.

``numba`` is best at accelerating functions that apply numerical functions to numpy arrays. When passed a function that only uses operations it knows how to accelerate, it will execute in ``nopython`` mode.

If ``numba`` is passed a function that includes something it doesn't know how to work with -- a category that currently includes sets, lists, dictionaries, or string functions -- it will revert to ``object mode``. In ``object mode``, numba will execute but your code will not speed up significantly. If you would prefer that ``numba`` throw an error if it cannot compile a function in a way that speeds up your code, pass numba the argument ``nopython=True`` (e.g.  ``@numba.jit(nopython=True)``). For more on troubleshooting ``numba`` modes, see the `numba troubleshooting page <http://numba.pydata.org/numba-doc/0.20.0/user/troubleshoot.html#the-compiled-code-is-too-slow>`__.

Read more in the `numba docs <http://numba.pydata.org/>`__.