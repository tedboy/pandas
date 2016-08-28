.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Description
-----------

Using ``.describe()`` on categorical data will produce similar output to a `Series` or
`DataFrame` of type ``string``.

.. ipython:: python

    cat = pd.Categorical(["a", "c", "c", np.nan], categories=["b", "a", "c"])
    df = pd.DataFrame({"cat":cat, "s":["a", "c", "c", np.nan]})
    df.describe()
    df["cat"].describe()