.. currentmodule:: pandas

Introduction
------------

The pandas I/O API is a set of top level ``reader`` functions accessed like ``pd.read_csv()`` that generally return a ``pandas``
object.

    * :ref:`read_csv<io.read_csv_table>`
    * :ref:`read_excel<io.excel_reader>`
    * :ref:`read_hdf<io.hdf5>`
    * :ref:`read_sql<io.sql>`
    * :ref:`read_json<io.json_reader>`
    * :ref:`read_msgpack<io.msgpack>` (experimental)
    * :ref:`read_html<io.read_html>`
    * :ref:`read_gbq<io.bigquery_reader>` (experimental)
    * :ref:`read_stata<io.stata_reader>`
    * :ref:`read_sas<io.sas_reader>`
    * :ref:`read_clipboard<io.clipboard>`
    * :ref:`read_pickle<io.pickle>`

The corresponding ``writer`` functions are object methods that are accessed like ``df.to_csv()``

    * :ref:`to_csv<io.store_in_csv>`
    * :ref:`to_excel<io.excel_writer>`
    * :ref:`to_hdf<io.hdf5>`
    * :ref:`to_sql<io.sql>`
    * :ref:`to_json<io.json_writer>`
    * :ref:`to_msgpack<io.msgpack>` (experimental)
    * :ref:`to_html<io.html>`
    * :ref:`to_gbq<io.bigquery_writer>` (experimental)
    * :ref:`to_stata<io.stata_writer>`
    * :ref:`to_clipboard<io.clipboard>`
    * :ref:`to_pickle<io.pickle>`

:ref:`Here <io.perf>` is an informal performance comparison for some of these IO methods.

.. note::
   For examples that use the ``StringIO`` class, make sure you import it
   according to your Python version, i.e. ``from StringIO import StringIO`` for
   Python 2 and ``from io import StringIO`` for Python 3.