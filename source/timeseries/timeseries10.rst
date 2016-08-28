.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   from datetime import datetime, timedelta, time
   import numpy as np
   import pandas as pd
   from pandas import datetools
   np.random.seed(123456)
   randn = np.random.randn
   randint = np.random.randint
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows=8
   import dateutil
   import pytz
   from dateutil.relativedelta import relativedelta

.. _timeseries.resampling:

Resampling
----------

.. warning::

   The interface to ``.resample`` has changed in 0.18.0 to be more groupby-like and hence more flexible.
   See the :ref:`whatsnew docs <whatsnew_0180.breaking.resample>` for a comparison with prior versions.

Pandas has a simple, powerful, and efficient functionality for
performing resampling operations during frequency conversion (e.g., converting
secondly data into 5-minutely data). This is extremely common in, but not
limited to, financial applications.

``.resample()`` is a time-based groupby, followed by a reduction method on each of its groups.

.. note::

   ``.resample()`` is similar to using a ``.rolling()`` operation with a time-based offset, see a discussion `here <stats.moments.ts-versus-resampling>`

See some :ref:`cookbook examples <cookbook.resample>` for some advanced strategies

.. ipython:: python

   rng = pd.date_range('1/1/2012', periods=100, freq='S')

   ts = pd.Series(np.random.randint(0, 500, len(rng)), index=rng)

   ts.resample('5Min').sum()

The ``resample`` function is very flexible and allows you to specify many
different parameters to control the frequency conversion and resampling
operation.

The ``how`` parameter can be a function name or numpy array function that takes
an array and produces aggregated values:

.. ipython:: python

   ts.resample('5Min').mean()

   ts.resample('5Min').ohlc()

   ts.resample('5Min').max()

Any function available via :ref:`dispatching <groupby.dispatch>` can be given to
the ``how`` parameter by name, including ``sum``, ``mean``, ``std``, ``sem``,
``max``, ``min``, ``median``, ``first``, ``last``, ``ohlc``.

For downsampling, ``closed`` can be set to 'left' or 'right' to specify which
end of the interval is closed:

.. ipython:: python

   ts.resample('5Min', closed='right').mean()

   ts.resample('5Min', closed='left').mean()

Parameters like ``label`` and ``loffset`` are used to manipulate the resulting
labels. ``label`` specifies whether the result is labeled with the beginning or
the end of the interval. ``loffset`` performs a time adjustment on the output
labels.

.. ipython:: python

   ts.resample('5Min').mean() # by default label='right'

   ts.resample('5Min', label='left').mean()

   ts.resample('5Min', label='left', loffset='1s').mean()

The ``axis`` parameter can be set to 0 or 1 and allows you to resample the
specified axis for a DataFrame.

``kind`` can be set to 'timestamp' or 'period' to convert the resulting index
to/from time-stamp and time-span representations. By default ``resample``
retains the input representation.

``convention`` can be set to 'start' or 'end' when resampling period data
(detail below). It specifies how low frequency periods are converted to higher
frequency periods.


Up Sampling
~~~~~~~~~~~

For upsampling, you can specify a way to upsample and the ``limit`` parameter to interpolate over the gaps that are created:

.. ipython:: python

   # from secondly to every 250 milliseconds

   ts[:2].resample('250L').asfreq()

   ts[:2].resample('250L').ffill()

   ts[:2].resample('250L').ffill(limit=2)

Sparse Resampling
~~~~~~~~~~~~~~~~~

Sparse timeseries are ones where you have a lot fewer points relative
to the amount of time you are looking to resample. Naively upsampling a sparse series can potentially
generate lots of intermediate values. When you don't want to use a method to fill these values, e.g. ``fill_method`` is ``None``,
then intermediate values will be filled with ``NaN``.

Since ``resample`` is a time-based groupby, the following is a method to efficiently
resample only the groups that are not all ``NaN``

.. ipython:: python

    rng = pd.date_range('2014-1-1', periods=100, freq='D') + pd.Timedelta('1s')
    ts = pd.Series(range(100), index=rng)

If we want to resample to the full range of the series

.. ipython:: python

    ts.resample('3T').sum()

We can instead only resample those groups where we have points as follows:

.. ipython:: python

    from functools import partial
    from pandas.tseries.frequencies import to_offset

    def round(t, freq):
        # round a Timestamp to a specified freq
        freq = to_offset(freq)
        return pd.Timestamp((t.value // freq.delta.value) * freq.delta.value)

    ts.groupby(partial(round, freq='3T')).sum()

Aggregation
~~~~~~~~~~~

Similar to :ref:`groupby aggregates <groupby.aggregate>` and the :ref:`window functions <stats.aggregate>`, a ``Resampler`` can be selectively
resampled.

Resampling a ``DataFrame``, the default will be to act on all columns with the same function.

.. ipython:: python

   df = pd.DataFrame(np.random.randn(1000, 3),
                     index=pd.date_range('1/1/2012', freq='S', periods=1000),
                     columns=['A', 'B', 'C'])
   r = df.resample('3T')
   r.mean()

We can select a specific column or columns using standard getitem.

.. ipython:: python

   r['A'].mean()

   r[['A','B']].mean()

You can pass a list or dict of functions to do aggregation with, outputting a DataFrame:

.. ipython:: python

   r['A'].agg([np.sum, np.mean, np.std])

If a dict is passed, the keys will be used to name the columns. Otherwise the
function's name (stored in the function object) will be used.

.. ipython:: python

   r['A'].agg({'result1' : np.sum,
               'result2' : np.mean})

On a resampled DataFrame, you can pass a list of functions to apply to each
column, which produces an aggregated result with a hierarchical index:

.. ipython:: python

   r.agg([np.sum, np.mean])

By passing a dict to ``aggregate`` you can apply a different aggregation to the
columns of a DataFrame:

.. ipython:: python
   :okexcept:

   r.agg({'A' : np.sum,
          'B' : lambda x: np.std(x, ddof=1)})

The function names can also be strings. In order for a string to be valid it
must be implemented on the Resampled object

.. ipython:: python

   r.agg({'A' : 'sum', 'B' : 'std'})

Furthermore, you can also specify multiple aggregation functions for each column separately.

.. ipython:: python

   r.agg({'A' : ['sum','std'], 'B' : ['mean','std'] })