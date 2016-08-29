.. currentmodule:: pandas
.. _compare_with_r:

.. ipython:: python
   :suppress:

   import pandas as pd
   import numpy as np
   pd.options.display.max_rows=8

Comparison with R / R libraries
*******************************

Since ``pandas`` aims to provide a lot of the data manipulation and analysis
functionality that people use `R <http://www.r-project.org/>`__ for, this page
was started to provide a more detailed look at the `R language
<http://en.wikipedia.org/wiki/R_(programming_language)>`__ and its many third
party libraries as they relate to ``pandas``. In comparisons with R and CRAN
libraries, we care about the following things:

  - **Functionality / flexibility**: what can/cannot be done with each tool
  - **Performance**: how fast are operations. Hard numbers/benchmarks are
    preferable
  - **Ease-of-use**: Is one tool easier/harder to use (you may have to be
    the judge of this, given side-by-side code comparisons)

This page is also here to offer a bit of a translation guide for users of these
R packages.

For transfer of ``DataFrame`` objects from ``pandas`` to R, one option is to
use HDF5 files, see :ref:`io.external_compatibility` for an
example.

.. toctree::
    :maxdepth: 1
    :caption: Contents
    :name: comparison_with_r

    comparison_with_r1
    comparison_with_r2
    comparison_with_r3
    comparison_with_r4

