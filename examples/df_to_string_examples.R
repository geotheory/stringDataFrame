require(stringDataFrame)
require(tidyverse)

set.seed(1)
df_orig = data_frame(`item date` = seq(as.Date('2018-01-01'), as.Date('2018-01-05'), 1),
                     id = 1:5, grp = c('A','A','B','B','B'),
                     val = c(NA, rlnorm(4, sd=10)), condition = c(T,F,F,T,T),
                     txt = c(NA, '', 'The quick brown fox', 'jumped over the', 'quick brown dog.'))
print(df_orig)


## conversion to string.dataframe and back

df_string = df_to_stringdf(df_orig)
cat(df_string)

df_from_string = stringdf_to_df(df_string)
print(df_from_string)


## conversion to markdown table and back

df_markdown = df_to_markdown(df_orig)
cat(df_markdown)

df_from_markdown = markdown_to_df(df_markdown)
print(df_from_markdown)


## Handling list-embedded data.frames

beavers = data_frame(beaver = c('beaver1','beaver2'), data = list(head(beaver1), head(beaver2)))
print(beavers)

beavers_mkd = beavers %>% mutate(data = map_chr(data, df_to_markdown))
print(beavers_mkd)

beavers_mkd$data[1] %>% cat

beavers_mkd %>% pmap_df(~ markdown_to_df(.y) %>% mutate(beaver = .x))


## To compare before/after you can use `all.equal` function. Objects won't always match up, but this example shows it can:

df_orig = ggplot2::diamonds %>% mutate_if(is.factor, funs(as.character(.)))
df_string = df_to_stringdf(df_orig)
df_from_string = stringdf_to_df(df_string)
all.equal(df_orig, df_from_string)
