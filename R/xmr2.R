#'Tidyeval Version of xmr()
#'@description Used to calculate XMR data. Now works with more tidy workflows.
#'
#'@param df The dataframe or tibble to calculate from.
#'Data must be in a tidy format.
#'At least one variable for time and one variable for measure.
#'@param measure The column containing the measure. Must be in numeric format.
#'@param recalc Logical: if you'd like it to recalculate bounds. Defaults to True
#'@param reuse Logical: Should points be re-used in calculations? Defaults to False
#'@param interval The interval you'd like to use to calculate the averages. 
#'Defaults to 5.
#'@param longrun Used to determine rules for long run. First point is the 'n' of points used to recalculate with, and the second is to determine what qualifies as a long run. Default is c(5,8) which uses the first 5 points of a run of 8 to recalculate the bounds. If a single value is used, then that value is used twice i.e. c(6,6))
#'@param shortrun Used to determine rules for a short run. The first point is the minimum number of points within the set to qualify a shortrun, and the second is the length of a possible set. Default is c(3,4) which states that 3 of 4 points need to pass the test to be used in a calculation. If a single value is used, then that value is used twice i.e. c(3,3))
#'@param testing Logical to print test results
#'@param prefer_longrun Logical if you want to first test for long-runs or for short-runs. 
#'@examples
#'\dontrun{ xmr(df, "Measure", recalc = T) }
#'\dontrun{ xmr(df, "Measure", recalc = T, shortrun = c(3,4), longrun = c(5,8))}
#'@import dplyr
#'@import ggplot2
#'@import tidyr
#'@export xmr2

xmr2 = function(dataframe, measure, ...){
  require(purrr)
  vc = deparse(substitute(measure))
  dataframe %>% 
    group_split() %>% 
    map_df(xmr, measure = vc, ...)
}
