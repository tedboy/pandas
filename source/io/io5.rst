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

.. _io.excel:

Excel files
-----------

The :func:`~pandas.read_excel` method can read Excel 2003 (``.xls``) and
Excel 2007+ (``.xlsx``) files using the ``xlrd`` Python
module.  The :meth:`~DataFrame.to_excel` instance method is used for
saving a ``DataFrame`` to Excel.  Generally the semantics are
similar to working with :ref:`csv<io.read_csv_table>` data.  See the :ref:`cookbook<cookbook.excel>` for some
advanced strategies

.. _io.excel_reader:

Reading Excel Files
'''''''''''''''''''

In the most basic use-case, ``read_excel`` takes a path to an Excel
file, and the ``sheetname`` indicating which sheet to parse.

.. code-block:: python

   # Returns a DataFrame
   read_excel('path_to_file.xls', sheetname='Sheet1')


.. _io.excel.excelfile_class:

``ExcelFile`` class
+++++++++++++++++++

To facilitate working with multiple sheets from the same file, the ``ExcelFile``
class can be used to wrap the file and can be be passed into ``read_excel``
There will be a performance benefit for reading multiple sheets as the file is
read into memory only once.

.. code-block:: python

   xlsx = pd.ExcelFile('path_to_file.xls)
   df = pd.read_excel(xlsx, 'Sheet1')

The ``ExcelFile`` class can also be used as a context manager.

.. code-block:: python

   with pd.ExcelFile('path_to_file.xls') as xls:
       df1 = pd.read_excel(xls, 'Sheet1')
       df2 = pd.read_excel(xls, 'Sheet2')

The ``sheet_names`` property will generate
a list of the sheet names in the file.

The primary use-case for an ``ExcelFile`` is parsing multiple sheets with
different parameters

.. code-block:: python

    data = {}
    # For when Sheet1's format differs from Sheet2
    with pd.ExcelFile('path_to_file.xls') as xls:
        data['Sheet1'] = pd.read_excel(xls, 'Sheet1', index_col=None, na_values=['NA'])
        data['Sheet2'] = pd.read_excel(xls, 'Sheet2', index_col=1)

Note that if the same parsing parameters are used for all sheets, a list
of sheet names can simply be passed to ``read_excel`` with no loss in performance.

.. code-block:: python

    # using the ExcelFile class
    data = {}
    with pd.ExcelFile('path_to_file.xls') as xls:
        data['Sheet1'] = read_excel(xls, 'Sheet1', index_col=None, na_values=['NA'])
        data['Sheet2'] = read_excel(xls, 'Sheet2', index_col=None, na_values=['NA'])

    # equivalent using the read_excel function
    data = read_excel('path_to_file.xls', ['Sheet1', 'Sheet2'], index_col=None, na_values=['NA'])

.. versionadded:: 0.12

``ExcelFile`` has been moved to the top level namespace.

.. versionadded:: 0.17

``read_excel`` can take an ``ExcelFile`` object as input


.. _io.excel.specifying_sheets:

Specifying Sheets
+++++++++++++++++

.. note :: The second argument is ``sheetname``, not to be confused with ``ExcelFile.sheet_names``

.. note :: An ExcelFile's attribute ``sheet_names`` provides access to a list of sheets.

- The arguments ``sheetname`` allows specifying the sheet or sheets to read.
- The default value for ``sheetname`` is 0, indicating to read the first sheet
- Pass a string to refer to the name of a particular sheet in the workbook.
- Pass an integer to refer to the index of a sheet. Indices follow Python
  convention, beginning at 0.
- Pass a list of either strings or integers, to return a dictionary of specified sheets.
- Pass a ``None`` to return a dictionary of all available sheets.

.. code-block:: python

   # Returns a DataFrame
   read_excel('path_to_file.xls', 'Sheet1', index_col=None, na_values=['NA'])

Using the sheet index:

.. code-block:: python

   # Returns a DataFrame
   read_excel('path_to_file.xls', 0, index_col=None, na_values=['NA'])

Using all default values:

.. code-block:: python

   # Returns a DataFrame
   read_excel('path_to_file.xls')

Using None to get all sheets:

.. code-block:: python

   # Returns a dictionary of DataFrames
   read_excel('path_to_file.xls',sheetname=None)

Using a list to get multiple sheets:

.. code-block:: python

   # Returns the 1st and 4th sheet, as a dictionary of DataFrames.
   read_excel('path_to_file.xls',sheetname=['Sheet1',3])

.. versionadded:: 0.16

``read_excel`` can read more than one sheet, by setting ``sheetname`` to either
a list of sheet names, a list of sheet positions, or ``None`` to read all sheets.

.. versionadded:: 0.13

Sheets can be specified by sheet index or sheet name, using an integer or string,
respectively.

.. _io.excel.reading_multiindex:

Reading a ``MultiIndex``
++++++++++++++++++++++++

.. versionadded:: 0.17

``read_excel`` can read a ``MultiIndex`` index, by passing a list of columns to ``index_col``
and a ``MultiIndex`` column by passing a list of rows to ``header``.  If either the ``index``
or ``columns`` have serialized level names those will be read in as well by specifying
the rows/columns that make up the levels.

For example, to read in a ``MultiIndex`` index without names:

.. ipython:: python

   df = pd.DataFrame({'a':[1,2,3,4], 'b':[5,6,7,8]},
                     index=pd.MultiIndex.from_product([['a','b'],['c','d']]))
   df.to_excel('path_to_file.xlsx')
   df = pd.read_excel('path_to_file.xlsx', index_col=[0,1])
   df

If the index has level names, they will parsed as well, using the same
parameters.

.. ipython:: python

   df.index = df.index.set_names(['lvl1', 'lvl2'])
   df.to_excel('path_to_file.xlsx')
   df = pd.read_excel('path_to_file.xlsx', index_col=[0,1])
   df


If the source file has both ``MultiIndex`` index and columns, lists specifying each
should be passed to ``index_col`` and ``header``

.. ipython:: python

   df.columns = pd.MultiIndex.from_product([['a'],['b', 'd']], names=['c1', 'c2'])
   df.to_excel('path_to_file.xlsx')
   df = pd.read_excel('path_to_file.xlsx',
                       index_col=[0,1], header=[0,1])
   df

.. ipython:: python
   :suppress:

   import os
   os.remove('path_to_file.xlsx')

.. warning::

   Excel files saved in version 0.16.2 or prior that had index names will still able to be read in,
   but the ``has_index_names`` argument must specified to ``True``.


Parsing Specific Columns
++++++++++++++++++++++++

It is often the case that users will insert columns to do temporary computations
in Excel and you may not want to read in those columns. `read_excel` takes
a `parse_cols` keyword to allow you to specify a subset of columns to parse.

If `parse_cols` is an integer, then it is assumed to indicate the last column
to be parsed.

.. code-block:: python

   read_excel('path_to_file.xls', 'Sheet1', parse_cols=2)

If `parse_cols` is a list of integers, then it is assumed to be the file column
indices to be parsed.

.. code-block:: python

   read_excel('path_to_file.xls', 'Sheet1', parse_cols=[0, 2, 3])

Cell Converters
+++++++++++++++

It is possible to transform the contents of Excel cells via the `converters`
option. For instance, to convert a column to boolean:

.. code-block:: python

   read_excel('path_to_file.xls', 'Sheet1', converters={'MyBools': bool})

This options handles missing values and treats exceptions in the converters
as missing data. Transformations are applied cell by cell rather than to the
column as a whole, so the array dtype is not guaranteed. For instance, a
column of integers with missing values cannot be transformed to an array
with integer dtype, because NaN is strictly a float. You can manually mask
missing data to recover integer dtype:

.. code-block:: python

   cfun = lambda x: int(x) if x else -1
   read_excel('path_to_file.xls', 'Sheet1', converters={'MyInts': cfun})

.. _io.excel_writer:

Writing Excel Files
'''''''''''''''''''

Writing Excel Files to Disk
+++++++++++++++++++++++++++

To write a DataFrame object to a sheet of an Excel file, you can use the
``to_excel`` instance method.  The arguments are largely the same as ``to_csv``
described above, the first argument being the name of the excel file, and the
optional second argument the name of the sheet to which the DataFrame should be
written.  For example:

.. code-block:: python

   df.to_excel('path_to_file.xlsx', sheet_name='Sheet1')

Files with a ``.xls`` extension will be written using ``xlwt`` and those with a
``.xlsx`` extension will be written using ``xlsxwriter`` (if available) or
``openpyxl``.

The DataFrame will be written in a way that tries to mimic the REPL output. One
difference from 0.12.0 is that the ``index_label`` will be placed in the second
row instead of the first. You can get the previous behaviour by setting the
``merge_cells`` option in ``to_excel()`` to ``False``:

.. code-block:: python

   df.to_excel('path_to_file.xlsx', index_label='label', merge_cells=False)

The Panel class also has a ``to_excel`` instance method,
which writes each DataFrame in the Panel to a separate sheet.

In order to write separate DataFrames to separate sheets in a single Excel file,
one can pass an :class:`~pandas.io.excel.ExcelWriter`.

.. code-block:: python

   with ExcelWriter('path_to_file.xlsx') as writer:
       df1.to_excel(writer, sheet_name='Sheet1')
       df2.to_excel(writer, sheet_name='Sheet2')

.. note::

    Wringing a little more performance out of ``read_excel``
    Internally, Excel stores all numeric data as floats. Because this can
    produce unexpected behavior when reading in data, pandas defaults to trying
    to convert integers to floats if it doesn't lose information (``1.0 -->
    1``).  You can pass ``convert_float=False`` to disable this behavior, which
    may give a slight performance improvement.

.. _io.excel_writing_buffer:

Writing Excel Files to Memory
+++++++++++++++++++++++++++++

.. versionadded:: 0.17

Pandas supports writing Excel files to buffer-like objects such as ``StringIO`` or
``BytesIO`` using :class:`~pandas.io.excel.ExcelWriter`.

.. versionadded:: 0.17

Added support for Openpyxl >= 2.2

.. code-block:: python

   # Safe import for either Python 2.x or 3.x
   try:
       from io import BytesIO
   except ImportError:
       from cStringIO import StringIO as BytesIO

   bio = BytesIO()

   # By setting the 'engine' in the ExcelWriter constructor.
   writer = ExcelWriter(bio, engine='xlsxwriter')
   df.to_excel(writer, sheet_name='Sheet1')

   # Save the workbook
   writer.save()

   # Seek to the beginning and read to copy the workbook to a variable in memory
   bio.seek(0)
   workbook = bio.read()

.. note::

    ``engine`` is optional but recommended.  Setting the engine determines
    the version of workbook produced. Setting ``engine='xlrd'`` will produce an
    Excel 2003-format workbook (xls).  Using either ``'openpyxl'`` or
    ``'xlsxwriter'`` will produce an Excel 2007-format workbook (xlsx). If
    omitted, an Excel 2007-formatted workbook is produced.

.. _io.excel.writers:

Excel writer engines
''''''''''''''''''''

.. versionadded:: 0.13

``pandas`` chooses an Excel writer via two methods:

1. the ``engine`` keyword argument
2. the filename extension (via the default specified in config options)

By default, ``pandas`` uses the `XlsxWriter`_  for ``.xlsx`` and `openpyxl`_
for ``.xlsm`` files and `xlwt`_ for ``.xls`` files.  If you have multiple
engines installed, you can set the default engine through :ref:`setting the
config options <options>` ``io.excel.xlsx.writer`` and
``io.excel.xls.writer``. pandas will fall back on `openpyxl`_ for ``.xlsx``
files if `Xlsxwriter`_ is not available.

.. _XlsxWriter: http://xlsxwriter.readthedocs.org
.. _openpyxl: http://openpyxl.readthedocs.org/
.. _xlwt: http://www.python-excel.org

To specify which writer you want to use, you can pass an engine keyword
argument to ``to_excel`` and to ``ExcelWriter``. The built-in engines are:

- ``openpyxl``: This includes stable support for Openpyxl from 1.6.1. However,
  it is advised to use version 2.2 and higher, especially when working with
  styles.
- ``xlsxwriter``
- ``xlwt``

.. code-block:: python

   # By setting the 'engine' in the DataFrame and Panel 'to_excel()' methods.
   df.to_excel('path_to_file.xlsx', sheet_name='Sheet1', engine='xlsxwriter')

   # By setting the 'engine' in the ExcelWriter constructor.
   writer = ExcelWriter('path_to_file.xlsx', engine='xlsxwriter')

   # Or via pandas configuration.
   from pandas import options
   options.io.excel.xlsx.writer = 'xlsxwriter'

   df.to_excel('path_to_file.xlsx', sheet_name='Sheet1')