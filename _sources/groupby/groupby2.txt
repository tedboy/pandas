.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows = 15
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')
   from collections import OrderedDict

.. _groupby.split:

Splitting an object into groups
-------------------------------

pandas objects can be split on any of their axes. The abstract definition of
grouping is to provide a mapping of labels to group names. To create a GroupBy
object (more on what the GroupBy object is later), you do the following:

>>> # default is axis=0
>>> grouped = obj.groupby(key)
>>> grouped = obj.groupby(key, axis=1)
>>> grouped = obj.groupby([key1, key2])

The mapping can be specified many different ways:

  - A Python function, to be called on each of the axis labels
  - A list or NumPy array of the same length as the selected axis
  - A dict or Series, providing a ``label -> group name`` mapping
  - For DataFrame objects, a string indicating a column to be used to group. Of
    course ``df.groupby('A')`` is just syntactic sugar for
    ``df.groupby(df['A'])``, but it makes life simpler
  - A list of any of the above things

Collectively we refer to the grouping objects as the **keys**. For example,
consider the following DataFrame:

.. ipython:: python

   df = pd.DataFrame({'A' : ['foo', 'bar', 'foo', 'bar',
                             'foo', 'bar', 'foo', 'foo'],
                      'B' : ['one', 'one', 'two', 'three',
                             'two', 'two', 'one', 'three'],
                      'C' : np.random.randn(8),
                      'D' : np.random.randn(8)})
   df

We could naturally group by either the ``A`` or ``B`` columns or both:

.. ipython:: python

   grouped = df.groupby('A')
   grouped = df.groupby(['A', 'B'])

These will split the DataFrame on its index (rows). We could also split by the
columns:

.. ipython::

    In [4]: def get_letter_type(letter):
       ...:     if letter.lower() in 'aeiou':
       ...:         return 'vowel'
       ...:     else:
       ...:         return 'consonant'
       ...:

    In [5]: grouped = df.groupby(get_letter_type, axis=1)

Starting with 0.8, pandas Index objects now support duplicate values. If a
non-unique index is used as the group key in a groupby operation, all values
for the same index value will be considered to be in one group and thus the
output of aggregation functions will only contain unique index values:

.. ipython:: python

   lst = [1, 2, 3, 1, 2, 3]

   s = pd.Series([1, 2, 3, 10, 20, 30], lst)

   grouped = s.groupby(level=0)

   grouped.first()

   grouped.last()

   grouped.sum()

Note that **no splitting occurs** until it's needed. Creating the GroupBy object
only verifies that you've passed a valid mapping.

.. note::

   Many kinds of complicated data manipulations can be expressed in terms of
   GroupBy operations (though can't be guaranteed to be the most
   efficient). You can get quite creative with the label mapping functions.

.. _groupby.sorting:

GroupBy sorting
~~~~~~~~~~~~~~~~~~~~~~~~~

By default the group keys are sorted during the ``groupby`` operation. You may however pass ``sort=False`` for potential speedups:

.. ipython:: python

   df2 = pd.DataFrame({'X' : ['B', 'B', 'A', 'A'], 'Y' : [1, 2, 3, 4]})
   df2.groupby(['X']).sum()
   df2.groupby(['X'], sort=False).sum()


Note that ``groupby`` will preserve the order in which *observations* are sorted *within* each group.
For example, the groups created by ``groupby()`` below are in the order they appeared in the original ``DataFrame``:

.. ipython:: python

   df3 = pd.DataFrame({'X' : ['A', 'B', 'A', 'B'], 'Y' : [1, 4, 3, 2]})
   df3.groupby(['X']).get_group('A')

   df3.groupby(['X']).get_group('B')



.. _groupby.attributes:

GroupBy object attributes
~~~~~~~~~~~~~~~~~~~~~~~~~

The ``groups`` attribute is a dict whose keys are the computed unique groups
and corresponding values being the axis labels belonging to each group. In the
above example we have:

.. ipython:: python

   df.groupby('A').groups
   df.groupby(get_letter_type, axis=1).groups

Calling the standard Python ``len`` function on the GroupBy object just returns
the length of the ``groups`` dict, so it is largely just a convenience:

.. ipython:: python

   grouped = df.groupby(['A', 'B'])
   grouped.groups
   len(grouped)


.. _groupby.tabcompletion:

``GroupBy`` will tab complete column names (and other attributes)

.. ipython:: python
   :suppress:

   n = 10
   weight = np.random.normal(166, 20, size=n)
   height = np.random.normal(60, 10, size=n)
   time = pd.date_range('1/1/2000', periods=n)
   gender = np.random.choice(['male', 'female'], size=n)
   df = pd.DataFrame({'height': height, 'weight': weight,
                      'gender': gender}, index=time)

.. ipython:: python

   df
   gb = df.groupby('gender')


.. ipython::

   @verbatim
   In [1]: gb.<TAB>
   gb.agg        gb.boxplot    gb.cummin     gb.describe   gb.filter     gb.get_group  gb.height     gb.last       gb.median     gb.ngroups    gb.plot       gb.rank       gb.std        gb.transform
   gb.aggregate  gb.count      gb.cumprod    gb.dtype      gb.first      gb.groups     gb.hist       gb.max        gb.min        gb.nth        gb.prod       gb.resample   gb.sum        gb.var
   gb.apply      gb.cummax     gb.cumsum     gb.fillna     gb.gender     gb.head       gb.indices    gb.mean       gb.name       gb.ohlc       gb.quantile   gb.size       gb.tail       gb.weight


.. ipython:: python
   :suppress:

   df = pd.DataFrame({'A' : ['foo', 'bar', 'foo', 'bar',
                             'foo', 'bar', 'foo', 'foo'],
                      'B' : ['one', 'one', 'two', 'three',
                             'two', 'two', 'one', 'three'],
                      'C' : np.random.randn(8),
                      'D' : np.random.randn(8)})

.. _groupby.multiindex:

GroupBy with MultiIndex
~~~~~~~~~~~~~~~~~~~~~~~

With :ref:`hierarchically-indexed data <advanced.hierarchical>`, it's quite
natural to group by one of the levels of the hierarchy.

Let's create a Series with a two-level ``MultiIndex``.

.. ipython:: python


   arrays = [['bar', 'bar', 'baz', 'baz', 'foo', 'foo', 'qux', 'qux'],
             ['one', 'two', 'one', 'two', 'one', 'two', 'one', 'two']]
   index = pd.MultiIndex.from_arrays(arrays, names=['first', 'second'])
   s = pd.Series(np.random.randn(8), index=index)
   s

We can then group by one of the levels in ``s``.

.. ipython:: python

   grouped = s.groupby(level=0)
   grouped.sum()

If the MultiIndex has names specified, these can be passed instead of the level
number:

.. ipython:: python

   s.groupby(level='second').sum()

The aggregation functions such as ``sum`` will take the level parameter
directly. Additionally, the resulting index will be named according to the
chosen level:

.. ipython:: python

   s.sum(level='second')

Also as of v0.6, grouping with multiple levels is supported.

.. ipython:: python
   :suppress:

   arrays = [['bar', 'bar', 'baz', 'baz', 'foo', 'foo', 'qux', 'qux'],
             ['doo', 'doo', 'bee', 'bee', 'bop', 'bop', 'bop', 'bop'],
             ['one', 'two', 'one', 'two', 'one', 'two', 'one', 'two']]
   tuples = list(zip(*arrays))
   index = pd.MultiIndex.from_tuples(tuples, names=['first', 'second', 'third'])
   s = pd.Series(np.random.randn(8), index=index)

.. ipython:: python

   s
   s.groupby(level=['first', 'second']).sum()

More on the ``sum`` function and aggregation later.

DataFrame column selection in GroupBy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once you have created the GroupBy object from a DataFrame, for example, you
might want to do something different for each of the columns. Thus, using
``[]`` similar to getting a column from a DataFrame, you can do:

.. ipython:: python

   grouped = df.groupby(['A'])
   grouped_C = grouped['C']
   grouped_D = grouped['D']

This is mainly syntactic sugar for the alternative and much more verbose:

.. ipython:: python

   df['C'].groupby(df['A'])

Additionally this method avoids recomputing the internal grouping information
derived from the passed key.