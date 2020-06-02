#'Tidyeval Version of xmr()
#'@description Used to calculate XMR data. Now works with more tidy workflows.
#'
#'@param dataframe The dataframe or tibble to calculate from.
#'Data must be in a tidy format.
#'At least one variable for time and one variable for measure.
#'@param measure The column containing the measure. Must be in numeric format.
#'@param ... Arguments to pipe to xmr
#'@import dplyr
#'@import ggplot2
#'@import tidyr
#'@export xmr2

xmr2 = function(dataframe, measure, ...){
  vc = deparse(substitute(measure))
  dataframe %>% 
    group_split() %>% 
    purrr::map_df(xmr, measure = vc, ...)
}
