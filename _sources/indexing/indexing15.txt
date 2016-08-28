.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(1234567)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

Duplicate Data
--------------

.. _indexing.duplicate:

If you want to identify and remove duplicate rows in a DataFrame,  there are
two methods that will help: ``duplicated`` and ``drop_duplicates``. Each
takes as an argument the columns to use to identify duplicated rows.

- ``duplicated`` returns a boolean vector whose length is the number of rows, and which indicates whether a row is duplicated.
- ``drop_duplicates`` removes duplicate rows.

By default, the first observed row of a duplicate set is considered unique, but
each method has a ``keep`` parameter to specify targets to be kept.

- ``keep='first'`` (default): mark / drop duplicates except for the first occurrence.
- ``keep='last'``: mark / drop duplicates except for the last occurrence.
- ``keep=False``: mark  / drop all duplicates.

.. ipython:: python

   df2 = pd.DataFrame({'a': ['one', 'one', 'two', 'two', 'two', 'three', 'four'],
                       'b': ['x', 'y', 'x', 'y', 'x', 'x', 'x'],
                       'c': np.random.randn(7)})
   df2
   df2.duplicated('a')
   df2.duplicated('a', keep='last')
   df2.duplicated('a', keep=False)
   df2.drop_duplicates('a')
   df2.drop_duplicates('a', keep='last')
   df2.drop_duplicates('a', keep=False)

Also, you can pass a list of columns to identify duplications.

.. ipython:: python

   df2.duplicated(['a', 'b'])
   df2.drop_duplicates(['a', 'b'])

To drop duplicates by index value, use ``Index.duplicated`` then perform slicing.
Same options are available in ``keep`` parameter.

.. ipython:: python

   df3 = pd.DataFrame({'a': np.arange(6),
                       'b': np.random.randn(6)},
                      index=['a', 'a', 'b', 'c', 'b', 'a'])
   df3
   df3.index.duplicated()
   df3[~df3.index.duplicated()]
   df3[~df3.index.duplicated(keep='last')]
   df3[~df3.index.duplicated(keep=False)]