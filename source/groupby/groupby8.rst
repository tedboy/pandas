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

.. _groupby.apply:

Flexible ``apply``
------------------

Some operations on the grouped data might not fit into either the aggregate or
transform categories. Or, you may simply want GroupBy to infer how to combine
the results. For these, use the ``apply`` function, which can be substituted
for both ``aggregate`` and ``transform`` in many standard use cases. However,
``apply`` can handle some exceptional use cases, for example:

.. ipython:: python

   df
   grouped = df.groupby('A')

   # could also just call .describe()
   grouped['C'].apply(lambda x: x.describe())

The dimension of the returned result can also change:

.. ipython::

    In [8]: grouped = df.groupby('A')['C']

    In [10]: def f(group):
       ....:     return pd.DataFrame({'original' : group,
       ....:                          'demeaned' : group - group.mean()})
       ....:

    In [11]: grouped.apply(f)

``apply`` on a Series can operate on a returned value from the applied function, that is itself a series, and possibly upcast the result to a DataFrame

.. ipython:: python

    def f(x):
      return pd.Series([ x, x**2 ], index = ['x', 'x^2'])
    s = pd.Series(np.random.rand(5))
    s
    s.apply(f)


.. note::

   ``apply`` can act as a reducer, transformer, *or* filter function, depending on exactly what is passed to it.
   So depending on the path taken, and exactly what you are grouping. Thus the grouped columns(s) may be included in
   the output as well as set the indices.

.. warning::

    In the current implementation apply calls func twice on the
    first group to decide whether it can take a fast or slow code
    path. This can lead to unexpected behavior if func has
    side-effects, as they will take effect twice for the first
    group.

    .. ipython:: python

        d = pd.DataFrame({"a":["x", "y"], "b":[1,2]})
        def identity(df):
            print df
            return df

        d.groupby("a").apply(identity)