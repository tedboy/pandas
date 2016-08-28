.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   randn = np.random.randn
   np.set_printoptions(precision=4, suppress=True)
   from pandas.compat import lrange
   pd.options.display.max_rows=8
   
.. _text.indicator:

Creating Indicator Variables
----------------------------

You can extract dummy variables from string columns.
For example if they are separated by a ``'|'``:

.. ipython:: python

    s = pd.Series(['a', 'a|b', np.nan, 'a|c'])
    s.str.get_dummies(sep='|')

String ``Index`` also supports ``get_dummies`` which returns a ``MultiIndex``.

.. versionadded:: 0.18.1

.. ipython:: python

    idx = pd.Index(['a', 'a|b', np.nan, 'a|c'])
    idx.str.get_dummies(sep='|')

See also :func:`~pandas.get_dummies`.