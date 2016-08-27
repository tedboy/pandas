.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(0)
   pd.options.display.max_rows=15
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt

Missing data basics
-------------------

When / why does data become missing?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some might quibble over our usage of *missing*. By "missing" we simply mean
**null** or "not present for whatever reason". Many data sets simply arrive with
missing data, either because it exists and was not collected or it never
existed. For example, in a collection of financial time series, some of the time
series might start on different dates. Thus, values prior to the start date
would generally be marked as missing.

In pandas, one of the most common ways that missing data is **introduced** into
a data set is by reindexing. For example

.. ipython:: python

   df = pd.DataFrame(np.random.randn(5, 3), index=['a', 'c', 'e', 'f', 'h'],
                     columns=['one', 'two', 'three'])
   df['four'] = 'bar'
   df['five'] = df['one'] > 0
   df
   df2 = df.reindex(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'])
   df2

Values considered "missing"
~~~~~~~~~~~~~~~~~~~~~~~~~~~

As data comes in many shapes and forms, pandas aims to be flexible with regard
to handling missing data. While ``NaN`` is the default missing value marker for
reasons of computational speed and convenience, we need to be able to easily
detect this value with data of different types: floating point, integer,
boolean, and general object. In many cases, however, the Python ``None`` will
arise and we wish to also consider that "missing" or "null".

.. note::

   Prior to version v0.10.0 ``inf`` and ``-inf`` were also
   considered to be "null" in computations. This is no longer the case by
   default; use the ``mode.use_inf_as_null`` option to recover it.

.. _missing.isnull:

To make detecting missing values easier (and across different array dtypes),
pandas provides the :func:`~pandas.core.common.isnull` and
:func:`~pandas.core.common.notnull` functions, which are also methods on
``Series`` and ``DataFrame`` objects:

.. ipython:: python

   df2['one']
   pd.isnull(df2['one'])
   df2['four'].notnull()
   df2.isnull()

.. warning::

   One has to be mindful that in python (and numpy), the ``nan's`` don't compare equal, but ``None's`` **do**.
   Note that Pandas/numpy uses the fact that ``np.nan != np.nan``, and treats ``None`` like ``np.nan``.

   .. ipython:: python

      None == None
      np.nan == np.nan

   So as compared to above, a scalar equality comparison versus a ``None/np.nan`` doesn't provide useful information.

   .. ipython:: python

      df2['one'] == np.nan   