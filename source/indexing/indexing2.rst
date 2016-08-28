.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8
   
.. _indexing.basics:

Basics
------

As mentioned when introducing the data structures in the :ref:`last section
<basics>`, the primary function of indexing with ``[]`` (a.k.a. ``__getitem__``
for those familiar with implementing class behavior in Python) is selecting out
lower-dimensional slices. Thus,

.. csv-table::
    :header: "Object Type", "Selection", "Return Value Type"
    :widths: 30, 30, 60
    :delim: ;

    Series; ``series[label]``; scalar value
    DataFrame; ``frame[colname]``; ``Series`` corresponding to colname
    Panel; ``panel[itemname]``; ``DataFrame`` corresponding to the itemname

Here we construct a simple time series data set to use for illustrating the
indexing functionality:

.. ipython:: python

   dates = pd.date_range('1/1/2000', periods=8)
   df = pd.DataFrame(np.random.randn(8, 4), index=dates, columns=['A', 'B', 'C', 'D'])
   df
   panel = pd.Panel({'one' : df, 'two' : df - df.mean()})
   panel

.. note::

   None of the indexing functionality is time series specific unless
   specifically stated.

Thus, as per above, we have the most basic indexing using ``[]``:

.. ipython:: python

   s = df['A']
   s
   s[dates[5]]
   panel['two']

You can pass a list of columns to ``[]`` to select columns in that order.
If a column is not contained in the DataFrame, an exception will be
raised. Multiple columns can also be set in this manner:

.. ipython:: python

   df
   df[['B', 'A']] = df[['A', 'B']]
   df

You may find this useful for applying a transform (in-place) to a subset of the
columns.

.. warning::

   pandas aligns all AXES when setting ``Series`` and ``DataFrame`` from ``.loc``, ``.iloc`` and ``.ix``.

   This will **not** modify ``df`` because the column alignment is before value assignment.

   .. ipython:: python

      df[['A', 'B']]
      df.loc[:,['B', 'A']] = df[['A', 'B']]
      df[['A', 'B']]

   The correct way is to use raw values

   .. ipython:: python

      df.loc[:,['B', 'A']] = df[['A', 'B']].values
      df[['A', 'B']]