.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows = 15
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')
   from collections import OrderedDict

.. _groupby.filter:

Filtration
----------

.. versionadded:: 0.12

The ``filter`` method returns a subset of the original object. Suppose we
want to take only elements that belong to groups with a group sum greater
than 2.

.. ipython:: python

   sf = pd.Series([1, 1, 2, 3, 3, 3])
   sf.groupby(sf).filter(lambda x: x.sum() > 2)

The argument of ``filter`` must be a function that, applied to the group as a
whole, returns ``True`` or ``False``.

Another useful operation is filtering out elements that belong to groups
with only a couple members.

.. ipython:: python

   dff = pd.DataFrame({'A': np.arange(8), 'B': list('aabbbbcc')})
   dff.groupby('B').filter(lambda x: len(x) > 2)

Alternatively, instead of dropping the offending groups, we can return a
like-indexed objects where the groups that do not pass the filter are filled
with NaNs.

.. ipython:: python

   dff.groupby('B').filter(lambda x: len(x) > 2, dropna=False)

For DataFrames with multiple columns, filters should explicitly specify a column as the filter criterion.

.. ipython:: python

   dff['C'] = np.arange(8)
   dff.groupby('B').filter(lambda x: len(x['C']) > 2)

.. note::

   Some functions when applied to a groupby object will act as a **filter** on the input, returning
   a reduced shape of the original (and potentially eliminating groups), but with the index unchanged.
   Passing ``as_index=False`` will not affect these transformation methods.

   For example: ``head, tail``.

   .. ipython:: python

      dff.groupby('B').head(2)