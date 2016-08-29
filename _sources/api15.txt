.. currentmodule:: pandas

Style
-----
.. currentmodule:: pandas.formats.style

``Styler`` objects are returned by :attr:`pandas.DataFrame.style`.


Constructor
~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Styler

Style Application
~~~~~~~~~~~~~~~~~
.. autosummary::
   :toctree: generated/

   Styler.apply
   Styler.applymap
   Styler.format
   Styler.set_precision
   Styler.set_table_styles
   Styler.set_caption
   Styler.set_properties
   Styler.set_uuid
   Styler.clear

Builtin Styles
~~~~~~~~~~~~~~

.. autosummary::
   :toctree: generated/

   Styler.highlight_max
   Styler.highlight_min
   Styler.highlight_null
   Styler.background_gradient
   Styler.bar

Style Export and Import
~~~~~~~~~~~~~~~~~~~~~~~

.. autosummary::
   :toctree: generated/

   Styler.render
   Styler.export
   Styler.use