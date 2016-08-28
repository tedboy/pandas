.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. ipython:: python

   dates = pd.date_range('1/1/2000', periods=8)
   df = pd.DataFrame(np.random.randn(8, 4), index=dates, columns=['A', 'B', 'C', 'D'])

Boolean indexing
----------------

.. _indexing.boolean:

Another common operation is the use of boolean vectors to filter the data.
The operators are: ``|`` for ``or``, ``&`` for ``and``, and ``~`` for ``not``. These **must** be grouped by using parentheses.

Using a boolean vector to index a Series works exactly as in a numpy ndarray:

.. ipython:: python

   s = pd.Series(range(-3, 4))
   s
   s[s > 0]
   s[(s < -1) | (s > 0.5)]
   s[~(s < 0)]

You may select rows from a DataFrame using a boolean vector the same length as
the DataFrame's index (for example, something derived from one of the columns
of the DataFrame):

.. ipython:: python

   df
   df[df['A'] > 0]

List comprehensions and ``map`` method of Series can also be used to produce
more complex criteria:

.. ipython:: python

   df2 = pd.DataFrame({'a' : ['one', 'one', 'two', 'three', 'two', 'one', 'six'],
                       'b' : ['x', 'y', 'y', 'x', 'y', 'x', 'x'],
                       'c' : np.random.randn(7)})
   df2
   
   # only want 'two' or 'three'
   criterion = df2['a'].map(lambda x: x.startswith('t'))

   df2[criterion]

   # equivalent but slower
   df2[[x.startswith('t') for x in df2['a']]]

   # Multiple criteria
   df2[criterion & (df2['b'] == 'x')]

Note, with the choice methods :ref:`Selection by Label <indexing.label>`, :ref:`Selection by Position <indexing.integer>`,
and :ref:`Advanced Indexing <advanced>` you may select along more than one axis using boolean vectors combined with other indexing expressions.

.. ipython:: python

   df2.loc[criterion & (df2['b'] == 'x'),'b':'c']