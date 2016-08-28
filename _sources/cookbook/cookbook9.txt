.. ipython:: python
   :suppress:
   
   import pandas as pd
   import numpy as np

   import random
   import os
   import itertools
   import functools
   import datetime

   np.random.seed(123456)
   pd.options.display.max_rows=8
   import matplotlib
   matplotlib.style.use('ggplot')
   np.set_printoptions(precision=4, suppress=True)

Data In/Out
-----------

`Performance comparison of SQL vs HDF5
<http://stackoverflow.com/questions/16628329/hdf5-and-sqlite-concurrency-compression-i-o-performance>`__

.. _cookbook.csv:

CSV
***

The :ref:`CSV <io.read_csv_table>` docs

`read_csv in action <http://wesmckinney.com/blog/?p=635>`__

`appending to a csv
<http://stackoverflow.com/questions/17134942/pandas-dataframe-output-end-of-csv>`__

`how to read in multiple files, appending to create a single dataframe
<http://stackoverflow.com/questions/25210819/speeding-up-data-import-function-pandas-and-appending-to-dataframe/25210900#25210900>`__

`Reading a csv chunk-by-chunk
<http://stackoverflow.com/questions/11622652/large-persistent-dataframe-in-pandas/12193309#12193309>`__

`Reading only certain rows of a csv chunk-by-chunk
<http://stackoverflow.com/questions/19674212/pandas-data-frame-select-rows-and-clear-memory>`__

`Reading the first few lines of a frame
<http://stackoverflow.com/questions/15008970/way-to-read-first-few-lines-for-pandas-dataframe>`__

Reading a file that is compressed but not by ``gzip/bz2`` (the native compressed formats which ``read_csv`` understands).
This example shows a ``WinZipped`` file, but is a general application of opening the file within a context manager and
using that handle to read.
`See here
<http://stackoverflow.com/questions/17789907/pandas-convert-winzipped-csv-file-to-data-frame>`__

`Inferring dtypes from a file
<http://stackoverflow.com/questions/15555005/get-inferred-dataframe-types-iteratively-using-chunksize>`__

`Dealing with bad lines
<http://github.com/pydata/pandas/issues/2886>`__

`Dealing with bad lines II
<http://nipunbatra.github.io/2013/06/reading-unclean-data-csv-using-pandas/>`__

`Reading CSV with Unix timestamps and converting to local timezone
<http://nipunbatra.github.io/2013/06/pandas-reading-csv-with-unix-timestamps-and-converting-to-local-timezone/>`__

`Write a multi-row index CSV without writing duplicates
<http://stackoverflow.com/questions/17349574/pandas-write-multiindex-rows-with-to-csv>`__

Parsing date components in multi-columns is faster with a format

.. code-block:: python

    In [30]: i = pd.date_range('20000101',periods=10000)

    In [31]: df = pd.DataFrame(dict(year = i.year, month = i.month, day = i.day))

    In [32]: df.head()
    Out[32]:
       day  month  year
    0    1      1  2000
    1    2      1  2000
    2    3      1  2000
    3    4      1  2000
    4    5      1  2000

    In [33]: %timeit pd.to_datetime(df.year*10000+df.month*100+df.day,format='%Y%m%d')
    100 loops, best of 3: 7.08 ms per loop

    # simulate combinging into a string, then parsing
    In [34]: ds = df.apply(lambda x: "%04d%02d%02d" % (x['year'],x['month'],x['day']),axis=1)

    In [35]: ds.head()
    Out[35]:
    0    20000101
    1    20000102
    2    20000103
    3    20000104
    4    20000105
    dtype: object

    In [36]: %timeit pd.to_datetime(ds)
    1 loops, best of 3: 488 ms per loop

Skip row between header and data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. ipython:: python

    from io import StringIO
    import pandas as pd

    data = """;;;;
     ;;;;
     ;;;;
     ;;;;
     ;;;;
     ;;;;
    ;;;;
     ;;;;
     ;;;;
    ;;;;
    date;Param1;Param2;Param4;Param5
        ;m;C;m;m
    ;;;;
    01.01.1990 00:00;1;1;2;3
    01.01.1990 01:00;5;3;4;5
    01.01.1990 02:00;9;5;6;7
    01.01.1990 03:00;13;7;8;9
    01.01.1990 04:00;17;9;10;11
    01.01.1990 05:00;21;11;12;13
    """

Option 1: pass rows explicitly to skiprows
""""""""""""""""""""""""""""""""""""""""""

.. ipython:: python

    pd.read_csv(StringIO(data.decode('UTF-8')), sep=';', skiprows=[11,12],
            index_col=0, parse_dates=True, header=10)

Option 2: read column names and then data
"""""""""""""""""""""""""""""""""""""""""

.. ipython:: python

    pd.read_csv(StringIO(data.decode('UTF-8')), sep=';',
            header=10, parse_dates=True, nrows=10).columns
    columns = pd.read_csv(StringIO(data.decode('UTF-8')), sep=';',
                      header=10, parse_dates=True, nrows=10).columns
    pd.read_csv(StringIO(data.decode('UTF-8')), sep=';',
                header=12, parse_dates=True, names=columns)



.. _cookbook.sql:

SQL
***

The :ref:`SQL <io.sql>` docs

`Reading from databases with SQL
<http://stackoverflow.com/questions/10065051/python-pandas-and-databases-like-mysql>`__

.. _cookbook.excel:

Excel
*****

The :ref:`Excel <io.excel>` docs

`Reading from a filelike handle
<http://stackoverflow.com/questions/15588713/sheets-of-excel-workbook-from-a-url-into-a-pandas-dataframe>`__

`Modifying formatting in XlsxWriter output
<http://pbpython.com/improve-pandas-excel-output.html>`__

.. _cookbook.html:

HTML
****

`Reading HTML tables from a server that cannot handle the default request
header <http://stackoverflow.com/a/18939272/564538>`__

.. _cookbook.hdf:

HDFStore
********

The :ref:`HDFStores <io.hdf5>` docs

`Simple Queries with a Timestamp Index
<http://stackoverflow.com/questions/13926089/selecting-columns-from-pandas-hdfstore-table>`__

`Managing heterogeneous data using a linked multiple table hierarchy
<http://github.com/pydata/pandas/issues/3032>`__

`Merging on-disk tables with millions of rows
<http://stackoverflow.com/questions/14614512/merging-two-tables-with-millions-of-rows-in-python/14617925#14617925>`__

`Avoiding inconsistencies when writing to a store from multiple processes/threads
<http://stackoverflow.com/a/29014295/2858145>`__

De-duplicating a large store by chunks, essentially a recursive reduction operation. Shows a function for taking in data from
csv file and creating a store by chunks, with date parsing as well.
`See here
<http://stackoverflow.com/questions/16110252/need-to-compare-very-large-files-around-1-5gb-in-python/16110391#16110391>`__

`Creating a store chunk-by-chunk from a csv file
<http://stackoverflow.com/questions/20428355/appending-column-to-frame-of-hdf-file-in-pandas/20428786#20428786>`__

`Appending to a store, while creating a unique index
<http://stackoverflow.com/questions/16997048/how-does-one-append-large-amounts-of-data-to-a-pandas-hdfstore-and-get-a-natural/16999397#16999397>`__

`Large Data work flows
<http://stackoverflow.com/questions/14262433/large-data-work-flows-using-pandas>`__

`Reading in a sequence of files, then providing a global unique index to a store while appending
<http://stackoverflow.com/questions/16997048/how-does-one-append-large-amounts-of-data-to-a-pandas-hdfstore-and-get-a-natural>`__

`Groupby on a HDFStore with low group density
<http://stackoverflow.com/questions/15798209/pandas-group-by-query-on-large-data-in-hdfstore>`__

`Groupby on a HDFStore with high group density
<http://stackoverflow.com/questions/25459982/trouble-with-grouby-on-millions-of-keys-on-a-chunked-file-in-python-pandas/25471765#25471765>`__

`Hierarchical queries on a HDFStore
<http://stackoverflow.com/questions/22777284/improve-query-performance-from-a-large-hdfstore-table-with-pandas/22820780#22820780>`__

`Counting with a HDFStore
<http://stackoverflow.com/questions/20497897/converting-dict-of-dicts-into-pandas-dataframe-memory-issues>`__

`Troubleshoot HDFStore exceptions
<http://stackoverflow.com/questions/15488809/how-to-trouble-shoot-hdfstore-exception-cannot-find-the-correct-atom-type>`__

`Setting min_itemsize with strings
<http://stackoverflow.com/questions/15988871/hdfstore-appendstring-dataframe-fails-when-string-column-contents-are-longer>`__

`Using ptrepack to create a completely-sorted-index on a store
<http://stackoverflow.com/questions/17893370/ptrepack-sortby-needs-full-index>`__

Storing Attributes to a group node

.. ipython:: python

   df = pd.DataFrame(np.random.randn(8,3))
   store = pd.HDFStore('test.h5')
   store.put('df',df)

   # you can store an arbitrary python object via pickle
   store.get_storer('df').attrs.my_attribute = dict(A = 10)
   store.get_storer('df').attrs.my_attribute

.. ipython:: python
   :suppress:

   store.close()
   os.remove('test.h5')

.. _cookbook.binary:

Binary Files
************

pandas readily accepts numpy record arrays, if you need to read in a binary
file consisting of an array of C structs. For example, given this C program
in a file called ``main.c`` compiled with ``gcc main.c -std=gnu99`` on a
64-bit machine,

.. code-block:: c

   #include <stdio.h>
   #include <stdint.h>

   typedef struct _Data
   {
       int32_t count;
       double avg;
       float scale;
   } Data;

   int main(int argc, const char *argv[])
   {
       size_t n = 10;
       Data d[n];

       for (int i = 0; i < n; ++i)
       {
           d[i].count = i;
           d[i].avg = i + 1.0;
           d[i].scale = (float) i + 2.0f;
       }

       FILE *file = fopen("binary.dat", "wb");
       fwrite(&d, sizeof(Data), n, file);
       fclose(file);

       return 0;
   }

the following Python code will read the binary file ``'binary.dat'`` into a
pandas ``DataFrame``, where each element of the struct corresponds to a column
in the frame:

.. code-block:: python

   names = 'count', 'avg', 'scale'

   # note that the offsets are larger than the size of the type because of
   # struct padding
   offsets = 0, 8, 16
   formats = 'i4', 'f8', 'f4'
   dt = np.dtype({'names': names, 'offsets': offsets, 'formats': formats},
                 align=True)
   df = pd.DataFrame(np.fromfile('binary.dat', dt))

.. note::

   The offsets of the structure elements may be different depending on the
   architecture of the machine on which the file was created. Using a raw
   binary file format like this for general data storage is not recommended, as
   it is not cross platform. We recommended either HDF5 or msgpack, both of
   which are supported by pandas' IO facilities.