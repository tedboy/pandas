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

.. _merging.time_series:

Timeseries friendly merging
---------------------------

.. _merging.merge_ordered:

Merging Ordered Data
~~~~~~~~~~~~~~~~~~~~

A :func:`merge_ordered` function allows combining time series and other
ordered data. In particular it has an optional ``fill_method`` keyword to
fill/interpolate missing data:

.. ipython:: python

   left = pd.DataFrame({'k': ['K0', 'K1', 'K1', 'K2'],
                        'lv': [1, 2, 3, 4],
                        's': ['a', 'b', 'c', 'd']})

   right = pd.DataFrame({'k': ['K1', 'K2', 'K4'],
                         'rv': [1, 2, 3]})

   pd.merge_ordered(left, right, fill_method='ffill', left_by='s')

.. _merging.merge_asof:

Merging AsOf
~~~~~~~~~~~~

.. versionadded:: 0.19.0

A :func:`merge_asof` is similar to an ordered left-join except that we match on nearest key rather than equal keys. For each row in the ``left`` DataFrame, we select the last row in the ``right`` DataFrame whose ``on`` key is less than the left's key. Both DataFrames must be sorted by the key.

Optionally an asof merge can perform a group-wise merge. This matches the ``by`` key equally,
in addition to the nearest match on the ``on`` key.

For example; we might have ``trades`` and ``quotes`` and we want to ``asof`` merge them.

.. ipython:: python

   trades = pd.DataFrame({
       'time': pd.to_datetime(['20160525 13:30:00.023',
                               '20160525 13:30:00.038',
                               '20160525 13:30:00.048',
                               '20160525 13:30:00.048',
                               '20160525 13:30:00.048']),
       'ticker': ['MSFT', 'MSFT',
                  'GOOG', 'GOOG', 'AAPL'],
       'price': [51.95, 51.95,
                 720.77, 720.92, 98.00],
       'quantity': [75, 155,
                    100, 100, 100]},
       columns=['time', 'ticker', 'price', 'quantity'])

   quotes = pd.DataFrame({
       'time': pd.to_datetime(['20160525 13:30:00.023',
                               '20160525 13:30:00.023',
                               '20160525 13:30:00.030',
                               '20160525 13:30:00.041',
                               '20160525 13:30:00.048',
                               '20160525 13:30:00.049',
                               '20160525 13:30:00.072',
                               '20160525 13:30:00.075']),
       'ticker': ['GOOG', 'MSFT', 'MSFT',
                  'MSFT', 'GOOG', 'AAPL', 'GOOG',
                  'MSFT'],
       'bid': [720.50, 51.95, 51.97, 51.99,
               720.50, 97.99, 720.50, 52.01],
       'ask': [720.93, 51.96, 51.98, 52.00,
               720.93, 98.01, 720.88, 52.03]},
       columns=['time', 'ticker', 'bid', 'ask'])

.. ipython:: python

   trades
   quotes

By default we are taking the asof of the quotes.

.. ipython:: python

   pd.merge_asof(trades, quotes,
                 on='time',
                 by='ticker')

We only asof within ``2ms`` betwen the quote time and the trade time.

.. ipython:: python

   pd.merge_asof(trades, quotes,
                 on='time',
                 by='ticker',
                 tolerance=pd.Timedelta('2ms'))

We only asof within ``10ms`` betwen the quote time and the trade time and we exclude exact matches on time.
Note that though we exclude the exact matches (of the quotes), prior quotes DO propogate to that point
in time.

.. ipython:: python

   pd.merge_asof(trades, quotes,
                 on='time',
                 by='ticker',
                 tolerance=pd.Timedelta('10ms'),
                 allow_exact_matches=False)
