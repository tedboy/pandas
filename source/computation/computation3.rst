.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')
   pd.options.display.max_rows=8

.. _stats.aggregate:

Aggregation
-----------

Once the ``Rolling``, ``Expanding`` or ``EWM`` objects have been created, several methods are available to
perform multiple computations on the data. This is very similar to a ``.groupby(...).agg`` seen :ref:`here <groupby.aggregate>`.

.. ipython:: python

   dfa = pd.DataFrame(np.random.randn(1000, 3),
                      index=pd.date_range('1/1/2000', periods=1000),
                      columns=['A', 'B', 'C'])
   r = dfa.rolling(window=60,min_periods=1)
   r

We can aggregate by passing a function to the entire DataFrame, or select a Series (or multiple Series) via standard getitem.

.. ipython:: python

   r.aggregate(np.sum)

   r['A'].aggregate(np.sum)

   r[['A','B']].aggregate(np.sum)

As you can see, the result of the aggregation will have the selected columns, or all
columns if none are selected.

.. _stats.aggregate.multifunc:

Applying multiple functions at once
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

With windowed Series you can also pass a list or dict of functions to do
aggregation with, outputting a DataFrame:

.. ipython:: python

   r['A'].agg([np.sum, np.mean, np.std])

If a dict is passed, the keys will be used to name the columns. Otherwise the
function's name (stored in the function object) will be used.

.. ipython:: python

   r['A'].agg({'result1' : np.sum,
               'result2' : np.mean})

On a widowed DataFrame, you can pass a list of functions to apply to each
column, which produces an aggregated result with a hierarchical index:

.. ipython:: python

   r.agg([np.sum, np.mean])

Passing a dict of functions has different behavior by default, see the next
section.

Applying different functions to DataFrame columns
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By passing a dict to ``aggregate`` you can apply a different aggregation to the
columns of a DataFrame:

.. ipython:: python
   :okexcept:

   r.agg({'A' : np.sum,
          'B' : lambda x: np.std(x, ddof=1)})

The function names can also be strings. In order for a string to be valid it
must be implemented on the windowed object

.. ipython:: python

   r.agg({'A' : 'sum', 'B' : 'std'})

Furthermore you can pass a nested dict to indicate different aggregations on different columns.

.. ipython:: python

   r.agg({'A' : ['sum','std'], 'B' : ['mean','std'] })