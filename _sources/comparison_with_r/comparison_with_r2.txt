.. ipython:: python
   :suppress:

   import pandas as pd
   import numpy as np
   pd.options.display.max_rows=8

Base R
------

Slicing with R's |c|_
~~~~~~~~~~~~~~~~~~~~~

R makes it easy to access ``data.frame`` columns by name

.. code-block:: r

   df <- data.frame(a=rnorm(5), b=rnorm(5), c=rnorm(5), d=rnorm(5), e=rnorm(5))
   df[, c("a", "c", "e")]

or by integer location

.. code-block:: r

   df <- data.frame(matrix(rnorm(1000), ncol=100))
   df[, c(1:10, 25:30, 40, 50:100)]

Selecting multiple columns by name in ``pandas`` is straightforward

.. ipython:: python

   df = pd.DataFrame(np.random.randn(10, 3), columns=list('abc'))
   df[['a', 'c']]
   df.loc[:, ['a', 'c']]

Selecting multiple noncontiguous columns by integer location can be achieved
with a combination of the ``iloc`` indexer attribute and ``numpy.r_``.

.. ipython:: python

   named = list('abcdefg')
   n = 30
   columns = named + np.arange(len(named), n).tolist()
   df = pd.DataFrame(np.random.randn(n, n), columns=columns)

   df.iloc[:, np.r_[:10, 24:30]]

|aggregate|_
~~~~~~~~~~~~

In R you may want to split data into subsets and compute the mean for each.
Using a data.frame called ``df`` and splitting it into groups ``by1`` and
``by2``:

.. code-block:: r

   df <- data.frame(
     v1 = c(1,3,5,7,8,3,5,NA,4,5,7,9),
     v2 = c(11,33,55,77,88,33,55,NA,44,55,77,99),
     by1 = c("red", "blue", 1, 2, NA, "big", 1, 2, "red", 1, NA, 12),
     by2 = c("wet", "dry", 99, 95, NA, "damp", 95, 99, "red", 99, NA, NA))
   aggregate(x=df[, c("v1", "v2")], by=list(mydf2$by1, mydf2$by2), FUN = mean)

The :meth:`~pandas.DataFrame.groupby` method is similar to base R ``aggregate``
function.

.. ipython:: python

   df = pd.DataFrame({
     'v1': [1,3,5,7,8,3,5,np.nan,4,5,7,9],
     'v2': [11,33,55,77,88,33,55,np.nan,44,55,77,99],
     'by1': ["red", "blue", 1, 2, np.nan, "big", 1, 2, "red", 1, np.nan, 12],
     'by2': ["wet", "dry", 99, 95, np.nan, "damp", 95, 99, "red", 99, np.nan,
             np.nan]
   })

   g = df.groupby(['by1','by2'])
   g[['v1','v2']].mean()

For more details and examples see :ref:`the groupby documentation
<groupby.split>`.

|match|_
~~~~~~~~~~~~

A common way to select data in R is using ``%in%`` which is defined using the
function ``match``. The operator ``%in%`` is used to return a logical vector
indicating if there is a match or not:

.. code-block:: r

   s <- 0:4
   s %in% c(2,4)

The :meth:`~pandas.DataFrame.isin` method is similar to R ``%in%`` operator:

.. ipython:: python

   s = pd.Series(np.arange(5),dtype=np.float32)
   s.isin([2, 4])

The ``match`` function returns a vector of the positions of matches
of its first argument in its second:

.. code-block:: r

   s <- 0:4
   match(s, c(2,4))

The :meth:`~pandas.core.groupby.GroupBy.apply` method can be used to replicate
this:

.. ipython:: python

   s = pd.Series(np.arange(5),dtype=np.float32)
   pd.Series(pd.match(s,[2,4],np.nan))

For more details and examples see :ref:`the reshaping documentation
<indexing.basics.indexing_isin>`.

|tapply|_
~~~~~~~~~

``tapply`` is similar to ``aggregate``, but data can be in a ragged array,
since the subclass sizes are possibly irregular. Using a data.frame called
``baseball``, and retrieving information based on the array ``team``:

.. code-block:: r

   baseball <-
     data.frame(team = gl(5, 5,
                labels = paste("Team", LETTERS[1:5])),
                player = sample(letters, 25),
                batting.average = runif(25, .200, .400))

   tapply(baseball$batting.average, baseball.example$team,
          max)

In ``pandas`` we may use :meth:`~pandas.pivot_table` method to handle this:

.. ipython:: python

   import random
   import string

   baseball = pd.DataFrame({
      'team': ["team %d" % (x+1) for x in range(5)]*5,
      'player': random.sample(list(string.ascii_lowercase),25),
      'batting avg': np.random.uniform(.200, .400, 25)
      })
   baseball.pivot_table(values='batting avg', columns='team', aggfunc=np.max)

For more details and examples see :ref:`the reshaping documentation
<reshaping.pivot>`.

|subset|_
~~~~~~~~~~

.. versionadded:: 0.13

The :meth:`~pandas.DataFrame.query` method is similar to the base R ``subset``
function. In R you might want to get the rows of a ``data.frame`` where one
column's values are less than another column's values:

.. code-block:: r

   df <- data.frame(a=rnorm(10), b=rnorm(10))
   subset(df, a <= b)
   df[df$a <= df$b,]  # note the comma

In ``pandas``, there are a few ways to perform subsetting. You can use
:meth:`~pandas.DataFrame.query` or pass an expression as if it were an
index/slice as well as standard boolean indexing:

.. ipython:: python

   df = pd.DataFrame({'a': np.random.randn(10), 'b': np.random.randn(10)})
   df.query('a <= b')
   df[df.a <= df.b]
   df.loc[df.a <= df.b]

For more details and examples see :ref:`the query documentation
<indexing.query>`.


|with|_
~~~~~~~~

.. versionadded:: 0.13

An expression using a data.frame called ``df`` in R with the columns ``a`` and
``b`` would be evaluated using ``with`` like so:

.. code-block:: r

   df <- data.frame(a=rnorm(10), b=rnorm(10))
   with(df, a + b)
   df$a + df$b  # same as the previous expression

In ``pandas`` the equivalent expression, using the
:meth:`~pandas.DataFrame.eval` method, would be:

.. ipython:: python

   df = pd.DataFrame({'a': np.random.randn(10), 'b': np.random.randn(10)})
   df.eval('a + b')
   df.a + df.b  # same as the previous expression

In certain cases :meth:`~pandas.DataFrame.eval` will be much faster than
evaluation in pure Python. For more details and examples see :ref:`the eval
documentation <enhancingperf.eval>`.