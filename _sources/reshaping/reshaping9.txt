.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   import pandas as pd
   pd.options.display.max_rows=8
   np.set_printoptions(precision=4, suppress=True)

Factorizing values
------------------

To encode 1-d values as an enumerated type use ``factorize``:

.. ipython:: python

   x = pd.Series(['A', 'A', np.nan, 'B', 3.14, np.inf])
   x
   labels, uniques = pd.factorize(x)
   labels
   uniques

Note that ``factorize`` is similar to ``numpy.unique``, but differs in its
handling of NaN:

.. note::
   The following ``numpy.unique`` will fail under Python 3 with a ``TypeError``
   because of an ordering bug. See also
   `Here <https://github.com/numpy/numpy/issues/641>`__

.. ipython:: python

   pd.factorize(x, sort=True)
   np.unique(x, return_inverse=True)[::-1]

.. note::
    If you just want to handle one column as a categorical variable (like R's factor),
    you can use  ``df["cat_col"] = pd.Categorical(df["col"])`` or
    ``df["cat_col"] = df["col"].astype("category")``. For full docs on :class:`~pandas.Categorical`,
    see the :ref:`Categorical introduction <categorical>` and the
    :ref:`API documentation <api.categorical>`. This feature was introduced in version 0.15.
