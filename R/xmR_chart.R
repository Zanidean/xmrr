#'Generate the XMR chart for XMR data
#'@description Useful for diagnostics on xmr, and just visualizing the data.
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
#'\dontrun{ xmr_chart(df, "Year", "Measure") }
#'@import dplyr
#'@import ggplot2
#'@import tidyr
#'@export xmr_chart
xmr_chart <- function(df, time, measure, 
                      boundary_linetype = "dashed",
                      central_linetype = "dotted",
                      boundary_colour = "#d02b27",
                      point_colour = "#7ECBB5",
                      point_size = 2,
                      line_width = 0.5,
                      text_size = 9){
  
  
  if("Upper Natural Process Limit" %in% names(df)){
  
    . <- "donotuse"
    `Order` <- .
    `Central Line` <- .
    `Average Moving Range` <- .
    `Lower Natural Process Limit` <- .
    `Upper Natural Process Limit` <- .
    
    if(missing(time)){time <- names(df)[1]}
    if(missing(measure)){measure <- names(df)[2]}
    
    plot <- ggplot2::ggplot(df, aes(as.character(df[[time]]), group = 1)) +
      geom_line(aes(y = `Central Line`),
                size = line_width, 
                linetype = central_linetype, 
                na.rm = T) +
      geom_line(aes(y = `Lower Natural Process Limit`), 
                color = boundary_colour,
                size = line_width, 
                linetype = boundary_linetype, 
                na.rm = T) +
      geom_line(aes(y = `Upper Natural Process Limit`), 
                color = boundary_colour,
                size = line_width, 
                linetype = boundary_linetype, na.rm = T) +
      geom_line(aes(y = df[[measure]])) + 
      geom_point(aes(y = df[[measure]]), 
                 size = point_size, color = "#000000") +
      geom_point(aes(y = df[[measure]]), 
                 size = point_size*.625, color = point_colour) +
      guides(colour=FALSE) + 
      labs(x = time, y = measure) + 
      theme_bw() + 
      theme(strip.background = element_rect(fill = NA, linetype = 0), 
            panel.border = element_rect(color = NA), 
            panel.spacing.y = unit(4, "lines"), 
            panel.spacing.x = unit(2, "lines"), 
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank(),
            axis.text.y =  element_blank(),
            axis.title.y = element_blank(),
            axis.ticks.y = element_blank(), 
            axis.ticks.x = element_blank(),
            text = element_text(family = "sans"),
            axis.text.x = element_text(colour = "#000000", size = text_size-2),
            axis.title.x = element_text(size = text_size, face = "bold"))
    return(plot)
  } else {warning("Data has not been analyzed using xmr().")}
}
