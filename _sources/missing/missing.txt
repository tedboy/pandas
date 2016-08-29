.. currentmodule:: pandas

.. _missing_data:

*************************
Working with missing data
*************************

In this section, we will discuss missing (also referred to as NA) values in
pandas.

.. note::

    The choice of using ``NaN`` internally to denote missing data was largely
    for simplicity and performance reasons. It differs from the MaskedArray
    approach of, for example, :mod:`scikits.timeseries`. We are hopeful that
    NumPy will soon be able to provide a native NA type solution (similar to R)
    performant enough to be used in pandas.

See the :ref:`cookbook<cookbook.missing_data>` for some advanced strategies

.. toctree::
    :maxdepth: 1
    :caption: Contents
    :name: missing

    missing1
    missing2
    missing3
    missing4
    missing5
    missing6

.. ipython:: python

   import numpy as np
   import pandas as pd
   pd.options.display.max_rows=8
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt