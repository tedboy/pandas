.. ipython:: python
   :suppress:

   import numpy as np
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

Thread-safety
-------------

As of pandas 0.11, pandas is not 100% thread safe. The known issues relate to
the ``DataFrame.copy`` method. If you are doing a lot of copying of DataFrame
objects shared among threads, we recommend holding locks inside the threads
where the data copying occurs.

See `this link <http://stackoverflow.com/questions/13592618/python-pandas-dataframe-thread-safe>`__
for more information.