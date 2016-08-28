.. _indexing.index_types:

Index Types
-----------

We have discussed ``MultiIndex`` in the previous sections pretty extensively. ``DatetimeIndex`` and ``PeriodIndex``
are shown :ref:`here <timeseries.overview>`. ``TimedeltaIndex`` are :ref:`here <timedeltas.timedeltas>`.

In the following sub-sections we will highlite some other index types.

.. _indexing.categoricalindex:

CategoricalIndex
~~~~~~~~~~~~~~~~

.. versionadded:: 0.16.1

We introduce a ``CategoricalIndex``, a new type of index object that is useful for supporting
indexing with duplicates. This is a container around a ``Categorical`` (introduced in v0.15.0)
and allows efficient indexing and storage of an index with a large number of duplicated elements. Prior to 0.16.1,
setting the index of a ``DataFrame/Series`` with a ``category`` dtype would convert this to regular object-based ``Index``.

.. ipython:: python

   df = pd.DataFrame({'A': np.arange(6),
                      'B': list('aabbca')})
   df['B'] = df['B'].astype('category', categories=list('cab'))
   df
   df.dtypes
   df.B.cat.categories

Setting the index, will create create a ``CategoricalIndex``

.. ipython:: python

   df2 = df.set_index('B')
   df2.index

Indexing with ``__getitem__/.iloc/.loc/.ix`` works similarly to an ``Index`` with duplicates.
The indexers MUST be in the category or the operation will raise.

.. ipython:: python

   df2.loc['a']

These PRESERVE the ``CategoricalIndex``

.. ipython:: python

   df2.loc['a'].index

Sorting will order by the order of the categories

.. ipython:: python

   df2.sort_index()

Groupby operations on the index will preserve the index nature as well

.. ipython:: python

   df2.groupby(level=0).sum()
   df2.groupby(level=0).sum().index

Reindexing operations, will return a resulting index based on the type of the passed
indexer, meaning that passing a list will return a plain-old-``Index``; indexing with
a ``Categorical`` will return a ``CategoricalIndex``, indexed according to the categories
of the PASSED ``Categorical`` dtype. This allows one to arbitrarly index these even with
values NOT in the categories, similarly to how you can reindex ANY pandas index.

.. ipython :: python

   df2.reindex(['a','e'])
   df2.reindex(['a','e']).index
   df2.reindex(pd.Categorical(['a','e'],categories=list('abcde')))
   df2.reindex(pd.Categorical(['a','e'],categories=list('abcde'))).index

.. warning::

   Reshaping and Comparison operations on a ``CategoricalIndex`` must have the same categories
   or a ``TypeError`` will be raised.

   .. code-block:: python

      In [9]: df3 = pd.DataFrame({'A' : np.arange(6),
                                  'B' : pd.Series(list('aabbca')).astype('category')})

      In [11]: df3 = df3.set_index('B')

      In [11]: df3.index
      Out[11]: CategoricalIndex([u'a', u'a', u'b', u'b', u'c', u'a'], categories=[u'a', u'b', u'c'], ordered=False, name=u'B', dtype='category')

      In [12]: pd.concat([df2, df3]
      TypeError: categories must match existing categories when appending

.. _indexing.rangeindex:

Int64Index and RangeIndex
~~~~~~~~~~~~~~~~~~~~~~~~~

.. warning::

   Indexing on an integer-based Index with floats has been clarified in 0.18.0, for a summary of the changes, see :ref:`here <whatsnew_0180.float_indexers>`.

``Int64Index`` is a fundamental basic index in *pandas*. This is an Immutable array implementing an ordered, sliceable set.
Prior to 0.18.0, the ``Int64Index`` would provide the default index for all ``NDFrame`` objects.

``RangeIndex`` is a sub-class of ``Int64Index`` added in version 0.18.0, now providing the default index for all ``NDFrame`` objects.
``RangeIndex`` is an optimized version of ``Int64Index`` that can represent a monotonic ordered set. These are analagous to python `range types <https://docs.python.org/3/library/stdtypes.html#typesseq-range>`__.

.. _indexing.float64index:

Float64Index
~~~~~~~~~~~~

.. note::

   As of 0.14.0, ``Float64Index`` is backed by a native ``float64`` dtype
   array. Prior to 0.14.0, ``Float64Index`` was backed by an ``object`` dtype
   array. Using a ``float64`` dtype in the backend speeds up arithmetic
   operations by about 30x and boolean indexing operations on the
   ``Float64Index`` itself are about 2x as fast.

.. versionadded:: 0.13.0

By default a ``Float64Index`` will be automatically created when passing floating, or mixed-integer-floating values in index creation.
This enables a pure label-based slicing paradigm that makes ``[],ix,loc`` for scalar indexing and slicing work exactly the
same.

.. ipython:: python

   indexf = pd.Index([1.5, 2, 3, 4.5, 5])
   indexf
   sf = pd.Series(range(5), index=indexf)
   sf

Scalar selection for ``[],.ix,.loc`` will always be label based. An integer will match an equal float index (e.g. ``3`` is equivalent to ``3.0``)

.. ipython:: python

   sf[3]
   sf[3.0]
   sf.ix[3]
   sf.ix[3.0]
   sf.loc[3]
   sf.loc[3.0]

The only positional indexing is via ``iloc``

.. ipython:: python

   sf.iloc[3]

A scalar index that is not found will raise ``KeyError``

Slicing is ALWAYS on the values of the index, for ``[],ix,loc`` and ALWAYS positional with ``iloc``

.. ipython:: python

   sf[2:4]
   sf.ix[2:4]
   sf.loc[2:4]
   sf.iloc[2:4]

In float indexes, slicing using floats is allowed

.. ipython:: python

   sf[2.1:4.6]
   sf.loc[2.1:4.6]

In non-float indexes, slicing using floats will raise a ``TypeError``

.. code-block:: ipython

   In [1]: pd.Series(range(5))[3.5]
   TypeError: the label [3.5] is not a proper indexer for this index type (Int64Index)

   In [1]: pd.Series(range(5))[3.5:4.5]
   TypeError: the slice start [3.5] is not a proper indexer for this index type (Int64Index)

.. warning::

   Using a scalar float indexer for ``.iloc`` has been removed in 0.18.0, so the following will raise a ``TypeError``

   .. code-block:: ipython

      In [3]: pd.Series(range(5)).iloc[3.0]
      TypeError: cannot do positional indexing on <class 'pandas.indexes.range.RangeIndex'> with these indexers [3.0] of <type 'float'>

   Further the treatment of ``.ix`` with a float indexer on a non-float index, will be label based, and thus coerce the index.

   .. ipython:: python

      s2 = pd.Series([1, 2, 3], index=list('abc'))
      s2
      s2.ix[1.0] = 10
      s2

Here is a typical use-case for using this type of indexing. Imagine that you have a somewhat
irregular timedelta-like indexing scheme, but the data is recorded as floats. This could for
example be millisecond offsets.

.. ipython:: python

   dfir = pd.concat([pd.DataFrame(np.random.randn(5,2),
                                  index=np.arange(5) * 250.0,
                                  columns=list('AB')),
                     pd.DataFrame(np.random.randn(6,2),
                                  index=np.arange(4,10) * 250.1,
                                  columns=list('AB'))])
   dfir

Selection operations then will always work on a value basis, for all selection operators.

.. ipython:: python

   dfir[0:1000.4]
   dfir.loc[0:1001,'A']
   dfir.loc[1000.4]

You could then easily pick out the first 1 second (1000 ms) of data then.

.. ipython:: python

   dfir[0:1000]

Of course if you need integer based selection, then use ``iloc``

.. ipython:: python

   dfir.iloc[0:5]
