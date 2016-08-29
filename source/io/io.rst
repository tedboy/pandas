.. _io:

.. currentmodule:: pandas

===============================
IO Tools (Text, CSV, HDF5, ...)
===============================



.. toctree::
    :maxdepth: 1
    :caption: Contents
    :name: io

    io1
    io2
    io3
    io4
    io5
    io6
    io7
    io8
    io9
    io10
    io11
    io12
    io13
    io14
    io15

>>> import os
>>> import csv
>>> from pandas.compat import StringIO, BytesIO
>>> import pandas as pd
>>> ExcelWriter = pd.ExcelWriter
>>> 
>>> import numpy as np
>>> np.random.seed(123456)
>>> randn = np.random.randn
>>> np.set_printoptions(precision=4, suppress=True)
>>> 
>>> import matplotlib.pyplot as plt
>>> plt.close('all')
>>> 
>>> import pandas.util.testing as tm
>>> pd.options.display.max_rows=15
>>> clipdf = pd.DataFrame({'A':[1,2,3],'B':[4,5,6],'C':['p','q','r']},
>>>                       index=['x','y','z'])