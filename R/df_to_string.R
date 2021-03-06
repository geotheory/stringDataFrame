##' @title
##' String Data Frames
##' @description This package provides 2 methods to convert a data.frame/tibble to a single character string and back to its original form (largely intact).  Conversion is either to an unformatted string or a markdown table.
##'
##' The aim is to provide a method to convert data.frames that are embedded inside other data.frames (as list fields) to a form that enables them to be saved to a single csv file or an external database table (rather than requiring a relational multi-table approach), but so the resulting embedded string_dataframes can be easily returned to data.frame format when returned to R.  This might suit you if your embedded dataframes are relatively small, static, or if you don't need to query them on a row-by-row basis.
##' @name df_to_stringdf
##'
##' @param df A data.frame or data_frame to convert to text
##' @param str_df A string dataframe output by df_to_stringdf(...)
##' @param md_df A markdown dataframe output by df_to_markdown(...)
##' @param col_classes A character vector of classes to coerce columns to (length to match column count)
##' @param data.frame Return rebuilt data.frames instead of tibbles
##'
##' @example examples/df_to_string_examples.R
##' @rdname df_to_stringdf
##' @export
df_to_stringdf = function(df, rownames = FALSE){
  if(is.na(df)) return(NA)
  suppressMessages(require(dplyr))
  if(rownames & class(df)[1] == 'data.frame') df = df %>% as_data_frame(rownames='name')
  df %>% purrr::imap(~ paste(.y, paste(stringr::str_replace_all(.x,'[|]','\u2758'), collapse=' | '), sep=': ')) %>%
    paste(collapse = ' |> ') # '\u2758' is temp unicode sub for any '|' chars
}
##'
##' @rdname df_to_stringdf
##' @export
df_to_markdown = function(df){
  if(is.na(df)) return(NA)
  knitr::kable(df) %>% as.character %>% paste(collapse='\n')
}
##'
##' @rdname df_to_stringdf
##' @return \code{df_to_stringdf() and df_to_markdown()} both return character string representing the data.frame
##' @export
stringdf_to_df = function(str_df, col_classes = NULL, data.frame = FALSE){
  if(is.na(str_df)) return(NA)
  rebuilt = purrr::flatten(stringr::str_split(str_df, stringr::fixed(' |> '))[[1]] %>% purrr::map(~ {
    setNames(object = stringr::str_remove(.x, '^[^:]+: ') %>% stringr::str_split(stringr::fixed(' | ')),
             nm = stringr::str_extract(.x, '^[^:]+'))
  })) %>% purrr::map(~ str_replace_all(.x, '\u2758', '|')) %>% # return '|' chars
    purrr::map(~ replace(.x, .x == 'NA', NA)) %>% as_data_frame %>%
    purrr::map_df(~ readr::parse_guess(.x, na='NA'))
  if(!is.null(col_classes)) rebuilt = map2_df(rebuilt, col_classes, ~ as(.x, .y))
  if(!data.frame) return(rebuilt)
  as.data.frame(rebuilt)
}
##'
##' @rdname df_to_stringdf
##' @return \code{stringdf_to_df() and markdown_to_df()} both return rebuilt data_frame/data.frame objects closely approximating the originals
##' @export
markdown_to_df = function(md_df, col_classes = NULL, na = 'NA', data.frame = FALSE){
  if(is.na(md_df)) return(NA)
  lines = readr::read_lines(md_df)
  lines = lines[!grepl('^[\\:\\s\\+\\-\\=\\_\\|]*$', lines, perl = TRUE)]
  lines = gsub('(^\\s*?\\|)|(\\|\\s*?$)', '', lines)
  rebuilt = readr::read_delim(paste(lines, collapse = '\n'), delim = '|',
                              trim_ws = TRUE, na = na)
  if(!is.null(attr(rebuilt, 'spec'))) attr(rebuilt, 'spec') = NULL # remove read_delim addon
  if(!is.null(col_classes)) rebuilt = map2_df(rebuilt, col_classes, ~ as(.x, .y))
  if(!data.frame) return(rebuilt)
  as.data.frame(rebuilt)
}
