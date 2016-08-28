.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(1234567)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8


The :meth:`~pandas.DataFrame.lookup` Method
-------------------------------------------

Sometimes you want to extract a set of values given a sequence of row labels
and column labels, and the ``lookup`` method allows for this and returns a
numpy array.  For instance,

.. ipython:: python

  dflookup = pd.DataFrame(np.random.rand(20,4), columns = ['A','B','C','D'])
  dflookup
  dflookup.lookup(list(range(0,10,2)), ['B','C','A','B','D'])