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

.. _basics.panel:

Panel
-----

Panel is a somewhat less-used, but still important container for 3-dimensional
data. The term `panel data <http://en.wikipedia.org/wiki/Panel_data>`__ is
derived from econometrics and is partially responsible for the name pandas:
pan(el)-da(ta)-s. The names for the 3 axes are intended to give some semantic
meaning to describing operations involving panel data and, in particular,
econometric analysis of panel data. However, for the strict purposes of slicing
and dicing a collection of DataFrame objects, you may find the axis names
slightly arbitrary:

  - **items**: axis 0, each item corresponds to a DataFrame contained inside
  - **major_axis**: axis 1, it is the **index** (rows) of each of the
    DataFrames
  - **minor_axis**: axis 2, it is the **columns** of each of the DataFrames

Construction of Panels works about like you would expect:

From 3D ndarray with optional axis labels
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. ipython:: python

   wp = pd.Panel(np.random.randn(2, 5, 4), items=['Item1', 'Item2'],
                 major_axis=pd.date_range('1/1/2000', periods=5),
                 minor_axis=['A', 'B', 'C', 'D'])
   wp


From dict of DataFrame objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. ipython:: python

   data = {'Item1' : pd.DataFrame(np.random.randn(4, 3)),
           'Item2' : pd.DataFrame(np.random.randn(4, 2))}
   pd.Panel(data)

Note that the values in the dict need only be **convertible to
DataFrame**. Thus, they can be any of the other valid inputs to DataFrame as
per above.

One helpful factory method is ``Panel.from_dict``, which takes a
dictionary of DataFrames as above, and the following named parameters:

.. csv-table::
   :header: "Parameter", "Default", "Description"
   :widths: 10, 10, 40

   intersect, ``False``, drops elements whose indices do not align
   orient, ``items``, use ``minor`` to use DataFrames' columns as panel items

For example, compare to the construction above:

.. ipython:: python

   pd.Panel.from_dict(data, orient='minor')

Orient is especially useful for mixed-type DataFrames. If you pass a dict of
DataFrame objects with mixed-type columns, all of the data will get upcasted to
``dtype=object`` unless you pass ``orient='minor'``:

.. ipython:: python

   df = pd.DataFrame({'a': ['foo', 'bar', 'baz'],
                      'b': np.random.randn(3)})
   df
   data = {'item1': df, 'item2': df}
   panel = pd.Panel.from_dict(data, orient='minor')
   panel['a']
   panel['b']
   panel['b'].dtypes

.. note::

   Unfortunately Panel, being less commonly used than Series and DataFrame,
   has been slightly neglected feature-wise. A number of methods and options
   available in DataFrame are not available in Panel. This will get worked
   on, of course, in future releases. And faster if you join me in working on
   the codebase.

.. _dsintro.to_panel:

From DataFrame using ``to_panel`` method
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This method was introduced in v0.7 to replace ``LongPanel.to_long``, and converts
a DataFrame with a two-level index to a Panel.

.. ipython:: python

   midx = pd.MultiIndex(levels=[['one', 'two'], ['x','y']], labels=[[1,1,0,0],[1,0,1,0]])
   df = pd.DataFrame({'A' : [1, 2, 3, 4], 'B': [5, 6, 7, 8]}, index=midx)
   df.to_panel()

.. _dsintro.panel_item_selection:

Item selection / addition / deletion
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Similar to DataFrame functioning as a dict of Series, Panel is like a dict
of DataFrames:

.. ipython:: python

   wp['Item1']
   wp['Item3'] = wp['Item1'] / wp['Item2']

The API for insertion and deletion is the same as for DataFrame. And as with
DataFrame, if the item is a valid python identifier, you can access it as an
attribute and tab-complete it in IPython.

Transposing
~~~~~~~~~~~

A Panel can be rearranged using its ``transpose`` method (which does not make a
copy by default unless the data are heterogeneous):

.. ipython:: python

   wp.transpose(2, 0, 1)

Indexing / Selection
~~~~~~~~~~~~~~~~~~~~

.. csv-table::
    :header: "Operation", "Syntax", "Result"
    :widths: 30, 20, 10

    Select item, ``wp[item]``, DataFrame
    Get slice at major_axis label, ``wp.major_xs(val)``, DataFrame
    Get slice at minor_axis label, ``wp.minor_xs(val)``, DataFrame

For example, using the earlier example data, we could do:

.. ipython:: python

    wp['Item1']
    wp.major_xs(wp.major_axis[2])
    wp.minor_axis
    wp.minor_xs('C')

Squeezing
~~~~~~~~~

Another way to change the dimensionality of an object is to ``squeeze`` a 1-len object, similar to ``wp['Item1']``

.. ipython:: python

   wp.reindex(items=['Item1']).squeeze()
   wp.reindex(items=['Item1'], minor=['B']).squeeze()


Conversion to DataFrame
~~~~~~~~~~~~~~~~~~~~~~~

A Panel can be represented in 2D form as a hierarchically indexed
DataFrame. See the section :ref:`hierarchical indexing <advanced.hierarchical>`
for more on this. To convert a Panel to a DataFrame, use the ``to_frame``
method:

.. ipython:: python

   panel = pd.Panel(np.random.randn(3, 5, 4), items=['one', 'two', 'three'],
                    major_axis=pd.date_range('1/1/2000', periods=5),
                    minor_axis=['a', 'b', 'c', 'd'])
   panel.to_frame()