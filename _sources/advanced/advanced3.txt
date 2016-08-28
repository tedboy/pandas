Sorting a :class:`~pandas.MultiIndex`
-------------------------------------

For MultiIndex-ed objects to be indexed & sliced effectively, they need
to be sorted. As with any index, you can use ``sort_index``.

.. ipython:: python

   import random; random.shuffle(tuples)
   s = pd.Series(np.random.randn(8), index=pd.MultiIndex.from_tuples(tuples))
   s
   s.sort_index()
   s.sort_index(level=0)
   s.sort_index(level=1)

.. _advanced.sortlevel_byname:

You may also pass a level name to ``sort_index`` if the MultiIndex levels
are named.

.. ipython:: python

   s.index.set_names(['L1', 'L2'], inplace=True)
   s.sort_index(level='L1')
   s.sort_index(level='L2')

On higher dimensional objects, you can sort any of the other axes by level if
they have a MultiIndex:

.. ipython:: python

   df.T.sort_index(level=1, axis=1)

Indexing will work even if the data are not sorted, but will be rather
inefficient (and show a ``PerformanceWarning``). It will also
return a copy of the data rather than a view:

.. ipython:: python

   dfm = pd.DataFrame({'jim': [0, 0, 1, 1],
                       'joe': ['x', 'x', 'z', 'y'],
                       'jolie': np.random.rand(4)})
   dfm = dfm.set_index(['jim', 'joe'])
   dfm

.. code-block:: ipython

   In [4]: dfm.loc[(1, 'z')]
   PerformanceWarning: indexing past lexsort depth may impact performance.

   Out[4]:
              jolie
   jim joe
   1   z    0.64094

Furthermore if you try to index something that is not fully lexsorted, this can raise:

.. code-block:: ipython

    In [5]: dfm.loc[(0,'y'):(1, 'z')]
    KeyError: 'Key length (2) was greater than MultiIndex lexsort depth (1)'

The ``is_lexsorted()`` method on an ``Index`` show if the index is sorted, and the ``lexsort_depth`` property returns the sort depth:

.. ipython:: python

   dfm.index.is_lexsorted()
   dfm.index.lexsort_depth

.. ipython:: python

   dfm = dfm.sort_index()
   dfm
   dfm.index.is_lexsorted()
   dfm.index.lexsort_depth

And now selection works as expected.

.. ipython:: python

   dfm.loc[(0,'y'):(1, 'z')]
