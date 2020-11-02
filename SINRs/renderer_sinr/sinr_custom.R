sinrOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    plotly::plotlyOutput(ns('bar'),height=height)
    
  ) 
}

renderSinr <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  output$bar<-plotly::renderPlotly({
    # barplot(rbind(data$maxworst,data$maxaverage),main="SINR of Max_Worst and Max_Average model" , 
    #         names.arg = data$n,legend=c("Worst","Average"),xlab = "User",ylab = "SINR",col=c("blue","green"),beside=TRUE)
  pl<-plotly::plot_ly(x=data$n,y=data$maxworst,name="Worst",type='bar')
  pl<-plotly::add_trace(pl,y=data$maxaverage,name="Average")
  pl<-plotly::layout(pl,title="SINR of Max_Worst and Max_Average model",
             yaxis=list(title="SINR"),
             xaxis=list(title="User"))
  })
}

pieOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    fluidRow(column(6,plotly::plotlyOutput(ns("pie1"),height=height)),
             column(6,plotly::plotlyOutput(ns("pie2"),height=height)))
  )
}

renderPie <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  output$pie1<-plotly::renderPlotly({
    pl<-plotly::plot_ly(labels=data$n,values=round(data$maxworst,3),type = 'pie')
    pl<-plotly::layout(pl,title="Power of Max_Worst Model")
    
  })
  output$pie2<-plotly::renderPlotly({
    pl<-plotly::plot_ly(labels=data$n,values=round(data$maxaverage,3),type = 'pie')
    pl<-plotly::layout(pl,title="Power of Max_Average Model")
  })
}