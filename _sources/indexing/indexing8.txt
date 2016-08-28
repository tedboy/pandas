.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. _indexing.basics.partial_setting:

Selecting Random Samples
------------------------
.. versionadded::0.16.1

A random selection of rows or columns from a Series, DataFrame, or Panel with the :meth:`~DataFrame.sample` method. The method will sample rows by default, and accepts a specific number of rows/columns to return, or a fraction of rows.

.. ipython :: python

    s = pd.Series([0,1,2,3,4,5])

    # When no arguments are passed, returns 1 row.
    s.sample()

    # One may specify either a number of rows:
    s.sample(n=3)

    # Or a fraction of the rows:
    s.sample(frac=0.5)

By default, ``sample`` will return each row at most once, but one can also sample with replacement
using the ``replace`` option:

.. ipython :: python

   s = pd.Series([0,1,2,3,4,5])

    # Without replacement (default):
    s.sample(n=6, replace=False)

    # With replacement:
    s.sample(n=6, replace=True)


By default, each row has an equal probability of being selected, but if you want rows
to have different probabilities, you can pass the ``sample`` function sampling weights as
``weights``. These weights can be a list, a numpy array, or a Series, but they must be of the same length as the object you are sampling. Missing values will be treated as a weight of zero, and inf values are not allowed. If weights do not sum to 1, they will be re-normalized by dividing all weights by the sum of the weights. For example:

.. ipython :: python

    s = pd.Series([0,1,2,3,4,5])
    example_weights = [0, 0, 0.2, 0.2, 0.2, 0.4]
    s.sample(n=3, weights=example_weights)

    # Weights will be re-normalized automatically
    example_weights2 = [0.5, 0, 0, 0, 0, 0]
    s.sample(n=1, weights=example_weights2)

When applied to a DataFrame, you can use a column of the DataFrame as sampling weights
(provided you are sampling rows and not columns) by simply passing the name of the column
as a string.

.. ipython :: python

    df2 = pd.DataFrame({'col1':[9,8,7,6], 'weight_column':[0.5, 0.4, 0.1, 0]})
    df2.sample(n = 3, weights = 'weight_column')

``sample`` also allows users to sample columns instead of rows using the ``axis`` argument.

..  ipython :: python

    df3 = pd.DataFrame({'col1':[1,2,3], 'col2':[2,3,4]})
    df3.sample(n=1, axis=1)

Finally, one can also set a seed for ``sample``'s random number generator using the ``random_state`` argument, which will accept either an integer (as a seed) or a numpy RandomState object.

..  ipython :: python

    df4 = pd.DataFrame({'col1':[1,2,3], 'col2':[2,3,4]})

    # With a given seed, the sample will always draw the same rows.
    df4.sample(n=2, random_state=2)
    df4.sample(n=2, random_state=2)