.. ipython:: python
   :suppress:

   import pandas as pd
   import numpy as np
   pd.options.display.max_rows=8

reshape / reshape2
------------------

|meltarray|_
~~~~~~~~~~~~~

An expression using a 3 dimensional array called ``a`` in R where you want to
melt it into a data.frame:

.. code-block:: r

   a <- array(c(1:23, NA), c(2,3,4))
   data.frame(melt(a))

In Python, since ``a`` is a list, you can simply use list comprehension.

.. ipython:: python

   a = np.array(list(range(1,24))+[np.NAN]).reshape(2,3,4)
   pd.DataFrame([tuple(list(x)+[val]) for x, val in np.ndenumerate(a)])

|meltlist|_
~~~~~~~~~~~~

An expression using a list called ``a`` in R where you want to melt it
into a data.frame:

.. code-block:: r

   a <- as.list(c(1:4, NA))
   data.frame(melt(a))

In Python, this list would be a list of tuples, so
:meth:`~pandas.DataFrame` method would convert it to a dataframe as required.

.. ipython:: python

   a = list(enumerate(list(range(1,5))+[np.NAN]))
   pd.DataFrame(a)

For more details and examples see :ref:`the Into to Data Structures
documentation <basics.dataframe.from_items>`.

|meltdf|_
~~~~~~~~~~~~~~~~

An expression using a data.frame called ``cheese`` in R where you want to
reshape the data.frame:

.. code-block:: r

   cheese <- data.frame(
     first = c('John', 'Mary'),
     last = c('Doe', 'Bo'),
     height = c(5.5, 6.0),
     weight = c(130, 150)
   )
   melt(cheese, id=c("first", "last"))

In Python, the :meth:`~pandas.melt` method is the R equivalent:

.. ipython:: python

   cheese = pd.DataFrame({'first' : ['John', 'Mary'],
                       'last' : ['Doe', 'Bo'],
                       'height' : [5.5, 6.0],
                       'weight' : [130, 150]})
   pd.melt(cheese, id_vars=['first', 'last'])
   cheese.set_index(['first', 'last']).stack() # alternative way

For more details and examples see :ref:`the reshaping documentation
<reshaping.melt>`.

|cast|_
~~~~~~~

In R ``acast`` is an expression using a data.frame called ``df`` in R to cast
into a higher dimensional array:

.. code-block:: r

   df <- data.frame(
     x = runif(12, 1, 168),
     y = runif(12, 7, 334),
     z = runif(12, 1.7, 20.7),
     month = rep(c(5,6,7),4),
     week = rep(c(1,2), 6)
   )

   mdf <- melt(df, id=c("month", "week"))
   acast(mdf, week ~ month ~ variable, mean)

In Python the best way is to make use of :meth:`~pandas.pivot_table`:

.. ipython:: python

   df = pd.DataFrame({
        'x': np.random.uniform(1., 168., 12),
        'y': np.random.uniform(7., 334., 12),
        'z': np.random.uniform(1.7, 20.7, 12),
        'month': [5,6,7]*4,
        'week': [1,2]*6
   })
   mdf = pd.melt(df, id_vars=['month', 'week'])
   pd.pivot_table(mdf, values='value', index=['variable','week'],
                    columns=['month'], aggfunc=np.mean)

Similarly for ``dcast`` which uses a data.frame called ``df`` in R to
aggregate information based on ``Animal`` and ``FeedType``:

.. code-block:: r

   df <- data.frame(
     Animal = c('Animal1', 'Animal2', 'Animal3', 'Animal2', 'Animal1',
                'Animal2', 'Animal3'),
     FeedType = c('A', 'B', 'A', 'A', 'B', 'B', 'A'),
     Amount = c(10, 7, 4, 2, 5, 6, 2)
   )

   dcast(df, Animal ~ FeedType, sum, fill=NaN)
   # Alternative method using base R
   with(df, tapply(Amount, list(Animal, FeedType), sum))

Python can approach this in two different ways. Firstly, similar to above
using :meth:`~pandas.pivot_table`:

.. ipython:: python

   df = pd.DataFrame({
       'Animal': ['Animal1', 'Animal2', 'Animal3', 'Animal2', 'Animal1',
                  'Animal2', 'Animal3'],
       'FeedType': ['A', 'B', 'A', 'A', 'B', 'B', 'A'],
       'Amount': [10, 7, 4, 2, 5, 6, 2],
   })

   df.pivot_table(values='Amount', index='Animal', columns='FeedType', aggfunc='sum')

The second approach is to use the :meth:`~pandas.DataFrame.groupby` method:

.. ipython:: python

   df.groupby(['Animal','FeedType'])['Amount'].sum()

For more details and examples see :ref:`the reshaping documentation
<reshaping.pivot>` or :ref:`the groupby documentation<groupby.split>`.

|factor|_
~~~~~~~~~

.. versionadded:: 0.15

pandas has a data type for categorical data.

.. code-block:: r

   cut(c(1,2,3,4,5,6), 3)
   factor(c(1,2,3,2,2,3))

In pandas this is accomplished with ``pd.cut`` and ``astype("category")``:

.. ipython:: python

   pd.cut(pd.Series([1,2,3,4,5,6]), 3)
   pd.Series([1,2,3,2,2,3]).astype("category")

For more details and examples see :ref:`categorical introduction <categorical>` and the
:ref:`API documentation <api.categorical>`. There is also a documentation regarding the
:ref:`differences to R's factor <categorical.rfactor>`.


.. |c| replace:: ``c``
.. _c: http://stat.ethz.ch/R-manual/R-patched/library/base/html/c.html

.. |aggregate| replace:: ``aggregate``
.. _aggregate: http://finzi.psych.upenn.edu/R/library/stats/html/aggregate.html

.. |match| replace:: ``match`` / ``%in%``
.. _match: http://finzi.psych.upenn.edu/R/library/base/html/match.html

.. |tapply| replace:: ``tapply``
.. _tapply: http://finzi.psych.upenn.edu/R/library/base/html/tapply.html

.. |with| replace:: ``with``
.. _with: http://finzi.psych.upenn.edu/R/library/base/html/with.html

.. |subset| replace:: ``subset``
.. _subset: http://finzi.psych.upenn.edu/R/library/base/html/subset.html

.. |ddply| replace:: ``ddply``
.. _ddply: http://www.inside-r.org/packages/cran/plyr/docs/ddply

.. |meltarray| replace:: ``melt.array``
.. _meltarray: http://www.inside-r.org/packages/cran/reshape2/docs/melt.array

.. |meltlist| replace:: ``melt.list``
.. meltlist: http://www.inside-r.org/packages/cran/reshape2/docs/melt.list

.. |meltdf| replace:: ``melt.data.frame``
.. meltdf: http://www.inside-r.org/packages/cran/reshape2/docs/melt.data.frame

.. |cast| replace:: ``cast``
.. cast: http://www.inside-r.org/packages/cran/reshape2/docs/cast

.. |factor| replace:: ``factor``
.. _factor: https://stat.ethz.ch/R-manual/R-devel/library/base/html/factor.html