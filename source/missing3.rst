.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   pd.options.display.max_rows=15
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   
.. _missing.inserting:

Inserting missing data
----------------------

You can insert missing values by simply assigning to containers. The
actual missing value used will be chosen based on the dtype.

For example, numeric containers will always use ``NaN`` regardless of
the missing value type chosen:

.. ipython:: python

   s = pd.Series([1, 2, 3])
   s.loc[0] = None
   s

Likewise, datetime containers will always use ``NaT``.

For object containers, pandas will use the value given:

.. ipython:: python

   s = pd.Series(["a", "b", "c"])
   s.loc[0] = None
   s.loc[1] = np.nan
   s