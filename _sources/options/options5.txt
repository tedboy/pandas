.. currentmodule:: pandas

.. ipython:: python
   :suppress:

   import pandas as pd
   import numpy as np
   np.random.seed(123456)

.. _options.available:

Available Options
-----------------

========================== ============ ==================================
Option                     Default      Function
========================== ============ ==================================
display.chop_threshold     None         If set to a float value, all float
                                        values smaller then the given
                                        threshold will be displayed as
                                        exactly 0 by repr and friends.
display.colheader_justify  right        Controls the justification of
                                        column headers. used by DataFrameFormatter.
display.column_space       12           No description available.
display.date_dayfirst      False        When True, prints and parses dates
                                        with the day first, eg 20/01/2005
display.date_yearfirst     False        When True, prints and parses dates
                                        with the year first, eg 2005/01/20
display.encoding           UTF-8        Defaults to the detected encoding
                                        of the console. Specifies the encoding
                                        to be used for strings returned by
                                        to_string, these are generally strings
                                        meant to be displayed on the console.
display.expand_frame_repr  True         Whether to print out the full DataFrame
                                        repr for wide DataFrames across
                                        multiple lines, `max_columns` is
                                        still respected, but the output will
                                        wrap-around across multiple "pages"
                                        if its width exceeds `display.width`.
display.float_format       None         The callable should accept a floating
                                        point number and return a string with
                                        the desired format of the number.
                                        This is used in some places like
                                        SeriesFormatter.
                                        See core.format.EngFormatter for an example.
display.height             60           Deprecated. Use `display.max_rows` instead.
display.large_repr         truncate     For DataFrames exceeding max_rows/max_cols,
                                        the repr (and HTML repr) can show
                                        a truncated table (the default from 0.13),
                                        or switch to the view from df.info()
                                        (the behaviour in earlier versions of pandas).
                                        allowable settings, ['truncate', 'info']
display.latex.repr         False        Whether to produce a latex DataFrame
                                        representation for jupyter frontends
                                        that support it.
display.latex.escape       True         Escapes special caracters in Dataframes, when
                                        using the to_latex method.
display.latex.longtable    False        Specifies if the to_latex method of a Dataframe
                                        uses the longtable format.
display.line_width         80           Deprecated. Use `display.width` instead.
display.max_columns        20           max_rows and max_columns are used
                                        in __repr__() methods to decide if
                                        to_string() or info() is used to
                                        render an object to a string.  In
                                        case python/IPython is running in
                                        a terminal this can be set to 0 and
                                        pandas will correctly auto-detect
                                        the width the terminal and swap to
                                        a smaller format in case all columns
                                        would not fit vertically. The IPython
                                        notebook, IPython qtconsole, or IDLE
                                        do not run in a terminal and hence
                                        it is not possible to do correct
                                        auto-detection. 'None' value means
                                        unlimited.
display.max_colwidth       50           The maximum width in characters of
                                        a column in the repr of a pandas
                                        data structure. When the column overflows,
                                        a "..." placeholder is embedded in
                                        the output.
display.max_info_columns   100          max_info_columns is used in DataFrame.info
                                        method to decide if per column information
                                        will be printed.
display.max_info_rows      1690785      df.info() will usually show null-counts
                                        for each column. For large frames
                                        this can be quite slow. max_info_rows
                                        and max_info_cols limit this null
                                        check only to frames with smaller
                                        dimensions then specified.
display.max_rows           60           This sets the maximum number of rows
                                        pandas should output when printing
                                        out various output. For example,
                                        this value determines whether the
                                        repr() for a dataframe prints out
                                        fully or just a summary repr.
                                        'None' value means unlimited.
display.max_seq_items      100          when pretty-printing a long sequence,
                                        no more then `max_seq_items` will
                                        be printed. If items are omitted,
                                        they will be denoted by the addition
                                        of "..." to the resulting string.
                                        If set to None, the number of items
                                        to be printed is unlimited.
display.memory_usage       True         This specifies if the memory usage of
                                        a DataFrame should be displayed when the
                                        df.info() method is invoked.
display.multi_sparse       True         "Sparsify" MultiIndex display (don't
                                        display repeated elements in outer
                                        levels within groups)
display.notebook_repr_html True         When True, IPython notebook will
                                        use html representation for
                                        pandas objects (if it is available).
display.pprint_nest_depth  3            Controls the number of nested levels
                                        to process when pretty-printing
display.precision          6            Floating point output precision in
                                        terms of number of places after the
                                        decimal, for regular formatting as well
                                        as scientific notation. Similar to
                                        numpy's ``precision`` print option
display.show_dimensions    truncate     Whether to print out dimensions
                                        at the end of DataFrame repr.
                                        If 'truncate' is specified, only
                                        print out the dimensions if the
                                        frame is truncated (e.g. not display
                                        all rows and/or columns)
display.width              80           Width of the display in characters.
                                        In case python/IPython is running in
                                        a terminal this can be set to None
                                        and pandas will correctly auto-detect
                                        the width. Note that the IPython notebook,
                                        IPython qtconsole, or IDLE do not run in a
                                        terminal and hence it is not possible
                                        to correctly detect the width.
io.excel.xls.writer        xlwt         The default Excel writer engine for
                                        'xls' files.
io.excel.xlsm.writer       openpyxl     The default Excel writer engine for
                                        'xlsm' files. Available options:
                                        'openpyxl' (the default).
io.excel.xlsx.writer       openpyxl     The default Excel writer engine for
                                        'xlsx' files.
io.hdf.default_format      None         default format writing format, if
                                        None, then put will default to
                                        'fixed' and append will default to
                                        'table'
io.hdf.dropna_table        True         drop ALL nan rows when appending
                                        to a table
mode.chained_assignment    warn         Raise an exception, warn, or no
                                        action if trying to use chained
                                        assignment, The default is warn
mode.sim_interactive       False        Whether to simulate interactive mode
                                        for purposes of testing
mode.use_inf_as_null       False        True means treat None, NaN, -INF,
                                        INF as null (old way), False means
                                        None and NaN are null, but INF, -INF
                                        are not null (new way).
========================== ============ ==================================
