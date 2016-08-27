.. _cookbook:

.. currentmodule:: pandas

********
Cookbook
********

This is a repository for *short and sweet* examples and links for useful pandas recipes. We encourage users to add to this documentation.

Adding interesting links and/or inline examples to this section is a great *First Pull Request*.

Simplified, condensed, new-user friendly, in-line examples have been inserted where possible to augment the Stack-Overflow and GitHub links.  Many of the links contain expanded information, above what the in-line examples offer.

These examples are written for python 3.4.  Minor tweaks might be necessary for earlier python versions.

.. toctree::
    :maxdepth: 2
    :caption: Contents
    :name: cookbook

    cookbook1
    cookbook2
    cookbook3
    cookbook4
    cookbook5
    cookbook6
    cookbook7
    cookbook8
    cookbook9
    cookbook10
    cookbook11
    cookbook12
    cookbook13

.. ipython:: python

   import pandas as pd
   import numpy as np

   import random
   import os
   import itertools
   import functools
   import datetime

   np.random.seed(123456)
   pd.options.display.max_rows=8
   import matplotlib
   matplotlib.style.use('ggplot')
   np.set_printoptions(precision=4, suppress=True)