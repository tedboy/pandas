Different Choices for Indexing
------------------------------

.. versionadded:: 0.11.0

Object selection has had a number of user-requested additions in order to
support more explicit location based indexing. pandas now supports three types
of multi-axis indexing.

- ``.loc`` is primarily label based, but may also be used with a boolean array. ``.loc`` will raise ``KeyError`` when the items are not found. Allowed inputs are:

  - A single label, e.g. ``5`` or ``'a'``, (note that ``5`` is interpreted as a
    *label* of the index. This use is **not** an integer position along the
    index)
  - A list or array of labels ``['a', 'b', 'c']``
  - A slice object with labels ``'a':'f'``, (note that contrary to usual python
    slices, **both** the start and the stop are included!)
  - A boolean array
  - A ``callable`` function with one argument (the calling Series, DataFrame or Panel) and
    that returns valid output for indexing (one of the above)

      .. versionadded:: 0.18.1

  See more at :ref:`Selection by Label <indexing.label>`

- ``.iloc`` is primarily integer position based (from ``0`` to
  ``length-1`` of the axis), but may also be used with a boolean
  array.  ``.iloc`` will raise ``IndexError`` if a requested
  indexer is out-of-bounds, except *slice* indexers which allow
  out-of-bounds indexing.  (this conforms with python/numpy *slice*
  semantics).  Allowed inputs are:

  - An integer e.g. ``5``
  - A list or array of integers ``[4, 3, 0]``
  - A slice object with ints ``1:7``
  - A boolean array
  - A ``callable`` function with one argument (the calling Series, DataFrame or Panel) and
    that returns valid output for indexing (one of the above)

      .. versionadded:: 0.18.1

  See more at :ref:`Selection by Position <indexing.integer>`

- ``.ix`` supports mixed integer and label based access. It is primarily label
  based, but will fall back to integer positional access unless the corresponding
  axis is of integer type. ``.ix`` is the most general and will
  support any of the inputs in ``.loc`` and ``.iloc``. ``.ix`` also supports floating point
  label schemes. ``.ix`` is exceptionally useful when dealing with mixed positional
  and label based hierarchical indexes.

  However, when an axis is integer based, ONLY
  label based access and not positional access is supported.
  Thus, in such cases, it's usually better to be explicit and use ``.iloc`` or ``.loc``.

  See more at :ref:`Advanced Indexing <advanced>` and :ref:`Advanced
  Hierarchical <advanced.advanced_hierarchical>`.

- ``.loc``, ``.iloc``, ``.ix`` and also ``[]`` indexing can accept a ``callable`` as indexer. See more at :ref:`Selection By Callable <indexing.callable>`.

Getting values from an object with multi-axes selection uses the following
notation (using ``.loc`` as an example, but applies to ``.iloc`` and ``.ix`` as
well). Any of the axes accessors may be the null slice ``:``. Axes left out of
the specification are assumed to be ``:``. (e.g. ``p.loc['a']`` is equiv to
``p.loc['a', :, :]``)

.. csv-table::
    :header: "Object Type", "Indexers"
    :widths: 30, 50
    :delim: ;

    Series; ``s.loc[indexer]``
    DataFrame; ``df.loc[row_indexer,column_indexer]``
    Panel; ``p.loc[item_indexer,major_indexer,minor_indexer]``