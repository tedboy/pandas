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

.. _io.read_csv_table:

CSV & Text files
----------------

The two workhorse functions for reading text files (a.k.a. flat files) are
:func:`read_csv` and :func:`read_table`. They both use the same parsing code to
intelligently convert tabular data into a DataFrame object. See the
:ref:`cookbook<cookbook.csv>` for some advanced strategies.

Parsing options
'''''''''''''''

:func:`read_csv` and :func:`read_table` accept the following arguments:

Basic
+++++

filepath_or_buffer : various
  Either a path to a file (a :class:`python:str`, :class:`python:pathlib.Path`,
  or :class:`py:py._path.local.LocalPath`), URL (including http, ftp, and S3
  locations), or any object with a ``read()`` method (such as an open file or
  :class:`~python:io.StringIO`).
sep : str, defaults to ``','`` for :func:`read_csv`, ``\t`` for :func:`read_table`
  Delimiter to use. If sep is ``None``,
  will try to automatically determine this. Separators longer than 1 character
  and different from ``'\s+'`` will be interpreted as regular expressions, will
  force use of the python parsing engine and will ignore quotes in the data.
  Regex example: ``'\\r\\t'``.
delimiter : str, default ``None``
  Alternative argument name for sep.
delim_whitespace : boolean, default False
  Specifies whether or not whitespace (e.g. ``' '`` or ``'\t'``)
  will be used as the delimiter. Equivalent to setting ``sep='\s+'``.
  If this option is set to True, nothing should be passed in for the
  ``delimiter`` parameter.

  .. versionadded:: 0.18.1 support for the Python parser.

Column and Index Locations and Names
++++++++++++++++++++++++++++++++++++

header : int or list of ints, default ``'infer'``
  Row number(s) to use as the column names, and the start of the data. Default
  behavior is as if ``header=0`` if no ``names`` passed, otherwise as if
  ``header=None``. Explicitly pass ``header=0`` to be able to replace existing
  names. The header can be a list of ints that specify row locations for a
  multi-index on the columns e.g. ``[0,1,3]``. Intervening rows that are not
  specified will be skipped (e.g. 2 in this example is skipped). Note that
  this parameter ignores commented lines and empty lines if
  ``skip_blank_lines=True``, so header=0 denotes the first line of data
  rather than the first line of the file.
names : array-like, default ``None``
  List of column names to use. If file contains no header row, then you should
  explicitly pass ``header=None``. Duplicates in this list are not allowed unless
  ``mangle_dupe_cols=True``, which is the default.
index_col :  int or sequence or ``False``, default ``None``
  Column to use as the row labels of the DataFrame. If a sequence is given, a
  MultiIndex is used. If you have a malformed file with delimiters at the end of
  each line, you might consider ``index_col=False`` to force pandas to *not* use
  the first column as the index (row names).
usecols : array-like, default ``None``
  Return a subset of the columns. All elements in this array must either
  be positional (i.e. integer indices into the document columns) or strings
  that correspond to column names provided either by the user in `names` or
  inferred from the document header row(s). For example, a valid `usecols`
  parameter would be [0, 1, 2] or ['foo', 'bar', 'baz']. Using this parameter
  results in much faster parsing time and lower memory usage.
as_recarray : boolean, default ``False``
  DEPRECATED: this argument will be removed in a future version. Please call
  ``pd.read_csv(...).to_records()`` instead.

  Return a NumPy recarray instead of a DataFrame after parsing the data. If
  set to ``True``, this option takes precedence over the ``squeeze`` parameter.
  In addition, as row indices are not available in such a format, the ``index_col``
  parameter will be ignored.
squeeze : boolean, default ``False``
  If the parsed data only contains one column then return a Series.
prefix : str, default ``None``
  Prefix to add to column numbers when no header, e.g. 'X' for X0, X1, ...
mangle_dupe_cols : boolean, default ``True``
  Duplicate columns will be specified as 'X.0'...'X.N', rather than 'X'...'X'.
  Passing in False will cause data to be overwritten if there are duplicate
  names in the columns.

General Parsing Configuration
+++++++++++++++++++++++++++++

dtype : Type name or dict of column -> type, default ``None``
  Data type for data or columns. E.g. ``{'a': np.float64, 'b': np.int32}``
  (unsupported with ``engine='python'``). Use `str` or `object` to preserve and
  not interpret dtype.
engine : {``'c'``, ``'python'``}
  Parser engine to use. The C engine is faster while the python engine is
  currently more feature-complete.
converters : dict, default ``None``
  Dict of functions for converting values in certain columns. Keys can either be
  integers or column labels.
true_values : list, default ``None``
  Values to consider as ``True``.
false_values : list, default ``None``
  Values to consider as ``False``.
skipinitialspace : boolean, default ``False``
  Skip spaces after delimiter.
skiprows : list-like or integer, default ``None``
  Line numbers to skip (0-indexed) or number of lines to skip (int) at the start
  of the file.
skipfooter : int, default ``0``
  Number of lines at bottom of file to skip (unsupported with engine='c').
skip_footer : int, default ``0``
  DEPRECATED: use the ``skipfooter`` parameter instead, as they are identical
nrows : int, default ``None``
  Number of rows of file to read. Useful for reading pieces of large files.
low_memory : boolean, default ``True``
  Internally process the file in chunks, resulting in lower memory use
  while parsing, but possibly mixed type inference.  To ensure no mixed
  types either set ``False``, or specify the type with the ``dtype`` parameter.
  Note that the entire file is read into a single DataFrame regardless,
  use the ``chunksize`` or ``iterator`` parameter to return the data in chunks.
  (Only valid with C parser)
buffer_lines : int, default None
    DEPRECATED: this argument will be removed in a future version because its
    value is not respected by the parser
compact_ints : boolean, default False
  DEPRECATED: this argument will be removed in a future version

  If ``compact_ints`` is ``True``, then for any column that is of integer dtype, the
  parser will attempt to cast it as the smallest integer ``dtype`` possible, either
  signed or unsigned depending on the specification from the ``use_unsigned`` parameter.
use_unsigned : boolean, default False
  DEPRECATED: this argument will be removed in a future version

  If integer columns are being compacted (i.e. ``compact_ints=True``), specify whether
  the column should be compacted to the smallest signed or unsigned integer dtype.
memory_map : boolean, default False
  If a filepath is provided for ``filepath_or_buffer``, map the file object
  directly onto memory and access the data directly from there. Using this
  option can improve performance because there is no longer any I/O overhead.

NA and Missing Data Handling
++++++++++++++++++++++++++++

na_values : scalar, str, list-like, or dict, default ``None``
  Additional strings to recognize as NA/NaN. If dict passed, specific per-column
  NA values. By default the following values are interpreted as NaN:
  ``'-1.#IND', '1.#QNAN', '1.#IND', '-1.#QNAN', '#N/A N/A', '#N/A', 'N/A', 'NA',
  '#NA', 'NULL', 'NaN', '-NaN', 'nan', '-nan', ''``.
keep_default_na : boolean, default ``True``
  If na_values are specified and keep_default_na is ``False`` the default NaN
  values are overridden, otherwise they're appended to.
na_filter : boolean, default ``True``
  Detect missing value markers (empty strings and the value of na_values). In
  data without any NAs, passing ``na_filter=False`` can improve the performance
  of reading a large file.
verbose : boolean, default ``False``
  Indicate number of NA values placed in non-numeric columns.
skip_blank_lines : boolean, default ``True``
  If ``True``, skip over blank lines rather than interpreting as NaN values.

Datetime Handling
+++++++++++++++++

parse_dates : boolean or list of ints or names or list of lists or dict, default ``False``.
  - If ``True`` -> try parsing the index.
  - If ``[1, 2, 3]`` ->  try parsing columns 1, 2, 3 each as a separate date
    column.
  - If ``[[1, 3]]`` -> combine columns 1 and 3 and parse as a single date
    column.
  - If ``{'foo' : [1, 3]}`` -> parse columns 1, 3 as date and call result 'foo'.
    A fast-path exists for iso8601-formatted dates.
infer_datetime_format : boolean, default ``False``
  If ``True`` and parse_dates is enabled for a column, attempt to infer the
  datetime format to speed up the processing.
keep_date_col : boolean, default ``False``
  If ``True`` and parse_dates specifies combining multiple columns then keep the
  original columns.
date_parser : function, default ``None``
  Function to use for converting a sequence of string columns to an array of
  datetime instances. The default uses ``dateutil.parser.parser`` to do the
  conversion. Pandas will try to call date_parser in three different ways,
  advancing to the next if an exception occurs: 1) Pass one or more arrays (as
  defined by parse_dates) as arguments; 2) concatenate (row-wise) the string
  values from the columns defined by parse_dates into a single array and pass
  that; and 3) call date_parser once for each row using one or more strings
  (corresponding to the columns defined by parse_dates) as arguments.
dayfirst : boolean, default ``False``
  DD/MM format dates, international and European format.

Iteration
+++++++++

iterator : boolean, default ``False``
  Return `TextFileReader` object for iteration or getting chunks with
  ``get_chunk()``.
chunksize : int, default ``None``
  Return `TextFileReader` object for iteration. See :ref:`iterating and chunking
  <io.chunking>` below.

Quoting, Compression, and File Format
+++++++++++++++++++++++++++++++++++++

compression : {``'infer'``, ``'gzip'``, ``'bz2'``, ``'zip'``, ``'xz'``, ``None``}, default ``'infer'``
  For on-the-fly decompression of on-disk data. If 'infer', then use gzip,
  bz2, zip, or xz if filepath_or_buffer is a string ending in '.gz', '.bz2',
  '.zip', or '.xz', respectively, and no decompression otherwise. If using 'zip',
  the ZIP file must contain only one data file to be read in.
  Set to ``None`` for no decompression.

  .. versionadded:: 0.18.1 support for 'zip' and 'xz' compression.

thousands : str, default ``None``
  Thousands separator.
decimal : str, default ``'.'``
  Character to recognize as decimal point. E.g. use ``','`` for European data.
float_precision : string, default None
  Specifies which converter the C engine should use for floating-point values.
  The options are ``None`` for the ordinary converter, ``high`` for the
  high-precision converter, and ``round_trip`` for the round-trip converter.
lineterminator : str (length 1), default ``None``
  Character to break file into lines. Only valid with C parser.
quotechar : str (length 1)
  The character used to denote the start and end of a quoted item. Quoted items
  can include the delimiter and it will be ignored.
quoting : int or ``csv.QUOTE_*`` instance, default ``0``
  Control field quoting behavior per ``csv.QUOTE_*`` constants. Use one of
  ``QUOTE_MINIMAL`` (0), ``QUOTE_ALL`` (1), ``QUOTE_NONNUMERIC`` (2) or
  ``QUOTE_NONE`` (3).
doublequote : boolean, default ``True``
   When ``quotechar`` is specified and ``quoting`` is not ``QUOTE_NONE``,
   indicate whether or not to interpret two consecutive ``quotechar`` elements
   **inside** a field as a single ``quotechar`` element.
escapechar : str (length 1), default ``None``
  One-character string used to escape delimiter when quoting is ``QUOTE_NONE``.
comment : str, default ``None``
  Indicates remainder of line should not be parsed. If found at the beginning of
  a line, the line will be ignored altogether. This parameter must be a single
  character. Like empty lines (as long as ``skip_blank_lines=True``), fully
  commented lines are ignored by the parameter `header` but not by `skiprows`.
  For example, if ``comment='#'``, parsing '#empty\\na,b,c\\n1,2,3' with
  `header=0` will result in 'a,b,c' being treated as the header.
encoding : str, default ``None``
  Encoding to use for UTF when reading/writing (e.g. ``'utf-8'``). `List of
  Python standard encodings
  <https://docs.python.org/3/library/codecs.html#standard-encodings>`_.
dialect : str or :class:`python:csv.Dialect` instance, default ``None``
  If ``None`` defaults to Excel dialect. Ignored if sep longer than 1 char. See
  :class:`python:csv.Dialect` documentation for more details.
tupleize_cols : boolean, default ``False``
  Leave a list of tuples on columns as is (default is to convert to a MultiIndex
  on the columns).  

Error Handling
++++++++++++++

error_bad_lines : boolean, default ``True``
  Lines with too many fields (e.g. a csv line with too many commas) will by
  default cause an exception to be raised, and no DataFrame will be returned. If
  ``False``, then these "bad lines" will dropped from the DataFrame that is
  returned (only valid with C parser). See :ref:`bad lines <io.bad_lines>`
  below.
warn_bad_lines : boolean, default ``True``
  If error_bad_lines is ``False``, and warn_bad_lines is ``True``, a warning for
  each "bad line" will be output (only valid with C parser).

.. ipython:: python
   :suppress:

   f = open('foo.csv','w')
   f.write('date,A,B,C\n20090101,a,1,2\n20090102,b,3,4\n20090103,c,4,5')
   f.close()

Consider a typical CSV file containing, in this case, some time series data:

.. ipython:: python

   print(open('foo.csv').read())

The default for `read_csv` is to create a DataFrame with simple numbered rows:

.. ipython:: python

   pd.read_csv('foo.csv')

In the case of indexed data, you can pass the column number or column name you
wish to use as the index:

.. ipython:: python

   pd.read_csv('foo.csv', index_col=0)

.. ipython:: python

   pd.read_csv('foo.csv', index_col='date')

You can also use a list of columns to create a hierarchical index:

.. ipython:: python

   pd.read_csv('foo.csv', index_col=[0, 'A'])

.. _io.dialect:

The ``dialect`` keyword gives greater flexibility in specifying the file format.
By default it uses the Excel dialect but you can specify either the dialect name
or a :class:`python:csv.Dialect` instance.

.. ipython:: python
   :suppress:

   data = ('label1,label2,label3\n'
           'index1,"a,c,e\n'
           'index2,b,d,f')

Suppose you had data with unenclosed quotes:

.. ipython:: python

   print(data)

By default, ``read_csv`` uses the Excel dialect and treats the double quote as
the quote character, which causes it to fail when it finds a newline before it
finds the closing double quote.

We can get around this using ``dialect``

.. ipython:: python

   dia = csv.excel()
   dia.quoting = csv.QUOTE_NONE
   pd.read_csv(StringIO(data), dialect=dia)

All of the dialect options can be specified separately by keyword arguments:

.. ipython:: python

    data = 'a,b,c~1,2,3~4,5,6'
    pd.read_csv(StringIO(data), lineterminator='~')

Another common dialect option is ``skipinitialspace``, to skip any whitespace
after a delimiter:

.. ipython:: python

   data = 'a, b, c\n1, 2, 3\n4, 5, 6'
   print(data)
   pd.read_csv(StringIO(data), skipinitialspace=True)

The parsers make every attempt to "do the right thing" and not be very
fragile. Type inference is a pretty big deal. So if a column can be coerced to
integer dtype without altering the contents, it will do so. Any non-numeric
columns will come through as object dtype as with the rest of pandas objects.  


.. _io.dtypes:

Specifying column data types
''''''''''''''''''''''''''''

Starting with v0.10, you can indicate the data type for the whole DataFrame or
individual columns:

.. ipython:: python

    data = 'a,b,c\n1,2,3\n4,5,6\n7,8,9'
    print(data)

    df = pd.read_csv(StringIO(data), dtype=object)
    df
    df['a'][0]
    df = pd.read_csv(StringIO(data), dtype={'b': object, 'c': np.float64})
    df.dtypes

Fortunately, ``pandas`` offers more than one way to ensure that your column(s)
contain only one ``dtype``. If you're unfamiliar with these concepts, you can
see :ref:`here<basics.dtypes>` to learn more about dtypes, and
:ref:`here<basics.object_conversion>` to learn more about ``object`` conversion in
``pandas``.


For instance, you can use the ``converters`` argument
of :func:`~pandas.read_csv`:

.. ipython:: python

    data = "col_1\n1\n2\n'A'\n4.22"
    df = pd.read_csv(StringIO(data), converters={'col_1':str})
    df
    df['col_1'].apply(type).value_counts()

Or you can use the :func:`~pandas.to_numeric` function to coerce the
dtypes after reading in the data,

.. ipython:: python

    df2 = pd.read_csv(StringIO(data))
    df2['col_1'] = pd.to_numeric(df2['col_1'], errors='coerce')
    df2
    df2['col_1'].apply(type).value_counts()

which would convert all valid parsing to floats, leaving the invalid parsing
as ``NaN``.

Ultimately, how you deal with reading in columns containing mixed dtypes
depends on your specific needs. In the case above, if you wanted to ``NaN`` out
the data anomalies, then :func:`~pandas.to_numeric` is probably your best option.
However, if you wanted for all the data to be coerced, no matter the type, then
using the ``converters`` argument of :func:`~pandas.read_csv` would certainly be
worth trying.

.. note::
    The ``dtype`` option is currently only supported by the C engine.
    Specifying ``dtype`` with ``engine`` other than 'c' raises a
    ``ValueError``.

.. note::
   In some cases, reading in abnormal data with columns containing mixed dtypes
   will result in an inconsistent dataset. If you rely on pandas to infer the
   dtypes of your columns, the parsing engine will go and infer the dtypes for
   different chunks of the data, rather than the whole dataset at once. Consequently,
   you can end up with column(s) with mixed dtypes. For example,

   .. ipython:: python
        :okwarning:

        df = pd.DataFrame({'col_1':range(500000) + ['a', 'b'] + range(500000)})
        df.to_csv('foo')
        mixed_df = pd.read_csv('foo')
        mixed_df['col_1'].apply(type).value_counts()
        mixed_df['col_1'].dtype

   will result with `mixed_df` containing an ``int`` dtype for certain chunks
   of the column, and ``str`` for others due to the mixed dtypes from the
   data that was read in. It is important to note that the overall column will be
   marked with a ``dtype`` of ``object``, which is used for columns with mixed dtypes.


Naming and Using Columns
''''''''''''''''''''''''

.. _io.headers:

Handling column names
+++++++++++++++++++++

A file may or may not have a header row. pandas assumes the first row should be
used as the column names:

.. ipython:: python

    data = 'a,b,c\n1,2,3\n4,5,6\n7,8,9'
    print(data)
    pd.read_csv(StringIO(data))

By specifying the ``names`` argument in conjunction with ``header`` you can
indicate other names to use and whether or not to throw away the header row (if
any):

.. ipython:: python

    print(data)
    pd.read_csv(StringIO(data), names=['foo', 'bar', 'baz'], header=0)
    pd.read_csv(StringIO(data), names=['foo', 'bar', 'baz'], header=None)

If the header is in a row other than the first, pass the row number to
``header``. This will skip the preceding rows:

.. ipython:: python

    data = 'skip this skip it\na,b,c\n1,2,3\n4,5,6\n7,8,9'
    pd.read_csv(StringIO(data), header=1)

.. _io.dupe_names:

Duplicate names parsing
'''''''''''''''''''''''

If the file or header contains duplicate names, pandas by default will deduplicate
these names so as to prevent data overwrite:

.. ipython :: python

   data = 'a,b,a\n0,1,2\n3,4,5'
   pd.read_csv(StringIO(data))

There is no more duplicate data because ``mangle_dupe_cols=True`` by default, which modifies
a series of duplicate columns 'X'...'X' to become 'X.0'...'X.N'.  If ``mangle_dupe_cols
=False``, duplicate data can arise:

.. code-block :: python

   In [2]: data = 'a,b,a\n0,1,2\n3,4,5'
   In [3]: pd.read_csv(StringIO(data), mangle_dupe_cols=False)
   Out[3]:
      a  b  a
   0  2  1  2
   1  5  4  5

To prevent users from encountering this problem with duplicate data, a ``ValueError``
exception is raised if ``mangle_dupe_cols != True``:

.. code-block :: python

   In [2]: data = 'a,b,a\n0,1,2\n3,4,5'
   In [3]: pd.read_csv(StringIO(data), mangle_dupe_cols=False)
   ...
   ValueError: Setting mangle_dupe_cols=False is not supported yet

.. _io.usecols:

Filtering columns (``usecols``)
+++++++++++++++++++++++++++++++

The ``usecols`` argument allows you to select any subset of the columns in a
file, either using the column names or position numbers:

.. ipython:: python

    data = 'a,b,c,d\n1,2,3,foo\n4,5,6,bar\n7,8,9,baz'
    pd.read_csv(StringIO(data))
    pd.read_csv(StringIO(data), usecols=['b', 'd'])
    pd.read_csv(StringIO(data), usecols=[0, 2, 3])

Comments and Empty Lines
''''''''''''''''''''''''

.. _io.skiplines:

Ignoring line comments and empty lines
++++++++++++++++++++++++++++++++++++++

If the ``comment`` parameter is specified, then completely commented lines will
be ignored. By default, completely blank lines will be ignored as well. Both of
these are API changes introduced in version 0.15.

.. ipython:: python

   data = '\na,b,c\n  \n# commented line\n1,2,3\n\n4,5,6'
   print(data)
   pd.read_csv(StringIO(data), comment='#')

If ``skip_blank_lines=False``, then ``read_csv`` will not ignore blank lines:

.. ipython:: python

   data = 'a,b,c\n\n1,2,3\n\n\n4,5,6'
   pd.read_csv(StringIO(data), skip_blank_lines=False)

.. warning::

   The presence of ignored lines might create ambiguities involving line numbers;
   the parameter ``header`` uses row numbers (ignoring commented/empty
   lines), while ``skiprows`` uses line numbers (including commented/empty lines):

   .. ipython:: python

      data = '#comment\na,b,c\nA,B,C\n1,2,3'
      pd.read_csv(StringIO(data), comment='#', header=1)
      data = 'A,B,C\n#comment\na,b,c\n1,2,3'
      pd.read_csv(StringIO(data), comment='#', skiprows=2)

   If both ``header`` and ``skiprows`` are specified, ``header`` will be
   relative to the end of ``skiprows``. For example:

   .. ipython:: python

      data = '# empty\n# second empty line\n# third empty' \
                'line\nX,Y,Z\n1,2,3\nA,B,C\n1,2.,4.\n5.,NaN,10.0'
      print(data)
      pd.read_csv(StringIO(data), comment='#', skiprows=4, header=1)

.. _io.comments:

Comments
++++++++

Sometimes comments or meta data may be included in a file:

.. ipython:: python
   :suppress:

   data =  ("ID,level,category\n"
            "Patient1,123000,x # really unpleasant\n"
            "Patient2,23000,y # wouldn't take his medicine\n"
            "Patient3,1234018,z # awesome")

   with open('tmp.csv', 'w') as fh:
       fh.write(data)

.. ipython:: python

   print(open('tmp.csv').read())

By default, the parser includes the comments in the output:

.. ipython:: python

   df = pd.read_csv('tmp.csv')
   df

We can suppress the comments using the ``comment`` keyword:

.. ipython:: python

   df = pd.read_csv('tmp.csv', comment='#')
   df

.. ipython:: python
   :suppress:

   os.remove('tmp.csv')

.. _io.unicode:

Dealing with Unicode Data
'''''''''''''''''''''''''

The ``encoding`` argument should be used for encoded unicode data, which will
result in byte strings being decoded to unicode in the result:

.. ipython:: python

   data = b'word,length\nTr\xc3\xa4umen,7\nGr\xc3\xbc\xc3\x9fe,5'.decode('utf8').encode('latin-1')
   df = pd.read_csv(BytesIO(data), encoding='latin-1')
   df
   df['word'][1]

Some formats which encode all characters as multiple bytes, like UTF-16, won't
parse correctly at all without specifying the encoding. `Full list of Python
standard encodings
<https://docs.python.org/3/library/codecs.html#standard-encodings>`_

.. _io.index_col:

Index columns and trailing delimiters
'''''''''''''''''''''''''''''''''''''

If a file has one more column of data than the number of column names, the
first column will be used as the DataFrame's row names:

.. ipython:: python

    data = 'a,b,c\n4,apple,bat,5.7\n8,orange,cow,10'
    pd.read_csv(StringIO(data))

.. ipython:: python

    data = 'index,a,b,c\n4,apple,bat,5.7\n8,orange,cow,10'
    pd.read_csv(StringIO(data), index_col=0)

Ordinarily, you can achieve this behavior using the ``index_col`` option.

There are some exception cases when a file has been prepared with delimiters at
the end of each data line, confusing the parser. To explicitly disable the
index column inference and discard the last column, pass ``index_col=False``:

.. ipython:: python

    data = 'a,b,c\n4,apple,bat,\n8,orange,cow,'
    print(data)
    pd.read_csv(StringIO(data))
    pd.read_csv(StringIO(data), index_col=False)

.. _io.parse_dates:

Date Handling
'''''''''''''

Specifying Date Columns
+++++++++++++++++++++++

To better facilitate working with datetime data, :func:`read_csv` and
:func:`read_table` use the keyword arguments ``parse_dates`` and ``date_parser``
to allow users to specify a variety of columns and date/time formats to turn the
input text data into ``datetime`` objects.

The simplest case is to just pass in ``parse_dates=True``:

.. ipython:: python

   # Use a column as an index, and parse it as dates.
   df = pd.read_csv('foo.csv', index_col=0, parse_dates=True)
   df

   # These are python datetime objects
   df.index

It is often the case that we may want to store date and time data separately,
or store various date fields separately. the ``parse_dates`` keyword can be
used to specify a combination of columns to parse the dates and/or times from.

You can specify a list of column lists to ``parse_dates``, the resulting date
columns will be prepended to the output (so as to not affect the existing column
order) and the new column names will be the concatenation of the component
column names:

.. ipython:: python
   :suppress:

   data =  ("KORD,19990127, 19:00:00, 18:56:00, 0.8100\n"
            "KORD,19990127, 20:00:00, 19:56:00, 0.0100\n"
            "KORD,19990127, 21:00:00, 20:56:00, -0.5900\n"
            "KORD,19990127, 21:00:00, 21:18:00, -0.9900\n"
            "KORD,19990127, 22:00:00, 21:56:00, -0.5900\n"
            "KORD,19990127, 23:00:00, 22:56:00, -0.5900")

   with open('tmp.csv', 'w') as fh:
       fh.write(data)

.. ipython:: python

    print(open('tmp.csv').read())
    df = pd.read_csv('tmp.csv', header=None, parse_dates=[[1, 2], [1, 3]])
    df

By default the parser removes the component date columns, but you can choose
to retain them via the ``keep_date_col`` keyword:

.. ipython:: python

   df = pd.read_csv('tmp.csv', header=None, parse_dates=[[1, 2], [1, 3]],
                    keep_date_col=True)
   df

Note that if you wish to combine multiple columns into a single date column, a
nested list must be used. In other words, ``parse_dates=[1, 2]`` indicates that
the second and third columns should each be parsed as separate date columns
while ``parse_dates=[[1, 2]]`` means the two columns should be parsed into a
single column.

You can also use a dict to specify custom name columns:

.. ipython:: python

   date_spec = {'nominal': [1, 2], 'actual': [1, 3]}
   df = pd.read_csv('tmp.csv', header=None, parse_dates=date_spec)
   df

It is important to remember that if multiple text columns are to be parsed into
a single date column, then a new column is prepended to the data. The `index_col`
specification is based off of this new set of columns rather than the original
data columns:


.. ipython:: python

   date_spec = {'nominal': [1, 2], 'actual': [1, 3]}
   df = pd.read_csv('tmp.csv', header=None, parse_dates=date_spec,
                    index_col=0) #index is the nominal column
   df

.. note::
   read_csv has a fast_path for parsing datetime strings in iso8601 format,
   e.g "2000-01-01T00:01:02+00:00" and similar variations. If you can arrange
   for your data to store datetimes in this format, load times will be
   significantly faster, ~20x has been observed.


.. note::

   When passing a dict as the `parse_dates` argument, the order of
   the columns prepended is not guaranteed, because `dict` objects do not impose
   an ordering on their keys. On Python 2.7+ you may use `collections.OrderedDict`
   instead of a regular `dict` if this matters to you. Because of this, when using a
   dict for 'parse_dates' in conjunction with the `index_col` argument, it's best to
   specify `index_col` as a column label rather then as an index on the resulting frame.


Date Parsing Functions
++++++++++++++++++++++

Finally, the parser allows you to specify a custom ``date_parser`` function to
take full advantage of the flexibility of the date parsing API:

.. ipython:: python

   import pandas.io.date_converters as conv
   df = pd.read_csv('tmp.csv', header=None, parse_dates=date_spec,
                    date_parser=conv.parse_date_time)
   df

Pandas will try to call the ``date_parser`` function in three different ways. If
an exception is raised, the next one is tried:

1. ``date_parser`` is first called with one or more arrays as arguments,
   as defined using `parse_dates` (e.g., ``date_parser(['2013', '2013'], ['1', '2'])``)

2. If #1 fails, ``date_parser`` is called with all the columns
   concatenated row-wise into a single array (e.g., ``date_parser(['2013 1', '2013 2'])``)

3. If #2 fails, ``date_parser`` is called once for every row with one or more
   string arguments from the columns indicated with `parse_dates`
   (e.g., ``date_parser('2013', '1')`` for the first row, ``date_parser('2013', '2')``
   for the second, etc.)

Note that performance-wise, you should try these methods of parsing dates in order:

1. Try to infer the format using ``infer_datetime_format=True`` (see section below)

2. If you know the format, use ``pd.to_datetime()``:
   ``date_parser=lambda x: pd.to_datetime(x, format=...)``

3. If you have a really non-standard format, use a custom ``date_parser`` function.
   For optimal performance, this should be vectorized, i.e., it should accept arrays
   as arguments.

You can explore the date parsing functionality in ``date_converters.py`` and
add your own. We would love to turn this module into a community supported set
of date/time parsers. To get you started, ``date_converters.py`` contains
functions to parse dual date and time columns, year/month/day columns,
and year/month/day/hour/minute/second columns. It also contains a
``generic_parser`` function so you can curry it with a function that deals with
a single date rather than the entire array.

.. ipython:: python
   :suppress:

   os.remove('tmp.csv')

.. _io.dayfirst:


Inferring Datetime Format
+++++++++++++++++++++++++

If you have ``parse_dates`` enabled for some or all of your columns, and your
datetime strings are all formatted the same way, you may get a large speed
up by setting ``infer_datetime_format=True``.  If set, pandas will attempt
to guess the format of your datetime strings, and then use a faster means
of parsing the strings.  5-10x parsing speeds have been observed.  pandas
will fallback to the usual parsing if either the format cannot be guessed
or the format that was guessed cannot properly parse the entire column
of strings.  So in general, ``infer_datetime_format`` should not have any
negative consequences if enabled.

Here are some examples of datetime strings that can be guessed (All
representing December 30th, 2011 at 00:00:00)

- "20111230"
- "2011/12/30"
- "20111230 00:00:00"
- "12/30/2011 00:00:00"
- "30/Dec/2011 00:00:00"
- "30/December/2011 00:00:00"

``infer_datetime_format`` is sensitive to ``dayfirst``.  With
``dayfirst=True``, it will guess "01/12/2011" to be December 1st. With
``dayfirst=False`` (default) it will guess "01/12/2011" to be January 12th.

.. ipython:: python

   # Try to infer the format for the index column
   df = pd.read_csv('foo.csv', index_col=0, parse_dates=True,
                    infer_datetime_format=True)
   df

.. ipython:: python
   :suppress:

   os.remove('foo.csv')

International Date Formats
++++++++++++++++++++++++++

While US date formats tend to be MM/DD/YYYY, many international formats use
DD/MM/YYYY instead. For convenience, a ``dayfirst`` keyword is provided:

.. ipython:: python
   :suppress:

   data = "date,value,cat\n1/6/2000,5,a\n2/6/2000,10,b\n3/6/2000,15,c"
   with open('tmp.csv', 'w') as fh:
        fh.write(data)

.. ipython:: python

   print(open('tmp.csv').read())

   pd.read_csv('tmp.csv', parse_dates=[0])
   pd.read_csv('tmp.csv', dayfirst=True, parse_dates=[0])

.. _io.float_precision:

Specifying method for floating-point conversion
'''''''''''''''''''''''''''''''''''''''''''''''

The parameter ``float_precision`` can be specified in order to use
a specific floating-point converter during parsing with the C engine.
The options are the ordinary converter, the high-precision converter, and
the round-trip converter (which is guaranteed to round-trip values after
writing to a file). For example:

.. ipython:: python

   val = '0.3066101993807095471566981359501369297504425048828125'
   data = 'a,b,c\n1,2,{0}'.format(val)
   abs(pd.read_csv(StringIO(data), engine='c', float_precision=None)['c'][0] - float(val))
   abs(pd.read_csv(StringIO(data), engine='c', float_precision='high')['c'][0] - float(val))
   abs(pd.read_csv(StringIO(data), engine='c', float_precision='round_trip')['c'][0] - float(val))


.. _io.thousands:

Thousand Separators
'''''''''''''''''''

For large numbers that have been written with a thousands separator, you can
set the ``thousands`` keyword to a string of length 1 so that integers will be parsed
correctly:

.. ipython:: python
   :suppress:

   data =  ("ID|level|category\n"
            "Patient1|123,000|x\n"
            "Patient2|23,000|y\n"
            "Patient3|1,234,018|z")

   with open('tmp.csv', 'w') as fh:
       fh.write(data)

By default, numbers with a thousands separator will be parsed as strings

.. ipython:: python

    print(open('tmp.csv').read())
    df = pd.read_csv('tmp.csv', sep='|')
    df

    df.level.dtype

The ``thousands`` keyword allows integers to be parsed correctly

.. ipython:: python

    print(open('tmp.csv').read())
    df = pd.read_csv('tmp.csv', sep='|', thousands=',')
    df

    df.level.dtype

.. ipython:: python
   :suppress:

   os.remove('tmp.csv')

.. _io.na_values:

NA Values
'''''''''

To control which values are parsed as missing values (which are signified by ``NaN``), specifiy a
string in ``na_values``. If you specify a list of strings, then all values in
it are considered to be missing values. If you specify a number (a ``float``, like ``5.0`` or an ``integer`` like ``5``),
the corresponding equivalent values will also imply a missing value (in this case effectively
``[5.0,5]`` are recognized as ``NaN``.

To completely override the default values that are recognized as missing, specify ``keep_default_na=False``.
The default ``NaN`` recognized values are ``['-1.#IND', '1.#QNAN', '1.#IND', '-1.#QNAN', '#N/A','N/A', 'NA',
'#NA', 'NULL', 'NaN', '-NaN', 'nan', '-nan']``. Although a 0-length string
``''`` is not included in the default ``NaN`` values list, it is still treated
as a missing value.

.. code-block:: python

   read_csv(path, na_values=[5])

the default values, in addition to ``5`` , ``5.0`` when interpreted as numbers are recognized as ``NaN``

.. code-block:: python

   read_csv(path, keep_default_na=False, na_values=[""])

only an empty field will be ``NaN``

.. code-block:: python

   read_csv(path, keep_default_na=False, na_values=["NA", "0"])

only ``NA`` and ``0`` as strings are ``NaN``

.. code-block:: python

   read_csv(path, na_values=["Nope"])

the default values, in addition to the string ``"Nope"`` are recognized as ``NaN``

.. _io.infinity:

Infinity
''''''''

``inf`` like values will be parsed as ``np.inf`` (positive infinity), and ``-inf`` as ``-np.inf`` (negative infinity).
These will ignore the case of the value, meaning ``Inf``, will also be parsed as ``np.inf``.


Returning Series
''''''''''''''''

Using the ``squeeze`` keyword, the parser will return output with a single column
as a ``Series``:

.. ipython:: python
   :suppress:

   data =  ("level\n"
            "Patient1,123000\n"
            "Patient2,23000\n"
            "Patient3,1234018")

   with open('tmp.csv', 'w') as fh:
       fh.write(data)

.. ipython:: python

   print(open('tmp.csv').read())

   output =  pd.read_csv('tmp.csv', squeeze=True)
   output

   type(output)

.. ipython:: python
   :suppress:

   os.remove('tmp.csv')

.. _io.boolean:

Boolean values
''''''''''''''

The common values ``True``, ``False``, ``TRUE``, and ``FALSE`` are all
recognized as boolean. Sometime you would want to recognize some other values
as being boolean. To do this use the ``true_values`` and ``false_values``
options:

.. ipython:: python

    data= 'a,b,c\n1,Yes,2\n3,No,4'
    print(data)
    pd.read_csv(StringIO(data))
    pd.read_csv(StringIO(data), true_values=['Yes'], false_values=['No'])

.. _io.bad_lines:

Handling "bad" lines
''''''''''''''''''''

Some files may have malformed lines with too few fields or too many. Lines with
too few fields will have NA values filled in the trailing fields. Lines with
too many will cause an error by default:

.. ipython:: python
   :suppress:

    data = 'a,b,c\n1,2,3\n4,5,6,7\n8,9,10'

.. code-block:: ipython

    In [27]: data = 'a,b,c\n1,2,3\n4,5,6,7\n8,9,10'

    In [28]: pd.read_csv(StringIO(data))
    ---------------------------------------------------------------------------
    CParserError                              Traceback (most recent call last)
    CParserError: Error tokenizing data. C error: Expected 3 fields in line 3, saw 4

You can elect to skip bad lines:

.. code-block:: ipython

    In [29]: pd.read_csv(StringIO(data), error_bad_lines=False)
    Skipping line 3: expected 3 fields, saw 4

    Out[29]:
       a  b   c
    0  1  2   3
    1  8  9  10

.. _io.quoting:

Quoting and Escape Characters
'''''''''''''''''''''''''''''

Quotes (and other escape characters) in embedded fields can be handled in any
number of ways. One way is to use backslashes; to properly parse this data, you
should pass the ``escapechar`` option:

.. ipython:: python

   data = 'a,b\n"hello, \\"Bob\\", nice to see you",5'
   print(data)
   pd.read_csv(StringIO(data), escapechar='\\')

.. _io.fwf:

Files with Fixed Width Columns
''''''''''''''''''''''''''''''

While ``read_csv`` reads delimited data, the :func:`read_fwf` function works
with data files that have known and fixed column widths. The function parameters
to ``read_fwf`` are largely the same as `read_csv` with two extra parameters:

  - ``colspecs``: A list of pairs (tuples) giving the extents of the
    fixed-width fields of each line as half-open intervals (i.e.,  [from, to[ ).
    String value 'infer' can be used to instruct the parser to try detecting
    the column specifications from the first 100 rows of the data. Default
    behaviour, if not specified, is to infer.
  - ``widths``: A list of field widths which can be used instead of 'colspecs'
    if the intervals are contiguous.

.. ipython:: python
   :suppress:

   f = open('bar.csv', 'w')
   data1 = ("id8141    360.242940   149.910199   11950.7\n"
            "id1594    444.953632   166.985655   11788.4\n"
            "id1849    364.136849   183.628767   11806.2\n"
            "id1230    413.836124   184.375703   11916.8\n"
            "id1948    502.953953   173.237159   12468.3")
   f.write(data1)
   f.close()

Consider a typical fixed-width data file:

.. ipython:: python

   print(open('bar.csv').read())

In order to parse this file into a DataFrame, we simply need to supply the
column specifications to the `read_fwf` function along with the file name:

.. ipython:: python

   #Column specifications are a list of half-intervals
   colspecs = [(0, 6), (8, 20), (21, 33), (34, 43)]
   df = pd.read_fwf('bar.csv', colspecs=colspecs, header=None, index_col=0)
   df

Note how the parser automatically picks column names X.<column number> when
``header=None`` argument is specified. Alternatively, you can supply just the
column widths for contiguous columns:

.. ipython:: python

   #Widths are a list of integers
   widths = [6, 14, 13, 10]
   df = pd.read_fwf('bar.csv', widths=widths, header=None)
   df

The parser will take care of extra white spaces around the columns
so it's ok to have extra separation between the columns in the file.

.. versionadded:: 0.13.0

By default, ``read_fwf`` will try to infer the file's ``colspecs`` by using the
first 100 rows of the file. It can do it only in cases when the columns are
aligned and correctly separated by the provided ``delimiter`` (default delimiter
is whitespace).

.. ipython:: python

   df = pd.read_fwf('bar.csv', header=None, index_col=0)
   df

.. ipython:: python
   :suppress:

   os.remove('bar.csv')

Indexes
'''''''

Files with an "implicit" index column
+++++++++++++++++++++++++++++++++++++

.. ipython:: python
   :suppress:

   f = open('foo.csv', 'w')
   f.write('A,B,C\n20090101,a,1,2\n20090102,b,3,4\n20090103,c,4,5')
   f.close()

Consider a file with one less entry in the header than the number of data
column:

.. ipython:: python

   print(open('foo.csv').read())

In this special case, ``read_csv`` assumes that the first column is to be used
as the index of the DataFrame:

.. ipython:: python

   pd.read_csv('foo.csv')

Note that the dates weren't automatically parsed. In that case you would need
to do as before:

.. ipython:: python

   df = pd.read_csv('foo.csv', parse_dates=True)
   df.index

.. ipython:: python
   :suppress:

   os.remove('foo.csv')


Reading an index with a ``MultiIndex``
++++++++++++++++++++++++++++++++++++++

.. _io.csv_multiindex:

Suppose you have data indexed by two columns:

.. ipython:: python

   #print os.getcwd()
   print(open("./source/data/mindex_ex.csv").read())

The ``index_col`` argument to ``read_csv`` and ``read_table`` can take a list of
column numbers to turn multiple columns into a ``MultiIndex`` for the index of the
returned object:

.. ipython:: python

   df = pd.read_csv("./source/data/mindex_ex.csv", index_col=[0,1])
   df
   df.ix[1978]

.. _io.multi_index_columns:

Reading columns with a ``MultiIndex``
+++++++++++++++++++++++++++++++++++++

By specifying list of row locations for the ``header`` argument, you
can read in a ``MultiIndex`` for the columns. Specifying non-consecutive
rows will skip the intervening rows. In order to have the pre-0.13 behavior
of tupleizing columns, specify ``tupleize_cols=True``.

.. ipython:: python

   from pandas.util.testing import makeCustomDataframe as mkdf
   df = mkdf(5,3,r_idx_nlevels=2,c_idx_nlevels=4)
   df.to_csv('mi.csv')
   print(open('mi.csv').read())
   pd.read_csv('mi.csv',header=[0,1,2,3],index_col=[0,1])

Starting in 0.13.0, ``read_csv`` will be able to interpret a more common format
of multi-columns indices.

.. ipython:: python
   :suppress:

   data = ",a,a,a,b,c,c\n,q,r,s,t,u,v\none,1,2,3,4,5,6\ntwo,7,8,9,10,11,12"
   fh = open('mi2.csv','w')
   fh.write(data)
   fh.close()

.. ipython:: python

   print(open('mi2.csv').read())
   pd.read_csv('mi2.csv',header=[0,1],index_col=0)

Note: If an ``index_col`` is not specified (e.g. you don't have an index, or wrote it
with ``df.to_csv(..., index=False``), then any ``names`` on the columns index will be *lost*.

.. ipython:: python
   :suppress:

   import os
   os.remove('mi.csv')
   os.remove('mi2.csv')

.. _io.sniff:

Automatically "sniffing" the delimiter
''''''''''''''''''''''''''''''''''''''

``read_csv`` is capable of inferring delimited (not necessarily
comma-separated) files, as pandas uses the :class:`python:csv.Sniffer`
class of the csv module. For this, you have to specify ``sep=None``.

.. ipython:: python
   :suppress:

   df = pd.DataFrame(np.random.randn(10, 4))
   df.to_csv('tmp.sv', sep='|')
   df.to_csv('tmp2.sv', sep=':')

.. ipython:: python

    print(open('tmp2.sv').read())
    pd.read_csv('tmp2.sv', sep=None, engine='python')

.. _io.chunking:

Iterating through files chunk by chunk
''''''''''''''''''''''''''''''''''''''

Suppose you wish to iterate through a (potentially very large) file lazily
rather than reading the entire file into memory, such as the following:


.. ipython:: python

   print(open('tmp.sv').read())
   table = pd.read_table('tmp.sv', sep='|')
   table


By specifying a ``chunksize`` to ``read_csv`` or ``read_table``, the return
value will be an iterable object of type ``TextFileReader``:

.. ipython:: python

   reader = pd.read_table('tmp.sv', sep='|', chunksize=4)
   reader

   for chunk in reader:
       print(chunk)


Specifying ``iterator=True`` will also return the ``TextFileReader`` object:

.. ipython:: python

   reader = pd.read_table('tmp.sv', sep='|', iterator=True)
   reader.get_chunk(5)

.. ipython:: python
   :suppress:

   os.remove('tmp.sv')
   os.remove('tmp2.sv')

Specifying the parser engine
''''''''''''''''''''''''''''

Under the hood pandas uses a fast and efficient parser implemented in C as well
as a python implementation which is currently more feature-complete. Where
possible pandas uses the C parser (specified as ``engine='c'``), but may fall
back to python if C-unsupported options are specified. Currently, C-unsupported
options include:

- ``sep`` other than a single character (e.g. regex separators)
- ``skipfooter``
- ``sep=None`` with ``delim_whitespace=False``

Specifying any of the above options will produce a ``ParserWarning`` unless the
python engine is selected explicitly using ``engine='python'``.

Writing out Data
''''''''''''''''

.. _io.store_in_csv:

Writing to CSV format
+++++++++++++++++++++

The Series and DataFrame objects have an instance method ``to_csv`` which
allows storing the contents of the object as a comma-separated-values file. The
function takes a number of arguments. Only the first is required.

  - ``path_or_buf``: A string path to the file to write or a StringIO
  - ``sep`` : Field delimiter for the output file (default ",")
  - ``na_rep``: A string representation of a missing value (default '')
  - ``float_format``: Format string for floating point numbers
  - ``cols``: Columns to write (default None)
  - ``header``: Whether to write out the column names (default True)
  - ``index``: whether to write row (index) names (default True)
  - ``index_label``: Column label(s) for index column(s) if desired. If None
    (default), and `header` and `index` are True, then the index names are
    used. (A sequence should be given if the DataFrame uses MultiIndex).
  - ``mode`` : Python write mode, default 'w'
  - ``encoding``: a string representing the encoding to use if the contents are
    non-ASCII, for python versions prior to 3
  - ``line_terminator``: Character sequence denoting line end (default '\\n')
  - ``quoting``: Set quoting rules as in csv module (default csv.QUOTE_MINIMAL)
  - ``quotechar``: Character used to quote fields (default '"')
  - ``doublequote``: Control quoting of ``quotechar`` in fields (default True)
  - ``escapechar``: Character used to escape ``sep`` and ``quotechar`` when
    appropriate (default None)
  - ``chunksize``: Number of rows to write at a time
  - ``tupleize_cols``: If False (default), write as a list of tuples, otherwise
    write in an expanded line format suitable for ``read_csv``
  - ``date_format``: Format string for datetime objects

Writing a formatted string
++++++++++++++++++++++++++

.. _io.formatting:

The DataFrame object has an instance method ``to_string`` which allows control
over the string representation of the object. All arguments are optional:

  - ``buf`` default None, for example a StringIO object
  - ``columns`` default None, which columns to write
  - ``col_space`` default None, minimum width of each column.
  - ``na_rep`` default ``NaN``, representation of NA value
  - ``formatters`` default None, a dictionary (by column) of functions each of
    which takes a single argument and returns a formatted string
  - ``float_format`` default None, a function which takes a single (float)
    argument and returns a formatted string; to be applied to floats in the
    DataFrame.
  - ``sparsify`` default True, set to False for a DataFrame with a hierarchical
    index to print every multiindex key at each row.
  - ``index_names`` default True, will print the names of the indices
  - ``index`` default True, will print the index (ie, row labels)
  - ``header`` default True, will print the column labels
  - ``justify`` default ``left``, will print column headers left- or
    right-justified

The Series object also has a ``to_string`` method, but with only the ``buf``,
``na_rep``, ``float_format`` arguments. There is also a ``length`` argument
which, if set to ``True``, will additionally output the length of the Series.