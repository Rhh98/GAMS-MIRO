# module UI, Input or Output suffix
dblbar2DOutput <- function(id, height = NULL, options = NULL, path = NULL){
    ns <- NS(id)
    if(is.null(height)){
        height <- 700
    }
    # use tagList, fluidPage or pageWithSidebar, e.g.
    tagList(plotly::plotlyOutput(ns("dblbar2D")))
}

renderDblbar2D <- function(input, output, session, data, options = NULL, path = NULL, ...){
    output$dblbar2D <-
      plotly::renderPlotly(
                plotly::plot_ly(data,
                                x = ~i,
                                y = ~value, color=~day,
                                type = 'bar') %>%
                plotly::layout(barmode = "group",                   
                               xaxis = list(title = "Region"),
                               yaxis = list(title = "Beds"),
                               title = options$title)
              )
}

bar2DOutput <- function(id, height = NULL, options = NULL, path = NULL){
    ns <- NS(id)
    if(is.null(height)){
        height <- 700
    } 
    tagList(plotly::plotlyOutput(ns("bar2D"),height=height))
}

renderBar2D <- function(input, output, session, data, options = NULL, path = NULL, ...){
    output$bar2D <-
      plotly::renderPlotly(
                plotly::plot_ly(data,
                                x = ~i,
                                y = ~value, color=~day,
                                type = 'bar') %>%
                plotly::layout(barmode = "group",                   
                               xaxis = list(title = "Region"),
                               yaxis = list(title = "Beds"),
                               title = options$title)
              )
}

stacked1DbarOutput <- function(id, height = NULL, options = NULL, path = NULL){
    ns <- NS(id)
    if(is.null(height)){
        height <- 700
    } 
    tagList(plotly::plotlyOutput(ns("stacked1D"),height=height))
}

renderStacked1Dbar <- function(input, output, session, data, options = NULL, path = NULL, ...){
    output$stacked1D <-
      plotly::renderPlotly(
                plotly::plot_ly(data,
                                x = ~day,
                                y = ~value, color=~paste0(i, ".", ptype),
                                type = 'bar') %>%
                plotly::layout(barmode = "stack",                   
                               xaxis = list(title = "Date",tickangle = 45,autotick=F,dtick=2),
                               yaxis = list(title = "Patients"),
                               title = "Patients in regions over time")
              )
}

stacked2DbarOutput <- function(id, height = NULL, options = NULL, path = NULL){
    ns <- NS(id)
    if(is.null(height)){
        height <- 700
    } 
    tagList(plotly::plotlyOutput(ns("stacked2D"),height=height))
}

renderStacked2Dbar <- function(input, output, session, data, options = NULL, path = NULL, ...){
    output$stacked2D <-
      plotly::renderPlotly(
                plotly::plot_ly(data,
                                x = ~paste0(i, ".", day),
                                y = ~value, color=~j,
                                type = 'bar') %>%
                plotly::layout(barmode = "stack",                   
                               xaxis = list(title = "From region on date",tickangle = 45,autotick=F,dtick=4),
                               yaxis = list(title = "Patients moved"),
                               title = options$title)
              )
}
