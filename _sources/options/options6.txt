.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import pandas as pd
   import numpy as np
   np.random.seed(123456)

.. _basics.console_output:

Number Formatting
------------------

pandas also allows you to set how numbers are displayed in the console.
This option is not set through the ``set_options`` API.

Use the ``set_eng_float_format`` function
to alter the floating-point formatting of pandas objects to produce a particular
format.

For instance:

.. ipython:: python

   import numpy as np

   pd.set_eng_float_format(accuracy=3, use_eng_prefix=True)
   s = pd.Series(np.random.randn(5), index=['a', 'b', 'c', 'd', 'e'])
   s/1.e3
   s/1.e6

.. ipython:: python
   :suppress:
   :okwarning:

   pd.reset_option('^display\.')

To round floats on a case-by-case basis, you can also use :meth:`~pandas.Series.round` and :meth:`~pandas.DataFrame.round`.