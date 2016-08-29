.. ipython:: python
   :suppress:

   import pandas as pd
   import numpy as np
   pd.options.display.max_rows=8

plyr
----

``plyr`` is an R library for the split-apply-combine strategy for data
analysis. The functions revolve around three data structures in R, ``a``
for ``arrays``, ``l`` for ``lists``, and ``d`` for ``data.frame``. The
table below shows how these data structures could be mapped in Python.

+------------+-------------------------------+
| R          | Python                        |
+============+===============================+
| array      | list                          |
+------------+-------------------------------+
| lists      | dictionary or list of objects |
+------------+-------------------------------+
| data.frame | dataframe                     |
+------------+-------------------------------+

|ddply|_
~~~~~~~~

An expression using a data.frame called ``df`` in R where you want to
summarize ``x`` by ``month``:

.. code-block:: r

   require(plyr)
   df <- data.frame(
     x = runif(120, 1, 168),
     y = runif(120, 7, 334),
     z = runif(120, 1.7, 20.7),
     month = rep(c(5,6,7,8),30),
     week = sample(1:4, 120, TRUE)
   )

   ddply(df, .(month, week), summarize,
         mean = round(mean(x), 2),
         sd = round(sd(x), 2))

In ``pandas`` the equivalent expression, using the
:meth:`~pandas.DataFrame.groupby` method, would be:

.. ipython:: python

   df = pd.DataFrame({
       'x': np.random.uniform(1., 168., 120),
       'y': np.random.uniform(7., 334., 120),
       'z': np.random.uniform(1.7, 20.7, 120),
       'month': [5,6,7,8]*30,
       'week': np.random.randint(1,4, 120)
   })

   grouped = df.groupby(['month','week'])
   grouped['x'].agg([np.mean, np.std])


For more details and examples see :ref:`the groupby documentation
<groupby.aggregate>`.