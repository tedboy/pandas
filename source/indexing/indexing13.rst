.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. ipython:: python

   s = pd.Series(np.arange(5), index=np.arange(5)[::-1], dtype='int64')

.. _indexing.where_mask:

The :meth:`~pandas.DataFrame.where` Method and Masking
------------------------------------------------------

Selecting values from a Series with a boolean vector generally returns a
subset of the data. To guarantee that selection output has the same shape as
the original data, you can use the ``where`` method in ``Series`` and ``DataFrame``.

To return only the selected rows

.. ipython:: python

   s
   s[s > 0]

To return a Series of the same shape as the original

.. ipython:: python

   s.where(s > 0)

Selecting values from a DataFrame with a boolean criterion now also preserves
input data shape. ``where`` is used under the hood as the implementation.
Equivalent is ``df.where(df < 0)``

.. ipython:: python

   dates = pd.date_range('1/1/2000', periods=8)
   df = pd.DataFrame(np.random.randn(8, 4), index=dates, columns=['A', 'B', 'C', 'D'])
   df

.. ipython:: python

   df[df < 0]

In addition, ``where`` takes an optional ``other`` argument for replacement of
values where the condition is False, in the returned copy.

.. ipython:: python

   df.where(df < 0, -df)

You may wish to set values based on some boolean criteria.
This can be done intuitively like so:

.. ipython:: python

   s2 = s.copy()
   s2
   s2[s2 < 0] = 0
   s2

   df2 = df.copy()   
   df2
   df2[df2 < 0] = 0
   df2

By default, ``where`` returns a modified copy of the data. There is an
optional parameter ``inplace`` so that the original data can be modified
without creating a copy:

.. ipython:: python

   df_orig = df.copy()
   df_orig.where(df > 0, -df, inplace=True);
   df_orig

.. note::

   The signature for :func:`DataFrame.where` differs from :func:`numpy.where`.
   Roughly ``df1.where(m, df2)`` is equivalent to ``np.where(m, df1, df2)``.

   .. ipython:: python

      df.where(df < 0, -df) == np.where(df < 0, df, -df)

**alignment**

Furthermore, ``where`` aligns the input boolean condition (ndarray or DataFrame),
such that partial selection with setting is possible. This is analogous to
partial setting via ``.ix`` (but on the contents rather than the axis labels)

.. ipython:: python

   df2 = df.copy()
   df2
   df2[ df2[1:4] > 0 ] = 3
   df2

.. versionadded:: 0.13

Where can also accept ``axis`` and ``level`` parameters to align the input when
performing the ``where``.

.. ipython:: python

   df2 = df.copy()
   df2
   df2.where(df2>0,df2['A'],axis='index')

This is equivalent (but faster than) the following.

.. ipython:: python

   df2 = df.copy()
   df.apply(lambda x, y: x.where(x>0,y), y=df['A'])

.. versionadded:: 0.18.1

Where can accept a callable as condition and ``other`` arguments. The function must
be with one argument (the calling Series or DataFrame) and that returns valid output
as condition and ``other`` argument.

.. ipython:: python

   df3 = pd.DataFrame({'A': [1, 2, 3],
                       'B': [4, 5, 6],
                       'C': [7, 8, 9]})
   df3
   df3.where(lambda x: x > 4, lambda x: x + 10)

**mask**

``mask`` is the inverse boolean operation of ``where``.

.. ipython:: python

   s
   s.mask(s >= 0)
   df
   df.mask(df >= 0)