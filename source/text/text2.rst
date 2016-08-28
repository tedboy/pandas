.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   randn = np.random.randn
   np.set_printoptions(precision=4, suppress=True)
   from pandas.compat import lrange
   pd.options.display.max_rows=8
   
Splitting and Replacing Strings
-------------------------------

.. _text.split:

Methods like ``split`` return a Series of lists:

.. ipython:: python

   s2 = pd.Series(['a_b_c', 'c_d_e', np.nan, 'f_g_h'])
   s2.str.split('_')

Elements in the split lists can be accessed using ``get`` or ``[]`` notation:

.. ipython:: python

   s2.str.split('_').str.get(1)
   s2.str.split('_').str[1]

Easy to expand this to return a DataFrame using ``expand``.

.. ipython:: python

   s2.str.split('_', expand=True)

It is also possible to limit the number of splits:

.. ipython:: python

   s2.str.split('_', expand=True, n=1)

``rsplit`` is similar to ``split`` except it works in the reverse direction,
i.e., from the end of the string to the beginning of the string:

.. ipython:: python

   s2.str.rsplit('_', expand=True, n=1)

Methods like ``replace`` and ``findall`` take `regular expressions
<https://docs.python.org/2/library/re.html>`__, too:

.. ipython:: python

   s3 = pd.Series(['A', 'B', 'C', 'Aaba', 'Baca',
                  '', np.nan, 'CABA', 'dog', 'cat'])
   s3
   s3.str.replace('^.a|dog', 'XX-XX ', case=False)

Some caution must be taken to keep regular expressions in mind! For example, the
following code will cause trouble because of the regular expression meaning of
`$`:

.. ipython:: python

   # Consider the following badly formatted financial data
   dollars = pd.Series(['12', '-$10', '$10,000'])

   # This does what you'd naively expect:
   dollars.str.replace('$', '')

   # But this doesn't:
   dollars.str.replace('-$', '-')

   # We need to escape the special character (for >1 len patterns)
   dollars.str.replace(r'-\$', '-')