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

.. _io.msgpack:

msgpack (experimental)
----------------------

.. versionadded:: 0.13.0

Starting in 0.13.0, pandas is supporting the ``msgpack`` format for
object serialization. This is a lightweight portable binary format, similar
to binary JSON, that is highly space efficient, and provides good performance
both on the writing (serialization), and reading (deserialization).

.. warning::

   This is a very new feature of pandas. We intend to provide certain
   optimizations in the io of the ``msgpack`` data. Since this is marked
   as an EXPERIMENTAL LIBRARY, the storage format may not be stable until a future release.

   As a result of writing format changes and other issues:
   
   +----------------------+------------------------+
   | Packed with          | Can be unpacked with   |
   +======================+========================+
   | pre-0.17 / Python 2  | any                    |
   +----------------------+------------------------+
   | pre-0.17 / Python 3  | any                    |
   +----------------------+------------------------+
   | 0.17 / Python 2      | - 0.17 / Python 2      |
   |                      | - >=0.18 / any Python  |
   +----------------------+------------------------+
   | 0.17 / Python 3      | >=0.18 / any Python    |
   +----------------------+------------------------+
   | 0.18                 | >= 0.18                |
   +----------------------+------------------------+

   Reading (files packed by older versions) is backward-compatibile, except for files packed with 0.17 in Python 2, in which case only they can only be unpacked in Python 2.

.. ipython:: python

   df = pd.DataFrame(np.random.rand(5,2),columns=list('AB'))
   df.to_msgpack('foo.msg')
   pd.read_msgpack('foo.msg')
   s = pd.Series(np.random.rand(5),index=pd.date_range('20130101',periods=5))

You can pass a list of objects and you will receive them back on deserialization.

.. ipython:: python

   pd.to_msgpack('foo.msg', df, 'foo', np.array([1,2,3]), s)
   pd.read_msgpack('foo.msg')

You can pass ``iterator=True`` to iterate over the unpacked results

.. ipython:: python

   for o in pd.read_msgpack('foo.msg',iterator=True):
       print o

You can pass ``append=True`` to the writer to append to an existing pack

.. ipython:: python

   df.to_msgpack('foo.msg',append=True)
   pd.read_msgpack('foo.msg')

Unlike other io methods, ``to_msgpack`` is available on both a per-object basis,
``df.to_msgpack()`` and using the top-level ``pd.to_msgpack(...)`` where you
can pack arbitrary collections of python lists, dicts, scalars, while intermixing
pandas objects.

.. ipython:: python

   pd.to_msgpack('foo2.msg', { 'dict' : [ { 'df' : df }, { 'string' : 'foo' }, { 'scalar' : 1. }, { 's' : s } ] })
   pd.read_msgpack('foo2.msg')

.. ipython:: python
   :suppress:
   :okexcept:

   os.remove('foo.msg')
   os.remove('foo2.msg')

Read/Write API
''''''''''''''

Msgpacks can also be read from and written to strings.

.. ipython:: python

   df.to_msgpack()

Furthermore you can concatenate the strings to produce a list of the original objects.

.. ipython:: python

  pd.read_msgpack(df.to_msgpack() + s.to_msgpack())
