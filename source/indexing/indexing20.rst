.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(1234567)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

Set / Reset Index
-----------------

Occasionally you will load or create a data set into a DataFrame and want to
add an index after you've already done so. There are a couple of different
ways.

Set an index
~~~~~~~~~~~~

.. _indexing.set_index:

DataFrame has a ``set_index`` method which takes a column name (for a regular
``Index``) or a list of column names (for a ``MultiIndex``), to create a new,
indexed DataFrame:

.. ipython:: python

   data = pd.DataFrame({'a' : ['bar', 'bar', 'foo', 'foo'],
                        'b' : ['one', 'two', 'one', 'two'],
                        'c' : ['z', 'y', 'x', 'w'],
                        'd' : [1., 2., 3, 4]})

.. ipython:: python

   data
   indexed1 = data.set_index('c')
   indexed1
   indexed2 = data.set_index(['a', 'b'])
   indexed2

The ``append`` keyword option allow you to keep the existing index and append
the given columns to a MultiIndex:

.. ipython:: python

   frame = data.set_index('c', drop=False)
   frame
   frame = frame.set_index(['a', 'b'], append=True)
   frame

Other options in ``set_index`` allow you not drop the index columns or to add
the index in-place (without creating a new object):

.. ipython:: python

   data
   data.set_index('c', drop=False)
   data.set_index(['a', 'b'], inplace=True)
   data

Reset the index
~~~~~~~~~~~~~~~

As a convenience, there is a new function on DataFrame called ``reset_index``
which transfers the index values into the DataFrame's columns and sets a simple
integer index. This is the inverse operation to ``set_index``

.. ipython:: python

   data
   data.reset_index()

The output is more similar to a SQL table or a record array. The names for the
columns derived from the index are the ones stored in the ``names`` attribute.

You can use the ``level`` keyword to remove only a portion of the index:

.. ipython:: python

   frame
   frame.reset_index(level=1)


``reset_index`` takes an optional parameter ``drop`` which if true simply
discards the index, instead of putting index values in the DataFrame's columns.

.. note::

   The ``reset_index`` method used to be called ``delevel`` which is now
   deprecated.

Adding an ad hoc index
~~~~~~~~~~~~~~~~~~~~~~

If you create an index yourself, you can just assign it to the ``index`` field:

.. code-block:: python

   data.index = index