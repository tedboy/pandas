Introduction
------------
By "group by" we are referring to a process involving one or more of the following
steps

 - **Splitting** the data into groups based on some criteria
 - **Applying** a function to each group independently
 - **Combining** the results into a data structure

Of these, the split step is the most straightforward. In fact, in many
situations you may wish to split the data set into groups and do something with
those groups yourself. In the apply step, we might wish to one of the
following:

 - **Aggregation**: computing a summary statistic (or statistics) about each
   group. Some examples:

    - Compute group sums or means
    - Compute group sizes / counts

 - **Transformation**: perform some group-specific computations and return a
   like-indexed. Some examples:

    - Standardizing data (zscore) within group
    - Filling NAs within groups with a value derived from each group

 - **Filtration**: discard some groups, according to a group-wise computation
   that evaluates True or False. Some examples:

    - Discarding data that belongs to groups with only a few members
    - Filtering out data based on the group sum or mean

 - Some combination of the above: GroupBy will examine the results of the apply
   step and try to return a sensibly combined result if it doesn't fit into
   either of the above two categories

Since the set of object instance methods on pandas data structures are generally
rich and expressive, we often simply want to invoke, say, a DataFrame function
on each group. The name GroupBy should be quite familiar to those who have used
a SQL-based tool (or ``itertools``), in which you can write code like:

.. code-block:: sql

   SELECT Column1, Column2, mean(Column3), sum(Column4)
   FROM SomeTable
   GROUP BY Column1, Column2

We aim to make operations like this natural and easy to express using
pandas. We'll address each area of GroupBy functionality then provide some
non-trivial examples / use cases.

See the :ref:`cookbook<cookbook.grouping>` for some advanced strategies

