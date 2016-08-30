.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   import pandas as pd
   np.random.seed(123456)
   np.set_printoptions(precision=4, suppress=True)
   pd.options.display.max_rows = 8
   import matplotlib
   matplotlib.style.use('ggplot')
   import matplotlib.pyplot as plt
   plt.close('all')

.. ipython:: python

   import matplotlib as mpl
   #mpl.rcParams['legend.fontsize']=20.0
   #print mpl.matplotlib_fname() # location of the rc file
   #print mpl.rcParams # current config
   print mpl.get_backend()

Plotting directly with matplotlib
---------------------------------

In some situations it may still be preferable or necessary to prepare plots
directly with matplotlib, for instance when a certain type of plot or
customization is not (yet) supported by pandas. Series and DataFrame objects
behave like arrays and can therefore be passed directly to matplotlib functions
without explicit casts.

pandas also automatically registers formatters and locators that recognize date
indices, thereby extending date and time support to practically all plot types
available in matplotlib. Although this formatting does not provide the same
level of refinement you would get when plotting via pandas, it can be faster
when plotting a large number of points.

.. note::

    The speed up for large data sets only applies to pandas 0.14.0 and later.

.. ipython:: python
   :suppress:

   np.random.seed(123456)

.. ipython:: python

   price = pd.Series(np.random.randn(150).cumsum(),
                     index=pd.date_range('2000-1-1', periods=150, freq='B'))
   ma = price.rolling(20).mean()
   mstd = price.rolling(20).std()

   plt.figure()

   plt.plot(price.index, price, 'k')
   plt.plot(ma.index, ma, 'b')
   @savefig bollinger.png
   plt.fill_between(mstd.index, ma-2*mstd, ma+2*mstd, color='b', alpha=0.2)

.. ipython:: python
   :suppress:

    plt.close('all')