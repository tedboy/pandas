.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8

Introduction
------------

This is an introduction to pandas categorical data type, including a short comparison
with R's ``factor``.

`Categoricals` are a pandas data type, which correspond to categorical variables in
statistics: a variable, which can take on only a limited, and usually fixed,
number of possible values (`categories`; `levels` in R). Examples are gender, social class,
blood types, country affiliations, observation time or ratings via Likert scales.

In contrast to statistical categorical variables, categorical data might have an order (e.g.
'strongly agree' vs 'agree' or 'first observation' vs. 'second observation'), but numerical
operations (additions, divisions, ...) are not possible.

All values of categorical data are either in `categories` or `np.nan`. Order is defined by
the order of `categories`, not lexical order of the values. Internally, the data structure
consists of a `categories` array and an integer array of `codes` which point to the real value in
the `categories` array.

The categorical data type is useful in the following cases:

* A string variable consisting of only a few different values. Converting such a string
  variable to a categorical variable will save some memory, see :ref:`here <categorical.memory>`.
* The lexical order of a variable is not the same as the logical order ("one", "two", "three").
  By converting to a categorical and specifying an order on the categories, sorting and
  min/max will use the logical order instead of the lexical order, see :ref:`here <categorical.sort>`.
* As a signal to other python libraries that this column should be treated as a categorical
  variable (e.g. to use suitable statistical methods or plot types).

See also the :ref:`API docs on categoricals<api.categorical>`.
