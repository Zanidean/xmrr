---
title: "Using xmr() and xmr_chart()"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteEngine{knitr::knitr}
  %\VignetteIndexEntry{Using xmr() and xmr_chart()}
  %\usepackage[UTF-8]{inputenc}
---

#Introduction

XMR control charts are useful when determining if there are significant trends in data. XMR charts have two key assumptions: one is that the measurements of value happen over time, and the other is that each measurement of time has exactly one measurement of value. 


Take careful thought about *what* you are trying to measure with XMR. Proportions work great, headcount is okay, costs over time don't work well.

-------

#Arguments

The arguments for `xmr()` are: 

- **df**: The dataframe containing the time-series data.

- **measure**: The column containing the measure. This must be in a numeric format.

- **interval**: The interval you'd like to use to calculate the averages. Defaults to 5.

- **recalc**: Logical if you'd like it to recalculate bounds. Defaults to False for safety.

- **reuse**: Logical: Should points be re-used in calculations? Defaults to False.

- **longrun**: A vector of 2 to determine the rules for a long run. The first point is the 'n' of points used to calculate the new reference lines, and the second is to determine how many consecutive points are needed to define a longrun. Default is c(5,8) which uses the first 5 points of a run of 8 to recalculate the bounds. 

- **shortrun**: A vector of 2 to determine the rules for a short run. The first point is the minimum number of points within the set to qualify a shortrun, and the second is the length of a possible set. Default is c(3,4) which states that 3 of 4 consecutive points need to pass the test to be used in a calculation. 

The data required for XMR charts take a specific format, with at least two columns of data - one for the time variable and another for the measurement. 

Like so:


| Time | Measure |
|:----:|:-------:|
| 2000 |   54    |
| 2001 |   56    |
| 2002 |   59    |
| 2003 |   65    |
| 2004 |   53    |
| 2005 |   64    |
| 2006 |   65    |
| 2007 |   61    |
| 2008 |   60    |
| 2009 |   51    |
| 2010 |   53    |
| 2011 |   53    |
| 2012 |   80    |
| 2013 |   76    |
| 2014 |   82    |
| 2015 |   77    |
| 2016 |   81    |
| 2017 |   85    |

If we wanted to use `xmr()` on this data would be written like this: 


```r
xmr_data <- xmr(df = example_data, measure = "Measure")
```

And if we wanted the bounds to recalculate, we'd use this.


```r
xmr_data <- xmr(df = example_data, measure = "Measure", recalc = T)
```

Output data looks like this:

| Time | Measure | Central Line | Moving Range | Average Moving Range | Lower Natural Process Limit | Upper Natural Process Limit |
|:----:|:-------:|:------------:|:------------:|:--------------------:|:---------------------------:|:---------------------------:|
| 2000 |   54    |    57.400    |      NA      |          NA          |             NA              |             NA              |
| 2001 |   56    |    57.400    |      2       |        5.750         |           42.105            |           72.695            |
| 2002 |   59    |    57.400    |      3       |        5.750         |           42.105            |           72.695            |
| 2003 |   65    |    57.400    |      6       |        5.750         |           42.105            |           72.695            |
| 2004 |   53    |    57.400    |      12      |        5.750         |           42.105            |           72.695            |
| 2005 |   64    |    57.400    |      11      |        5.750         |           42.105            |           72.695            |
| 2006 |   65    |    57.400    |      1       |        5.750         |           42.105            |           72.695            |
| 2007 |   61    |    57.400    |      4       |        5.750         |           42.105            |           72.695            |
| 2008 |   60    |    57.400    |      1       |        5.750         |           42.105            |           72.695            |
| 2009 |   51    |    57.400    |      9       |        5.750         |           42.105            |           72.695            |
| 2010 |   53    |    57.400    |      2       |        5.750         |           42.105            |           72.695            |
| 2011 |   53    |    57.400    |      0       |        5.750         |           42.105            |           72.695            |
| 2012 |   80    |    79.333    |      27      |        12.333        |           46.527            |           112.140           |
| 2013 |   76    |    79.333    |      4       |        12.333        |           46.527            |           112.140           |
| 2014 |   82    |    79.333    |      6       |        12.333        |           46.527            |           112.140           |
| 2015 |   77    |    79.333    |      5       |        12.333        |           46.527            |           112.140           |
| 2016 |   81    |    79.333    |      4       |        12.333        |           46.527            |           112.140           |
| 2017 |   85    |    79.333    |      4       |        12.333        |           46.527            |           112.140           |

The only mandatory arguments are **df**, because the function needs to operate on a dataframe, and **measure** because the function needs to be told which column contains the measurements. Everything else has been set to what I believe is a safe and sensible default. 

In our shop, we typically run the following rules. Since they are the default, there is no need to specify them directly:


```r
xmr_data <- xmr(example_data,  "Measure", 
                recalc = T,
                interval = 5,
                shortrun = c(3,4),
                longrun = c(5,8))
```

Feel free to play around with your own definitions of what a shortrun or longrun is.


```r
xmr_data <- xmr(df = example_data, 
                measure = "Measure", 
                recalc = T,
                #change the rule like so:,
                interval = 4,
                shortrun = c(2,3))
```

The statistical differences between rules are slight, but each user will have different needs and it's useful to be able to tune the function to those needs. 

It is important to use a consistent definition of what a long/short run are. It wouldn't be appropriate in one report to use one set of definitions for one dataset, and another set for a different dataset.

-------

# Charts

The `xmr()` function is handy for generating chart data as the output can be saved and used in other applications. But what about visualization within R?

`xmr_chart()` takes the output from `xmr()` and generates a ggplot graphic. This works well for reporting, but it also works great for quick diagnostics of your data.

The arguments for `xmr_chart()` are: 

- **df**: Output from xmr()

- **time**: The column containing the time variable for the x-axis.

- **measure**: The column containing the measure for the y-axis. 

- **boundary_linetype**: Type of line for upper and lower boundary lines. Defaults to "dashed".

- **central_linetype**: Type of line for central line. Defaults to "dotted".

- **boundary_colour**:	Colour of line for upper and lower boundary lines. Defaults to "#d02b27".

- **point_colour**:	Colour of points. Defaults to "#7ECBB5".

- **point_size**:	Size of points. Defaults to 2.

- **line_width**:	Width of lines. Defaults to 0.5.

- **text_size**:	Size of chart text. Defaults to 9.

There are defaults set for most arguments, so all the user *needs* to supply are the column names for the Time and Measurement column unless they want some slight modification of the default chart.














