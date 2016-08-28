.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   randn = np.random.randn
   np.set_printoptions(precision=4, suppress=True)
   from pandas.compat import lrange
   pd.options.display.max_rows=8
   
Method Summary
--------------

.. _text.summary:

.. csv-table::
    :header: "Method", "Description"
    :widths: 20, 80
    :delim: ;

    :meth:`~Series.str.cat`;Concatenate strings
    :meth:`~Series.str.split`;Split strings on delimiter
    :meth:`~Series.str.rsplit`;Split strings on delimiter working from the end of the string
    :meth:`~Series.str.get`;Index into each element (retrieve i-th element)
    :meth:`~Series.str.join`;Join strings in each element of the Series with passed separator
    :meth:`~Series.str.get_dummies`;Split strings on the delimiter returning DataFrame of dummy variables
    :meth:`~Series.str.contains`;Return boolean array if each string contains pattern/regex
    :meth:`~Series.str.replace`;Replace occurrences of pattern/regex with some other string
    :meth:`~Series.str.repeat`;Duplicate values (``s.str.repeat(3)`` equivalent to ``x * 3``)
    :meth:`~Series.str.pad`;"Add whitespace to left, right, or both sides of strings"
    :meth:`~Series.str.center`;Equivalent to ``str.center``
    :meth:`~Series.str.ljust`;Equivalent to ``str.ljust``
    :meth:`~Series.str.rjust`;Equivalent to ``str.rjust``
    :meth:`~Series.str.zfill`;Equivalent to ``str.zfill``
    :meth:`~Series.str.wrap`;Split long strings into lines with length less than a given width
    :meth:`~Series.str.slice`;Slice each string in the Series
    :meth:`~Series.str.slice_replace`;Replace slice in each string with passed value
    :meth:`~Series.str.count`;Count occurrences of pattern
    :meth:`~Series.str.startswith`;Equivalent to ``str.startswith(pat)`` for each element
    :meth:`~Series.str.endswith`;Equivalent to ``str.endswith(pat)`` for each element
    :meth:`~Series.str.findall`;Compute list of all occurrences of pattern/regex for each string
    :meth:`~Series.str.match`;"Call ``re.match`` on each element, returning matched groups as list"
    :meth:`~Series.str.extract`;"Call ``re.search`` on each element, returning DataFrame with one row for each element and one column for each regex capture group"
    :meth:`~Series.str.extractall`;"Call ``re.findall`` on each element, returning DataFrame with one row for each match and one column for each regex capture group"
    :meth:`~Series.str.len`;Compute string lengths
    :meth:`~Series.str.strip`;Equivalent to ``str.strip``
    :meth:`~Series.str.rstrip`;Equivalent to ``str.rstrip``
    :meth:`~Series.str.lstrip`;Equivalent to ``str.lstrip``
    :meth:`~Series.str.partition`;Equivalent to ``str.partition``
    :meth:`~Series.str.rpartition`;Equivalent to ``str.rpartition``
    :meth:`~Series.str.lower`;Equivalent to ``str.lower``
    :meth:`~Series.str.upper`;Equivalent to ``str.upper``
    :meth:`~Series.str.find`;Equivalent to ``str.find``
    :meth:`~Series.str.rfind`;Equivalent to ``str.rfind``
    :meth:`~Series.str.index`;Equivalent to ``str.index``
    :meth:`~Series.str.rindex`;Equivalent to ``str.rindex``
    :meth:`~Series.str.capitalize`;Equivalent to ``str.capitalize``
    :meth:`~Series.str.swapcase`;Equivalent to ``str.swapcase``
    :meth:`~Series.str.normalize`;Return Unicode normal form. Equivalent to ``unicodedata.normalize``
    :meth:`~Series.str.translate`;Equivalent to ``str.translate``
    :meth:`~Series.str.isalnum`;Equivalent to ``str.isalnum``
    :meth:`~Series.str.isalpha`;Equivalent to ``str.isalpha``
    :meth:`~Series.str.isdigit`;Equivalent to ``str.isdigit``
    :meth:`~Series.str.isspace`;Equivalent to ``str.isspace``
    :meth:`~Series.str.islower`;Equivalent to ``str.islower``
    :meth:`~Series.str.isupper`;Equivalent to ``str.isupper``
    :meth:`~Series.str.istitle`;Equivalent to ``str.istitle``
    :meth:`~Series.str.isnumeric`;Equivalent to ``str.isnumeric``
    :meth:`~Series.str.isdecimal`;Equivalent to ``str.isdecimal``
