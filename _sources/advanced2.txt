.. _advanced.advanced_hierarchical:

Advanced indexing with hierarchical index
-----------------------------------------

Syntactically integrating ``MultiIndex`` in advanced indexing with ``.loc/.ix`` is a
bit challenging, but we've made every effort to do so. for example the
following works as you would expect:

.. ipython:: python

   df
   df = df.T
   df
   df.loc['bar']
   df.loc['bar', 'two']

"Partial" slicing also works quite nicely.

.. ipython:: python

   df.loc['baz':'foo']

You can slice with a 'range' of values, by providing a slice of tuples.

.. ipython:: python

   df.loc[('baz', 'two'):('qux', 'one')]
   df.loc[('baz', 'two'):'foo']

Passing a list of labels or tuples works similar to reindexing:

.. ipython:: python

   df.ix[[('bar', 'two'), ('qux', 'one')]]

.. _advanced.mi_slicers:

Using slicers
~~~~~~~~~~~~~

.. versionadded:: 0.14.0

In 0.14.0 we added a new way to slice multi-indexed objects.
You can slice a multi-index by providing multiple indexers.

You can provide any of the selectors as if you are indexing by label, see :ref:`Selection by Label <indexing.label>`,
including slices, lists of labels, labels, and boolean indexers.

You can use ``slice(None)`` to select all the contents of *that* level. You do not need to specify all the
*deeper* levels, they will be implied as ``slice(None)``.

As usual, **both sides** of the slicers are included as this is label indexing.

.. warning::

   You should specify all axes in the ``.loc`` specifier, meaning the indexer for the **index** and
   for the **columns**. There are some ambiguous cases where the passed indexer could be mis-interpreted
   as indexing *both* axes, rather than into say the MuliIndex for the rows.

   You should do this:

   .. code-block:: python

      df.loc[(slice('A1','A3'),.....),:]

   rather than this:

   .. code-block:: python

      df.loc[(slice('A1','A3'),.....)]

.. ipython:: python

   def mklbl(prefix,n):
       return ["%s%s" % (prefix,i)  for i in range(n)]

   miindex = pd.MultiIndex.from_product([mklbl('A',4),
                                         mklbl('B',2),
                                         mklbl('C',4),
                                         mklbl('D',2)])
   micolumns = pd.MultiIndex.from_tuples([('a','foo'),('a','bar'),
                                          ('b','foo'),('b','bah')],
                                         names=['lvl0', 'lvl1'])
   dfmi = pd.DataFrame(np.arange(len(miindex)*len(micolumns)).reshape((len(miindex),len(micolumns))),
                       index=miindex,
                       columns=micolumns).sort_index().sort_index(axis=1)
   dfmi

Basic multi-index slicing using slices, lists, and labels.

.. ipython:: python

   dfmi.loc[(slice('A1','A3'),slice(None), ['C1','C3']),:]

You can use a ``pd.IndexSlice`` to have a more natural syntax using ``:`` rather than using ``slice(None)``

.. ipython:: python

   idx = pd.IndexSlice
   dfmi.loc[idx[:,:,['C1','C3']],idx[:,'foo']]

It is possible to perform quite complicated selections using this method on multiple
axes at the same time.

.. ipython:: python

   dfmi.loc['A1',(slice(None),'foo')]
   dfmi.loc[idx[:,:,['C1','C3']],idx[:,'foo']]

Using a boolean indexer you can provide selection related to the *values*.

.. ipython:: python

   mask = dfmi[('a','foo')]>200
   dfmi.loc[idx[mask,:,['C1','C3']],idx[:,'foo']]

You can also specify the ``axis`` argument to ``.loc`` to interpret the passed
slicers on a single axis.

.. ipython:: python

   dfmi.loc(axis=0)[:,:,['C1','C3']]

Furthermore you can *set* the values using these methods

.. ipython:: python

   df2 = dfmi.copy()
   df2.loc(axis=0)[:,:,['C1','C3']] = -10
   df2

You can use a right-hand-side of an alignable object as well.

.. ipython:: python

   df2 = dfmi.copy()
   df2.loc[idx[:,:,['C1','C3']],:] = df2*1000
   df2

.. _advanced.xs:

Cross-section
~~~~~~~~~~~~~

The ``xs`` method of ``DataFrame`` additionally takes a level argument to make
selecting data at a particular level of a MultiIndex easier.

.. ipython:: python

   df
   df.xs('one', level='second')

.. ipython:: python

   # using the slicers (new in 0.14.0)
   df.loc[(slice(None),'one'),:]

You can also select on the columns with :meth:`~pandas.MultiIndex.xs`, by
providing the axis argument

.. ipython:: python

   df = df.T
   df.xs('one', level='second', axis=1)

.. ipython:: python

   # using the slicers (new in 0.14.0)
   df.loc[:,(slice(None),'one')]

:meth:`~pandas.MultiIndex.xs` also allows selection with multiple keys

.. ipython:: python

   df.xs(('one', 'bar'), level=('second', 'first'), axis=1)

.. ipython:: python

   # using the slicers (new in 0.14.0)
   df.loc[:,('bar','one')]

.. versionadded:: 0.13.0

You can pass ``drop_level=False`` to :meth:`~pandas.MultiIndex.xs` to retain
the level that was selected

.. ipython:: python

   df.xs('one', level='second', axis=1, drop_level=False)

versus the result with ``drop_level=True`` (the default value)

.. ipython:: python

   df.xs('one', level='second', axis=1, drop_level=True)

.. ipython:: python
   :suppress:

   df = df.T

.. _advanced.advanced_reindex:

Advanced reindexing and alignment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The parameter ``level`` has been added to the ``reindex`` and ``align`` methods
of pandas objects. This is useful to broadcast values across a level. For
instance:

.. ipython:: python

   midx = pd.MultiIndex(levels=[['zero', 'one'], ['x','y']],
                        labels=[[1,1,0,0],[1,0,1,0]])
   df = pd.DataFrame(np.random.randn(4,2), index=midx)
   df
   df2 = df.mean(level=0)
   df2
   df2.reindex(df.index, level=0)

   # aligning
   df_aligned, df2_aligned = df.align(df2, level=0)
   df_aligned
   df2_aligned


Swapping levels with :meth:`~pandas.MultiIndex.swaplevel`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``swaplevel`` function can switch the order of two levels:

.. ipython:: python

   df[:5]
   df[:5].swaplevel(0, 1, axis=0)

.. _advanced.reorderlevels:

Reordering levels with :meth:`~pandas.MultiIndex.reorder_levels`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``reorder_levels`` function generalizes the ``swaplevel`` function,
allowing you to permute the hierarchical index levels in one step:

.. ipython:: python

   df[:5].reorder_levels([1,0], axis=0)