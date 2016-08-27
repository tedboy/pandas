.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8
   index = pd.date_range('1/1/2000', periods=8)
   s = pd.Series(np.random.randn(5), index=['a', 'b', 'c', 'd', 'e'])
   df = pd.DataFrame(np.random.randn(8, 3), index=index,
                     columns=['A', 'B', 'C'])
   wp = pd.Panel(np.random.randn(2, 5, 4), items=['Item1', 'Item2'],
                 major_axis=pd.date_range('1/1/2000', periods=5),
                 minor_axis=['A', 'B', 'C', 'D'])   

.. _basics.binop:

Flexible binary operations
--------------------------

With binary operations between pandas data structures, there are two key points
of interest:

  * Broadcasting behavior between higher- (e.g. DataFrame) and
    lower-dimensional (e.g. Series) objects.
  * Missing data in computations

We will demonstrate how to manage these issues independently, though they can
be handled simultaneously.

Matching / broadcasting behavior
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DataFrame has the methods :meth:`~DataFrame.add`, :meth:`~DataFrame.sub`,
:meth:`~DataFrame.mul`, :meth:`~DataFrame.div` and related functions
:meth:`~DataFrame.radd`, :meth:`~DataFrame.rsub`, ...
for carrying out binary operations. For broadcasting behavior,
Series input is of primary interest. Using these functions, you can use to
either match on the *index* or *columns* via the **axis** keyword:

.. ipython:: python

   df = pd.DataFrame({'one' : pd.Series(np.random.randn(3), index=['a', 'b', 'c']),
                      'two' : pd.Series(np.random.randn(4), index=['a', 'b', 'c', 'd']),
                      'three' : pd.Series(np.random.randn(3), index=['b', 'c', 'd'])})
   df
   row = df.ix[1]
   column = df['two']

   df.sub(row, axis='columns')
   df.sub(row, axis=1)

   df.sub(column, axis='index')
   df.sub(column, axis=0)

.. ipython:: python
   :suppress:

   df_orig = df

Furthermore you can align a level of a multi-indexed DataFrame with a Series.

.. ipython:: python

   dfmi = df.copy()
   dfmi.index = pd.MultiIndex.from_tuples([(1,'a'),(1,'b'),(1,'c'),(2,'a')],
                                          names=['first','second'])
   dfmi.sub(column, axis=0, level='second')

With Panel, describing the matching behavior is a bit more difficult, so
the arithmetic methods instead (and perhaps confusingly?) give you the option
to specify the *broadcast axis*. For example, suppose we wished to demean the
data over a particular axis. This can be accomplished by taking the mean over
an axis and broadcasting over the same axis:

.. ipython:: python

   major_mean = wp.mean(axis='major')
   major_mean
   wp.sub(major_mean, axis='major')

And similarly for ``axis="items"`` and ``axis="minor"``.

.. note::

   I could be convinced to make the **axis** argument in the DataFrame methods
   match the broadcasting behavior of Panel. Though it would require a
   transition period so users can change their code...

Missing data / operations with fill values
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In Series and DataFrame (though not yet in Panel), the arithmetic functions
have the option of inputting a *fill_value*, namely a value to substitute when
at most one of the values at a location are missing. For example, when adding
two DataFrame objects, you may wish to treat NaN as 0 unless both DataFrames
are missing that value, in which case the result will be NaN (you can later
replace NaN with some other value using ``fillna`` if you wish).

.. ipython:: python
   :suppress:

   df2 = df.copy()
   df2['three']['a'] = 1.

.. ipython:: python

   df
   df2
   df + df2
   df.add(df2, fill_value=0)

.. _basics.compare:

Flexible Comparisons
~~~~~~~~~~~~~~~~~~~~

Starting in v0.8, pandas introduced binary comparison methods eq, ne, lt, gt,
le, and ge to Series and DataFrame whose behavior is analogous to the binary
arithmetic operations described above:

.. ipython:: python

   df.gt(df2)
   df2.ne(df)

These operations produce a pandas object the same type as the left-hand-side input
that if of dtype ``bool``. These ``boolean`` objects can be used in indexing operations,
see :ref:`here<indexing.boolean>`

.. _basics.reductions:

Boolean Reductions
~~~~~~~~~~~~~~~~~~

You can apply the reductions: :attr:`~DataFrame.empty`, :meth:`~DataFrame.any`,
:meth:`~DataFrame.all`, and :meth:`~DataFrame.bool` to provide a
way to summarize a boolean result.

.. ipython:: python

   (df > 0).all()
   (df > 0).any()

You can reduce to a final boolean value.

.. ipython:: python

   (df > 0).any().any()

You can test if a pandas object is empty, via the :attr:`~DataFrame.empty` property.

.. ipython:: python

   df.empty
   pd.DataFrame(columns=list('ABC')).empty

To evaluate single-element pandas objects in a boolean context, use the method
:meth:`~DataFrame.bool`:

.. ipython:: python

   pd.Series([True]).bool()
   pd.Series([False]).bool()
   pd.DataFrame([[True]]).bool()
   pd.DataFrame([[False]]).bool()

.. warning::

   You might be tempted to do the following:

   .. code-block:: python

       >>> if df:
            ...

   Or

   .. code-block:: python

       >>> df and df2

   These both will raise as you are trying to compare multiple values.

   .. code-block:: python

       ValueError: The truth value of an array is ambiguous. Use a.empty, a.any() or a.all().

See :ref:`gotchas<gotchas.truth>` for a more detailed discussion.

.. _basics.equals:

Comparing if objects are equivalent
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Often you may find there is more than one way to compute the same
result.  As a simple example, consider ``df+df`` and ``df*2``. To test
that these two computations produce the same result, given the tools
shown above, you might imagine using ``(df+df == df*2).all()``. But in
fact, this expression is False:

.. ipython:: python

   df+df == df*2
   (df+df == df*2).all()

Notice that the boolean DataFrame ``df+df == df*2`` contains some False values!
That is because NaNs do not compare as equals:

.. ipython:: python

   np.nan == np.nan

So, as of v0.13.1, NDFrames (such as Series, DataFrames, and Panels)
have an :meth:`~DataFrame.equals` method for testing equality, with NaNs in
corresponding locations treated as equal.

.. ipython:: python

   (df+df).equals(df*2)

Note that the Series or DataFrame index needs to be in the same order for
equality to be True:

.. ipython:: python

   df1 = pd.DataFrame({'col':['foo', 0, np.nan]})
   df2 = pd.DataFrame({'col':[np.nan, 0, 'foo']}, index=[2,1,0])
   df1.equals(df2)
   df1.equals(df2.sort_index())

Comparing array-like objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can conveniently do element-wise comparisons when comparing a pandas
data structure with a scalar value:

.. ipython:: python

   pd.Series(['foo', 'bar', 'baz']) == 'foo'
   pd.Index(['foo', 'bar', 'baz']) == 'foo'

Pandas also handles element-wise comparisons between different array-like
objects of the same length:

.. ipython:: python

    pd.Series(['foo', 'bar', 'baz']) == pd.Index(['foo', 'bar', 'qux'])
    pd.Series(['foo', 'bar', 'baz']) == np.array(['foo', 'bar', 'qux'])

Trying to compare ``Index`` or ``Series`` objects of different lengths will
raise a ValueError:

.. code-block:: ipython

    In [55]: pd.Series(['foo', 'bar', 'baz']) == pd.Series(['foo', 'bar'])
    ValueError: Series lengths must match to compare

    In [56]: pd.Series(['foo', 'bar', 'baz']) == pd.Series(['foo'])
    ValueError: Series lengths must match to compare

Note that this is different from the numpy behavior where a comparison can
be broadcast:

.. ipython:: python

    np.array([1, 2, 3]) == np.array([2])

or it can return False if broadcasting can not be done:

.. ipython:: python
   :okwarning:

    np.array([1, 2, 3]) == np.array([1, 2])

Combining overlapping data sets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A problem occasionally arising is the combination of two similar data sets
where values in one are preferred over the other. An example would be two data
series representing a particular economic indicator where one is considered to
be of "higher quality". However, the lower quality series might extend further
back in history or have more complete data coverage. As such, we would like to
combine two DataFrame objects where missing values in one DataFrame are
conditionally filled with like-labeled values from the other DataFrame. The
function implementing this operation is :meth:`~DataFrame.combine_first`,
which we illustrate:

.. ipython:: python

   df1 = pd.DataFrame({'A' : [1., np.nan, 3., 5., np.nan],
                       'B' : [np.nan, 2., 3., np.nan, 6.]})
   df2 = pd.DataFrame({'A' : [5., 2., 4., np.nan, 3., 7.],
                       'B' : [np.nan, np.nan, 3., 4., 6., 8.]})
   df1
   df2
   df1.combine_first(df2)

General DataFrame Combine
~~~~~~~~~~~~~~~~~~~~~~~~~

The :meth:`~DataFrame.combine_first` method above calls the more general
DataFrame method :meth:`~DataFrame.combine`. This method takes another DataFrame
and a combiner function, aligns the input DataFrame and then passes the combiner
function pairs of Series (i.e., columns whose names are the same).

So, for instance, to reproduce :meth:`~DataFrame.combine_first` as above:

.. ipython:: python

   combiner = lambda x, y: np.where(pd.isnull(x), y, x)
   df1.combine(df2, combiner)
