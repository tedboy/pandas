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

.. _groupby.aggregate:

Aggregation
-----------

Once the GroupBy object has been created, several methods are available to
perform a computation on the grouped data.

An obvious one is aggregation via the ``aggregate`` or equivalently ``agg`` method:

.. ipython:: python

   df
   grouped = df.groupby('A')
   grouped.aggregate(np.sum)

   grouped = df.groupby(['A', 'B'])
   grouped.aggregate(np.sum)

As you can see, the result of the aggregation will have the group names as the
new index along the grouped axis. In the case of multiple keys, the result is a
:ref:`MultiIndex <advanced.hierarchical>` by default, though this can be
changed by using the ``as_index`` option:

.. ipython:: python

   grouped = df.groupby(['A', 'B'], as_index=False)
   grouped.aggregate(np.sum)

   df.groupby('A', as_index=False).sum()

Note that you could use the ``reset_index`` DataFrame function to achieve the
same result as the column names are stored in the resulting ``MultiIndex``:

.. ipython:: python

   df.groupby(['A', 'B']).sum().reset_index()

Another simple aggregation example is to compute the size of each group.
This is included in GroupBy as the ``size`` method. It returns a Series whose
index are the group names and whose values are the sizes of each group.

.. ipython:: python

   grouped.size()

.. ipython:: python

   grouped.describe()

.. note::

   Aggregation functions **will not** return the groups that you are aggregating over
   if they are named *columns*, when ``as_index=True``, the default. The grouped columns will
   be the **indices** of the returned object.

   Passing ``as_index=False`` **will** return the groups that you are aggregating over, if they are
   named *columns*.

   Aggregating functions are ones that reduce the dimension of the returned objects,
   for example: ``mean, sum, size, count, std, var, sem, describe, first, last, nth, min, max``. This is
   what happens when you do for example ``DataFrame.sum()`` and get back a ``Series``.

   ``nth`` can act as a reducer *or* a filter, see :ref:`here <groupby.nth>`

.. _groupby.aggregate.multifunc:

Applying multiple functions at once
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

With grouped Series you can also pass a list or dict of functions to do
aggregation with, outputting a DataFrame:

.. ipython:: python

   grouped = df.groupby('A')
   grouped['C'].agg([np.sum, np.mean, np.std])

If a dict is passed, the keys will be used to name the columns. Otherwise the
function's name (stored in the function object) will be used.

.. ipython:: python

   grouped['D'].agg({'result1' : np.sum,
                     'result2' : np.mean})

On a grouped DataFrame, you can pass a list of functions to apply to each
column, which produces an aggregated result with a hierarchical index:

.. ipython:: python

   grouped.agg([np.sum, np.mean, np.std])

Passing a dict of functions has different behavior by default, see the next
section.

Applying different functions to DataFrame columns
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By passing a dict to ``aggregate`` you can apply a different aggregation to the
columns of a DataFrame:

.. ipython:: python

   grouped.agg({'C' : np.sum,
                'D' : lambda x: np.std(x, ddof=1)})

The function names can also be strings. In order for a string to be valid it
must be either implemented on GroupBy or available via :ref:`dispatching
<groupby.dispatch>`:

.. ipython:: python

   grouped.agg({'C' : 'sum', 'D' : 'std'})

.. note::

    If you pass a dict to ``aggregate``, the ordering of the output colums is
    non-deterministic. If you want to be sure the output columns will be in a specific
    order, you can use an ``OrderedDict``.  Compare the output of the following two commands:

.. ipython:: python

   grouped.agg({'D': 'std', 'C': 'mean'})
   grouped.agg(OrderedDict([('D', 'std'), ('C', 'mean')]))

.. _groupby.aggregate.cython:

Cython-optimized aggregation functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some common aggregations, currently only ``sum``, ``mean``, ``std``, and ``sem``, have
optimized Cython implementations:

.. ipython:: python

   df.groupby('A').sum()
   df.groupby(['A', 'B']).mean()

Of course ``sum`` and ``mean`` are implemented on pandas objects, so the above
code would work even without the special versions via dispatching (see below).
