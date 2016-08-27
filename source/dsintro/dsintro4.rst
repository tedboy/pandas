.. ipython:: python
   :suppress:

   import numpy as np
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.set_option('display.precision', 4, 'display.max_columns', 8)
   pd.options.display.max_rows = 8

   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')

.. _dsintro.panel4d:

Panel4D (Experimental)
----------------------

.. warning::

   In 0.19.0 ``Panel4D`` is deprecated and will be removed in a future version. The recommended way to represent these types of n-dimensional data are with the `xarray package <http://xarray.pydata.org/en/stable/>`__. Pandas provides a :meth:`~Panel4D.to_xarray` method to automate this conversion.

``Panel4D`` is a 4-Dimensional named container very much like a ``Panel``, but
having 4 named dimensions. It is intended as a test bed for more N-Dimensional named
containers.

  - **labels**: axis 0, each item corresponds to a Panel contained inside
  - **items**: axis 1, each item corresponds to a DataFrame contained inside
  - **major_axis**: axis 2, it is the **index** (rows) of each of the
    DataFrames
  - **minor_axis**: axis 3, it is the **columns** of each of the DataFrames

``Panel4D`` is a sub-class of ``Panel``, so most methods that work on Panels are
applicable to Panel4D. The following methods are disabled:

  - ``join , to_frame , to_excel , to_sparse , groupby``

Construction of Panel4D works in a very similar manner to a ``Panel``

From 4D ndarray with optional axis labels
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. ipython:: python

   p4d = pd.Panel4D(np.random.randn(2, 2, 5, 4),
                    labels=['Label1','Label2'],
                    items=['Item1', 'Item2'],
                    major_axis=pd.date_range('1/1/2000', periods=5),
                    minor_axis=['A', 'B', 'C', 'D'])
   p4d


From dict of Panel objects
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. ipython:: python

   data = { 'Label1' : pd.Panel({ 'Item1' : pd.DataFrame(np.random.randn(4, 3)) }),
            'Label2' : pd.Panel({ 'Item2' : pd.DataFrame(np.random.randn(4, 2)) }) }
   pd.Panel4D(data)

Note that the values in the dict need only be **convertible to Panels**.
Thus, they can be any of the other valid inputs to Panel as per above.

Slicing
~~~~~~~

Slicing works in a similar manner to a Panel. ``[]`` slices the first dimension.
``.ix`` allows you to slice arbitrarily and get back lower dimensional objects

.. ipython:: python

   p4d['Label1']

4D -> Panel

.. ipython:: python

   p4d.ix[:,:,:,'A']

4D -> DataFrame

.. ipython:: python

   p4d.ix[:,:,0,'A']

4D -> Series

.. ipython:: python

   p4d.ix[:,0,0,'A']

Transposing
~~~~~~~~~~~

A Panel4D can be rearranged using its ``transpose`` method (which does not make a
copy by default unless the data are heterogeneous):

.. ipython:: python

   p4d.transpose(3, 2, 1, 0)