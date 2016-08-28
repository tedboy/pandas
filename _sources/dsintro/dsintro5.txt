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

.. _dsintro.panelnd:

PanelND (Experimental)
----------------------

.. warning::

   In 0.19.0 ``PanelND`` is deprecated and will be removed in a future version. The recommended way to represent these types of n-dimensional data are with the `xarray package <http://xarray.pydata.org/en/stable/>`__.

PanelND is a module with a set of factory functions to enable a user to construct N-dimensional named
containers like Panel4D, with a custom set of axis labels. Thus a domain-specific container can easily be
created.

The following creates a Panel5D. A new panel type object must be sliceable into a lower dimensional object.
Here we slice to a Panel4D.

.. ipython:: python
    :okwarning:

    from pandas.core import panelnd
    Panel5D = panelnd.create_nd_panel_factory(
        klass_name   = 'Panel5D',
        orders  = [ 'cool', 'labels','items','major_axis','minor_axis'],
        slices  = { 'labels' : 'labels', 'items' : 'items',
                    'major_axis' : 'major_axis', 'minor_axis' : 'minor_axis' },
        slicer  = pd.Panel4D,
        aliases = { 'major' : 'major_axis', 'minor' : 'minor_axis' },
        stat_axis    = 2)

    p5d = Panel5D(dict(C1 = p4d))
    p5d

    # print a slice of our 5D
    p5d.ix['C1',:,:,0:3,:]

    # transpose it
    p5d.transpose(1,2,3,4,0)

    # look at the shape & dim
    p5d.shape
    p5d.ndim
