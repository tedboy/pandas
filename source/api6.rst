.. currentmodule:: pandas
.. _api.panel4d:

Panel4D
-------

Constructor
~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Panel4D

Serialization / IO / Conversion
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Panel4D.to_xarray

Attributes and underlying data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**Axes**

  * **labels**: axis 1; each label corresponds to a Panel contained inside
  * **items**: axis 2; each item corresponds to a DataFrame contained inside
  * **major_axis**: axis 3; the index (rows) of each of the DataFrames
  * **minor_axis**: axis 4; the columns of each of the DataFrames

.. autosummary::
   :toctree: generated/

   Panel4D.values
   Panel4D.axes
   Panel4D.ndim
   Panel4D.size
   Panel4D.shape
   Panel4D.dtypes
   Panel4D.ftypes
   Panel4D.get_dtype_counts
   Panel4D.get_ftype_counts

Conversion
~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Panel4D.astype
   Panel4D.copy
   Panel4D.isnull
   Panel4D.notnull