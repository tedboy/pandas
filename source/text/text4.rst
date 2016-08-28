.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   randn = np.random.randn
   np.set_printoptions(precision=4, suppress=True)
   from pandas.compat import lrange
   pd.options.display.max_rows=8
   
Extracting Substrings
---------------------

.. _text.extract:

Extract first match in each subject (extract)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. versionadded:: 0.13.0

.. warning::

   In version 0.18.0, ``extract`` gained the ``expand`` argument. When
   ``expand=False`` it returns a ``Series``, ``Index``, or
   ``DataFrame``, depending on the subject and regular expression
   pattern (same behavior as pre-0.18.0). When ``expand=True`` it
   always returns a ``DataFrame``, which is more consistent and less
   confusing from the perspective of a user.

The ``extract`` method accepts a `regular expression
<https://docs.python.org/2/library/re.html>`__ with at least one
capture group.

Extracting a regular expression with more than one group returns a
DataFrame with one column per group.

.. ipython:: python

   pd.Series(['a1', 'b2', 'c3']).str.extract('([ab])(\d)', expand=False)

Elements that do not match return a row filled with ``NaN``. Thus, a
Series of messy strings can be "converted" into a like-indexed Series
or DataFrame of cleaned-up or more useful strings, without
necessitating ``get()`` to access tuples or ``re.match`` objects. The
dtype of the result is always object, even if no match is found and
the result only contains ``NaN``.

Named groups like

.. ipython:: python

   pd.Series(['a1', 'b2', 'c3']).str.extract('(?P<letter>[ab])(?P<digit>\d)', expand=False)

and optional groups like

.. ipython:: python

   pd.Series(['a1', 'b2', '3']).str.extract('([ab])?(\d)', expand=False)

can also be used. Note that any capture group names in the regular
expression will be used for column names; otherwise capture group
numbers will be used.

Extracting a regular expression with one group returns a ``DataFrame``
with one column if ``expand=True``.

.. ipython:: python

   pd.Series(['a1', 'b2', 'c3']).str.extract('[ab](\d)', expand=True)

It returns a Series if ``expand=False``.

.. ipython:: python

   pd.Series(['a1', 'b2', 'c3']).str.extract('[ab](\d)', expand=False)

Calling on an ``Index`` with a regex with exactly one capture group
returns a ``DataFrame`` with one column if ``expand=True``,

.. ipython:: python

   s = pd.Series(["a1", "b2", "c3"], ["A11", "B22", "C33"])
   s
   s.index.str.extract("(?P<letter>[a-zA-Z])", expand=True)

It returns an ``Index`` if ``expand=False``.

.. ipython:: python

   s.index.str.extract("(?P<letter>[a-zA-Z])", expand=False)

Calling on an ``Index`` with a regex with more than one capture group
returns a ``DataFrame`` if ``expand=True``.

.. ipython:: python

   s.index.str.extract("(?P<letter>[a-zA-Z])([0-9]+)", expand=True)

It raises ``ValueError`` if ``expand=False``.

.. code-block:: python

    >>> s.index.str.extract("(?P<letter>[a-zA-Z])([0-9]+)", expand=False)
    ValueError: only one regex group is supported with Index

The table below summarizes the behavior of ``extract(expand=False)``
(input subject in first column, number of groups in regex in
first row)

+--------+---------+------------+
|        | 1 group | >1 group   |
+--------+---------+------------+
| Index  | Index   | ValueError |
+--------+---------+------------+
| Series | Series  | DataFrame  |
+--------+---------+------------+

Extract all matches in each subject (extractall)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. _text.extractall:

.. versionadded:: 0.18.0

Unlike ``extract`` (which returns only the first match),

.. ipython:: python

   s = pd.Series(["a1a2", "b1", "c1"], index=["A", "B", "C"])
   s
   two_groups = '(?P<letter>[a-z])(?P<digit>[0-9])'
   s.str.extract(two_groups, expand=True)

the ``extractall`` method returns every match. The result of
``extractall`` is always a ``DataFrame`` with a ``MultiIndex`` on its
rows. The last level of the ``MultiIndex`` is named ``match`` and
indicates the order in the subject.

.. ipython:: python

   s.str.extractall(two_groups)

When each subject string in the Series has exactly one match,

.. ipython:: python

   s = pd.Series(['a3', 'b3', 'c2'])
   s

then ``extractall(pat).xs(0, level='match')`` gives the same result as
``extract(pat)``.

.. ipython:: python

   extract_result = s.str.extract(two_groups, expand=True)
   extract_result
   extractall_result = s.str.extractall(two_groups)
   extractall_result
   extractall_result.xs(0, level="match")

``Index`` also supports ``.str.extractall``. It returns a ``DataFrame`` which has the
same result as a ``Series.str.extractall`` with a default index (starts from 0).

.. versionadded:: 0.19.0

.. ipython:: python

   pd.Index(["a1a2", "b1", "c1"]).str.extractall(two_groups)

   pd.Series(["a1a2", "b1", "c1"]).str.extractall(two_groups)