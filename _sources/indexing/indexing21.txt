.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import numpy as np
   np.random.seed(1234567)
   np.set_printoptions(precision=4, suppress=True)
   import pandas as pd
   pd.options.display.max_rows=8

.. _indexing.view_versus_copy:

Returning a view versus a copy
------------------------------

When setting values in a pandas object, care must be taken to avoid what is called
``chained indexing``. Here is an example.

.. ipython:: python

   dfmi = pd.DataFrame([list('abcd'),
                        list('efgh'),
                        list('ijkl'),
                        list('mnop')],
                       columns=pd.MultiIndex.from_product([['one','two'],
                                                           ['first','second']]))
   dfmi

Compare these two access methods:

.. ipython:: python

   dfmi['one']['second']

.. ipython:: python

   dfmi.loc[:,('one','second')]

These both yield the same results, so which should you use? It is instructive to understand the order
of operations on these and why method 2 (``.loc``) is much preferred over method 1 (chained ``[]``)

``dfmi['one']`` selects the first level of the columns and returns a DataFrame that is singly-indexed.
Then another python operation ``dfmi_with_one['second']`` selects the series indexed by ``'second'`` happens.
This is indicated by the variable ``dfmi_with_one`` because pandas sees these operations as separate events.
e.g. separate calls to ``__getitem__``, so it has to treat them as linear operations, they happen one after another.

Contrast this to ``df.loc[:,('one','second')]`` which passes a nested tuple of ``(slice(None),('one','second'))`` to a single call to
``__getitem__``. This allows pandas to deal with this as a single entity. Furthermore this order of operations *can* be significantly
faster, and allows one to index *both* axes if so desired.

Why does assignment fail when using chained indexing?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The problem in the previous section is just a performance issue. What's up with
the ``SettingWithCopy`` warning? We don't **usually** throw warnings around when
you do something that might cost a few extra milliseconds!

But it turns out that assigning to the product of chained indexing has
inherently unpredictable results. To see this, think about how the Python
interpreter executes this code:

.. code-block:: python

   dfmi.loc[:,('one','second')] = value
   # becomes
   dfmi.loc.__setitem__((slice(None), ('one', 'second')), value)

But this code is handled differently:

.. code-block:: python

   dfmi['one']['second'] = value
   # becomes
   dfmi.__getitem__('one').__setitem__('second', value)

See that ``__getitem__`` in there? Outside of simple cases, it's very hard to
predict whether it will return a view or a copy (it depends on the memory layout
of the array, about which *pandas* makes no guarantees), and therefore whether
the ``__setitem__`` will modify ``dfmi`` or a temporary object that gets thrown
out immediately afterward. **That's** what ``SettingWithCopy`` is warning you
about!

.. note:: You may be wondering whether we should be concerned about the ``loc``
   property in the first example. But ``dfmi.loc`` is guaranteed to be ``dfmi``
   itself with modified indexing behavior, so ``dfmi.loc.__getitem__`` /
   ``dfmi.loc.__setitem__`` operate on ``dfmi`` directly. Of course,
   ``dfmi.loc.__getitem__(idx)`` may be a view or a copy of ``dfmi``.

Sometimes a ``SettingWithCopy`` warning will arise at times when there's no
obvious chained indexing going on. **These** are the bugs that
``SettingWithCopy`` is designed to catch! Pandas is probably trying to warn you
that you've done this:

.. code-block:: python

   def do_something(df):
      foo = df[['bar', 'baz']]  # Is foo a view? A copy? Nobody knows!
      # ... many lines here ...
      foo['quux'] = value       # We don't know whether this will modify df or not!
      return foo

Yikes!

Evaluation order matters
~~~~~~~~~~~~~~~~~~~~~~~~

Furthermore, in chained expressions, the order may determine whether a copy is returned or not.
If an expression will set values on a copy of a slice, then a ``SettingWithCopy``
exception will be raised (this raise/warn behavior is new starting in 0.13.0)

You can control the action of a chained assignment via the option ``mode.chained_assignment``,
which can take the values ``['raise','warn',None]``, where showing a warning is the default.

.. ipython:: python
   :okwarning:

   dfb = pd.DataFrame({'a' : ['one', 'one', 'two',
                              'three', 'two', 'one', 'six'],
                       'c' : np.arange(7)})
   # This will show the SettingWithCopyWarning
   # but the frame values will be set
   dfb['c'][dfb.a.str.startswith('o')] = 42

This however is operating on a copy and will not work.

::

   >>> pd.set_option('mode.chained_assignment','warn')
   >>> dfb[dfb.a.str.startswith('o')]['c'] = 42
   Traceback (most recent call last)
        ...
   SettingWithCopyWarning:
        A value is trying to be set on a copy of a slice from a DataFrame.
        Try using .loc[row_index,col_indexer] = value instead

A chained assignment can also crop up in setting in a mixed dtype frame.

.. note::

   These setting rules apply to all of ``.loc/.iloc/.ix``

This is the correct access method

.. ipython:: python

   dfc = pd.DataFrame({'A':['aaa','bbb','ccc'],'B':[1,2,3]})
   dfc.loc[0,'A'] = 11
   dfc

This *can* work at times, but is not guaranteed, and so should be avoided

.. ipython:: python
   :okwarning:

   dfc = dfc.copy()
   dfc['A'][0] = 111
   dfc

This will **not** work at all, and so should be avoided

::

   >>> pd.set_option('mode.chained_assignment','raise')
   >>> dfc.loc[0]['A'] = 1111
   Traceback (most recent call last)
        ...
   SettingWithCopyException:
        A value is trying to be set on a copy of a slice from a DataFrame.
        Try using .loc[row_index,col_indexer] = value instead

.. warning::

   The chained assignment warnings / exceptions are aiming to inform the user of a possibly invalid
   assignment. There may be false positives; situations where a chained assignment is inadvertently
   reported.
