.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import pandas as pd
   import numpy as np
   np.random.seed(123456)

.. _options.east_asian_width:

Unicode Formatting
------------------

.. warning::

   Enabling this option will affect the performance for printing of DataFrame and Series (about 2 times slower).
   Use only when it is actually required.

Some East Asian countries use Unicode characters its width is corresponding to 2 alphabets.
If DataFrame or Series contains these characters, default output cannot be aligned properly.

.. note:: Screen captures are attached for each outputs to show the actual results.

.. code-block:: python
   
   df = pd.DataFrame({u'国籍': ['UK', u'日本'], u'名前': ['Alice', u'しのぶ']})
   df;

.. image:: ../_static/option_unicode01.png

Enable ``display.unicode.east_asian_width`` allows pandas to check each character's "East Asian Width" property.
These characters can be aligned properly by checking this property, but it takes longer time than standard ``len`` function.

.. ipython:: python

   pd.set_option('display.unicode.east_asian_width', True)
   df;

.. image:: ../_static/option_unicode02.png

In addition, Unicode contains characters which width is "Ambiguous". These character's width should be either 1 or 2 depending on terminal setting or encoding. Because this cannot be distinguished from Python, ``display.unicode.ambiguous_as_wide`` option is added to handle this.

By default, "Ambiguous" character's width, "¡" (inverted exclamation) in below example, is regarded as 1.

.. code-block:: python

   df = pd.DataFrame({'a': ['xxx', u'¡¡'], 'b': ['yyy', u'¡¡']})
   df;

.. image:: ../_static/option_unicode03.png

Enabling ``display.unicode.ambiguous_as_wide`` lets pandas to figure these character's width as 2. Note that this option will be effective only when ``display.unicode.east_asian_width`` is enabled. Confirm starting position has been changed, but is not aligned properly because the setting is mismatched with this environment.

.. ipython:: python

   pd.set_option('display.unicode.ambiguous_as_wide', True)
   df;

.. image:: ../_static/option_unicode04.png

.. ipython:: python
   :suppress:

   pd.set_option('display.unicode.east_asian_width', False)
   pd.set_option('display.unicode.ambiguous_as_wide', False)
