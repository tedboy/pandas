Take Methods
------------

.. _advanced.take:

Similar to numpy ndarrays, pandas Index, Series, and DataFrame also provides
the ``take`` method that retrieves elements along a given axis at the given
indices. The given indices must be either a list or an ndarray of integer
index positions. ``take`` will also accept negative integers as relative positions to the end of the object.

.. ipython:: python

   index = pd.Index(np.random.randint(0, 1000, 10))
   index

   positions = [0, 9, 3]

   index[positions]
   index.take(positions)

   ser = pd.Series(np.random.randn(10))

   ser.iloc[positions]
   ser.take(positions)

For DataFrames, the given indices should be a 1d list or ndarray that specifies
row or column positions.

.. ipython:: python

   frm = pd.DataFrame(np.random.randn(5, 3))

   frm.take([1, 4, 3])

   frm.take([0, 2], axis=1)

It is important to note that the ``take`` method on pandas objects are not
intended to work on boolean indices and may return unexpected results.

.. ipython:: python

   arr = np.random.randn(10)
   arr.take([False, False, True, True])
   arr[[0, 1]]

   ser = pd.Series(np.random.randn(10))
   ser.take([False, False, True, True])
   ser.ix[[0, 1]]

Finally, as a small note on performance, because the ``take`` method handles
a narrower range of inputs, it can offer performance that is a good deal
faster than fancy indexing.

.. ipython::

   arr = np.random.randn(10000, 5)
   indexer = np.arange(10000)
   random.shuffle(indexer)

   timeit arr[indexer]
   timeit arr.take(indexer, axis=0)

   ser = pd.Series(arr[:, 0])
   timeit ser.ix[indexer]
   timeit ser.take(indexer)