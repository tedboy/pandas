.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. ipython:: python
   :suppress:

   dates = pd.date_range('1/1/2000', periods=8)
   df = pd.DataFrame(np.random.randn(8, 4), index=dates, columns=['A', 'B', 'C', 'D'])
   s = df['A']
   panel = pd.Panel({'one' : df, 'two' : df - df.mean()})

.. _indexing.label:

Selection By Label
------------------

.. warning::

   Whether a copy or a reference is returned for a setting operation, may depend on the context.
   This is sometimes called ``chained assignment`` and should be avoided.
   See :ref:`Returning a View versus Copy <indexing.view_versus_copy>`

.. warning::

   ``.loc`` is strict when you present slicers that are not compatible (or convertible) with the index type. For example
   using integers in a ``DatetimeIndex``. These will raise a ``TypeError``.

  .. ipython:: python

     dfl = pd.DataFrame(np.random.randn(5,4), columns=list('ABCD'), index=pd.date_range('20130101',periods=5))
     dfl

  .. code-block:: ipython

     In [4]: dfl.loc[2:3]
     TypeError: cannot do slice indexing on <class 'pandas.tseries.index.DatetimeIndex'> with these indexers [2] of <type 'int'>

  String likes in slicing *can* be convertible to the type of the index and lead to natural slicing.

  .. ipython:: python

     dfl.loc['20130102':'20130104']

pandas provides a suite of methods in order to have **purely label based indexing**. This is a strict inclusion based protocol.
**At least 1** of the labels for which you ask, must be in the index or a ``KeyError`` will be raised! When slicing, the start bound is *included*, **AND** the stop bound is *included*. Integers are valid labels, but they refer to the label **and not the position**.

The ``.loc`` attribute is the primary access method. The following are valid inputs:

- A single label, e.g. ``5`` or ``'a'``, (note that ``5`` is interpreted as a *label* of the index. This use is **not** an integer position along the index)
- A list or array of labels ``['a', 'b', 'c']``
- A slice object with labels ``'a':'f'`` (note that contrary to usual python slices, **both** the start and the stop are included!)
- A boolean array
- A ``callable``, see :ref:`Selection By Callable <indexing.callable>`

.. ipython:: python

   s1 = pd.Series(np.random.randn(6),index=list('abcdef'))
   s1
   s1.loc['c':]
   s1.loc['b']

Note that setting works as well:

.. ipython:: python

   s1.loc['c':] = 0
   s1

With a DataFrame

.. ipython:: python

   df1 = pd.DataFrame(np.random.randn(6,4),
                      index=list('abcdef'),
                      columns=list('ABCD'))
   df1
   df1.loc[['a', 'b', 'd'], :]

Accessing via label slices

.. ipython:: python

   df1.loc['d':, 'A':'C']

For getting a cross section using a label (equiv to ``df.xs('a')``)

.. ipython:: python

   df1.loc['a']

For getting values with a boolean array

.. ipython:: python

   df1.loc['a'] > 0
   df1.loc[:, df1.loc['a'] > 0]

For getting a value explicitly (equiv to deprecated ``df.get_value('a','A')``)

.. ipython:: python

   # this is also equivalent to ``df1.at['a','A']``
   df1.loc['a', 'A']