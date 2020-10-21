assignOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    leafletOutput(ns('net'),height=height)
    )
    #define rendererOutput function here 
   
}

renderAssign <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  
   output$net<-renderLeaflet({
     ind<-which(is.na(data$value))
     weight<-data$value[-ind]
     fromlng<-data$x[-ind]
     fromlat<-data$y[-ind]
     tolng<-data$tox[-ind]
     tolat<-data$toy[-ind]
     node<-unique(data$l)
     x<-data$tox[1:length(node)]
     y<-data$toy[1:length(node)]
     fromlng=(fromlng-min(x))/(max(x)-min(x))
     fromlat=(fromlat-min(y))/(max(y)-min(y))
     tolng=(tolng-min(x))/(max(x)-min(x))
     tolat=(tolat-min(y))/(max(y)-min(y))
     x=(x-min(x))/(max(x)-min(x))
     y=(y-min(y))/(max(y)-min(y))
     map<-leaflet()
     map<-addMarkers(map,lng=x,lat=y,label = node)
     map<-addFlows(map,fromlng,fromlat,tolng,tolat,flow = weight,maxThickness = 5)
     # Ver<-data.frame(node,x,y)
     # edges<-data.frame(from,to)
     #  network<-graph_from_data_frame(d=edges,vertices=Ver,)
     #   plot(network,edge.label=weight,main = 'Helicopter Reassignment')
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
    fluidRow(
      column(5,dataTableOutput(ns('dataT'))),
      column(7,plotOutput(ns('plot'),height=height))
    )
  ) 
}

renderHeli <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  output$dataT<-DT::renderDataTable(datatable(data,colnames=c('location','previous number of helicopters','demand of helicopters','new number of helicopters')))
  output$plot<-renderPlot(
    {
      bar<-barplot(rbind(data$old,data$demand,data$new),main='Number of helicopters in each location',
                   names.arg = data$l,legend=c('old number','demand','new number'),xlab='location',
                   ylab='number of helicopters',col = c('blue','green','red'),beside=TRUE) 
      # text(bar,20,rbind(data$old,data$new),cex=1.2,font = 2,col='white')
    }
  )
}
