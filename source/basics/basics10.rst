.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Vectorized string methods
-------------------------

Series is equipped with a set of string processing methods that make it easy to
operate on each element of the array. Perhaps most importantly, these methods
exclude missing/NA values automatically. These are accessed via the Series's
``str`` attribute and generally have names matching the equivalent (scalar)
built-in string methods. For example:

 .. ipython:: python

  s = pd.Series(['A', 'B', 'C', 'Aaba', 'Baca', np.nan, 'CABA', 'dog', 'cat'])
  s.str.lower()

Powerful pattern-matching methods are provided as well, but note that
pattern-matching generally uses `regular expressions
<https://docs.python.org/2/library/re.html>`__ by default (and in some cases
always uses them).

Please see :ref:`Vectorized String Methods <text.string_methods>` for a complete
description.