.. ipython:: python
   :suppress:
   
   import pandas as pd
   import numpy as np

   import random
   import os
   import itertools
   import functools
   import datetime

   np.random.seed(123456)
   pd.options.display.max_rows=8
   import matplotlib
   matplotlib.style.use('ggplot')
   np.set_printoptions(precision=4, suppress=True)

Aliasing Axis Names
-------------------

To globally provide aliases for axis names, one can define these 2 functions:

.. ipython:: python

   def set_axis_alias(cls, axis, alias):
      if axis not in cls._AXIS_NUMBERS:
         raise Exception("invalid axis [%s] for alias [%s]" % (axis, alias))
      cls._AXIS_ALIASES[alias] = axis

.. ipython:: python

   def clear_axis_alias(cls, axis, alias):
      if axis not in cls._AXIS_NUMBERS:
         raise Exception("invalid axis [%s] for alias [%s]" % (axis, alias))
      cls._AXIS_ALIASES.pop(alias,None)

.. ipython:: python

   set_axis_alias(pd.DataFrame,'columns', 'myaxis2')
   df2 = pd.DataFrame(np.random.randn(3,2),columns=['c1','c2'],index=['i1','i2','i3'])
   df2.sum(axis='myaxis2')
   clear_axis_alias(pd.DataFrame,'columns', 'myaxis2')