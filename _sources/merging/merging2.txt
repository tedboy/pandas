.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   import pandas as pd
   pd.options.display.max_rows=15
   randn = np.random.randn
   np.set_printoptions(precision=4, suppress=True)

   import matplotlib.pyplot as plt
   plt.close('all')
   import pandas.util.doctools as doctools
   p = doctools.TablePlotter()

.. _merging.join:

Database-style DataFrame joining/merging
----------------------------------------

pandas has full-featured, **high performance** in-memory join operations
idiomatically very similar to relational databases like SQL. These methods
perform significantly better (in some cases well over an order of magnitude
better) than other open source implementations (like ``base::merge.data.frame``
in R). The reason for this is careful algorithmic design and internal layout of
the data in DataFrame.

See the :ref:`cookbook<cookbook.merge>` for some advanced strategies.

Users who are familiar with SQL but new to pandas might be interested in a
:ref:`comparison with SQL<compare_with_sql.join>`.

pandas provides a single function, ``merge``, as the entry point for all
standard database join operations between DataFrame objects:

::

    pd.merge(left, right, how='inner', on=None, left_on=None, right_on=None,
             left_index=False, right_index=False, sort=True,
             suffixes=('_x', '_y'), copy=True, indicator=False)

- ``left``: A DataFrame object
- ``right``: Another DataFrame object
- ``on``: Columns (names) to join on. Must be found in both the left and
  right DataFrame objects. If not passed and ``left_index`` and
  ``right_index`` are ``False``, the intersection of the columns in the
  DataFrames will be inferred to be the join keys
- ``left_on``: Columns from the left DataFrame to use as keys. Can either be
  column names or arrays with length equal to the length of the DataFrame
- ``right_on``: Columns from the right DataFrame to use as keys. Can either be
  column names or arrays with length equal to the length of the DataFrame
- ``left_index``: If ``True``, use the index (row labels) from the left
  DataFrame as its join key(s). In the case of a DataFrame with a MultiIndex
  (hierarchical), the number of levels must match the number of join keys
  from the right DataFrame
- ``right_index``: Same usage as ``left_index`` for the right DataFrame
- ``how``: One of ``'left'``, ``'right'``, ``'outer'``, ``'inner'``. Defaults
  to ``inner``. See below for more detailed description of each method
- ``sort``: Sort the result DataFrame by the join keys in lexicographical
  order. Defaults to ``True``, setting to ``False`` will improve performance
  substantially in many cases
- ``suffixes``: A tuple of string suffixes to apply to overlapping
  columns. Defaults to ``('_x', '_y')``.
- ``copy``: Always copy data (default ``True``) from the passed DataFrame
  objects, even when reindexing is not necessary. Cannot be avoided in many
  cases but may improve performance / memory usage. The cases where copying
  can be avoided are somewhat pathological but this option is provided
  nonetheless.
- ``indicator``: Add a column to the output DataFrame called ``_merge``
  with information on the source of each row. ``_merge`` is Categorical-type
  and takes on a value of ``left_only`` for observations whose merge key
  only appears in ``'left'`` DataFrame, ``right_only`` for observations whose
  merge key only appears in ``'right'`` DataFrame, and ``both`` if the
  observation's merge key is found in both.

  .. versionadded:: 0.17.0

The return type will be the same as ``left``. If ``left`` is a ``DataFrame``
and ``right`` is a subclass of DataFrame, the return type will still be
``DataFrame``.

``merge`` is a function in the pandas namespace, and it is also available as a
DataFrame instance method, with the calling DataFrame being implicitly
considered the left object in the join.

The related ``DataFrame.join`` method, uses ``merge`` internally for the
index-on-index (by default) and column(s)-on-index join. If you are joining on
index only, you may wish to use ``DataFrame.join`` to save yourself some typing.

Brief primer on merge methods (relational algebra)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Experienced users of relational databases like SQL will be familiar with the
terminology used to describe join operations between two SQL-table like
structures (DataFrame objects). There are several cases to consider which are
very important to understand:

- **one-to-one** joins: for example when joining two DataFrame objects on
  their indexes (which must contain unique values)
- **many-to-one** joins: for example when joining an index (unique) to one or
  more columns in a DataFrame
- **many-to-many** joins: joining columns on columns.

.. note::

   When joining columns on columns (potentially a many-to-many join), any
   indexes on the passed DataFrame objects **will be discarded**.


It is worth spending some time understanding the result of the **many-to-many**
join case. In SQL / standard relational algebra, if a key combination appears
more than once in both tables, the resulting table will have the **Cartesian
product** of the associated data. Here is a very basic example with one unique
key combination:

.. ipython:: python

   left = pd.DataFrame({'key': ['K0', 'K1', 'K2', 'K3'],
                        'A': ['A0', 'A1', 'A2', 'A3'],
                        'B': ['B0', 'B1', 'B2', 'B3']})

   right = pd.DataFrame({'key': ['K0', 'K1', 'K2', 'K3'],
                         'C': ['C0', 'C1', 'C2', 'C3'],
                         'D': ['D0', 'D1', 'D2', 'D3']})
   result = pd.merge(left, right, on='key')

.. ipython:: python

   @savefig merging_merge_on_key.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);

Here is a more complicated example with multiple join keys:

.. ipython:: python

   left = pd.DataFrame({'key1': ['K0', 'K0', 'K1', 'K2'],
                        'key2': ['K0', 'K1', 'K0', 'K1'],
                        'A': ['A0', 'A1', 'A2', 'A3'],
                        'B': ['B0', 'B1', 'B2', 'B3']})

   right = pd.DataFrame({'key1': ['K0', 'K1', 'K1', 'K2'],
                         'key2': ['K0', 'K0', 'K0', 'K0'],
                         'C': ['C0', 'C1', 'C2', 'C3'],
                         'D': ['D0', 'D1', 'D2', 'D3']})

   result = pd.merge(left, right, on=['key1', 'key2'])

.. ipython:: python
   :suppress:

   @savefig merging_merge_on_key_multiple.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);

The ``how`` argument to ``merge`` specifies how to determine which keys are to
be included in the resulting table. If a key combination **does not appear** in
either the left or right tables, the values in the joined table will be
``NA``. Here is a summary of the ``how`` options and their SQL equivalent names:

.. csv-table::
    :header: "Merge method", "SQL Join Name", "Description"
    :widths: 20, 20, 60

    ``left``, ``LEFT OUTER JOIN``, Use keys from left frame only
    ``right``, ``RIGHT OUTER JOIN``, Use keys from right frame only
    ``outer``, ``FULL OUTER JOIN``, Use union of keys from both frames
    ``inner``, ``INNER JOIN``, Use intersection of keys from both frames

.. ipython:: python

   result = pd.merge(left, right, how='left', on=['key1', 'key2'])

.. ipython:: python

   @savefig merging_merge_on_key_left.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);

.. ipython:: python

   result = pd.merge(left, right, how='right', on=['key1', 'key2'])

.. ipython:: python

   @savefig merging_merge_on_key_right.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);

.. ipython:: python

   result = pd.merge(left, right, how='outer', on=['key1', 'key2'])

.. ipython:: python

   @savefig merging_merge_on_key_outer.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);

.. ipython:: python

   result = pd.merge(left, right, how='inner', on=['key1', 'key2'])

.. ipython:: python

   @savefig merging_merge_on_key_inner.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);  

.. _merging.indicator:

The merge indicator
~~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.17.0

``merge`` now accepts the argument ``indicator``. If ``True``, a Categorical-type column called ``_merge`` will be added to the output object that takes on values:

  ===================================   ================
  Observation Origin                    ``_merge`` value
  ===================================   ================
  Merge key only in ``'left'`` frame    ``left_only``
  Merge key only in ``'right'`` frame   ``right_only``
  Merge key in both frames              ``both``
  ===================================   ================

.. ipython:: python

   df1 = pd.DataFrame({'col1': [0, 1], 'col_left':['a', 'b']})
   df2 = pd.DataFrame({'col1': [1, 2, 2],'col_right':[2, 2, 2]})
   pd.merge(df1, df2, on='col1', how='outer', indicator=True)

The ``indicator`` argument will also accept string arguments, in which case the indicator function will use the value of the passed string as the name for the indicator column.

.. ipython:: python

   pd.merge(df1, df2, on='col1', how='outer', indicator='indicator_column')


.. _merging.join.index:

Joining on index
~~~~~~~~~~~~~~~~

``DataFrame.join`` is a convenient method for combining the columns of two
potentially differently-indexed DataFrames into a single result DataFrame. Here
is a very basic example:

.. ipython:: python

   left = pd.DataFrame({'A': ['A0', 'A1', 'A2'],
                        'B': ['B0', 'B1', 'B2']},
                        index=['K0', 'K1', 'K2'])

   right = pd.DataFrame({'C': ['C0', 'C2', 'C3'],
                         'D': ['D0', 'D2', 'D3']},
                         index=['K0', 'K2', 'K3'])

   result = left.join(right)

.. ipython:: python

   @savefig merging_join.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);  

.. ipython:: python

   result = left.join(right, how='outer')

.. ipython:: python

   @savefig merging_join_outer.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);   

.. ipython:: python

   result = left.join(right, how='inner')

.. ipython:: python

   @savefig merging_join_inner.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);   

The data alignment here is on the indexes (row labels). This same behavior can
be achieved using ``merge`` plus additional arguments instructing it to use the
indexes:

.. ipython:: python

   result = pd.merge(left, right, left_index=True, right_index=True, how='outer')

.. ipython:: python

   @savefig merging_merge_index_outer.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);   

.. ipython:: python

   result = pd.merge(left, right, left_index=True, right_index=True, how='inner');

.. ipython:: python

   @savefig merging_merge_index_inner.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);   

Joining key columns on an index
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``join`` takes an optional ``on`` argument which may be a column or multiple
column names, which specifies that the passed DataFrame is to be aligned on
that column in the DataFrame. These two function calls are completely
equivalent:

::

    left.join(right, on=key_or_keys)
    pd.merge(left, right, left_on=key_or_keys, right_index=True,
          how='left', sort=False)

Obviously you can choose whichever form you find more convenient. For
many-to-one joins (where one of the DataFrame's is already indexed by the join
key), using ``join`` may be more convenient. Here is a simple example:

.. ipython:: python

   left = pd.DataFrame({'A': ['A0', 'A1', 'A2', 'A3'],
                        'B': ['B0', 'B1', 'B2', 'B3'],
                        'key': ['K0', 'K1', 'K0', 'K1']})

   right = pd.DataFrame({'C': ['C0', 'C1'],
                         'D': ['D0', 'D1']},
                         index=['K0', 'K1'])

   result = left.join(right, on='key')

.. ipython:: python

   @savefig merging_join_key_columns.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);   

.. ipython:: python

   result = pd.merge(left, right, left_on='key', right_index=True,
                     how='left', sort=False);

.. ipython:: python

   @savefig merging_merge_key_columns.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);   

.. _merging.multikey_join:

To join on multiple keys, the passed DataFrame must have a ``MultiIndex``:

.. ipython:: python

   left = pd.DataFrame({'A': ['A0', 'A1', 'A2', 'A3'],
                        'B': ['B0', 'B1', 'B2', 'B3'],
                        'key1': ['K0', 'K0', 'K1', 'K2'],
                        'key2': ['K0', 'K1', 'K0', 'K1']})

   index = pd.MultiIndex.from_tuples([('K0', 'K0'), ('K1', 'K0'),
                                     ('K2', 'K0'), ('K2', 'K1')])
   right = pd.DataFrame({'C': ['C0', 'C1', 'C2', 'C3'],
                      'D': ['D0', 'D1', 'D2', 'D3']},
                     index=index)

Now this can be joined by passing the two key column names:

.. ipython:: python

   result = left.join(right, on=['key1', 'key2'])

.. ipython:: python

   @savefig merging_join_multikeys.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);   

.. _merging.df_inner_join:

The default for ``DataFrame.join`` is to perform a left join (essentially a
"VLOOKUP" operation, for Excel users), which uses only the keys found in the
calling DataFrame. Other join types, for example inner join, can be just as
easily performed:

.. ipython:: python

   result = left.join(right, on=['key1', 'key2'], how='inner')

.. ipython:: python

   @savefig merging_join_multikeys_inner.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);   
   plt.close('all');

As you can see, this drops any rows where there was no match.

.. _merging.join_on_mi:

Joining a single Index to a Multi-index
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.14.0

You can join a singly-indexed ``DataFrame`` with a level of a multi-indexed ``DataFrame``.
The level will match on the name of the index of the singly-indexed frame against
a level name of the multi-indexed frame.

..  ipython:: python

   left = pd.DataFrame({'A': ['A0', 'A1', 'A2'],
                        'B': ['B0', 'B1', 'B2']},
                        index=pd.Index(['K0', 'K1', 'K2'], name='key'))

   index = pd.MultiIndex.from_tuples([('K0', 'Y0'), ('K1', 'Y1'),
                                     ('K2', 'Y2'), ('K2', 'Y3')],
                                      names=['key', 'Y'])
   right = pd.DataFrame({'C': ['C0', 'C1', 'C2', 'C3'],
                         'D': ['D0', 'D1', 'D2', 'D3']},
                         index=index)

   result = left.join(right, how='inner')

.. ipython:: python

   @savefig merging_join_multiindex_inner.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);

This is equivalent but less verbose and more memory efficient / faster than this.

..  ipython:: python

    result = pd.merge(left.reset_index(), right.reset_index(),
          on=['key'], how='inner').set_index(['key','Y'])

.. ipython:: python

   @savefig merging_merge_multiindex_alternative.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);

Joining with two multi-indexes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is not Implemented via ``join`` at-the-moment, however it can be done using the following.

.. ipython:: python

   index = pd.MultiIndex.from_tuples([('K0', 'X0'), ('K0', 'X1'),
                                      ('K1', 'X2')],
                                       names=['key', 'X'])
   left = pd.DataFrame({'A': ['A0', 'A1', 'A2'],
                        'B': ['B0', 'B1', 'B2']},
                         index=index)

   result = pd.merge(left.reset_index(), right.reset_index(),
                     on=['key'], how='inner').set_index(['key','X','Y'])

.. ipython:: python

   @savefig merging_merge_two_multiindex.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);

Overlapping value columns
~~~~~~~~~~~~~~~~~~~~~~~~~

The merge ``suffixes`` argument takes a tuple of list of strings to append to
overlapping column names in the input DataFrames to disambiguate the result
columns:

.. ipython:: python

   left = pd.DataFrame({'k': ['K0', 'K1', 'K2'], 'v': [1, 2, 3]})
   right = pd.DataFrame({'k': ['K0', 'K0', 'K3'], 'v': [4, 5, 6]})

   result = pd.merge(left, right, on='k')

.. ipython:: python

   @savefig merging_merge_overlapped.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False); 

.. ipython:: python

   result = pd.merge(left, right, on='k', suffixes=['_l', '_r'])

.. ipython:: python

   @savefig merging_merge_overlapped_suffix.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);  

``DataFrame.join`` has ``lsuffix`` and ``rsuffix`` arguments which behave
similarly.

.. ipython:: python

   left = left.set_index('k')
   right = right.set_index('k')
   result = left.join(right, lsuffix='_l', rsuffix='_r')

.. ipython:: python

   @savefig merging_merge_overlapped_multi_suffix.png
   p.plot([left, right], result,labels=['left', 'right'], vertical=False);   

.. _merging.multiple_join:

Joining multiple DataFrame or Panel objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A list or tuple of DataFrames can also be passed to ``DataFrame.join`` to join
them together on their indexes. The same is true for ``Panel.join``.

.. ipython:: python

   right2 = pd.DataFrame({'v': [7, 8, 9]}, index=['K1', 'K1', 'K2'])
   result = left.join([right, right2])

.. ipython:: python

   @savefig merging_join_multi_df.png
   p.plot([left, right, right2], result,labels=['left', 'right', 'right2'], vertical=False);  

.. _merging.combine_first.update:

Merging together values within Series or DataFrame columns
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Another fairly common situation is to have two like-indexed (or similarly
indexed) Series or DataFrame objects and wanting to "patch" values in one
object from values for matching indices in the other. Here is an example:

.. ipython:: python

   df1 = pd.DataFrame([[np.nan, 3., 5.], [-4.6, np.nan, np.nan],
                      [np.nan, 7., np.nan]])
   df2 = pd.DataFrame([[-42.6, np.nan, -8.2], [-5., 1.6, 4]],
                      index=[1, 2])

For this, use the ``combine_first`` method:

.. ipython:: python

   result = df1.combine_first(df2)

.. ipython:: python

   @savefig merging_combine_first.png
   p.plot([df1, df2], result,labels=['df1', 'df2'], vertical=False);   

Note that this method only takes values from the right DataFrame if they are
missing in the left DataFrame. A related method, ``update``, alters non-NA
values inplace:

.. ipython:: python

   df1_copy = df1.copy()
   df1.update(df2)

.. ipython:: python

   @savefig merging_update.png
   p.plot([df1_copy, df2], df1,labels=['df1', 'df2'], vertical=False);
   plt.close('all');
