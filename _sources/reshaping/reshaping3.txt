.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   import pandas as pd
   pd.options.display.max_rows=8
   np.set_printoptions(precision=4, suppress=True)

.. _reshaping.melt:

Reshaping by Melt
-----------------

The :func:`~pandas.melt` function is useful to massage a
DataFrame into a format where one or more columns are identifier variables,
while all other columns, considered measured variables, are "unpivoted" to the
row axis, leaving just two non-identifier columns, "variable" and "value". The
names of those columns can be customized by supplying the ``var_name`` and
``value_name`` parameters.

For instance,

.. ipython:: python

   cheese = pd.DataFrame({'first' : ['John', 'Mary'],
                          'last' : ['Doe', 'Bo'],
                          'height' : [5.5, 6.0],
                          'weight' : [130, 150]})
   cheese
   pd.melt(cheese, id_vars=['first', 'last'])
   pd.melt(cheese, id_vars=['first', 'last'], var_name='quantity')

Another way to transform is to use the ``wide_to_long`` panel data convenience function.

.. ipython:: python

  dft = pd.DataFrame({"A1970" : {0 : "a", 1 : "b", 2 : "c"},
                      "A1980" : {0 : "d", 1 : "e", 2 : "f"},
                      "B1970" : {0 : 2.5, 1 : 1.2, 2 : .7},
                      "B1980" : {0 : 3.2, 1 : 1.3, 2 : .1},
                      "X"     : dict(zip(range(3), np.random.randn(3)))
                     })
  dft["id"] = dft.index
  dft
  pd.wide_to_long(dft, ["A", "B"], i="id", j="year")