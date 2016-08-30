.. ipython:: python
    :suppress:

    import pandas as pd
    import numpy as np
    pd.options.display.max_rows = 8
    url = 'https://raw.github.com/pydata/pandas/master/pandas/tests/data/tips.csv'
    tips = pd.read_csv(url)


UPDATE
------

.. code-block:: sql

    UPDATE tips
    SET tip = tip*2
    WHERE tip < 2;

.. ipython:: python

    tips
    tips.loc[tips['tip'] < 2, 'tip'] *= 2
    tips