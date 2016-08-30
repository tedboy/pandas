.. ipython:: python
    :suppress:

    import pandas as pd
    import numpy as np
    url = 'https://raw.github.com/pydata/pandas/master/pandas/tests/data/tips.csv'
    tips = pd.read_csv(url)
    pd.options.display.max_rows = 8

DELETE
------

.. code-block:: sql

    DELETE FROM tips
    WHERE tip > 9;

In pandas we select the rows that should remain, instead of deleting them

.. ipython:: python

    tips
    tips = tips.loc[tips['tip'] <= 9]
    tips