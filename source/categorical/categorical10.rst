.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Missing Data
------------

pandas primarily uses the value `np.nan` to represent missing data. It is by
default not included in computations. See the :ref:`Missing Data section
<missing_data>`.

Missing values should **not** be included in the Categorical's ``categories``,
only in the ``values``.
Instead, it is understood that NaN is different, and is always a possibility.
When working with the Categorical's ``codes``, missing values will always have
a code of ``-1``.

.. ipython:: python

    s = pd.Series(["a", "b", np.nan, "a"], dtype="category")
    # only two categories
    s
    s.cat.codes


Methods for working with missing data, e.g. :meth:`~Series.isnull`, :meth:`~Series.fillna`,
:meth:`~Series.dropna`, all work normally:

.. ipython:: python

    s = pd.Series(["a", "b", np.nan], dtype="category")
    s
    pd.isnull(s)
    s.fillna("a")