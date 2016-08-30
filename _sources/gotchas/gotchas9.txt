.. ipython:: python
   :suppress:

   import numpy as np
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. _html-gotchas:

HTML Table Parsing
------------------
There are some versioning issues surrounding the libraries that are used to
parse HTML tables in the top-level pandas io function ``read_html``.

**Issues with** |lxml|_

   * Benefits

     * |lxml|_ is very fast

     * |lxml|_ requires Cython to install correctly.

   * Drawbacks

     * |lxml|_ does *not* make any guarantees about the results of its parse
       *unless* it is given |svm|_.

     * In light of the above, we have chosen to allow you, the user, to use the
       |lxml|_ backend, but **this backend will use** |html5lib|_ if |lxml|_
       fails to parse

     * It is therefore *highly recommended* that you install both
       |BeautifulSoup4|_ and |html5lib|_, so that you will still get a valid
       result (provided everything else is valid) even if |lxml|_ fails.

**Issues with** |BeautifulSoup4|_ **using** |lxml|_ **as a backend**

   * The above issues hold here as well since |BeautifulSoup4|_ is essentially
     just a wrapper around a parser backend.

**Issues with** |BeautifulSoup4|_ **using** |html5lib|_ **as a backend**

   * Benefits

     * |html5lib|_ is far more lenient than |lxml|_ and consequently deals
       with *real-life markup* in a much saner way rather than just, e.g.,
       dropping an element without notifying you.

     * |html5lib|_ *generates valid HTML5 markup from invalid markup
       automatically*. This is extremely important for parsing HTML tables,
       since it guarantees a valid document. However, that does NOT mean that
       it is "correct", since the process of fixing markup does not have a
       single definition.

     * |html5lib|_ is pure Python and requires no additional build steps beyond
       its own installation.

   * Drawbacks

     * The biggest drawback to using |html5lib|_ is that it is slow as
       molasses.  However consider the fact that many tables on the web are not
       big enough for the parsing algorithm runtime to matter. It is more
       likely that the bottleneck will be in the process of reading the raw
       text from the URL over the web, i.e., IO (input-output). For very large
       tables, this might not be true.

**Issues with using** |Anaconda|_

   * `Anaconda`_ ships with `lxml`_ version 3.2.0; the following workaround for
     `Anaconda`_ was successfully used to deal with the versioning issues
     surrounding `lxml`_ and `BeautifulSoup4`_.

   .. note::

      Unless you have *both*:

         * A strong restriction on the upper bound of the runtime of some code
           that incorporates :func:`~pandas.io.html.read_html`
         * Complete knowledge that the HTML you will be parsing will be 100%
           valid at all times

      then you should install `html5lib`_ and things will work swimmingly
      without you having to muck around with `conda`. If you want the best of
      both worlds then install both `html5lib`_ and `lxml`_. If you do install
      `lxml`_ then you need to perform the following commands to ensure that
      lxml will work correctly:

      .. code-block:: sh

         # remove the included version
         conda remove lxml

         # install the latest version of lxml
         pip install 'git+git://github.com/lxml/lxml.git'

         # install the latest version of beautifulsoup4
         pip install 'bzr+lp:beautifulsoup'

      Note that you need `bzr <http://bazaar.canonical.com/en>`__ and `git
      <http://git-scm.com>`__ installed to perform the last two operations.

.. |svm| replace:: **strictly valid markup**
.. _svm: http://validator.w3.org/docs/help.html#validation_basics

.. |html5lib| replace:: **html5lib**
.. _html5lib: https://github.com/html5lib/html5lib-python

.. |BeautifulSoup4| replace:: **BeautifulSoup4**
.. _BeautifulSoup4: http://www.crummy.com/software/BeautifulSoup

.. |lxml| replace:: **lxml**
.. _lxml: http://lxml.de

.. |Anaconda| replace:: **Anaconda**
.. _Anaconda: https://store.continuum.io/cshop/anaconda