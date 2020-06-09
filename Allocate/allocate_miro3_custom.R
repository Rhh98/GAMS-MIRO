kitsinlOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    sidebarLayout(
      sidebarPanel(
    
    dataTableOutput(ns('dataT'),height=height)
    ),
    mainPanel(plotOutput(ns('plot'),height=height)
    ) 
    )
  )
}

renderKitsinl <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer
  
      dt<-cbind(paste(data$l,data$prv),data$value)
       
              
      output$dataT<-DT::renderDataTable(datatable(dt,colnames=c('labs and prevalence','number of samples')))
    
    
      output$plot<-renderPlot({
        
        bar=barplot(data$value,names.arg = paste(data$l,data$prv),xlab = 'labs and prevalence',
                    ylab = 'number of samples',main = 'Samples to test in each lab',col = 'blue1',
                    axes = TRUE,border = 'red')
        text(bar,data$value-30,data$value,cex=1.2,font = 2,col='yellow')
      })
}

allocateOutput <- function(id,height=NULL,options = NULL, path=NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    sidebarLayout(
      sidebarPanel(
        
        dataTableOutput(ns('dataT'),height=height)
      ),
      mainPanel(leafletOutput(ns('map'),height=height)
      ) 
    )
  )
}

renderAllocate <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer
  output$dataT<-DT::renderDataTable(datatable(cbind(data$c,data$l,data$prv,data$val),
                                              colnames=c('center','lab','prevalence','number of kits')))x=
  
  # latl=unique(data$value[data$allocateHeader == 'latl'])
  # lonl=unique(data$value[data$allocateHeader == 'lonl'])
  # l=unique(data$l)
  output$map<-renderLeaflet(leaflet(data) %>%
                            addTiles() %>%
                            addMarkers(~lonl, ~latl, label = ~l) %>%
                            addCircleMarkers(~lonc, ~latc, label = ~c) %>%
                            addFlows(c(data$lonc),c(data$latc),c(data$lonl),c(data$latl),flow=c(data$val),maxThickness=5,color='red')
                            )
  
  
}
