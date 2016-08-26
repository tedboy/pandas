.. _advanced.hierarchical:

Hierarchical indexing (MultiIndex)
----------------------------------

Hierarchical / Multi-level indexing is very exciting as it opens the door to some
quite sophisticated data analysis and manipulation, especially for working with
higher dimensional data. In essence, it enables you to store and manipulate
data with an arbitrary number of dimensions in lower dimensional data
structures like Series (1d) and DataFrame (2d).

In this section, we will show what exactly we mean by "hierarchical" indexing
and how it integrates with the all of the pandas indexing functionality
described above and in prior sections. Later, when discussing :ref:`group by
<groupby>` and :ref:`pivoting and reshaping data <reshaping>`, we'll show
non-trivial applications to illustrate how it aids in structuring data for
analysis.

See the :ref:`cookbook<cookbook.multi_index>` for some advanced strategies

Creating a MultiIndex (hierarchical index) object
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``MultiIndex`` object is the hierarchical analogue of the standard
``Index`` object which typically stores the axis labels in pandas objects. You
can think of ``MultiIndex`` an array of tuples where each tuple is unique. A
``MultiIndex`` can be created from a list of arrays (using
``MultiIndex.from_arrays``), an array of tuples (using
``MultiIndex.from_tuples``), or a crossed set of iterables (using
``MultiIndex.from_product``).  The ``Index`` constructor will attempt to return
a ``MultiIndex`` when it is passed a list of tuples.  The following examples
demo different ways to initialize MultiIndexes.


.. ipython:: python

   arrays = [['bar', 'bar', 'baz', 'baz', 'foo', 'foo', 'qux', 'qux'],
             ['one', 'two', 'one', 'two', 'one', 'two', 'one', 'two']]
   tuples = list(zip(*arrays))
   tuples

   index = pd.MultiIndex.from_tuples(tuples, names=['first', 'second'])
   index

   s = pd.Series(np.random.randn(8), index=index)
   s

When you want every pairing of the elements in two iterables, it can be easier
to use the ``MultiIndex.from_product`` function:

.. ipython:: python

   iterables = [['bar', 'baz', 'foo', 'qux'], ['one', 'two']]
   pd.MultiIndex.from_product(iterables, names=['first', 'second'])

As a convenience, you can pass a list of arrays directly into Series or
DataFrame to construct a MultiIndex automatically:

.. ipython:: python

   arrays = [np.array(['bar', 'bar', 'baz', 'baz', 'foo', 'foo', 'qux', 'qux']),
             np.array(['one', 'two', 'one', 'two', 'one', 'two', 'one', 'two'])]
   s = pd.Series(np.random.randn(8), index=arrays)
   s
   df = pd.DataFrame(np.random.randn(8, 4), index=arrays)
   df

All of the ``MultiIndex`` constructors accept a ``names`` argument which stores
string names for the levels themselves. If no names are provided, ``None`` will
be assigned:

.. ipython:: python

   df.index.names

This index can back any axis of a pandas object, and the number of **levels**
of the index is up to you:

.. ipython:: python

   df = pd.DataFrame(np.random.randn(3, 8), index=['A', 'B', 'C'], columns=index)
   df
   pd.DataFrame(np.random.randn(6, 6), index=index[:6], columns=index[:6])

We've "sparsified" the higher levels of the indexes to make the console output a
bit easier on the eyes.

It's worth keeping in mind that there's nothing preventing you from using
tuples as atomic labels on an axis:

.. ipython:: python

   pd.Series(np.random.randn(8), index=tuples)

The reason that the ``MultiIndex`` matters is that it can allow you to do
grouping, selection, and reshaping operations as we will describe below and in
subsequent areas of the documentation. As you will see in later sections, you
can find yourself working with hierarchically-indexed data without creating a
``MultiIndex`` explicitly yourself. However, when loading data from a file, you
may wish to generate your own ``MultiIndex`` when preparing the data set.

Note that how the index is displayed by be controlled using the
``multi_sparse`` option in ``pandas.set_printoptions``:

.. ipython:: python

   pd.set_option('display.multi_sparse', False)
   df
   pd.set_option('display.multi_sparse', True)

.. _advanced.get_level_values:

Reconstructing the level labels
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The method ``get_level_values`` will return a vector of the labels for each
location at a particular level:

.. ipython:: python

   index.get_level_values(0)
   index.get_level_values('second')

Basic indexing on axis with MultiIndex
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

One of the important features of hierarchical indexing is that you can select
data by a "partial" label identifying a subgroup in the data. **Partial**
selection "drops" levels of the hierarchical index in the result in a
completely analogous way to selecting a column in a regular DataFrame:

.. ipython:: python

   df['bar']
   df['bar', 'one']
   df['bar']['one']
   s['qux']

See :ref:`Cross-section with hierarchical index <advanced.xs>` for how to select
on a deeper level.

.. note::

   The repr of a ``MultiIndex`` shows ALL the defined levels of an index, even
   if the they are not actually used. When slicing an index, you may notice this.
   For example:

   .. ipython:: python

      # original multi-index
      df.columns

      # sliced
      df[['foo','qux']].columns

   This is done to avoid a recomputation of the levels in order to make slicing
   highly performant. If you want to see the actual used levels.

   .. ipython:: python

      df[['foo','qux']].columns.values

      # for a specific level
      df[['foo','qux']].columns.get_level_values(0)

   To reconstruct the multiindex with only the used levels

   .. ipython:: python

      pd.MultiIndex.from_tuples(df[['foo','qux']].columns.values)

Data alignment and using ``reindex``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Operations between differently-indexed objects having ``MultiIndex`` on the
axes will work as you expect; data alignment will work the same as an Index of
tuples:

.. ipython:: python

   s + s[:-2]
   s + s[::2]

``reindex`` can be called with another ``MultiIndex`` or even a list or array
of tuples:

.. ipython:: python

   s.reindex(index[:3])
   s.reindex([('foo', 'two'), ('bar', 'one'), ('qux', 'one'), ('baz', 'one')])