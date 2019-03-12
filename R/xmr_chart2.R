#'Generate the XMR chart for XMR data. 
#'@description Useful for diagnostics on xmr, and just visualizing the data. Now works with more tidy workflows.
#'
#'@param df Output from xmR()
#'@param time Time column
#'@param measure Measure
#'@param boundary_linetype Type of line for upper and lower boundary lines. Defaults to "dashed".
#'@param central_linetype Type of line for central line. Defaults to "dotted".
#'@param boundary_colour Colour of line for upper and lower boundary lines. Defaults to "#d02b27".
#'@param point_colour Colour of points. Defaults to "#7ECBB5".
#'@param point_size Size of points. Defaults to 2.
#'@param line_width Width of lines. Defaults to 0.5.
#'@param text_size Size of chart text. Defaults to 9.
#'@examples
#'\dontrun{ xmr_chart(df, Year, Measure) }
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