.. currentmodule:: pandas
.. _api.series:

Series
------

Constructor
~~~~~~~~~~~


.. autosummary::
   :toctree: generated/

   Series

Attributes
~~~~~~~~~~
**Axes**
  * **index**: axis labels

.. autosummary::
   :toctree: generated/

   Series.values
   Series.dtype
   Series.ftype
   Series.shape
   Series.nbytes
   Series.ndim
   Series.size
   Series.strides
   Series.itemsize
   Series.base
   Series.T
   Series.memory_usage

Conversion
~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Series.astype
   Series.copy
   Series.isnull
   Series.notnull

Indexing, iteration
~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Series.get
   Series.at
   Series.iat
   Series.ix
   Series.loc
   Series.iloc
   Series.__iter__
   Series.iteritems

For more information on ``.at``, ``.iat``, ``.ix``, ``.loc``, and
``.iloc``,  see the :ref:`indexing documentation <indexing>`.

Binary operator functions
~~~~~~~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Series.add
   Series.sub
   Series.mul
   Series.div
   Series.truediv
   Series.floordiv
   Series.mod
   Series.pow
   Series.radd
   Series.rsub
   Series.rmul
   Series.rdiv
   Series.rtruediv
   Series.rfloordiv
   Series.rmod
   Series.rpow
   Series.combine
   Series.combine_first
   Series.round
   Series.lt
   Series.gt
   Series.le
   Series.ge
   Series.ne
   Series.eq

Function application, GroupBy & Window
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Series.apply
   Series.map
   Series.groupby
   Series.rolling
   Series.expanding
   Series.ewm

.. _api.series.stats:

Computations / Descriptive Stats
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Series.abs
   Series.all
   Series.any
   Series.autocorr
   Series.between
   Series.clip
   Series.clip_lower
   Series.clip_upper
   Series.corr
   Series.count
   Series.cov
   Series.cummax
   Series.cummin
   Series.cumprod
   Series.cumsum
   Series.describe
   Series.diff
   Series.factorize
   Series.kurt
   Series.mad
   Series.max
   Series.mean
   Series.median
   Series.min
   Series.mode
   Series.nlargest
   Series.nsmallest
   Series.pct_change
   Series.prod
   Series.quantile
   Series.rank
   Series.sem
   Series.skew
   Series.std
   Series.sum
   Series.var
   Series.unique
   Series.nunique
   Series.is_unique
   Series.is_monotonic
   Series.is_monotonic_increasing
   Series.is_monotonic_decreasing
   Series.value_counts

Reindexing / Selection / Label manipulation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Series.align
   Series.drop
   Series.drop_duplicates
   Series.duplicated
   Series.equals
   Series.first
   Series.head
   Series.idxmax
   Series.idxmin
   Series.isin
   Series.last
   Series.reindex
   Series.reindex_like
   Series.rename
   Series.rename_axis
   Series.reset_index
   Series.sample
   Series.select
   Series.take
   Series.tail
   Series.truncate
   Series.where
   Series.mask

Missing data handling
~~~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Series.dropna
   Series.fillna
   Series.interpolate

Reshaping, sorting
~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Series.argsort
   Series.reorder_levels
   Series.sort_values
   Series.sort_index
   Series.sortlevel
   Series.swaplevel
   Series.unstack
   Series.searchsorted

Combining / joining / merging
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Series.append
   Series.replace
   Series.update

Time series-related
~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Series.asfreq
   Series.asof
   Series.shift
   Series.first_valid_index
   Series.last_valid_index
   Series.resample
   Series.tz_convert
   Series.tz_localize

Datetimelike Properties
~~~~~~~~~~~~~~~~~~~~~~~

``Series.dt`` can be used to access the values of the series as
datetimelike and return several properties.
These can be accessed like ``Series.dt.<property>``.

**Datetime Properties**

.. autosummary::
   :toctree: generated/
   :template: autosummary/accessor_attribute.rst

   Series.dt.date
   Series.dt.time
   Series.dt.year
   Series.dt.month
   Series.dt.day
   Series.dt.hour
   Series.dt.minute
   Series.dt.second
   Series.dt.microsecond
   Series.dt.nanosecond
   Series.dt.week
   Series.dt.weekofyear
   Series.dt.dayofweek
   Series.dt.weekday
   Series.dt.weekday_name
   Series.dt.dayofyear
   Series.dt.quarter
   Series.dt.is_month_start
   Series.dt.is_month_end
   Series.dt.is_quarter_start
   Series.dt.is_quarter_end
   Series.dt.is_year_start
   Series.dt.is_year_end
   Series.dt.is_leap_year
   Series.dt.daysinmonth
   Series.dt.days_in_month
   Series.dt.tz
   Series.dt.freq

**Datetime Methods**

.. autosummary::
   :toctree: generated/
   :template: autosummary/accessor_method.rst

   Series.dt.to_period
   Series.dt.to_pydatetime
   Series.dt.tz_localize
   Series.dt.tz_convert
   Series.dt.normalize
   Series.dt.strftime
   Series.dt.round
   Series.dt.floor
   Series.dt.ceil

**Timedelta Properties**

.. autosummary::
   :toctree: generated/
   :template: autosummary/accessor_attribute.rst

   Series.dt.days
   Series.dt.seconds
   Series.dt.microseconds
   Series.dt.nanoseconds
   Series.dt.components

**Timedelta Methods**

.. autosummary::
   :toctree: generated/
   :template: autosummary/accessor_method.rst

   Series.dt.to_pytimedelta
   Series.dt.total_seconds

String handling
~~~~~~~~~~~~~~~
``Series.str`` can be used to access the values of the series as
strings and apply several methods to it. These can be accessed like
``Series.str.<function/property>``.

.. autosummary::
   :toctree: generated/
   :template: autosummary/accessor_method.rst

   Series.str.capitalize
   Series.str.cat
   Series.str.center
   Series.str.contains
   Series.str.count
   Series.str.decode
   Series.str.encode
   Series.str.endswith
   Series.str.extract
   Series.str.extractall
   Series.str.find
   Series.str.findall
   Series.str.get
   Series.str.index
   Series.str.join
   Series.str.len
   Series.str.ljust
   Series.str.lower
   Series.str.lstrip
   Series.str.match
   Series.str.normalize
   Series.str.pad
   Series.str.partition
   Series.str.repeat
   Series.str.replace
   Series.str.rfind
   Series.str.rindex
   Series.str.rjust
   Series.str.rpartition
   Series.str.rstrip
   Series.str.slice
   Series.str.slice_replace
   Series.str.split
   Series.str.rsplit
   Series.str.startswith
   Series.str.strip
   Series.str.swapcase
   Series.str.title
   Series.str.translate
   Series.str.upper
   Series.str.wrap
   Series.str.zfill
   Series.str.isalnum
   Series.str.isalpha
   Series.str.isdigit
   Series.str.isspace
   Series.str.islower
   Series.str.isupper
   Series.str.istitle
   Series.str.isnumeric
   Series.str.isdecimal
   Series.str.get_dummies

..
    The following is needed to ensure the generated pages are created with the
    correct template (otherwise they would be created in the Series/Index class page)

..
    .. autosummary::
       :toctree: generated/
       :template: autosummary/accessor.rst

       Series.str
       Series.cat
       Series.dt
       Index.str
       CategoricalIndex.str
       MultiIndex.str
       DatetimeIndex.str
       TimedeltaIndex.str

.. _api.categorical:

Categorical
~~~~~~~~~~~

If the Series is of dtype ``category``, ``Series.cat`` can be used to change the the categorical
data. This accessor is similar to the ``Series.dt`` or ``Series.str`` and has the
following usable methods and properties:

.. autosummary::
   :toctree: generated/
   :template: autosummary/accessor_attribute.rst

   Series.cat.categories
   Series.cat.ordered
   Series.cat.codes

.. autosummary::
   :toctree: generated/
   :template: autosummary/accessor_method.rst

   Series.cat.rename_categories
   Series.cat.reorder_categories
   Series.cat.add_categories
   Series.cat.remove_categories
   Series.cat.remove_unused_categories
   Series.cat.set_categories
   Series.cat.as_ordered
   Series.cat.as_unordered

To create a Series of dtype ``category``, use ``cat = s.astype("category")``.

The following two ``Categorical`` constructors are considered API but should only be used when
adding ordering information or special categories is need at creation time of the categorical data:

.. autosummary::
   :toctree: generated/
   :template: autosummary/class_without_autosummary.rst

   Categorical

.. autosummary::
   :toctree: generated/

   Categorical.from_codes

``np.asarray(categorical)`` works by implementing the array interface. Be aware, that this converts
the Categorical back to a numpy array, so levels and order information is not preserved!

.. autosummary::
   :toctree: generated/

   Categorical.__array__

Plotting
~~~~~~~~

``Series.plot`` is both a callable method and a namespace attribute for
specific plotting methods of the form ``Series.plot.<kind>``.

.. autosummary::
   :toctree: generated/
   :template: autosummary/accessor_callable.rst

   Series.plot

.. autosummary::
   :toctree: generated/
   :template: autosummary/accessor_method.rst

   Series.plot.area
   Series.plot.bar
   Series.plot.barh
   Series.plot.box
   Series.plot.density
   Series.plot.hist
   Series.plot.kde
   Series.plot.line
   Series.plot.pie

.. autosummary::
   :toctree: generated/

   Series.hist

Serialization / IO / Conversion
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Series.from_csv
   Series.to_pickle
   Series.to_csv
   Series.to_dict
   Series.to_frame
   Series.to_xarray
   Series.to_hdf
   Series.to_sql
   Series.to_msgpack
   Series.to_json
   Series.to_sparse
   Series.to_dense
   Series.to_string
   Series.to_clipboard

Sparse methods
~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   SparseSeries.to_coo
   SparseSeries.from_coo       