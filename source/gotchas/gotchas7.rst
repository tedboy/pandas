.. ipython:: python
   :suppress:

   import numpy as np
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

Differences with NumPy
----------------------
For Series and DataFrame objects, ``var`` normalizes by ``N-1`` to produce
unbiased estimates of the sample variance, while NumPy's ``var`` normalizes
by N, which measures the variance of the sample. Note that ``cov``
normalizes by ``N-1`` in both pandas and NumPy.
