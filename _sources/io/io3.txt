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

.. _io.json:

JSON
----

Read and write ``JSON`` format files and strings.

.. _io.json_writer:

Writing JSON
''''''''''''

A ``Series`` or ``DataFrame`` can be converted to a valid JSON string. Use ``to_json``
with optional parameters:

- ``path_or_buf`` : the pathname or buffer to write the output
  This can be ``None`` in which case a JSON string is returned
- ``orient`` :

  Series :
      - default is ``index``
      - allowed values are {``split``, ``records``, ``index``}

  DataFrame
      - default is ``columns``
      - allowed values are {``split``, ``records``, ``index``, ``columns``, ``values``}

  The format of the JSON string

  .. csv-table::
     :widths: 20, 150
     :delim: ;

     ``split``; dict like {index -> [index], columns -> [columns], data -> [values]}
     ``records``; list like [{column -> value}, ... , {column -> value}]
     ``index``; dict like {index -> {column -> value}}
     ``columns``; dict like {column -> {index -> value}}
     ``values``; just the values array

- ``date_format`` : string, type of date conversion, 'epoch' for timestamp, 'iso' for ISO8601.
- ``double_precision`` : The number of decimal places to use when encoding floating point values, default 10.
- ``force_ascii`` : force encoded string to be ASCII, default True.
- ``date_unit`` : The time unit to encode to, governs timestamp and ISO8601 precision. One of 's', 'ms', 'us' or 'ns' for seconds, milliseconds, microseconds and nanoseconds respectively. Default 'ms'.
- ``default_handler`` : The handler to call if an object cannot otherwise be converted to a suitable format for JSON. Takes a single argument, which is the object to convert, and returns a serializable object.
- ``lines`` : If ``records`` orient, then will write each record per line as json.

Note ``NaN``'s, ``NaT``'s and ``None`` will be converted to ``null`` and ``datetime`` objects will be converted based on the ``date_format`` and ``date_unit`` parameters.

.. ipython:: python

   dfj = pd.DataFrame(randn(5, 2), columns=list('AB'))
   json = dfj.to_json()
   json

Orient Options
++++++++++++++

There are a number of different options for the format of the resulting JSON
file / string. Consider the following DataFrame and Series:

.. ipython:: python

  dfjo = pd.DataFrame(dict(A=range(1, 4), B=range(4, 7), C=range(7, 10)),
                      columns=list('ABC'), index=list('xyz'))
  dfjo
  sjo = pd.Series(dict(x=15, y=16, z=17), name='D')
  sjo

**Column oriented** (the default for ``DataFrame``) serializes the data as
nested JSON objects with column labels acting as the primary index:

.. ipython:: python

  dfjo.to_json(orient="columns")
  # Not available for Series

**Index oriented** (the default for ``Series``) similar to column oriented
but the index labels are now primary:

.. ipython:: python

  dfjo.to_json(orient="index")
  sjo.to_json(orient="index")

**Record oriented** serializes the data to a JSON array of column -> value records,
index labels are not included. This is useful for passing DataFrame data to plotting
libraries, for example the JavaScript library d3.js:

.. ipython:: python

  dfjo.to_json(orient="records")
  sjo.to_json(orient="records")

**Value oriented** is a bare-bones option which serializes to nested JSON arrays of
values only, column and index labels are not included:

.. ipython:: python

  dfjo.to_json(orient="values")
  # Not available for Series

**Split oriented** serializes to a JSON object containing separate entries for
values, index and columns. Name is also included for ``Series``:

.. ipython:: python

  dfjo.to_json(orient="split")
  sjo.to_json(orient="split")

.. note::

  Any orient option that encodes to a JSON object will not preserve the ordering of
  index and column labels during round-trip serialization. If you wish to preserve
  label ordering use the `split` option as it uses ordered containers.

Date Handling
+++++++++++++

Writing in ISO date format

.. ipython:: python

   dfd = pd.DataFrame(randn(5, 2), columns=list('AB'))
   dfd['date'] = pd.Timestamp('20130101')
   dfd = dfd.sort_index(1, ascending=False)
   json = dfd.to_json(date_format='iso')
   json

Writing in ISO date format, with microseconds

.. ipython:: python

   json = dfd.to_json(date_format='iso', date_unit='us')
   json

Epoch timestamps, in seconds

.. ipython:: python

   json = dfd.to_json(date_format='epoch', date_unit='s')
   json

Writing to a file, with a date index and a date column

.. ipython:: python

   dfj2 = dfj.copy()
   dfj2['date'] = pd.Timestamp('20130101')
   dfj2['ints'] = list(range(5))
   dfj2['bools'] = True
   dfj2.index = pd.date_range('20130101', periods=5)
   dfj2.to_json('test.json')
   open('test.json').read()

Fallback Behavior
+++++++++++++++++

If the JSON serializer cannot handle the container contents directly it will fallback in the following manner:

- if the dtype is unsupported (e.g. ``np.complex``) then the ``default_handler``, if provided, will be called
  for each value, otherwise an exception is raised.

- if an object is unsupported it will attempt the following:


  * check if the object has defined a ``toDict`` method and call it.
    A ``toDict`` method should return a ``dict`` which will then be JSON serialized.

  * invoke the ``default_handler`` if one was provided.

  * convert the object to a ``dict`` by traversing its contents. However this will often fail
    with an ``OverflowError`` or give unexpected results.

In general the best approach for unsupported objects or dtypes is to provide a ``default_handler``.
For example:

.. code-block:: python

  DataFrame([1.0, 2.0, complex(1.0, 2.0)]).to_json()  # raises

  RuntimeError: Unhandled numpy dtype 15

can be dealt with by specifying a simple ``default_handler``:

.. ipython:: python

   pd.DataFrame([1.0, 2.0, complex(1.0, 2.0)]).to_json(default_handler=str)

.. _io.json_reader:

Reading JSON
''''''''''''

Reading a JSON string to pandas object can take a number of parameters.
The parser will try to parse a ``DataFrame`` if ``typ`` is not supplied or
is ``None``. To explicitly force ``Series`` parsing, pass ``typ=series``

- ``filepath_or_buffer`` : a **VALID** JSON string or file handle / StringIO. The string could be
  a URL. Valid URL schemes include http, ftp, S3, and file. For file URLs, a host
  is expected. For instance, a local file could be
  file ://localhost/path/to/table.json
- ``typ``    : type of object to recover (series or frame), default 'frame'
- ``orient`` :

  Series :
      - default is ``index``
      - allowed values are {``split``, ``records``, ``index``}

  DataFrame
      - default is ``columns``
      - allowed values are {``split``, ``records``, ``index``, ``columns``, ``values``}

  The format of the JSON string

  .. csv-table::
     :widths: 20, 150
     :delim: ;

     ``split``; dict like {index -> [index], columns -> [columns], data -> [values]}
     ``records``; list like [{column -> value}, ... , {column -> value}]
     ``index``; dict like {index -> {column -> value}}
     ``columns``; dict like {column -> {index -> value}}
     ``values``; just the values array

- ``dtype`` : if True, infer dtypes, if a dict of column to dtype, then use those, if False, then don't infer dtypes at all, default is True, apply only to the data
- ``convert_axes`` : boolean, try to convert the axes to the proper dtypes, default is True
- ``convert_dates`` : a list of columns to parse for dates; If True, then try to parse date-like columns, default is True
- ``keep_default_dates`` : boolean, default True. If parsing dates, then parse the default date-like columns
- ``numpy`` : direct decoding to numpy arrays. default is False;
  Supports numeric data only, although labels may be non-numeric. Also note that the JSON ordering **MUST** be the same for each term if ``numpy=True``
- ``precise_float`` : boolean, default ``False``. Set to enable usage of higher precision (strtod) function when decoding string to double values. Default (``False``) is to use fast but less precise builtin functionality
- ``date_unit`` : string, the timestamp unit to detect if converting dates. Default
  None. By default the timestamp precision will be detected, if this is not desired
  then pass one of 's', 'ms', 'us' or 'ns' to force timestamp precision to
  seconds, milliseconds, microseconds or nanoseconds respectively.
- ``lines`` : reads file as one json object per line.
- ``encoding`` : The encoding to use to decode py3 bytes.

The parser will raise one of ``ValueError/TypeError/AssertionError`` if the JSON is not parseable.

If a non-default ``orient`` was used when encoding to JSON be sure to pass the same
option here so that decoding produces sensible results, see `Orient Options`_ for an
overview.

Data Conversion
+++++++++++++++

The default of ``convert_axes=True``, ``dtype=True``, and ``convert_dates=True`` will try to parse the axes, and all of the data
into appropriate types, including dates. If you need to override specific dtypes, pass a dict to ``dtype``. ``convert_axes`` should only
be set to ``False`` if you need to preserve string-like numbers (e.g. '1', '2') in an axes.

.. note::

  Large integer values may be converted to dates if ``convert_dates=True`` and the data and / or column labels appear 'date-like'. The exact threshold depends on the ``date_unit`` specified. 'date-like' means that the column label meets one of the following criteria:

     * it ends with ``'_at'``
     * it ends with ``'_time'``
     * it begins with ``'timestamp'``
     * it is ``'modified'``
     * it is ``'date'``

.. warning::

   When reading JSON data, automatic coercing into dtypes has some quirks:

     * an index can be reconstructed in a different order from serialization, that is, the returned order is not guaranteed to be the same as before serialization
     * a column that was ``float`` data will be converted to ``integer`` if it can be done safely, e.g. a column of ``1.``
     * bool columns will be converted to ``integer`` on reconstruction

   Thus there are times where you may want to specify specific dtypes via the ``dtype`` keyword argument.

Reading from a JSON string:

.. ipython:: python

   pd.read_json(json)

Reading from a file:

.. ipython:: python

   pd.read_json('test.json')

Don't convert any data (but still convert axes and dates):

.. ipython:: python

   pd.read_json('test.json', dtype=object).dtypes

Specify dtypes for conversion:

.. ipython:: python

   pd.read_json('test.json', dtype={'A' : 'float32', 'bools' : 'int8'}).dtypes

Preserve string indices:

.. ipython:: python

   si = pd.DataFrame(np.zeros((4, 4)),
            columns=list(range(4)),
            index=[str(i) for i in range(4)])
   si
   si.index
   si.columns
   json = si.to_json()

   sij = pd.read_json(json, convert_axes=False)
   sij
   sij.index
   sij.columns

Dates written in nanoseconds need to be read back in nanoseconds:

.. ipython:: python

   json = dfj2.to_json(date_unit='ns')

   # Try to parse timestamps as millseconds -> Won't Work
   dfju = pd.read_json(json, date_unit='ms')
   dfju

   # Let pandas detect the correct precision
   dfju = pd.read_json(json)
   dfju

   # Or specify that all timestamps are in nanoseconds
   dfju = pd.read_json(json, date_unit='ns')
   dfju

The Numpy Parameter
+++++++++++++++++++

.. note::
  This supports numeric data only. Index and columns labels may be non-numeric, e.g. strings, dates etc.

If ``numpy=True`` is passed to ``read_json`` an attempt will be made to sniff
an appropriate dtype during deserialization and to subsequently decode directly
to numpy arrays, bypassing the need for intermediate Python objects.

This can provide speedups if you are deserialising a large amount of numeric
data:

.. ipython:: python

   randfloats = np.random.uniform(-100, 1000, 10000)
   randfloats.shape = (1000, 10)
   dffloats = pd.DataFrame(randfloats, columns=list('ABCDEFGHIJ'))

   jsonfloats = dffloats.to_json()

.. ipython:: python

   timeit pd.read_json(jsonfloats)

.. ipython:: python

   timeit pd.read_json(jsonfloats, numpy=True)

The speedup is less noticeable for smaller datasets:

.. ipython:: python

   jsonfloats = dffloats.head(100).to_json()

.. ipython:: python

   timeit pd.read_json(jsonfloats)

.. ipython:: python

   timeit pd.read_json(jsonfloats, numpy=True)

.. warning::

   Direct numpy decoding makes a number of assumptions and may fail or produce
   unexpected output if these assumptions are not satisfied:

    - data is numeric.

    - data is uniform. The dtype is sniffed from the first value decoded.
      A ``ValueError`` may be raised, or incorrect output may be produced
      if this condition is not satisfied.

    - labels are ordered. Labels are only read from the first container, it is assumed
      that each subsequent row / column has been encoded in the same order. This should be satisfied if the
      data was encoded using ``to_json`` but may not be the case if the JSON
      is from another source.

.. ipython:: python
   :suppress:

   import os
   os.remove('test.json')

.. _io.json_normalize:

Normalization
'''''''''''''

.. versionadded:: 0.13.0

pandas provides a utility function to take a dict or list of dicts and *normalize* this semi-structured data
into a flat table.

.. ipython:: python

   from pandas.io.json import json_normalize
   data = [{'state': 'Florida',
             'shortname': 'FL',
             'info': {
                  'governor': 'Rick Scott'
             },
             'counties': [{'name': 'Dade', 'population': 12345},
                         {'name': 'Broward', 'population': 40000},
                         {'name': 'Palm Beach', 'population': 60000}]},
            {'state': 'Ohio',
             'shortname': 'OH',
             'info': {
                  'governor': 'John Kasich'
             },
             'counties': [{'name': 'Summit', 'population': 1234},
                          {'name': 'Cuyahoga', 'population': 1337}]}]

   json_normalize(data, 'counties', ['state', 'shortname', ['info', 'governor']])

.. _io.jsonl:

Line delimited json
'''''''''''''''''''

.. versionadded:: 0.19.0

pandas is able to read and write line-delimited json files that are common in data processing pipelines
using Hadoop or Spark.

.. ipython:: python

  jsonl = '''
      {"a":1,"b":2}
      {"a":3,"b":4}
  '''
  df = pd.read_json(jsonl, lines=True)
  df
  df.to_json(orient='records', lines=True)