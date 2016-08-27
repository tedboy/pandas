.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

.. _basics.head_tail:

Head and Tail
-------------

To view a small sample of a Series or DataFrame object, use the
:meth:`~DataFrame.head` and :meth:`~DataFrame.tail` methods. The default number
of elements to display is five, but you may pass a custom number.

.. ipython:: python

   long_series = pd.Series(np.random.randn(1000))
   long_series.head()
   long_series.tail(3)                 