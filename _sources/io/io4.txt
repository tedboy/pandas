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

HTML
----

.. _io.read_html:

Reading HTML Content
''''''''''''''''''''''

.. warning::

   We **highly encourage** you to read the :ref:`HTML parsing gotchas
   <html-gotchas>` regarding the issues surrounding the
   BeautifulSoup4/html5lib/lxml parsers.

.. versionadded:: 0.12.0

The top-level :func:`~pandas.io.html.read_html` function can accept an HTML
string/file/URL and will parse HTML tables into list of pandas DataFrames.
Let's look at a few examples.

.. note::

   ``read_html`` returns a ``list`` of ``DataFrame`` objects, even if there is
   only a single table contained in the HTML content

Read a URL with no options

.. ipython:: python

   url = 'http://www.fdic.gov/bank/individual/failed/banklist.html'
   dfs = pd.read_html(url)
   dfs

.. note::

   The data from the above URL changes every Monday so the resulting data above
   and the data below may be slightly different.

Read in the content of the file from the above URL and pass it to ``read_html``
as a string

.. ipython:: python

   import os
   file_path = os.path.abspath(os.path.join('source', '_static', 'banklist.html'))

.. ipython:: python

   with open(file_path, 'r') as f:
       dfs = pd.read_html(f.read())
   dfs

You can even pass in an instance of ``StringIO`` if you so desire

.. ipython:: python

   with open(file_path, 'r') as f:
       sio = StringIO(f.read())

   dfs = pd.read_html(sio)
   dfs

.. note::

   The following examples are not run by the IPython evaluator due to the fact
   that having so many network-accessing functions slows down the documentation
   build. If you spot an error or an example that doesn't run, please do not
   hesitate to report it over on `pandas GitHub issues page
   <http://www.github.com/pydata/pandas/issues>`__.


Read a URL and match a table that contains specific text

.. code-block:: python

   match = 'Metcalf Bank'
   df_list = pd.read_html(url, match=match)

Specify a header row (by default ``<th>`` elements are used to form the column
index); if specified, the header row is taken from the data minus the parsed
header elements (``<th>`` elements).

.. code-block:: python

   dfs = pd.read_html(url, header=0)

Specify an index column

.. code-block:: python

   dfs = pd.read_html(url, index_col=0)

Specify a number of rows to skip

.. code-block:: python

   dfs = pd.read_html(url, skiprows=0)

Specify a number of rows to skip using a list (``xrange`` (Python 2 only) works
as well)

.. code-block:: python

   dfs = pd.read_html(url, skiprows=range(2))

Specify an HTML attribute

.. code-block:: python

   dfs1 = pd.read_html(url, attrs={'id': 'table'})
   dfs2 = pd.read_html(url, attrs={'class': 'sortable'})
   print(np.array_equal(dfs1[0], dfs2[0]))  # Should be True

Specify values that should be converted to NaN

.. code-block:: python

   dfs = pd.read_html(url, na_values=['No Acquirer'])

.. versionadded:: 0.19

Specify whether to keep the default set of NaN values

.. code-block:: python

   dfs = pd.read_html(url, keep_default_na=False)

.. versionadded:: 0.19

Specify converters for columns. This is useful for numerical text data that has
leading zeros.  By default columns that are numerical are cast to numeric
types and the leading zeros are lost.  To avoid this, we can convert these
columns to strings.

.. code-block:: python

   url_mcc = 'https://en.wikipedia.org/wiki/Mobile_country_code'
   dfs = pd.read_html(url_mcc, match='Telekom Albania', header=0, converters={'MNC':
   str})

.. versionadded:: 0.19

Use some combination of the above

.. code-block:: python

   dfs = pd.read_html(url, match='Metcalf Bank', index_col=0)

Read in pandas ``to_html`` output (with some loss of floating point precision)

.. code-block:: python

   df = pd.DataFrame(randn(2, 2))
   s = df.to_html(float_format='{0:.40g}'.format)
   dfin = pd.read_html(s, index_col=0)

The ``lxml`` backend will raise an error on a failed parse if that is the only
parser you provide (if you only have a single parser you can provide just a
string, but it is considered good practice to pass a list with one string if,
for example, the function expects a sequence of strings)

.. code-block:: python

   dfs = pd.read_html(url, 'Metcalf Bank', index_col=0, flavor=['lxml'])

or

.. code-block:: python

   dfs = pd.read_html(url, 'Metcalf Bank', index_col=0, flavor='lxml')

However, if you have bs4 and html5lib installed and pass ``None`` or ``['lxml',
'bs4']`` then the parse will most likely succeed. Note that *as soon as a parse
succeeds, the function will return*.

.. code-block:: python

   dfs = pd.read_html(url, 'Metcalf Bank', index_col=0, flavor=['lxml', 'bs4'])


.. _io.html:

Writing to HTML files
''''''''''''''''''''''

``DataFrame`` objects have an instance method ``to_html`` which renders the
contents of the ``DataFrame`` as an HTML table. The function arguments are as
in the method ``to_string`` described above.

.. note::

   Not all of the possible options for ``DataFrame.to_html`` are shown here for
   brevity's sake. See :func:`~pandas.core.frame.DataFrame.to_html` for the
   full set of options.

.. ipython:: python
   :suppress:

   def write_html(df, filename, *args, **kwargs):
       static = os.path.abspath(os.path.join('source', '_static'))
       with open(os.path.join(static, filename + '.html'), 'w') as f:
           df.to_html(f, *args, **kwargs)

.. ipython:: python

   df = pd.DataFrame(randn(2, 2))
   df
   print(df.to_html())  # raw html

.. ipython:: python
   :suppress:

   write_html(df, 'basic')

HTML:

.. raw:: html
   :file: _static/basic.html

The ``columns`` argument will limit the columns shown

.. ipython:: python

   print(df.to_html(columns=[0]))

.. ipython:: python
   :suppress:

   write_html(df, 'columns', columns=[0])

HTML:

.. raw:: html
   :file: _static/columns.html

``float_format`` takes a Python callable to control the precision of floating
point values

.. ipython:: python

   print(df.to_html(float_format='{0:.10f}'.format))

.. ipython:: python
   :suppress:

   write_html(df, 'float_format', float_format='{0:.10f}'.format)

HTML:

.. raw:: html
   :file: _static/float_format.html

``bold_rows`` will make the row labels bold by default, but you can turn that
off

.. ipython:: python

   print(df.to_html(bold_rows=False))

.. ipython:: python
   :suppress:

   write_html(df, 'nobold', bold_rows=False)

.. raw:: html
   :file: _static/nobold.html

The ``classes`` argument provides the ability to give the resulting HTML
table CSS classes. Note that these classes are *appended* to the existing
``'dataframe'`` class.

.. ipython:: python

   print(df.to_html(classes=['awesome_table_class', 'even_more_awesome_class']))

Finally, the ``escape`` argument allows you to control whether the
"<", ">" and "&" characters escaped in the resulting HTML (by default it is
``True``). So to get the HTML without escaped characters pass ``escape=False``

.. ipython:: python

   df = pd.DataFrame({'a': list('&<>'), 'b': randn(3)})


.. ipython:: python
   :suppress:

   write_html(df, 'escape')
   write_html(df, 'noescape', escape=False)

Escaped:

.. ipython:: python

   print(df.to_html())

.. raw:: html
   :file: _static/escape.html

Not escaped:

.. ipython:: python

   print(df.to_html(escape=False))

.. raw:: html
   :file: _static/noescape.html

.. note::

   Some browsers may not show a difference in the rendering of the previous two
   HTML tables.