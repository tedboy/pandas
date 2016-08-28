.. _dsintro:

************************
Intro to Data Structures
************************

We'll start with a quick, non-comprehensive overview of the fundamental data
structures in pandas to get you started. The fundamental behavior about data
types, indexing, and axis labeling / alignment apply across all of the
objects.

Here is a basic tenet to keep in mind: **data alignment is intrinsic**. The link
between labels and data will not be broken unless done so explicitly by you.

We'll give a brief intro to the data structures, then consider all of the broad
categories of functionality and methods in separate sections.

.. toctree::
    :maxdepth: 1
    :caption: Contents
    :name: dsintro

    dsintro1
    dsintro2
    dsintro3
    dsintro4
    dsintro5


.. currentmodule:: pandas

.. ipython:: python

   import numpy as np
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.set_option('display.precision', 4, 'display.max_columns', 8)
   pd.options.display.max_rows = 8

   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')