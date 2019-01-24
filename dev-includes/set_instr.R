wsp_instruction <- paste0(
  '<p>In this section, we will check for extra prefixed and suffixed whitespaces in selected columns.</p>',
  '<p>Choosing <strong>Auto Remove extra Whitespaces</strong>, you allow the program to attempt to remove them. 
  This is useful, but might cause unexpected problems if such extra spaces is added on purpose.</p>'
)

outl_instruction <- paste0(
  '<p>In this section, we will check for <em>outliers</em> in selected numerical columns.</p>',
  '<p>Choosing <strong>Plotting Outliers</strong>, you allow the program to attempt to plot a map using the <strong>OutliersO3</strong> package.
  However, sometimes, it is not suitable for doing so. In such circumstances, you might want to reduce the number of columns to be plotted.</p>',
  '<p>Usually, medical tests don\'t accept <strong>Negative</strong> and/or <strong>Zero</strong> results.
  Those results might be counted as illegitimate values unless you choose to accept them manually. </p>.'
)

msd_instruction <- paste0(
'<p>In this section, we will check for missing data in selected columns.</p>',
'<p>Missing data are cells that contains <em>no values</em>, <em>NA values</em>, or <em>extreme values</em> (ie. 999).</p>',
'<p>Choosing <strong>Auto Remove missing data</strong>, you allow the program to attempt to remove all observations that have empty cells. 
This is useful, but might cause unexpected problems, especially with small dataset.</p>'
)

spl_instruction <- paste0(
  '<p>In this section, we will check for typos and/or case issues in selected columns.</p>',
  '<p>Cells with case issues have the same values with others but are written in a different case 
  (ie. <em>FOO</em> instead of <em>Foo</em>, <em>bar</em> instead of <em>Bar</em>).</p>',
  '<p>Choosing <strong>Auto Remove whitespaces between words</strong>, you allows the program to remove all spaces between words.
  This will make the spellchecking process easier, but only useful when you are sure that your columns-to-check don\'t have any white spaces.</p>',
  '<p>With the <strong>Words Correction</strong> option on, we will leave a textbox in every cell that has typo(s),
  just so you are able to correct them immediately and conveniently.</p>',
  '<p>By <strong>Auto correction</strong>, such aformentioned process will be done automatically.
  This is useful, but might cause unexpected problems, because we are merely robots &#129302;.</p>',
  '<p>Sometimes, the columns we are checking contains non-English words, abbreviations, IDs, date-times, etc.
  It makes no sense trying to correct them.
  Hence, we purposely add an <strong>upper limit</strong> to the amount of errors allowed to exist in a column, in order to advoid noisy results.
  You can try adjusting the dial to get the result you want.</p>'
)

lnr_instruction <- paste0(
  '<p>In this section, we will check for values that only occur less than 6 times in selected columns.</p>',
  '<p>Usually, columns record date/time of events contain nothing but "loners", so in default settings, we omitted them.
  Choosing <strong>Treat Date-Time Columns as Factor</strong>, you override this setting.
  Only enable it when you are purposely want to check for this type of data.</p>',
  '<p>Sometimes, the columns we are checking contain <em>"intentional loners"</em> (ID values, for example).
  It makes no sense trying to cause an ruckus because of them.
  Hence, we purposely add an <strong>upper limit</strong> to the amount of errors allowed to exist in a column, in order to advoid noisy results.
  You can try adjusting the dial to get the result you want.</p>'
)

bin_instruction <- paste0(
  '<p>In medical researches, there are tests that only return <em>binary results</em> (ie. Yes/No, 1/0, Positive/Negative).
  A mistake in data input might allow abnormal values to sneak in, and thus, lead to further analytical issues.',
  '<p>In this section, we will try to tackle them.</p>',
  '<p>Sometimes, the columns we are checking are not binary.
  It makes no sense trying to cause an uproar because of them.
  Hence, we purposely add an <strong>upper limit</strong> to the amount of errors allowed to exist in a column, in order to advoid noisy results.
  You can try adjusting the dial to get the result you want.</p>'
)

instr <- list(wsp_instruction = wsp_instruction,
              outl_instruction = outl_instruction, 
              msd_instruction = msd_instruction,
              spl_instruction = spl_instruction,
              lnr_instruction = lnr_instruction,
              bin_instruction = bin_instruction)  
write_json(instr,path = 'meta/instr.json')
