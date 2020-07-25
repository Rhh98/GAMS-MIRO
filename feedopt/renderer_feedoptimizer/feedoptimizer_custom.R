resOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
   selectInput(ns('ScenarioSelect'), label="Scenario", 
                                  choice=c('c1','c2','c3')),
  plotOutput(ns('feed'),height=height))
  
}

renderRes <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  l<-length(unique(data$c))
  C<-unique(data$c)
  k<-floor(sqrt(l))
  output$feed<-renderPlot({
     par(mfrow=c(1,1),mar=c(1,1,1,1),oma=c(3,3,8,3))
    # for (i in 1:length(C))
    # {
      
      z<-data$c==input$ScenarioSelect &  !is.na(data$z)  &data$z >=1 & data$z!=3 
      areacover<-data$areacover[z]
      areacover<-areacover[1]
      type<-data$type[z]
      type[type==1]='1st'
      type[type==2]='2nd'
      type[type==3]='sponsored'
      S<-data$bigs[z]
      Time<-data$time[z]
      val<-data$value[z]
      xl<-data$x[z]
      xl[which(is.na(xl))]=0
      yb<-data$y[z]
      yb[which(is.na(yb))]=0
      xr<-xl+data$width[z]
      yt<-yb+data$height[z]
      plot(1:data$totalwidth[1],1:data$totalheight[1]
           ,xlab='width',ylab='height',type='n',cex=1.2,font = 2)
      bigM<-max(val)
      mtext(paste('Feed at scenario',input$ScenarioSelect),line = 1,side = 3,cex=1.5)
      mtext(paste('Area covered ratio:',round(areacover),'%'),side=3,line=-2,cex=1)
       Color<-heat.colors(bigM+1)
       heatcol<-Color[length(Color)-floor(val)]
        rect(xl,yb,xr,yt,col = heatcol)
        text((xl+xr)/2,(yb+yt)/2,paste(S,': ',type,'\n','Update time:',Time,'\n','value:',round(val,2)),cex=1.2,font = 2,col='black')
    # }
     mtext(paste('Feed at  scenario',input$ScenarioSelect),side=3,line=6,outer=TRUE,cex=3,font=3)
     mtext(paste('Time window:',data$window[1]),side = 3,line=3,outer=TRUE,cex=1.2)
     mtext(paste('Check time:',data$checkat[1]),side = 3,line=3,outer=TRUE,cex=1.2,adj=1)
     mtext(paste('Total value:',round(data$totalval[1])),side=3,line=3,outer=TRUE,cex=1.2,adj=0)
     
    })
  
}