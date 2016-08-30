.. ipython:: python
   :suppress:

   import pandas as pd
   import numpy as np
   pd.options.display.max_rows=8

Quick Reference
---------------

We'll start off with a quick reference guide pairing some common R
operations using `dplyr
<http://cran.r-project.org/web/packages/dplyr/index.html>`__ with
pandas equivalents.


Querying, Filtering, Sampling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

===========================================  ===========================================
R                                            pandas
===========================================  ===========================================
``dim(df)``                                  ``df.shape``
``head(df)``                                 ``df.head()``
``slice(df, 1:10)``                          ``df.iloc[:9]``
``filter(df, col1 == 1, col2 == 1)``         ``df.query('col1 == 1 & col2 == 1')``
``df[df$col1 == 1 & df$col2 == 1,]``         ``df[(df.col1 == 1) & (df.col2 == 1)]``
``select(df, col1, col2)``                   ``df[['col1', 'col2']]``
``select(df, col1:col3)``                    ``df.loc[:, 'col1':'col3']``
``select(df, -(col1:col3))``                 ``df.drop(cols_to_drop, axis=1)`` but see [#select_range]_
``distinct(select(df, col1))``               ``df[['col1']].drop_duplicates()``
``distinct(select(df, col1, col2))``         ``df[['col1', 'col2']].drop_duplicates()``
``sample_n(df, 10)``                         ``df.sample(n=10)``
``sample_frac(df, 0.01)``                    ``df.sample(frac=0.01)``
===========================================  ===========================================

.. [#select_range] R's shorthand for a subrange of columns
                   (``select(df, col1:col3)``) can be approached
                   cleanly in pandas, if you have the list of columns,
                   for example ``df[cols[1:3]]`` or
                   ``df.drop(cols[1:3])``, but doing this by column
                   name is a bit messy.


Sorting
~~~~~~~

===========================================  ===========================================
R                                            pandas
===========================================  ===========================================
``arrange(df, col1, col2)``                  ``df.sort_values(['col1', 'col2'])``
``arrange(df, desc(col1))``                  ``df.sort_values('col1', ascending=False)``
===========================================  ===========================================

Transforming
~~~~~~~~~~~~

===========================================  ===========================================
R                                            pandas
===========================================  ===========================================
``select(df, col_one = col1)``               ``df.rename(columns={'col1': 'col_one'})['col_one']``
``rename(df, col_one = col1)``               ``df.rename(columns={'col1': 'col_one'})``
``mutate(df, c=a-b)``                        ``df.assign(c=df.a-df.b)``
===========================================  ===========================================


Grouping and Summarizing
~~~~~~~~~~~~~~~~~~~~~~~~

==============================================  ===========================================
R                                               pandas
==============================================  ===========================================
``summary(df)``                                 ``df.describe()``
``gdf <- group_by(df, col1)``                   ``gdf = df.groupby('col1')``
``summarise(gdf, avg=mean(col1, na.rm=TRUE))``  ``df.groupby('col1').agg({'col1': 'mean'})``
``summarise(gdf, total=sum(col1))``             ``df.groupby('col1').sum()``
==============================================  ===========================================
