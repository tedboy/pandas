.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8
   index = pd.date_range('1/1/2000', periods=8)
   s = pd.Series(np.random.randn(5), index=['a', 'b', 'c', 'd', 'e'])
   df = pd.DataFrame(np.random.randn(8, 3), index=index,
                     columns=['A', 'B', 'C'])
   wp = pd.Panel(np.random.randn(2, 5, 4), items=['Item1', 'Item2'],
                 major_axis=pd.date_range('1/1/2000', periods=5),
                 minor_axis=['A', 'B', 'C', 'D'])   

.. _basics.accelerate:

Accelerated operations
----------------------

pandas has support for accelerating certain types of binary numerical and boolean operations using
the ``numexpr`` library (starting in 0.11.0) and the ``bottleneck`` libraries.

These libraries are especially useful when dealing with large data sets, and provide large
speedups. ``numexpr`` uses smart chunking, caching, and multiple cores. ``bottleneck`` is
a set of specialized cython routines that are especially fast when dealing with arrays that have
``nans``.

Here is a sample (using 100 column x 100,000 row ``DataFrames``):

.. csv-table::
    :header: "Operation", "0.11.0 (ms)", "Prior Version (ms)", "Ratio to Prior"
    :widths: 25, 25, 25, 25
    :delim: ;

    ``df1 > df2``; 13.32; 125.35;  0.1063
    ``df1 * df2``; 21.71;  36.63;  0.5928
    ``df1 + df2``; 22.04;  36.50;  0.6039

You are highly encouraged to install both libraries. See the section
:ref:`Recommended Dependencies <install.recommended_dependencies>` for more installation info.