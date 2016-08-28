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
   sa = pd.Series([1,2,3],index=list('abc'))
   dfa = df.copy()

Attribute Access
----------------

.. _indexing.columns.multiple:

.. _indexing.df_cols:

.. _indexing.attribute_access:

You may access an index on a ``Series``, column on a ``DataFrame``, and an item on a ``Panel`` directly
as an attribute:

.. ipython:: python

   sa
   sa.b

   dfa
   dfa.A

   panel
   panel.one

You can use attribute access to modify an existing element of a Series or column of a DataFrame, but be careful;
if you try to use attribute access to create a new column, it fails silently, creating a new attribute rather than a
new column.

.. ipython:: python

   sa
   sa.a = 5
   sa
   dfa
   dfa.A = list(range(len(dfa.index)))  # ok if A already exists
   dfa
   dfa['A'] = list(range(len(dfa.index)))  # use this form to create a new column
   dfa

.. warning::

   - You can use this access only if the index element is a valid python identifier, e.g. ``s.1`` is not allowed.
     See `here for an explanation of valid identifiers
     <http://docs.python.org/2.7/reference/lexical_analysis.html#identifiers>`__.

   - The attribute will not be available if it conflicts with an existing method name, e.g. ``s.min`` is not allowed.

   - Similarly, the attribute will not be available if it conflicts with any of the following list: ``index``,
     ``major_axis``, ``minor_axis``, ``items``, ``labels``.

   - In any of these cases, standard indexing will still work, e.g. ``s['1']``, ``s['min']``, and ``s['index']`` will
     access the corresponding element or column.

   - The ``Series/Panel`` accesses are available starting in 0.13.0.

If you are using the IPython environment, you may also use tab-completion to
see these accessible attributes.

You can also assign a ``dict`` to a row of a ``DataFrame``:

.. ipython:: python

   x = pd.DataFrame({'x': [1, 2, 3], 'y': [3, 4, 5]})
   x
   x.iloc[1] = dict(x=9, y=99)
   x