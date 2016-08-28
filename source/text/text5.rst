.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   randn = np.random.randn
   np.set_printoptions(precision=4, suppress=True)
   from pandas.compat import lrange
   pd.options.display.max_rows=8
   
Testing for Strings that Match or Contain a Pattern
---------------------------------------------------

You can check whether elements contain a pattern:

.. ipython:: python

   pattern = r'[a-z][0-9]'
   pd.Series(['1', '2', '3a', '3b', '03c']).str.contains(pattern)

or match a pattern:


.. ipython:: python

   pd.Series(['1', '2', '3a', '3b', '03c']).str.match(pattern, as_indexer=True)

The distinction between ``match`` and ``contains`` is strictness: ``match``
relies on strict ``re.match``, while ``contains`` relies on ``re.search``.

.. warning::

   In previous versions, ``match`` was for *extracting* groups,
   returning a not-so-convenient Series of tuples. The new method ``extract``
   (described in the previous section) is now preferred.

   This old, deprecated behavior of ``match`` is still the default. As
   demonstrated above, use the new behavior by setting ``as_indexer=True``.
   In this mode, ``match`` is analogous to ``contains``, returning a boolean
   Series. The new behavior will become the default behavior in a future
   release.

Methods like ``match``, ``contains``, ``startswith``, and ``endswith`` take
 an extra ``na`` argument so missing values can be considered True or False:

.. ipython:: python

   s4 = pd.Series(['A', 'B', 'C', 'Aaba', 'Baca', np.nan, 'CABA', 'dog', 'cat'])
   s4.str.contains('A', na=False)