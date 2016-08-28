.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import pandas as pd
   import numpy as np
   np.random.seed(123456)

Overview
--------
pandas has an options system that lets you customize some aspects of its behaviour,
display-related options being those the user is most likely to adjust.

Options have a full "dotted-style", case-insensitive name (e.g. ``display.max_rows``).
You can get/set options directly as attributes of the top-level ``options`` attribute:

.. ipython:: python

   import pandas as pd
   pd.options.display.max_rows
   pd.options.display.max_rows = 999
   pd.options.display.max_rows

There is also an API composed of 5 relevant functions, available directly from the ``pandas``
namespace:

- :func:`~pandas.get_option` / :func:`~pandas.set_option` - get/set the value of a single option.
- :func:`~pandas.reset_option` - reset one or more options to their default value.
- :func:`~pandas.describe_option` - print the descriptions of one or more options.
- :func:`~pandas.option_context` - execute a codeblock with a set of options
  that revert to prior settings after execution.

**Note:** developers can check out pandas/core/config.py for more info.

All of the functions above accept a regexp pattern (``re.search`` style) as an argument,
and so passing in a substring will work - as long as it is unambiguous :

.. ipython:: python

   pd.get_option("display.max_rows")
   pd.set_option("display.max_rows",101)
   pd.get_option("display.max_rows")
   pd.set_option("max_r",102)
   pd.get_option("display.max_rows")


The following will **not work** because it matches multiple option names, e.g.
``display.max_colwidth``, ``display.max_rows``, ``display.max_columns``:

.. ipython:: python
   :okexcept:

   try:
       pd.get_option("column")
   except KeyError as e:
       print(e)


**Note:** Using this form of shorthand may cause your code to break if new options with similar names are added in future versions.


You can get a list of available options and their descriptions with ``describe_option``. When called
with no argument ``describe_option`` will print out the descriptions for all available options.

.. ipython:: python
   :suppress:
   :okwarning:

   pd.reset_option("all")
