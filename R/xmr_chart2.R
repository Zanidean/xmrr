#'Generate the XMR chart for XMR data. 
#'@description Useful for diagnostics on xmr, and just visualizing the data. Now works with more tidy workflows.
#'
#'@param dataframe Output from xmR()
#'@param time Time column
#'@param measure Measure
#'@param ... Arguments to pipe to xmr_chart()
#'@import dplyr
#'@import ggplot2
#'@import tidyr
#'@export xmr_chart2

xmr_chart2 = function(dataframe, time, measure, ...){
  m = deparse(substitute(measure))
  t = deparse(substitute(time))
  
  dataframe %>% 
    xmr_chart(t, m, ...)
}