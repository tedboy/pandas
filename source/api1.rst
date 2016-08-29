.. currentmodule:: pandas

.. _api.functions:

Input/Output
------------

Pickling
~~~~~~~~

.. autosummary::
   :toctree: generated/

   read_pickle

Flat File
~~~~~~~~~

.. autosummary::
   :toctree: generated/

   read_table
   read_csv
   read_fwf

Clipboard
~~~~~~~~~

.. autosummary::
   :toctree: generated/

   read_clipboard

Excel
~~~~~

.. autosummary::
   :toctree: generated/

   read_excel
   ExcelFile.parse

JSON
~~~~

.. autosummary::
   :toctree: generated/

   read_json

.. currentmodule:: pandas.io.json

.. autosummary::
   :toctree: generated/

   json_normalize

.. currentmodule:: pandas

HTML
~~~~

.. autosummary::
   :toctree: generated/

   read_html

HDFStore: PyTables (HDF5)
~~~~~~~~~~~~~~~~~~~~~~~~~

.. autosummary::
   :toctree: generated/

   read_hdf
   HDFStore.put
   HDFStore.append
   HDFStore.get
   HDFStore.select

SAS
~~~

.. autosummary::
   :toctree: generated/

   read_sas

SQL
~~~

.. autosummary::
   :toctree: generated/

   read_sql_table
   read_sql_query
   read_sql

Google BigQuery
~~~~~~~~~~~~~~~
.. currentmodule:: pandas.io.gbq

.. autosummary::
   :toctree: generated/

   read_gbq
   to_gbq


.. currentmodule:: pandas


STATA
~~~~~

.. autosummary::
   :toctree: generated/

   read_stata

.. currentmodule:: pandas.io.stata

.. autosummary::
   :toctree: generated/

   StataReader.data
   StataReader.data_label
   StataReader.value_labels
   StataReader.variable_labels
   StataWriter.write_file