.. ipython:: python
   :suppress:

   import numpy as np
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

Parsing Dates from Text Files
-----------------------------

When parsing multiple text file columns into a single date column, the new date
column is prepended to the data and then `index_col` specification is indexed off
of the new set of columns rather than the original ones:

.. ipython:: python
   :suppress:

   data =  ("KORD,19990127, 19:00:00, 18:56:00, 0.8100\n"
            "KORD,19990127, 20:00:00, 19:56:00, 0.0100\n"
            "KORD,19990127, 21:00:00, 20:56:00, -0.5900\n"
            "KORD,19990127, 21:00:00, 21:18:00, -0.9900\n"
            "KORD,19990127, 22:00:00, 21:56:00, -0.5900\n"
            "KORD,19990127, 23:00:00, 22:56:00, -0.5900")

   with open('tmp.csv', 'w') as fh:
       fh.write(data)

.. ipython:: python

   print(open('tmp.csv').read())

   date_spec = {'nominal': [1, 2], 'actual': [1, 3]}
   df = pd.read_csv('tmp.csv', header=None,
                    parse_dates=date_spec,
                    keep_date_col=True,
                    index_col=0)

   # index_col=0 refers to the combined column "nominal" and not the original
   # first column of 'KORD' strings

   df

.. ipython:: python
   :suppress:

   import os
   os.remove('tmp.csv')