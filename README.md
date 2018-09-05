# String Data Frame

This package provides 2 methods to convert data.frames/tibbles to a single character string and back to their original form (largely intact).  Conversion is either to a string or a markdown table.

The aim is to provide a method to convert data.frames that are embedded inside other data.frames (as list fields) to a form that enables them to be saved to a single csv file or an external database table (rather than requiring a relational multi-table approach), but so the resulting embedded string_dataframes can be easily returned to data.frame format when returned to R.  This might suit you if your embedded dataframes are relatively small, static, or if you don't need to query them on a row-by-row basis.


### Installation

    devtools::install_github('geotheory/stringDataFrame')


### Usage

A demo data_frame:

    require(stringDataFrame)
    require(tidyverse)

    set.seed(1)
    df_orig = data_frame(`item date` = seq(as.Date('2018-01-01'), as.Date('2018-01-05'), 1),
                         id = 1:5, grp = c('A','A','B','B','B'),
                         val = c(NA, rlnorm(4, sd=10)), condition = c(T,F,F,T,T),
                         txt = c(NA, '', 'The quick brown fox', 'jumped over the', 'quick | brown dog.'))
    print(df_orig)
    #> # A tibble: 5 x 6
    #>   `item date`    id grp        val condition txt
    #>   <date>      <int> <chr>    <dbl> <lgl>     <chr>
    #> 1 2018-01-01      1 A     NA       TRUE      <NA>
    #> 2 2018-01-02      2 A      1.90e-3 FALSE     ""
    #> 3 2018-01-03      3 B      6.27e+0 FALSE     The quick brown fox
    #> 4 2018-01-04      4 B      2.35e-4 TRUE      jumped over the
    #> 5 2018-01-05      5 B      8.48e+6 TRUE      quick | brown dog.

**Conversion to string dataframes:**

    df_string = df_to_stringdf(df_orig)
    cat(df_string)
    #> item date: 2018-01-01 | 2018-01-02 | 2018-01-03 | 2018-01-04 | 2018-01-05 |> id: 1 | 2 | 3 | 4 | 5 |> grp: A | A | B | B | B |> val: NA | 0.00190259200865651 | 6.27412003815427 | 0.000234915161451801 | 8476498.59847671 |> condition: TRUE | FALSE | FALSE | TRUE | TRUE |> txt: NA |  | The quick brown fox | jumped over the | quick ❘ brown dog.

    df_from_string = stringdf_to_df(df_string)
    print(df_from_string)
    #> # A tibble: 5 x 6
    #>   `item date`    id grp        val condition txt
    #>   <date>      <int> <chr>    <dbl> <lgl>     <chr>
    #> 1 2018-01-01      1 A     NA       TRUE      <NA>
    #> 2 2018-01-02      2 A      1.90e-3 FALSE     ""
    #> 3 2018-01-03      3 B      6.27e+0 FALSE     The quick brown fox
    #> 4 2018-01-04      4 B      2.35e-4 TRUE      jumped over the
    #> 5 2018-01-05      5 B      8.48e+6 TRUE      quick | brown dog.


**Conversion to markdown tables:**

    df_markdown = df_to_markdown(df_orig)
    cat(df_markdown)
    #> item date     id  grp             val  condition   txt
    #> -----------  ---  ----  -------------  ----------  ----------------------
    #> 2018-01-01     1  A                NA  TRUE        NA
    #> 2018-01-02     2  A      1.902600e-03  FALSE
    #> 2018-01-03     3  B      6.274120e+00  FALSE       The quick brown fox
    #> 2018-01-04     4  B      2.349000e-04  TRUE        jumped over the
    #> 2018-01-05     5  B      8.476499e+06  TRUE        quick &#124; brown dog.

    df_from_markdown = markdown_to_df(df_markdown)
    print(df_from_markdown)
    #> # A tibble: 5 x 1
    #>   `item date     id  grp             val  condition   txt`
    #>   <chr>
    #> 1 2018-01-01     1  A                NA  TRUE        NA
    #> 2 2018-01-02     2  A      1.902600e-03  FALSE
    #> 3 2018-01-03     3  B      6.274120e+00  FALSE       The quick brown fox
    #> 4 2018-01-04     4  B      2.349000e-04  TRUE        jumped over the
    #> 5 2018-01-05     5  B      8.476499e+06  TRUE        quick | brown dog.


**Handling list-embedded data.frames**

    beavers = data_frame(beaver = c('beaver1','beaver2'), data = list(head(beaver1), head(beaver2)))
    print(beavers)
    #> # A tibble: 2 x 2
    #>   beaver  data
    #>   <chr>   <list>
    #> 1 beaver1 <data.frame [6 × 4]>
    #> 2 beaver2 <data.frame [6 × 4]>

    beavers_mkd = beavers %>% mutate(data = map_chr(data, df_to_markdown))
    print(beavers_mkd)
    #> # A tibble: 2 x 2
    #>   beaver  data
    #>   <chr>   <chr>
    #> 1 beaver1 " day   time    temp   activ\n----  -----  ------  ------\n 346…
    #> 2 beaver2 " day   time    temp   activ\n----  -----  ------  ------\n 307…

    beavers_mkd$data[1] %>% cat
    #>  day   time    temp   activ
    #> ----  -----  ------  ------
    #>  346    840   36.33       0
    #>  346    850   36.34       0
    #>  346    900   36.35       0
    #>  346    910   36.42       0
    #>  346    920   36.55       0
    #>  346    930   36.69       0

    beavers_mkd %>% pmap_df(~ markdown_to_df(.y) %>% mutate(beaver = .x))
    # A tibble: 12 x 5
    #>      day  time  temp activ beaver
    #>    <int> <int> <dbl> <int> <chr>
    #>  1   346   840  36.3     0 beaver1
    #>  2   346   850  36.3     0 beaver1
    #>  3   346   900  36.4     0 beaver1
    #>  4   346   910  36.4     0 beaver1
    #>  5   346   920  36.6     0 beaver1
    #>  6   346   930  36.7     0 beaver1
    #>  7   307   930  36.6     0 beaver2
    #>  8   307   940  36.7     0 beaver2
    #>  9   307   950  36.9     0 beaver2
    #> 10   307  1000  37.2     0 beaver2
    #> 11   307  1010  37.2     0 beaver2
    #> 12   307  1020  37.2     0 beaver2


**Comparing before/after conversion:**

To compare before/after you can use `all_equal` function (`convert=TRUE` recommended) on data.frames with any factors removed. Objects won't always match up exactly (e.g. numbers with long decimals may be truncated to ~7 places), but loss is either very small, or zero as in this example:

    df_orig = ggplot2::diamonds %>% mutate_if(is.factor, funs(as.character(.)))
    df_string = df_to_stringdf(df_orig)
    df_from_string = stringdf_to_df(df_string)
    all_equal(df_orig, df_from_string, convert=TRUE)
    [1] TRUE


**Notes**

- `df_from_markdown` is adapted from: https://gist.github.com/alistaire47/8bf30e30d66fd0a9225d5d82e0922757
