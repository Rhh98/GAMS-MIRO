tourOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    leaflet::leafletOutput(ns('T'),height=height)
  ) 
}

renderTour <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  ind<-data$status==1
  allcity<-unique(data$i)
  nind<-rep(1,length(allcity)-length(data$i[ind]))
  
  if(length(nind))
  {
    count=0
    for(i in 1:length(allcity))
    {

      if (!length(data$i[data$status==1 & data$i==allcity[i]]))
      {temp<-which(data$i==allcity[i])
      count=count+1
      nind[count]=temp[1]}
    }
    output$T<-leaflet::renderLeaflet({
      map<-leaflet::leaflet(data)
      map<-leaflet::addTiles(map)
      map<-leaflet::addMarkers(map,~long1[ind],~lat1[ind],label = ~i[ind],group = 'Selected Cities')
      map<-leaflet::addCircleMarkers(map,~long1[nind],~lat1[nind],label=~i[nind],color='grey',group = 'Non-Selected Cities')
      map<-leaflet.minicharts::addFlows(map,data$long1[ind],data$lat1[ind],data$long2[ind],data$lat2[ind],flow= data$dist[ind],minThickness = 5,maxThickness = 5)     
      map<-leaflet::addLayersControl(map,
                            overlayGroups ='Non-Selected Cities',
                            options = layersControlOptions(collapsed = FALSE)
      )
    })

  }
 else
  {
    output$T<-leaflet::renderLeaflet({
    map<-leaflet::leaflet(data)
    map<-leaflet::addTiles(map)
    map<-leaflet::addMarkers(map,~long1[ind],~lat1[ind],label = ~i[ind])
    map<-leaflet::addFlows(map,data$long1[ind],data$lat1[ind],data$long2[ind],data$lat2[ind],flow= data$dist[ind],minThickness = 5,maxThickness = 5)
    })
  }
}
