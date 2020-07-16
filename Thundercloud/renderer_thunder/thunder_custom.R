fflowOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    textOutput(ns('status')),
    fluidRow(
      column(4,dataTableOutput(ns('dataT'),height=height)),
      column(8, plotOutput(ns('plot1'),height=height))
    )
    
    )
}

renderFflow <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  if (data$status[1]==1){
    output$status<-renderText('The problem is solved to optimality')
  datap<-cbind(c(data$xcoord[-which(is.na(data$xcoord))]),c(data$zcoord[-which(is.na(data$zcoord))]))
  datap<-datap[order(datap[,1]),]
  output$dataT<-DT::renderDataTable(datatable(datap,colnames=c('nautical miles','altitude')))
  cloudx<-cbind(c(data$cloudx),c(data$cloudx))
  cloudx<-cloudx[-which(is.na(cloudx[,1])),]
  cloudz<-cbind(c(data$low),c(data$high))
  cloudz<-cloudz[-which(is.na(cloudz[,1])),]
 # output$textout<-renderText(length(cloudz[,1]))
  output$plot1<-renderPlot({
     plot(c(datap[,1]),c(datap[,2]),type='l',col='blue',main="Flow solution",xlab='nautical miles',ylab = 'altitude /1000 feet',lwd=2,
          ylim = c(min(min(datap[,2],min(cloudz))),max(max(datap[,2],max(cloudz)))))
     lines(c(cloudx[1,]),c(cloudz[1,]),col='red',lwd=3)
     lines(c(cloudx[2,]),c(cloudz[2,]),col='red',lwd=3)
     lines(c(cloudx[3,]),c(cloudz[3,]),col='red',lwd=3)
     legend(1,600,legend = c('flow','cloud 1','cloud 2','cloud 3'),col = c('blue','red','red','red'),lty=1, cex=5)
     })
  }
  else
  {
    output$status <- renderText(  'The problem is infeasible!' )
    output$dataT<-renderDataTable(c())
    output$plot1<-renderPlot(c())
  }
  
    #)


  
  
}

