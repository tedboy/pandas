.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(1234567)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8


.. ipython:: python
   :suppress:

   dates = pd.date_range('1/1/2000', periods=8)
   df = pd.DataFrame(np.random.randn(8, 4), index=dates, columns=['A', 'B', 'C', 'D'])

The :meth:`~pandas.DataFrame.select` Method
-------------------------------------------

Another way to extract slices from an object is with the ``select`` method of
Series, DataFrame, and Panel. This method should be used only when there is no
more direct way.  ``select`` takes a function which operates on labels along
``axis`` and returns a boolean.  For instance:

.. ipython:: python

   df
   df.select(lambda x: x == 'A', axis=1)