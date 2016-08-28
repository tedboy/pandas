.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   randn = np.random.randn
   np.set_printoptions(precision=4, suppress=True)
   from pandas.compat import lrange
   pd.options.display.max_rows=8
   
Indexing with ``.str``
----------------------

.. _text.indexing:

You can use ``[]`` notation to directly index by position locations. If you index past the end
of the string, the result will be a ``NaN``.


.. ipython:: python

   s = pd.Series(['A', 'B', 'C', 'Aaba', 'Baca', np.nan,
                  'CABA', 'dog', 'cat'])

   s.str[0]
   s.str[1]