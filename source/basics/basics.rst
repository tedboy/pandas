.. _basics:

==============================
 Essential Basic Functionality
==============================

Here we discuss a lot of the essential functionality common to the pandas data
structures. Here's how to create some of the objects used in the examples from
the previous section:

>>> import pandas as pd
>>> index = pd.date_range('1/1/2000', periods=8)
>>> s = pd.Series(np.random.randn(5), index=['a', 'b', 'c', 'd', 'e'])
>>> df = pd.DataFrame(np.random.randn(8, 3), index=index,
>>>                   columns=['A', 'B', 'C'])
>>> wp = pd.Panel(np.random.randn(2, 5, 4), items=['Item1', 'Item2'],
>>>               major_axis=pd.date_range('1/1/2000', periods=5),
>>>               minor_axis=['A', 'B', 'C', 'D'])


.. toctree::
    :maxdepth: 2
    :caption: Contents
    :name: basics

    basics1
    basics2
    basics3
    basics4
    basics5
    basics6
    basics7
    basics8
    basics9
    basics10
    basics11
    basics12
    basics13
    basics14


.. ipython:: python
  :suppress:

  import pandas as pd
  index = pd.date_range('1/1/2000', periods=8)
  df = pd.DataFrame(np.random.randn(8, 3), index=index,
                    columns=['A', 'B', 'C'])
  s = pd.Series(np.random.randn(5), index=['a', 'b', 'c', 'd', 'e'])
  wp = pd.Panel(np.random.randn(2, 5, 4), items=['Item1', 'Item2'],
                major_axis=pd.date_range('1/1/2000', periods=5),
                minor_axis=['A', 'B', 'C', 'D'])

.. ipython:: python

   index
   df
   s
   wp