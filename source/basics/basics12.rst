.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8
   df = pd.DataFrame({'one' : pd.Series(np.random.randn(3), index=['a', 'b', 'c']),
                      'two' : pd.Series(np.random.randn(4), index=['a', 'b', 'c', 'd']),
                      'three' : pd.Series(np.random.randn(3), index=['b', 'c', 'd'])})

Copying
-------

The :meth:`~DataFrame.copy` method on pandas objects copies the underlying data (though not
the axis indexes, since they are immutable) and returns a new object. Note that
**it is seldom necessary to copy objects**. For example, there are only a
handful of ways to alter a DataFrame *in-place*:

  * Inserting, deleting, or modifying a column
  * Assigning to the ``index`` or ``columns`` attributes
  * For homogeneous data, directly modifying the values via the ``values``
    attribute or advanced indexing

To be clear, no pandas methods have the side effect of modifying your data;
almost all methods return new objects, leaving the original object
untouched. If data is modified, it is because you did so explicitly.