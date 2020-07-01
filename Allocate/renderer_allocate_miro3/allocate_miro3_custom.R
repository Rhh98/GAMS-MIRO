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
  Nan<-which(is.na(data$val))
  output$dataT<-DT::renderDataTable(datatable(cbind(data$c[-Nan],data$l[-Nan],data$prv[-Nan],data$val[-Nan]),
                                              colnames=c('center','lab','prevalence','number of kits')))
  
  # latl=unique(data$value[data$allocateHeader == 'latl'])
  # lonl=unique(data$value[data$allocateHeader == 'lonl'])
   l=unique(data$l)
   c=unique(data$c)
   lind<-rep(1,length(l))
   cind<-rep(1,length(c))
  for ( i in 1:length(l))
  {
    temp<-which(data$l==l[i])
    lind[i]<-temp[1]
  }
   for (i in 1:length(c))
   {
     temp<-which(data$c==c[i])
     cind[i]<-temp[1]
   }
  output$map<-renderLeaflet({map<-leaflet(data) 
                            map<-addTiles(map) 
                            map<-addMarkers(map,~lonl[lind],~latl[lind] , label = l)
                            map<-addCircleMarkers(map,~lonc[cind], ~latc[cind], label = c)
                            for (i in 1:length(l))
                            {
                              ind<-data$l==l[i] & !is.na(data$val)
                              lon=cbind(data$lonc[ind],data$lonl[ind])
                              lat=cbind(data$latc[ind],data$latl[ind])
                              val=data$val[ind]
                              if (length(val))
                              {
                              for (j in 1:length(data$lonc[ind]))
                              {
                                
                                map<-addPolylines(map,lon[j,],lat[j,],weight=val[j]/max(data$val[-Nan])*6,
                                                  color='purple',group = paste('lab:',l[i]),label = val[j] )
                              }
                              }
                             
                            }
                            for (i in 1:length(data$l))
                            {
                              if(!is.na(data$val[i]))
                                
                            map<-addPolylines(map,c(data$lonc[i],data$lonl[i]),c(data$latc[i],data$latl[i]),weight=data$val[i]/max(data$val[-Nan])*6,
                                           color='red',group='all',label=data$val[i])
                            }
                            for (i in 1:length(c))
                            {
                              ind<-data$c==c[i] & !is.na(data$val)
                              lon=cbind(data$lonc[ind],data$lonl[ind])
                              lat=cbind(data$latc[ind],data$latl[ind])
                              val=data$val[ind]
                              if (length(val)){
                              for (j in 1:length(data$lonc[ind]))
                              {
                                map<-addPolylines(map,lon[j,],lat[j,],weight=val[j]/max(data$val[-Nan])*6,
                                                  color='green',group = paste('center:',c[i]),label=val[j])
                              }
                              }
                              
                            }
                            map<-addLayersControl(map,
                              baseGroups =c( 'all',paste('lab:',l),paste('center:',c)),
                              options = layersControlOptions(collapsed = FALSE)
                            )
                            })
  
  
}