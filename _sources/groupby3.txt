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
   df = pd.DataFrame({'A' : ['foo', 'bar', 'foo', 'bar',
                             'foo', 'bar', 'foo', 'foo'],
                      'B' : ['one', 'one', 'two', 'three',
                             'two', 'two', 'one', 'three'],
                      'C' : np.random.randn(8),
                      'D' : np.random.randn(8)})
                      
.. _groupby.iterating:

Iterating through groups
------------------------

With the GroupBy object in hand, iterating through the grouped data is very
natural and functions similarly to ``itertools.groupby``:

.. ipython::

   In [3]: df

   In [4]: grouped = df.groupby('A')

   In [5]: for name, group in grouped:
      ...:        print(name)
      ...:        print(group)
      ...:

In the case of grouping by multiple keys, the group name will be a tuple:

.. ipython::

   In [5]: for name, group in df.groupby(['A', 'B']):
      ...:        print(name)
      ...:        print(group)
      ...:

It's standard Python-fu but remember you can unpack the tuple in the for loop
statement if you wish: ``for (k1, k2), group in grouped:``.

Selecting a group
-----------------

A single group can be selected using ``GroupBy.get_group()``:

.. ipython:: python

   grouped.get_group('bar')

Or for an object grouped on multiple columns:

.. ipython:: python

   df.groupby(['A', 'B']).get_group(('bar', 'one'))