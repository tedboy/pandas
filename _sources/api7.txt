.. currentmodule:: pandas
.. _api.index:

Index
-----

**Many of these methods or variants thereof are available on the objects
that contain an index (Series/Dataframe) and those should most likely be
used before calling these methods directly.**

.. autosummary::
   :toctree: generated/

   Index

Attributes
~~~~~~~~~~

.. autosummary::
   :toctree: generated/

   Index.values
   Index.is_monotonic
   Index.is_monotonic_increasing
   Index.is_monotonic_decreasing
   Index.is_unique
   Index.has_duplicates
   Index.dtype
   Index.inferred_type
   Index.is_all_dates
   Index.shape
   Index.nbytes
   Index.ndim
   Index.size
   Index.strides
   Index.itemsize
   Index.base
   Index.T
   Index.memory_usage

Modifying and Computations
~~~~~~~~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Index.all
   Index.any
   Index.argmin
   Index.argmax
   Index.copy
   Index.delete
   Index.drop
   Index.drop_duplicates
   Index.duplicated
   Index.equals
   Index.factorize
   Index.identical
   Index.insert
   Index.min
   Index.max
   Index.reindex
   Index.repeat
   Index.where
   Index.take
   Index.putmask
   Index.set_names
   Index.unique
   Index.nunique
   Index.value_counts
   Index.fillna
   Index.dropna

Conversion
~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Index.astype
   Index.tolist
   Index.to_datetime
   Index.to_series

Sorting
~~~~~~~
.. autosummary::
   :toctree: generated/

   Index.argsort
   Index.sort_values

Time-specific operations
~~~~~~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Index.shift

Combining / joining / set operations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Index.append
   Index.join
   Index.intersection
   Index.union
   Index.difference
   Index.symmetric_difference

Selecting
~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Index.get_indexer
   Index.get_indexer_non_unique
   Index.get_level_values
   Index.get_loc
   Index.get_value
   Index.isin
   Index.slice_indexer
   Index.slice_locs