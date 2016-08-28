.. _indexing:

.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

***************************
Indexing and Selecting Data
***************************

The axis labeling information in pandas objects serves many purposes:

- Identifies data (i.e. provides *metadata*) using known indicators,
  important for analysis, visualization, and interactive console display
- Enables automatic and explicit data alignment
- Allows intuitive getting and setting of subsets of the data set

In this section, we will focus on the final point: namely, how to slice, dice,
and generally get and set subsets of pandas objects. The primary focus will be
on Series and DataFrame as they have received more development attention in
this area. Expect more work to be invested in higher-dimensional data
structures (including ``Panel``) in the future, especially in label-based
advanced indexing.

.. toctree::
    :maxdepth: 2
    :caption: Contents
    :name: indexing

    indexing1
    indexing2
    indexing3
    indexing4
    indexing5
    indexing6
    indexing7
    indexing8
    indexing9
    indexing10
    indexing11
    indexing12
    indexing13
    indexing14
    indexing15
    indexing16
    indexing17
    indexing18
    indexing19
    indexing20
    indexing21



.. note::

   The Python and NumPy indexing operators ``[]`` and attribute operator ``.``
   provide quick and easy access to pandas data structures across a wide range
   of use cases. This makes interactive work intuitive, as there's little new
   to learn if you already know how to deal with Python dictionaries and NumPy
   arrays. However, since the type of the data to be accessed isn't known in
   advance, directly using standard operators has some optimization limits. For
   production code, we recommended that you take advantage of the optimized
   pandas data access methods exposed in this chapter.

.. warning::

   Whether a copy or a reference is returned for a setting operation, may
   depend on the context.  This is sometimes called ``chained assignment`` and
   should be avoided.  See :ref:`Returning a View versus Copy
   <indexing.view_versus_copy>`

.. warning::

   In 0.15.0 ``Index`` has internally been refactored to no longer subclass ``ndarray``
   but instead subclass ``PandasObject``, similarly to the rest of the pandas objects. This should be
   a transparent change with only very limited API implications (See the :ref:`Internal Refactoring <whatsnew_0150.refactoring>`)

.. warning::

   Indexing on an integer-based Index with floats has been clarified in 0.18.0, for a summary of the changes, see :ref:`here <whatsnew_0180.float_indexers>`.

See the :ref:`MultiIndex / Advanced Indexing <advanced>` for ``MultiIndex`` and more advanced indexing documentation.

See the :ref:`cookbook<cookbook.selection>` for some advanced strategies

