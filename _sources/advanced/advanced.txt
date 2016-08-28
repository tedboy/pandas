.. _advanced:

******************************
MultiIndex / Advanced Indexing
******************************

This section covers indexing with a ``MultiIndex`` and more advanced indexing features.

See the :ref:`Indexing and Selecting Data <indexing>` for general indexing documentation.

.. warning::

   Whether a copy or a reference is returned for a setting operation, may
   depend on the context.  This is sometimes called ``chained assignment`` and
   should be avoided.  See :ref:`Returning a View versus Copy
   <indexing.view_versus_copy>`

.. warning::

   In 0.15.0 ``Index`` has internally been refactored to no longer sub-class ``ndarray``
   but instead subclass ``PandasObject``, similarly to the rest of the pandas objects. This should be
   a transparent change with only very limited API implications (See the :ref:`Internal Refactoring <whatsnew_0150.refactoring>`)

See the :ref:`cookbook<cookbook.selection>` for some advanced strategies


.. toctree::
    :maxdepth: 2
    :caption: Contents
    :name: advanced

    advanced1
    advanced2
    advanced3
    advanced4
    advanced5

.. currentmodule:: pandas

.. ipython:: python

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows=8