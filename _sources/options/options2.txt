.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import pandas as pd
   import numpy as np
   np.random.seed(123456)

Getting and Setting Options
---------------------------

As described above, ``get_option()`` and ``set_option()`` are available from the
pandas namespace.  To change an option, call ``set_option('option regex', new_value)``

.. ipython:: python

   pd.get_option('mode.sim_interactive')
   pd.set_option('mode.sim_interactive', True)
   pd.get_option('mode.sim_interactive')

**Note:** that the option 'mode.sim_interactive' is mostly used for debugging purposes.

All options also have a default value, and you can use ``reset_option`` to do just that:

.. ipython:: python
   :suppress:

   pd.reset_option("display.max_rows")

.. ipython:: python

   pd.get_option("display.max_rows")
   pd.set_option("display.max_rows",999)
   pd.get_option("display.max_rows")
   pd.reset_option("display.max_rows")
   pd.get_option("display.max_rows")


It's also possible to reset multiple options at once (using a regex):

.. ipython:: python
   :okwarning:

   pd.reset_option("^display")


``option_context`` context manager has been exposed through
the top-level API, allowing you to execute code with given option values. Option values
are restored automatically when you exit the `with` block:

.. ipython:: python

   with pd.option_context("display.max_rows",10,"display.max_columns", 5):
        print(pd.get_option("display.max_rows"))
        print(pd.get_option("display.max_columns"))
   print(pd.get_option("display.max_rows"))
   print(pd.get_option("display.max_columns"))