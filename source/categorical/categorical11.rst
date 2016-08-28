.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Differences to R's `factor`
---------------------------

The following differences to R's factor functions can be observed:

* R's `levels` are named `categories`
* R's `levels` are always of type string, while `categories` in pandas can be of any dtype.
* It's not possible to specify labels at creation time. Use ``s.cat.rename_categories(new_labels)``
  afterwards.
* In contrast to R's `factor` function, using categorical data as the sole input to create a
  new categorical series will *not* remove unused categories but create a new categorical series
  which is equal to the passed in one!
* R allows for missing values to be included in its `levels` (pandas' `categories`). Pandas
  does not allow `NaN` categories, but missing values can still be in the `values`.