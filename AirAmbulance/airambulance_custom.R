assignOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    plotOutput(ns('net'),height=height)
    )
    #define rendererOutput function here 
   
}

renderAssign <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  
   output$net<-renderPlot({
     weight<-data$value[-which(is.na(data$value))]
     from<-data$l[-which(is.na(data$value))]
     to<-data$nl[-which(is.na(data$value))]
     node<-unique(data$l)
     x<-data$x[1:length(node)]
     y<-data$y[1:length(node)]
     Ver<-data.frame(node,x,y)
     edges<-data.frame(from,to)
      network<-graph_from_data_frame(d=edges,vertices=Ver,)
       plot(network,edge.label=weight,main = 'Helicopter Assignment')
      #plot(c(1,2,3,4,5,6),c(length(from),length(to),length(weight),length(x),length(y),length(Ver)))
     }
  )
  
}



heliOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here
    sidebarLayout(
      sidebarPanel(
        dataTableOutput(ns('dataT'))
      ),
      mainPanel(
        plotOutput(ns('plot'),height=height)
      )
    )
  ) 
}

renderHeli <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  output$dataT<-DT::renderDataTable(datatable(data,colnames=c('location','previous number of helicopters','new number of helicopters')))
  output$plot<-renderPlot(
    {
      bar<-barplot(rbind(data$old,data$new),main='Number of helicopters in each location',
                   names.arg = data$l,legend=c('old number','new number'),xlab='location',
                   ylab='number of helicopters',col = c('blue','red'),beside=TRUE) 
      text(bar,10,rbind(data$old,data$new),cex=1.2,font = 2,col='white')
    }
  )
}
