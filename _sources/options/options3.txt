.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import pandas as pd
   import numpy as np
   np.random.seed(123456)

Setting Startup Options in python/ipython Environment
-----------------------------------------------------

Using startup scripts for the python/ipython environment to import pandas and set options makes working with pandas more efficient.  To do this, create a .py or .ipy script in the startup directory of the desired profile.  An example where the startup folder is in a default ipython profile can be found at:

.. code-block:: none

  $IPYTHONDIR/profile_default/startup

More information can be found in the `ipython documentation
<http://ipython.org/ipython-doc/stable/interactive/tutorial.html#startup-files>`__.  An example startup script for pandas is displayed below:

.. code-block:: python

  import pandas as pd
  pd.set_option('display.max_rows', 999)
  pd.set_option('precision', 5)