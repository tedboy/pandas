.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8
   df = pd.DataFrame({'one' : pd.Series(np.random.randn(3), index=['a', 'b', 'c']),
                      'two' : pd.Series(np.random.randn(4), index=['a', 'b', 'c', 'd']),
                      'three' : pd.Series(np.random.randn(3), index=['b', 'c', 'd'])})

.. _basics.apply:

Function application
--------------------

To apply your own or another library's functions to pandas objects,
you should be aware of the three methods below. The appropriate
method to use depends on whether your function expects to operate
on an entire ``DataFrame`` or ``Series``, row- or column-wise, or elementwise.

1. `Tablewise Function Application`_: :meth:`~DataFrame.pipe`
2. `Row or Column-wise Function Application`_: :meth:`~DataFrame.apply`
3. Elementwise_ function application: :meth:`~DataFrame.applymap`

.. _basics.pipe:

Tablewise Function Application
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.16.2

``DataFrames`` and ``Series`` can of course just be passed into functions.
However, if the function needs to be called in a chain, consider using the :meth:`~DataFrame.pipe` method.
Compare the following

.. code-block:: python

   # f, g, and h are functions taking and returning ``DataFrames``
   >>> f(g(h(df), arg1=1), arg2=2, arg3=3)

with the equivalent

.. code-block:: python

   >>> (df.pipe(h)
          .pipe(g, arg1=1)
          .pipe(f, arg2=2, arg3=3)
       )

Pandas encourages the second style, which is known as method chaining.
``pipe`` makes it easy to use your own or another library's functions
in method chains, alongside pandas' methods.

In the example above, the functions ``f``, ``g``, and ``h`` each expected the ``DataFrame`` as the first positional argument.
What if the function you wish to apply takes its data as, say, the second argument?
In this case, provide ``pipe`` with a tuple of ``(callable, data_keyword)``.
``.pipe`` will route the ``DataFrame`` to the argument specified in the tuple.

For example, we can fit a regression using statsmodels. Their API expects a formula first and a ``DataFrame`` as the second argument, ``data``. We pass in the function, keyword pair ``(sm.poisson, 'data')`` to ``pipe``:

.. ipython:: python

   import statsmodels.formula.api as sm

   bb = pd.read_csv('https://raw.githubusercontent.com/pydata/pandas/master/doc/data/baseball.csv',
       index_col='id')

   (bb.query('h > 0')
      .assign(ln_h = lambda df: np.log(df.h))
      .pipe((sm.poisson, 'data'), 'hr ~ ln_h + year + g + C(lg)')
      .fit()
      .summary()
   )

The pipe method is inspired by unix pipes and more recently dplyr_ and magrittr_, which
have introduced the popular ``(%>%)`` (read pipe) operator for R_.
The implementation of ``pipe`` here is quite clean and feels right at home in python.
We encourage you to view the source code (``pd.DataFrame.pipe??`` in IPython).

.. _dplyr: https://github.com/hadley/dplyr
.. _magrittr: https://github.com/smbache/magrittr
.. _R: http://www.r-project.org


Row or Column-wise Function Application
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Arbitrary functions can be applied along the axes of a DataFrame or Panel
using the :meth:`~DataFrame.apply` method, which, like the descriptive
statistics methods, take an optional ``axis`` argument:

.. ipython:: python

   df.apply(np.mean)
   df.apply(np.mean, axis=1)
   df.apply(lambda x: x.max() - x.min())
   df.apply(np.cumsum)
   df.apply(np.exp)

Depending on the return type of the function passed to :meth:`~DataFrame.apply`,
the result will either be of lower dimension or the same dimension.

:meth:`~DataFrame.apply` combined with some cleverness can be used to answer many questions
about a data set. For example, suppose we wanted to extract the date where the
maximum value for each column occurred:

.. ipython:: python

   tsdf = pd.DataFrame(np.random.randn(1000, 3), columns=['A', 'B', 'C'],
                       index=pd.date_range('1/1/2000', periods=1000))
   tsdf.apply(lambda x: x.idxmax())

You may also pass additional arguments and keyword arguments to the :meth:`~DataFrame.apply`
method. For instance, consider the following function you would like to apply:

.. code-block:: python

   def subtract_and_divide(x, sub, divide=1):
       return (x - sub) / divide

You may then apply this function as follows:

.. code-block:: python

   df.apply(subtract_and_divide, args=(5,), divide=3)

Another useful feature is the ability to pass Series methods to carry out some
Series operation on each column or row:

.. ipython:: python
   :suppress:

   tsdf = pd.DataFrame(np.random.randn(10, 3), columns=['A', 'B', 'C'],
                       index=pd.date_range('1/1/2000', periods=10))
   tsdf.values[3:7] = np.nan

.. ipython:: python

   tsdf
   tsdf.apply(pd.Series.interpolate)


Finally, :meth:`~DataFrame.apply` takes an argument ``raw`` which is False by default, which
converts each row or column into a Series before applying the function. When
set to True, the passed function will instead receive an ndarray object, which
has positive performance implications if you do not need the indexing
functionality.

.. seealso::

   The section on :ref:`GroupBy <groupby>` demonstrates related, flexible
   functionality for grouping by some criterion, applying, and combining the
   results into a Series, DataFrame, etc.

.. _Elementwise:

Applying elementwise Python functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Since not all functions can be vectorized (accept NumPy arrays and return
another array or value), the methods :meth:`~DataFrame.applymap` on DataFrame
and analogously :meth:`~Series.map` on Series accept any Python function taking
a single value and returning a single value. For example:

.. ipython:: python
   :suppress:

   df4 = df_orig.copy()

.. ipython:: python

   df4
   f = lambda x: len(str(x))
   df4['one'].map(f)
   df4.applymap(f)

:meth:`Series.map` has an additional feature which is that it can be used to easily
"link" or "map" values defined by a secondary series. This is closely related
to :ref:`merging/joining functionality <merging>`:

.. ipython:: python

   s = pd.Series(['six', 'seven', 'six', 'seven', 'six'],
                 index=['a', 'b', 'c', 'd', 'e'])
   t = pd.Series({'six' : 6., 'seven' : 7.})
   s
   s.map(t)


.. _basics.apply_panel:

Applying with a Panel
~~~~~~~~~~~~~~~~~~~~~

Applying with a ``Panel`` will pass a ``Series`` to the applied function. If the applied
function returns a ``Series``, the result of the application will be a ``Panel``. If the applied function
reduces to a scalar, the result of the application will be a ``DataFrame``.

.. note::

   Prior to 0.13.1 ``apply`` on a ``Panel`` would only work on ``ufuncs`` (e.g. ``np.sum/np.max``).

.. ipython:: python

   import pandas.util.testing as tm
   panel = tm.makePanel(5)
   panel
   panel['ItemA']

A transformational apply.

.. ipython:: python

   result = panel.apply(lambda x: x*2, axis='items')
   result
   result['ItemA']

A reduction operation.

.. ipython:: python

   panel.apply(lambda x: x.dtype, axis='items')

A similar reduction type operation

.. ipython:: python

   panel.apply(lambda x: x.sum(), axis='major_axis')

This last reduction is equivalent to

.. ipython:: python

   panel.sum('major_axis')

A transformation operation that returns a ``Panel``, but is computing
the z-score across the ``major_axis``.

.. ipython:: python

   result = panel.apply(
              lambda x: (x-x.mean())/x.std(),
              axis='major_axis')
   result
   result['ItemA']

Apply can also accept multiple axes in the ``axis`` argument. This will pass a
``DataFrame`` of the cross-section to the applied function.

.. ipython:: python

   f = lambda x: ((x.T-x.mean(1))/x.std(1)).T

   result = panel.apply(f, axis = ['items','major_axis'])
   result
   result.loc[:,:,'ItemA']

This is equivalent to the following

.. ipython:: python

   result = pd.Panel(dict([ (ax, f(panel.loc[:,:,ax]))
                           for ax in panel.minor_axis ]))
   result
   result.loc[:,:,'ItemA']