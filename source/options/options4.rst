.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import pandas as pd
   import numpy as np
   np.random.seed(123456)

.. _options.frequently_used:

Frequently Used Options
-----------------------
The following is a walkthrough of the more frequently used display options.

``display.max_rows`` and ``display.max_columns`` sets the maximum number
of rows and columns displayed when a frame is pretty-printed.  Truncated
lines are replaced by an ellipsis.

.. ipython:: python

   df = pd.DataFrame(np.random.randn(7,2))
   pd.set_option('max_rows', 7)
   df
   pd.set_option('max_rows', 5)
   df
   pd.reset_option('max_rows')

``display.expand_frame_repr`` allows for the the representation of
dataframes to stretch across pages, wrapped over the full column vs row-wise.

.. ipython:: python

   df = pd.DataFrame(np.random.randn(5,10))
   pd.set_option('expand_frame_repr', True)
   df
   pd.set_option('expand_frame_repr', False)
   df
   pd.reset_option('expand_frame_repr')

``display.large_repr`` lets you select whether to display dataframes that exceed
``max_columns`` or ``max_rows`` as a truncated frame, or as a summary.

.. ipython:: python

   df = pd.DataFrame(np.random.randn(10,10))
   pd.set_option('max_rows', 5)
   pd.set_option('large_repr', 'truncate')
   df
   pd.set_option('large_repr', 'info')
   df
   pd.reset_option('large_repr')
   pd.reset_option('max_rows')

``display.max_colwidth`` sets the maximum width of columns.  Cells
of this length or longer will be truncated with an ellipsis.

.. ipython:: python

   df = pd.DataFrame(np.array([['foo', 'bar', 'bim', 'uncomfortably long string'],
                               ['horse', 'cow', 'banana', 'apple']]))
   pd.set_option('max_colwidth',40)
   df
   pd.set_option('max_colwidth', 6)
   df
   pd.reset_option('max_colwidth')

``display.max_info_columns`` sets a threshold for when by-column info
will be given.

.. ipython:: python

   df = pd.DataFrame(np.random.randn(10,10))
   pd.set_option('max_info_columns', 11)
   df.info()
   pd.set_option('max_info_columns', 5)
   df.info()
   pd.reset_option('max_info_columns')

``display.max_info_rows``: ``df.info()`` will usually show null-counts for each column.
For large frames this can be quite slow. ``max_info_rows`` and ``max_info_cols``
limit this null check only to frames with smaller dimensions then specified. Note that you
can specify the option ``df.info(null_counts=True)`` to override on showing a particular frame.

.. ipython:: python

   df  =pd.DataFrame(np.random.choice([0,1,np.nan], size=(10,10)))
   df
   pd.set_option('max_info_rows', 11)
   df.info()
   pd.set_option('max_info_rows', 5)
   df.info()
   pd.reset_option('max_info_rows')

``display.precision`` sets the output display precision in terms of decimal places. This is only a
suggestion.

.. ipython:: python

   df = pd.DataFrame(np.random.randn(5,5))
   pd.set_option('precision',7)
   df
   pd.set_option('precision',4)
   df

``display.chop_threshold`` sets at what level pandas rounds to zero when
it displays a Series of DataFrame.  Note, this does not effect the
precision at which the number is stored.

.. ipython:: python

   df = pd.DataFrame(np.random.randn(6,6))
   pd.set_option('chop_threshold', 0)
   df
   pd.set_option('chop_threshold', .5)
   df
   pd.reset_option('chop_threshold')

``display.colheader_justify`` controls the justification of the headers.
Options are 'right', and 'left'.

.. ipython:: python

   df = pd.DataFrame(np.array([np.random.randn(6), np.random.randint(1,9,6)*.1, np.zeros(6)]).T,
                     columns=['A', 'B', 'C'], dtype='float')
   pd.set_option('colheader_justify', 'right')
   df
   pd.set_option('colheader_justify', 'left')
   df
   pd.reset_option('colheader_justify')