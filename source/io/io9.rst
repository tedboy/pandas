.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import os
   import csv
   from pandas.compat import StringIO, BytesIO
   import pandas as pd
   ExcelWriter = pd.ExcelWriter

   import numpy as np
   np.random.seed(123456)
   randn = np.random.randn
   np.set_printoptions(precision=4, suppress=True)

   import matplotlib.pyplot as plt
   plt.close('all')

   import pandas.util.testing as tm
   pd.options.display.max_rows=15
   clipdf = pd.DataFrame({'A':[1,2,3],'B':[4,5,6],'C':['p','q','r']},
                         index=['x','y','z'])

.. _io.hdf5:

HDF5 (PyTables)
---------------

``HDFStore`` is a dict-like object which reads and writes pandas using
the high performance HDF5 format using the excellent `PyTables
<http://www.pytables.org/>`__ library. See the :ref:`cookbook <cookbook.hdf>`
for some advanced strategies

.. warning::

   As of version 0.15.0, pandas requires ``PyTables`` >= 3.0.0. Stores written with prior versions of pandas / ``PyTables`` >= 2.3 are fully compatible (this was the previous minimum ``PyTables`` required version).

.. warning::

   There is a ``PyTables`` indexing bug which may appear when querying stores using an index.  If you see a subset of results being returned, upgrade to ``PyTables`` >= 3.2.  Stores created previously will need to be rewritten using the updated version.

.. warning::

   As of version 0.17.0, ``HDFStore`` will not drop rows that have all missing values by default. Previously, if all values (except the index) were missing, ``HDFStore`` would not write those rows to disk.

.. ipython:: python
   :suppress:
   :okexcept:

   os.remove('store.h5')

.. ipython:: python

   store = pd.HDFStore('store.h5')
   print(store)

Objects can be written to the file just like adding key-value pairs to a
dict:

.. ipython:: python

   np.random.seed(1234)
   index = pd.date_range('1/1/2000', periods=8)
   s = pd.Series(randn(5), index=['a', 'b', 'c', 'd', 'e'])
   df = pd.DataFrame(randn(8, 3), index=index,
                     columns=['A', 'B', 'C'])
   wp = pd.Panel(randn(2, 5, 4), items=['Item1', 'Item2'],
                 major_axis=pd.date_range('1/1/2000', periods=5),
                 minor_axis=['A', 'B', 'C', 'D'])

   # store.put('s', s) is an equivalent method
   store['s'] = s

   store['df'] = df

   store['wp'] = wp

   # the type of stored data
   store.root.wp._v_attrs.pandas_type

   store

In a current or later Python session, you can retrieve stored objects:

.. ipython:: python

   # store.get('df') is an equivalent method
   store['df']

   # dotted (attribute) access provides get as well
   store.df

Deletion of the object specified by the key

.. ipython:: python

   # store.remove('wp') is an equivalent method
   del store['wp']

   store

Closing a Store, Context Manager

.. ipython:: python

   store.close()
   store
   store.is_open

   # Working with, and automatically closing the store with the context
   # manager
   with pd.HDFStore('store.h5') as store:
       store.keys()

.. ipython:: python
   :suppress:

   store.close()
   import os
   os.remove('store.h5')



Read/Write API
''''''''''''''

``HDFStore`` supports an top-level API using  ``read_hdf`` for reading and ``to_hdf`` for writing,
similar to how ``read_csv`` and ``to_csv`` work. (new in 0.11.0)

.. ipython:: python

   df_tl = pd.DataFrame(dict(A=list(range(5)), B=list(range(5))))
   df_tl.to_hdf('store_tl.h5','table',append=True)
   pd.read_hdf('store_tl.h5', 'table', where = ['index>2'])

.. ipython:: python
   :suppress:
   :okexcept:

   os.remove('store_tl.h5')


As of version 0.17.0, HDFStore will no longer drop rows that are all missing by default. This behavior can be enabled by setting ``dropna=True``.

.. ipython:: python
   :suppress:

   import os

.. ipython:: python

   df_with_missing = pd.DataFrame({'col1':[0, np.nan, 2],
                                   'col2':[1, np.nan, np.nan]})
   df_with_missing

   df_with_missing.to_hdf('file.h5', 'df_with_missing',
                           format = 'table', mode='w')

   pd.read_hdf('file.h5', 'df_with_missing')

   df_with_missing.to_hdf('file.h5', 'df_with_missing',
                           format = 'table', mode='w', dropna=True)
   pd.read_hdf('file.h5', 'df_with_missing')


.. ipython:: python
   :suppress:

   os.remove('file.h5')

This is also true for the major axis of a ``Panel``:

.. ipython:: python

   matrix = [[[np.nan, np.nan, np.nan],[1,np.nan,np.nan]],
          [[np.nan, np.nan, np.nan], [np.nan,5,6]],
          [[np.nan, np.nan, np.nan],[np.nan,3,np.nan]]]

   panel_with_major_axis_all_missing = pd.Panel(matrix,
           items=['Item1', 'Item2','Item3'],
           major_axis=[1,2],
           minor_axis=['A', 'B', 'C'])

   panel_with_major_axis_all_missing

   panel_with_major_axis_all_missing.to_hdf('file.h5', 'panel',
                                           dropna = True,
                                           format='table',
                                           mode='w')
   reloaded = pd.read_hdf('file.h5', 'panel')
   reloaded


.. ipython:: python
   :suppress:

   os.remove('file.h5')



.. _io.hdf5-fixed:

Fixed Format
''''''''''''

.. note::

   This was prior to 0.13.0 the ``Storer`` format.

The examples above show storing using ``put``, which write the HDF5 to ``PyTables`` in a fixed array format, called
the ``fixed`` format. These types of stores are are **not** appendable once written (though you can simply
remove them and rewrite). Nor are they **queryable**; they must be
retrieved in their entirety. They also do not support dataframes with non-unique column names.
The ``fixed`` format stores offer very fast writing and slightly faster reading than ``table`` stores.
This format is specified by default when using ``put`` or ``to_hdf`` or by ``format='fixed'`` or ``format='f'``

.. warning::

   A ``fixed`` format will raise a ``TypeError`` if you try to retrieve using a ``where`` .

   .. code-block:: python

       pd.DataFrame(randn(10,2)).to_hdf('test_fixed.h5','df')

       pd.read_hdf('test_fixed.h5','df',where='index>5')
       TypeError: cannot pass a where specification when reading a fixed format.
                  this store must be selected in its entirety


.. _io.hdf5-table:

Table Format
''''''''''''

``HDFStore`` supports another ``PyTables`` format on disk, the ``table``
format. Conceptually a ``table`` is shaped very much like a DataFrame,
with rows and columns. A ``table`` may be appended to in the same or
other sessions.  In addition, delete & query type operations are
supported. This format is specified by ``format='table'`` or ``format='t'``
to ``append`` or ``put`` or ``to_hdf``

.. versionadded:: 0.13

This format can be set as an option as well ``pd.set_option('io.hdf.default_format','table')`` to
enable ``put/append/to_hdf`` to by default store in the ``table`` format.

.. ipython:: python
   :suppress:
   :okexcept:

   os.remove('store.h5')

.. ipython:: python

   store = pd.HDFStore('store.h5')
   df1 = df[0:4]
   df2 = df[4:]

   # append data (creates a table automatically)
   store.append('df', df1)
   store.append('df', df2)
   store

   # select the entire object
   store.select('df')

   # the type of stored data
   store.root.df._v_attrs.pandas_type

.. note::

   You can also create a ``table`` by passing ``format='table'`` or ``format='t'`` to a ``put`` operation.

.. _io.hdf5-keys:

Hierarchical Keys
'''''''''''''''''

Keys to a store can be specified as a string. These can be in a
hierarchical path-name like format (e.g. ``foo/bar/bah``), which will
generate a hierarchy of sub-stores (or ``Groups`` in PyTables
parlance). Keys can be specified with out the leading '/' and are ALWAYS
absolute (e.g. 'foo' refers to '/foo'). Removal operations can remove
everything in the sub-store and BELOW, so be *careful*.

.. ipython:: python

   store.put('foo/bar/bah', df)
   store.append('food/orange', df)
   store.append('food/apple',  df)
   store

   # a list of keys are returned
   store.keys()

   # remove all nodes under this level
   store.remove('food')
   store

.. warning::

    Hierarchical keys cannot be retrieved as dotted (attribute) access as described above for items stored under the root node.

    .. code-block:: python

       In [8]: store.foo.bar.bah
       AttributeError: 'HDFStore' object has no attribute 'foo'

       # you can directly access the actual PyTables node but using the root node
       In [9]: store.root.foo.bar.bah
       Out[9]:
       /foo/bar/bah (Group) ''
         children := ['block0_items' (Array), 'block0_values' (Array), 'axis0' (Array), 'axis1' (Array)]

    Instead, use explicit string based keys

    .. ipython:: python

       store['foo/bar/bah']


.. _io.hdf5-types:

Storing Types
'''''''''''''

Storing Mixed Types in a Table
++++++++++++++++++++++++++++++

Storing mixed-dtype data is supported. Strings are stored as a
fixed-width using the maximum size of the appended column. Subsequent attempts
at appending longer strings will raise a ``ValueError``.

Passing ``min_itemsize={`values`: size}`` as a parameter to append
will set a larger minimum for the string columns. Storing ``floats,
strings, ints, bools, datetime64`` are currently supported. For string
columns, passing ``nan_rep = 'nan'`` to append will change the default
nan representation on disk (which converts to/from `np.nan`), this
defaults to `nan`.

.. ipython:: python

    df_mixed = pd.DataFrame({ 'A' : randn(8),
                              'B' : randn(8),
                              'C' : np.array(randn(8),dtype='float32'),
                              'string' :'string',
                              'int' : 1,
                              'bool' : True,
                              'datetime64' : pd.Timestamp('20010102')},
                            index=list(range(8)))
    df_mixed.ix[3:5,['A', 'B', 'string', 'datetime64']] = np.nan

    store.append('df_mixed', df_mixed, min_itemsize = {'values': 50})
    df_mixed1 = store.select('df_mixed')
    df_mixed1
    df_mixed1.get_dtype_counts()

    # we have provided a minimum string column size
    store.root.df_mixed.table

Storing Multi-Index DataFrames
++++++++++++++++++++++++++++++

Storing multi-index dataframes as tables is very similar to
storing/selecting from homogeneous index DataFrames.

.. ipython:: python

        index = pd.MultiIndex(levels=[['foo', 'bar', 'baz', 'qux'],
                                      ['one', 'two', 'three']],
                              labels=[[0, 0, 0, 1, 1, 2, 2, 3, 3, 3],
                                      [0, 1, 2, 0, 1, 1, 2, 0, 1, 2]],
                              names=['foo', 'bar'])
        df_mi = pd.DataFrame(np.random.randn(10, 3), index=index,
                             columns=['A', 'B', 'C'])
        df_mi

        store.append('df_mi',df_mi)
        store.select('df_mi')

        # the levels are automatically included as data columns
        store.select('df_mi', 'foo=bar')


.. _io.hdf5-query:

Querying
''''''''

Querying a Table
++++++++++++++++

.. warning::

   This query capabilities have changed substantially starting in ``0.13.0``.
   Queries from prior version are accepted (with a ``DeprecationWarning``) printed
   if its not string-like.

``select`` and ``delete`` operations have an optional criterion that can
be specified to select/delete only a subset of the data. This allows one
to have a very large on-disk table and retrieve only a portion of the
data.

A query is specified using the ``Term`` class under the hood, as a boolean expression.

- ``index`` and ``columns`` are supported indexers of a DataFrame
- ``major_axis``, ``minor_axis``, and ``items`` are supported indexers of
  the Panel
- if ``data_columns`` are specified, these can be used as additional indexers

Valid comparison operators are:

``=, ==, !=, >, >=, <, <=``

Valid boolean expressions are combined with:

- ``|`` : or
- ``&`` : and
- ``(`` and ``)`` : for grouping

These rules are similar to how boolean expressions are used in pandas for indexing.

.. note::

   - ``=`` will be automatically expanded to the comparison operator ``==``
   - ``~`` is the not operator, but can only be used in very limited
     circumstances
   - If a list/tuple of expressions is passed they will be combined via ``&``

The following are valid expressions:

- ``'index>=date'``
- ``"columns=['A', 'D']"``
- ``"columns in ['A', 'D']"``
- ``'columns=A'``
- ``'columns==A'``
- ``"~(columns=['A','B'])"``
- ``'index>df.index[3] & string="bar"'``
- ``'(index>df.index[3] & index<=df.index[6]) | string="bar"'``
- ``"ts>=Timestamp('2012-02-01')"``
- ``"major_axis>=20130101"``

The ``indexers`` are on the left-hand side of the sub-expression:

``columns``, ``major_axis``, ``ts``

The right-hand side of the sub-expression (after a comparison operator) can be:

- functions that will be evaluated, e.g. ``Timestamp('2012-02-01')``
- strings, e.g. ``"bar"``
- date-like, e.g. ``20130101``, or ``"20130101"``
- lists, e.g. ``"['A','B']"``
- variables that are defined in the local names space, e.g. ``date``

.. note::

   Passing a string to a query by interpolating it into the query
   expression is not recommended. Simply assign the string of interest to a
   variable and use that variable in an expression. For example, do this

   .. code-block:: python

      string = "HolyMoly'"
      store.select('df', 'index == string')

   instead of this

   .. code-block:: python

      string = "HolyMoly'"
      store.select('df',  'index == %s' % string)

   The latter will **not** work and will raise a ``SyntaxError``.Note that
   there's a single quote followed by a double quote in the ``string``
   variable.

   If you *must* interpolate, use the ``'%r'`` format specifier

   .. code-block:: python

      store.select('df', 'index == %r' % string)

   which will quote ``string``.


Here are some examples:

.. ipython:: python

    dfq = pd.DataFrame(randn(10,4),columns=list('ABCD'),index=pd.date_range('20130101',periods=10))
    store.append('dfq',dfq,format='table',data_columns=True)

Use boolean expressions, with in-line function evaluation.

.. ipython:: python

    store.select('dfq',"index>pd.Timestamp('20130104') & columns=['A', 'B']")

Use and inline column reference

.. ipython:: python

   store.select('dfq',where="A>0 or C>0")

Works with a Panel as well.

.. ipython:: python

   store.append('wp',wp)
   store
   store.select('wp', "major_axis>pd.Timestamp('20000102') & minor_axis=['A', 'B']")

The ``columns`` keyword can be supplied to select a list of columns to be
returned, this is equivalent to passing a
``'columns=list_of_columns_to_filter'``:

.. ipython:: python

   store.select('df', "columns=['A', 'B']")

``start`` and ``stop`` parameters can be specified to limit the total search
space. These are in terms of the total number of rows in a table.

.. ipython:: python

   # this is effectively what the storage of a Panel looks like
   wp.to_frame()

   # limiting the search
   store.select('wp',"major_axis>20000102 & minor_axis=['A','B']",
                start=0, stop=10)

.. note::

   ``select`` will raise a ``ValueError`` if the query expression has an unknown
   variable reference. Usually this means that you are trying to select on a column
   that is **not** a data_column.

   ``select`` will raise a ``SyntaxError`` if the query expression is not valid.


.. _io.hdf5-timedelta:

Using timedelta64[ns]
+++++++++++++++++++++

.. versionadded:: 0.13

Beginning in 0.13.0, you can store and query using the ``timedelta64[ns]`` type. Terms can be
specified in the format: ``<float>(<unit>)``, where float may be signed (and fractional), and unit can be
``D,s,ms,us,ns`` for the timedelta. Here's an example:

.. ipython:: python

   from datetime import timedelta
   dftd = pd.DataFrame(dict(A = pd.Timestamp('20130101'), B = [ pd.Timestamp('20130101') + timedelta(days=i,seconds=10) for i in range(10) ]))
   dftd['C'] = dftd['A']-dftd['B']
   dftd
   store.append('dftd',dftd,data_columns=True)
   store.select('dftd',"C<'-3.5D'")

Indexing
++++++++

You can create/modify an index for a table with ``create_table_index``
after data is already in the table (after and ``append/put``
operation). Creating a table index is **highly** encouraged. This will
speed your queries a great deal when you use a ``select`` with the
indexed dimension as the ``where``.

.. note::

   Indexes are automagically created (starting ``0.10.1``) on the indexables
   and any data columns you specify. This behavior can be turned off by passing
   ``index=False`` to ``append``.

.. ipython:: python

   # we have automagically already created an index (in the first section)
   i = store.root.df.table.cols.index.index
   i.optlevel, i.kind

   # change an index by passing new parameters
   store.create_table_index('df', optlevel=9, kind='full')
   i = store.root.df.table.cols.index.index
   i.optlevel, i.kind

Oftentimes when appending large amounts of data to a store, it is useful to turn off index creation for each append, then recreate at the end.

.. ipython:: python

   df_1 = pd.DataFrame(randn(10,2),columns=list('AB'))
   df_2 = pd.DataFrame(randn(10,2),columns=list('AB'))

   st = pd.HDFStore('appends.h5',mode='w')
   st.append('df', df_1, data_columns=['B'], index=False)
   st.append('df', df_2, data_columns=['B'], index=False)
   st.get_storer('df').table

Then create the index when finished appending.

.. ipython:: python

   st.create_table_index('df', columns=['B'], optlevel=9, kind='full')
   st.get_storer('df').table

   st.close()

.. ipython:: python
   :suppress:
   :okexcept:

   os.remove('appends.h5')

See `here <http://stackoverflow.com/questions/17893370/ptrepack-sortby-needs-full-index>`__ for how to create a completely-sorted-index (CSI) on an existing store.

Query via Data Columns
++++++++++++++++++++++

You can designate (and index) certain columns that you want to be able
to perform queries (other than the `indexable` columns, which you can
always query). For instance say you want to perform this common
operation, on-disk, and return just the frame that matches this
query. You can specify ``data_columns = True`` to force all columns to
be data_columns

.. ipython:: python

   df_dc = df.copy()
   df_dc['string'] = 'foo'
   df_dc.ix[4:6,'string'] = np.nan
   df_dc.ix[7:9,'string'] = 'bar'
   df_dc['string2'] = 'cool'
   df_dc.ix[1:3,['B','C']] = 1.0
   df_dc

   # on-disk operations
   store.append('df_dc', df_dc, data_columns = ['B', 'C', 'string', 'string2'])
   store.select('df_dc', [ pd.Term('B>0') ])

   # getting creative
   store.select('df_dc', 'B > 0 & C > 0 & string == foo')

   # this is in-memory version of this type of selection
   df_dc[(df_dc.B > 0) & (df_dc.C > 0) & (df_dc.string == 'foo')]

   # we have automagically created this index and the B/C/string/string2
   # columns are stored separately as ``PyTables`` columns
   store.root.df_dc.table

There is some performance degradation by making lots of columns into
`data columns`, so it is up to the user to designate these. In addition,
you cannot change data columns (nor indexables) after the first
append/put operation (Of course you can simply read in the data and
create a new table!)

Iterator
++++++++

Starting in ``0.11.0``, you can pass, ``iterator=True`` or ``chunksize=number_in_a_chunk``
to ``select`` and ``select_as_multiple`` to return an iterator on the results.
The default is 50,000 rows returned in a chunk.

.. ipython:: python

   for df in store.select('df', chunksize=3):
      print(df)

.. note::

   .. versionadded:: 0.12.0

   You can also use the iterator with ``read_hdf`` which will open, then
   automatically close the store when finished iterating.

   .. code-block:: python

      for df in pd.read_hdf('store.h5','df', chunksize=3):
          print(df)

Note, that the chunksize keyword applies to the **source** rows. So if you
are doing a query, then the chunksize will subdivide the total rows in the table
and the query applied, returning an iterator on potentially unequal sized chunks.

Here is a recipe for generating a query and using it to create equal sized return
chunks.

.. ipython:: python

   dfeq = pd.DataFrame({'number': np.arange(1,11)})
   dfeq

   store.append('dfeq', dfeq, data_columns=['number'])

   def chunks(l, n):
        return [l[i:i+n] for i in range(0, len(l), n)]

   evens = [2,4,6,8,10]
   coordinates = store.select_as_coordinates('dfeq','number=evens')
   for c in chunks(coordinates, 2):
        print store.select('dfeq',where=c)

Advanced Queries
++++++++++++++++

Select a Single Column
^^^^^^^^^^^^^^^^^^^^^^

To retrieve a single indexable or data column, use the
method ``select_column``. This will, for example, enable you to get the index
very quickly. These return a ``Series`` of the result, indexed by the row number.
These do not currently accept the ``where`` selector.

.. ipython:: python

   store.select_column('df_dc', 'index')
   store.select_column('df_dc', 'string')

.. _io.hdf5-selecting_coordinates:

Selecting coordinates
^^^^^^^^^^^^^^^^^^^^^

Sometimes you want to get the coordinates (a.k.a the index locations) of your query. This returns an
``Int64Index`` of the resulting locations. These coordinates can also be passed to subsequent
``where`` operations.

.. ipython:: python

   df_coord = pd.DataFrame(np.random.randn(1000,2),index=pd.date_range('20000101',periods=1000))
   store.append('df_coord',df_coord)
   c = store.select_as_coordinates('df_coord','index>20020101')
   c.summary()
   store.select('df_coord',where=c)

.. _io.hdf5-where_mask:

Selecting using a where mask
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sometime your query can involve creating a list of rows to select. Usually this ``mask`` would
be a resulting ``index`` from an indexing operation. This example selects the months of
a datetimeindex which are 5.

.. ipython:: python

   df_mask = pd.DataFrame(np.random.randn(1000,2),index=pd.date_range('20000101',periods=1000))
   store.append('df_mask',df_mask)
   c = store.select_column('df_mask','index')
   where = c[pd.DatetimeIndex(c).month==5].index
   store.select('df_mask',where=where)

Storer Object
^^^^^^^^^^^^^

If you want to inspect the stored object, retrieve via
``get_storer``. You could use this programmatically to say get the number
of rows in an object.

.. ipython:: python

   store.get_storer('df_dc').nrows


Multiple Table Queries
++++++++++++++++++++++

New in 0.10.1 are the methods ``append_to_multiple`` and
``select_as_multiple``, that can perform appending/selecting from
multiple tables at once. The idea is to have one table (call it the
selector table) that you index most/all of the columns, and perform your
queries. The other table(s) are data tables with an index matching the
selector table's index. You can then perform a very fast query
on the selector table, yet get lots of data back. This method is similar to
having a very wide table, but enables more efficient queries.

The ``append_to_multiple`` method splits a given single DataFrame
into multiple tables according to ``d``, a dictionary that maps the
table names to a list of 'columns' you want in that table. If `None`
is used in place of a list, that table will have the remaining
unspecified columns of the given DataFrame. The argument ``selector``
defines which table is the selector table (which you can make queries from).
The argument ``dropna`` will drop rows from the input DataFrame to ensure
tables are synchronized.  This means that if a row for one of the tables
being written to is entirely ``np.NaN``, that row will be dropped from all tables.

If ``dropna`` is False, **THE USER IS RESPONSIBLE FOR SYNCHRONIZING THE TABLES**.
Remember that entirely ``np.Nan`` rows are not written to the HDFStore, so if
you choose to call ``dropna=False``, some tables may have more rows than others,
and therefore ``select_as_multiple`` may not work or it may return unexpected
results.

.. ipython:: python

   df_mt = pd.DataFrame(randn(8, 6), index=pd.date_range('1/1/2000', periods=8),
                                     columns=['A', 'B', 'C', 'D', 'E', 'F'])
   df_mt['foo'] = 'bar'
   df_mt.ix[1, ('A', 'B')] = np.nan

   # you can also create the tables individually
   store.append_to_multiple({'df1_mt': ['A', 'B'], 'df2_mt': None },
                             df_mt, selector='df1_mt')
   store

   # individual tables were created
   store.select('df1_mt')
   store.select('df2_mt')

   # as a multiple
   store.select_as_multiple(['df1_mt', 'df2_mt'], where=['A>0', 'B>0'],
                             selector = 'df1_mt')


Delete from a Table
'''''''''''''''''''

You can delete from a table selectively by specifying a ``where``. In
deleting rows, it is important to understand the ``PyTables`` deletes
rows by erasing the rows, then **moving** the following data. Thus
deleting can potentially be a very expensive operation depending on the
orientation of your data. This is especially true in higher dimensional
objects (``Panel`` and ``Panel4D``). To get optimal performance, it's
worthwhile to have the dimension you are deleting be the first of the
``indexables``.

Data is ordered (on the disk) in terms of the ``indexables``. Here's a
simple use case. You store panel-type data, with dates in the
``major_axis`` and ids in the ``minor_axis``. The data is then
interleaved like this:

- date_1
  - id_1
  - id_2
  -  .
  - id_n
- date_2
  - id_1
  -  .
  - id_n

It should be clear that a delete operation on the ``major_axis`` will be
fairly quick, as one chunk is removed, then the following data moved. On
the other hand a delete operation on the ``minor_axis`` will be very
expensive. In this case it would almost certainly be faster to rewrite
the table using a ``where`` that selects all but the missing data.

.. ipython:: python

   # returns the number of rows deleted
   store.remove('wp', 'major_axis>20000102' )
   store.select('wp')

.. warning::

   Please note that HDF5 **DOES NOT RECLAIM SPACE** in the h5 files
   automatically. Thus, repeatedly deleting (or removing nodes) and adding
   again, **WILL TEND TO INCREASE THE FILE SIZE**.

   To *repack and clean* the file, use :ref:`ptrepack <io.hdf5-ptrepack>`

.. _io.hdf5-notes:

Notes & Caveats
'''''''''''''''


Compression
+++++++++++

``PyTables`` allows the stored data to be compressed. This applies to
all kinds of stores, not just tables.

- Pass ``complevel=int`` for a compression level (1-9, with 0 being no
  compression, and the default)
- Pass ``complib=lib`` where lib is any of ``zlib, bzip2, lzo, blosc`` for
  whichever compression library you prefer.

``HDFStore`` will use the file based compression scheme if no overriding
``complib`` or ``complevel`` options are provided. ``blosc`` offers very
fast compression, and is my most used. Note that ``lzo`` and ``bzip2``
may not be installed (by Python) by default.

Compression for all objects within the file

.. code-block:: python

   store_compressed = pd.HDFStore('store_compressed.h5', complevel=9, complib='blosc')

Or on-the-fly compression (this only applies to tables). You can turn
off file compression for a specific table by passing ``complevel=0``

.. code-block:: python

   store.append('df', df, complib='zlib', complevel=5)

.. _io.hdf5-ptrepack:

ptrepack
++++++++

``PyTables`` offers better write performance when tables are compressed after
they are written, as opposed to turning on compression at the very
beginning. You can use the supplied ``PyTables`` utility
``ptrepack``. In addition, ``ptrepack`` can change compression levels
after the fact.

.. code-block:: console

   ptrepack --chunkshape=auto --propindexes --complevel=9 --complib=blosc in.h5 out.h5

Furthermore ``ptrepack in.h5 out.h5`` will *repack* the file to allow
you to reuse previously deleted space. Alternatively, one can simply
remove the file and write again, or use the ``copy`` method.

.. _io.hdf5-caveats:

Caveats
+++++++

.. warning::

   ``HDFStore`` is **not-threadsafe for writing**. The underlying
   ``PyTables`` only supports concurrent reads (via threading or
   processes). If you need reading and writing *at the same time*, you
   need to serialize these operations in a single thread in a single
   process. You will corrupt your data otherwise. See the (:issue:`2397`) for more information.

- If you use locks to manage write access between multiple processes, you
  may want to use :py:func:`~os.fsync` before releasing write locks. For
  convenience you can use ``store.flush(fsync=True)`` to do this for you.
- Once a ``table`` is created its items (Panel) / columns (DataFrame)
  are fixed; only exactly the same columns can be appended
- Be aware that timezones (e.g., ``pytz.timezone('US/Eastern')``)
  are not necessarily equal across timezone versions.  So if data is
  localized to a specific timezone in the HDFStore using one version
  of a timezone library and that data is updated with another version, the data
  will be converted to UTC since these timezones are not considered
  equal.  Either use the same version of timezone library or use ``tz_convert`` with
  the updated timezone definition.

.. warning::

   ``PyTables`` will show a ``NaturalNameWarning`` if a  column name
   cannot be used as an attribute selector.
   *Natural* identifiers contain only letters, numbers, and underscores,
   and may not begin with a number.
   Other identifiers cannot be used in a ``where`` clause
   and are generally a bad idea.

.. _io.hdf5-data_types:

DataTypes
'''''''''

``HDFStore`` will map an object dtype to the ``PyTables`` underlying
dtype. This means the following types are known to work:

======================================================  =========================
Type                                                    Represents missing values
======================================================  =========================
floating : ``float64, float32, float16``                ``np.nan``
integer : ``int64, int32, int8, uint64,uint32, uint8``
boolean
``datetime64[ns]``                                      ``NaT``
``timedelta64[ns]``                                     ``NaT``
categorical : see the section below
object : ``strings``                                    ``np.nan``
======================================================  =========================

``unicode`` columns are not supported, and **WILL FAIL**.

.. _io.hdf5-categorical:

Categorical Data
++++++++++++++++

.. versionadded:: 0.15.2

Writing data to a ``HDFStore`` that contains a ``category`` dtype was implemented
in 0.15.2. Queries work the same as if it was an object array. However, the ``category`` dtyped data is
stored in a more efficient manner.

.. ipython:: python

   dfcat = pd.DataFrame({ 'A' : pd.Series(list('aabbcdba')).astype('category'),
                          'B' : np.random.randn(8) })
   dfcat
   dfcat.dtypes
   cstore = pd.HDFStore('cats.h5', mode='w')
   cstore.append('dfcat', dfcat, format='table', data_columns=['A'])
   result = cstore.select('dfcat', where="A in ['b','c']")
   result
   result.dtypes

.. warning::

   The format of the ``Categorical`` is readable by prior versions of pandas (< 0.15.2), but will retrieve
   the data as an integer based column (e.g. the ``codes``). However, the ``categories`` *can* be retrieved
   but require the user to select them manually using the explicit meta path.

   The data is stored like so:

   .. ipython:: python

      cstore

      # to get the categories
      cstore.select('dfcat/meta/A/meta')

.. ipython:: python
   :suppress:
   :okexcept:

   cstore.close()
   import os
   os.remove('cats.h5')


String Columns
++++++++++++++

**min_itemsize**

The underlying implementation of ``HDFStore`` uses a fixed column width (itemsize) for string columns.
A string column itemsize is calculated as the maximum of the
length of data (for that column) that is passed to the ``HDFStore``, **in the first append**. Subsequent appends,
may introduce a string for a column **larger** than the column can hold, an Exception will be raised (otherwise you
could have a silent truncation of these columns, leading to loss of information). In the future we may relax this and
allow a user-specified truncation to occur.

Pass ``min_itemsize`` on the first table creation to a-priori specify the minimum length of a particular string column.
``min_itemsize`` can be an integer, or a dict mapping a column name to an integer. You can pass ``values`` as a key to
allow all *indexables* or *data_columns* to have this min_itemsize.

Starting in 0.11.0, passing a ``min_itemsize`` dict will cause all passed columns to be created as *data_columns* automatically.

.. note::

   If you are not passing any ``data_columns``, then the ``min_itemsize`` will be the maximum of the length of any string passed

.. ipython:: python

   dfs = pd.DataFrame(dict(A = 'foo', B = 'bar'),index=list(range(5)))
   dfs

   # A and B have a size of 30
   store.append('dfs', dfs, min_itemsize = 30)
   store.get_storer('dfs').table

   # A is created as a data_column with a size of 30
   # B is size is calculated
   store.append('dfs2', dfs, min_itemsize = { 'A' : 30 })
   store.get_storer('dfs2').table

**nan_rep**

String columns will serialize a ``np.nan`` (a missing value) with the ``nan_rep`` string representation. This defaults to the string value ``nan``.
You could inadvertently turn an actual ``nan`` value into a missing value.

.. ipython:: python

   dfss = pd.DataFrame(dict(A = ['foo','bar','nan']))
   dfss

   store.append('dfss', dfss)
   store.select('dfss')

   # here you need to specify a different nan rep
   store.append('dfss2', dfss, nan_rep='_nan_')
   store.select('dfss2')

.. _io.external_compatibility:

External Compatibility
''''''''''''''''''''''

``HDFStore`` writes ``table`` format objects in specific formats suitable for
producing loss-less round trips to pandas objects. For external
compatibility, ``HDFStore`` can read native ``PyTables`` format
tables.

It is possible to write an ``HDFStore`` object that can easily be imported into ``R`` using the
``rhdf5`` library (`Package website`_). Create a table format store like this:

.. _package website: http://www.bioconductor.org/packages/release/bioc/html/rhdf5.html

.. ipython:: python

   np.random.seed(1)
   df_for_r = pd.DataFrame({"first": np.random.rand(100),
                            "second": np.random.rand(100),
                            "class": np.random.randint(0, 2, (100,))},
                            index=range(100))
   df_for_r.head()

   store_export = pd.HDFStore('export.h5')
   store_export.append('df_for_r', df_for_r, data_columns=df_dc.columns)
   store_export

.. ipython:: python
   :suppress:

   store_export.close()
   import os
   os.remove('export.h5')

In R this file can be read into a ``data.frame`` object using the ``rhdf5``
library. The following example function reads the corresponding column names
and data values from the values and assembles them into a ``data.frame``:

.. code-block:: R

   # Load values and column names for all datasets from corresponding nodes and
   # insert them into one data.frame object.

   library(rhdf5)

   loadhdf5data <- function(h5File) {

   listing <- h5ls(h5File)
   # Find all data nodes, values are stored in *_values and corresponding column
   # titles in *_items
   data_nodes <- grep("_values", listing$name)
   name_nodes <- grep("_items", listing$name)
   data_paths = paste(listing$group[data_nodes], listing$name[data_nodes], sep = "/")
   name_paths = paste(listing$group[name_nodes], listing$name[name_nodes], sep = "/")
   columns = list()
   for (idx in seq(data_paths)) {
     # NOTE: matrices returned by h5read have to be transposed to to obtain
     # required Fortran order!
     data <- data.frame(t(h5read(h5File, data_paths[idx])))
     names <- t(h5read(h5File, name_paths[idx]))
     entry <- data.frame(data)
     colnames(entry) <- names
     columns <- append(columns, entry)
   }

   data <- data.frame(columns)

   return(data)
   }

Now you can import the ``DataFrame`` into R:

.. code-block:: R

   > data = loadhdf5data("transfer.hdf5")
   > head(data)
            first    second class
   1 0.4170220047 0.3266449     0
   2 0.7203244934 0.5270581     0
   3 0.0001143748 0.8859421     1
   4 0.3023325726 0.3572698     1
   5 0.1467558908 0.9085352     1
   6 0.0923385948 0.6233601     1

.. note::
   The R function lists the entire HDF5 file's contents and assembles the
   ``data.frame`` object from all matching nodes, so use this only as a
   starting point if you have stored multiple ``DataFrame`` objects to a
   single HDF5 file.

Backwards Compatibility
'''''''''''''''''''''''

0.10.1 of ``HDFStore`` can read tables created in a prior version of pandas,
however query terms using the
prior (undocumented) methodology are unsupported. ``HDFStore`` will
issue a warning if you try to use a legacy-format file. You must
read in the entire file and write it out using the new format, using the
method ``copy`` to take advantage of the updates. The group attribute
``pandas_version`` contains the version information. ``copy`` takes a
number of options, please see the docstring.


.. ipython:: python

   import os
   legacy_file_path = os.path.abspath('source/_static/legacy_0.10.h5')

.. ipython:: python
   :okwarning:

   # a legacy store
   legacy_store = pd.HDFStore(legacy_file_path,'r')
   legacy_store

   # copy (and return the new handle)
   new_store = legacy_store.copy('store_new.h5')
   new_store
   new_store.close()

.. ipython:: python
   :suppress:

   legacy_store.close()
   import os
   os.remove('store_new.h5')


Performance
'''''''''''

- ``tables`` format come with a writing performance penalty as compared to
  ``fixed`` stores. The benefit is the ability to append/delete and
  query (potentially very large amounts of data).  Write times are
  generally longer as compared with regular stores. Query times can
  be quite fast, especially on an indexed axis.
- You can pass ``chunksize=<int>`` to ``append``, specifying the
  write chunksize (default is 50000). This will significantly lower
  your memory usage on writing.
- You can pass ``expectedrows=<int>`` to the first ``append``,
  to set the TOTAL number of expected rows that ``PyTables`` will
  expected. This will optimize read/write performance.
- Duplicate rows can be written to tables, but are filtered out in
  selection (with the last items being selected; thus a table is
  unique on major, minor pairs)
- A ``PerformanceWarning`` will be raised if you are attempting to
  store types that will be pickled by PyTables (rather than stored as
  endemic types). See
  `Here <http://stackoverflow.com/questions/14355151/how-to-make-pandas-hdfstore-put-operation-faster/14370190#14370190>`__
  for more information and some solutions.

Experimental
''''''''''''

HDFStore supports ``Panel4D`` storage.

.. ipython:: python
   :okwarning:

   p4d = pd.Panel4D({ 'l1' : wp })
   p4d
   store.append('p4d', p4d)
   store

These, by default, index the three axes ``items, major_axis,
minor_axis``. On an ``AppendableTable`` it is possible to setup with the
first append a different indexing scheme, depending on how you want to
store your data. Pass the ``axes`` keyword with a list of dimensions
(currently must by exactly 1 less than the total dimensions of the
object). This cannot be changed after table creation.

.. ipython:: python
   :okwarning:

   store.append('p4d2', p4d, axes=['labels', 'major_axis', 'minor_axis'])
   store
   store.select('p4d2', [ pd.Term('labels=l1'), pd.Term('items=Item1'), pd.Term('minor_axis=A_big_strings') ])

.. ipython:: python
   :suppress:

   store.close()
   import os
   os.remove('store.h5')
