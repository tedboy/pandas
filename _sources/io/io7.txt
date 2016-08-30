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

.. _io.pickle:

Pickling
--------

All pandas objects are equipped with ``to_pickle`` methods which use Python's
``cPickle`` module to save data structures to disk using the pickle format.

.. ipython:: python

   df
   df.to_pickle('foo.pkl')

The ``read_pickle`` function in the ``pandas`` namespace can be used to load
any pickled pandas object (or any other pickled object) from file:


.. ipython:: python

   pd.read_pickle('foo.pkl')

.. ipython:: python
   :suppress:

   import os
   os.remove('foo.pkl')

.. warning::

   Loading pickled data received from untrusted sources can be unsafe.

   See: http://docs.python.org/2.7/library/pickle.html

.. warning::

   Several internal refactorings, 0.13 (:ref:`Series Refactoring <whatsnew_0130.refactoring>`), and 0.15 (:ref:`Index Refactoring <whatsnew_0150.refactoring>`),
   preserve compatibility with pickles created prior to these versions. However, these must
   be read with ``pd.read_pickle``, rather than the default python ``pickle.load``.
   See `this question <http://stackoverflow.com/questions/20444593/pandas-compiled-from-source-default-pickle-behavior-changed>`__
   for a detailed explanation.

.. note::

    These methods were previously ``pd.save`` and ``pd.load``, prior to 0.12.0, and are now deprecated.