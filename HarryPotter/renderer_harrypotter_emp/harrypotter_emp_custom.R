outputOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here
    fluidRow(column(6,plotly::plotlyOutput(ns('plot1'),height=height)),
              column(6,plotly::plotlyOutput(ns('plot2'),height=height)))
    #dataTableOutput(ns('tabletest'),height=height)
  ) 
}

renderOutput <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer
  X_heri<-data$heritage[-which(is.na(data$heritage))]
  X_edu<-data$education[-which(is.na(data$education))]
  X_label<-data$val[-which(is.na(data$val))]
  Posind<-which(X_label > 0)
  T_heri<-data$heritage_t[-which(is.na(data$heritage_t))]
  T_edu<-data$education_t[-which(is.na(data$education_t))]
  T_label<-data$label[-which(is.na(data$label))]
  Z<-matrix(data$zval[-which(is.na(data$zval))],nrow = 100)
  Z<-t(Z)
  newZ<-matrix(data$newz[-which(is.na(data$newz))],nrow = 100)
  newZ<-t(newZ)
  rank<-data$ranking[-which(is.na(data$ranking))]
  
  fig1<- plotly::plot_ly()
  fig1<-plotly::add_trace(fig1,type='scatter',x=X_heri[Posind],y=X_edu[Posind],name = "Train Pos"
  ,mode = "markers",marker=list(size=10,symbol='cross',color='blue'))
  
  X_temp<-X_heri[-Posind]
  X_temp2<-X_edu[-Posind]
  
  
  fig1<-plotly::add_trace(fig1,type='scatter',x=X_temp,y=X_temp2,name="Train Neg",mode="markers"
                  ,marker=list(size=10,symbol='o',color='blue'))
  
  Posind<-which(T_label>0)
  
  fig1<-plotly::add_trace(fig1,type='scatter',x=T_heri[Posind],y=T_edu[Posind],mode='markers'
                  ,marker=list(size=10,symbol='cross',color='orange'),name="Trust Pos")
  
  T_temp<-T_heri[-Posind]
  T_temp2<-T_edu[-Posind]
  fig1<-plotly::add_trace(fig1,type='scatter',x=T_temp,y=T_temp2,name="Trust Neg",mode="markers"
                  ,marker=list(size=10,symbol='o',color='orange'))
  
  Contour1<-contourLines(x=1:100/100,y=1:100/100,z=t(Z),levels = c(0))
  conx<-Contour1[[1]]$x
  cony<-Contour1[[1]]$y
  fig1<-plotly::add_trace(fig1,x=conx,y=cony,type='scatter',mode='lines',name="Classfier")
  fig1<-plotly::layout(fig1,title='Learning without Trusted item',xaxis=list(title='Magical Heritage')
               ,yaxis=list(title='Education'))
  
  #debug output
  Posind<-which(X_label > 0)
  Newind<-which(rank<41)
  NewPos<-setdiff(Newind,Posind)
  Posind<-setdiff(Posind,Newind)
  
    if(length(Posind)){
    
    fig2<- plotly::plot_ly()
    fig2<-plotly::add_trace(fig2,type='scatter',x=X_heri[Posind],y=X_edu[Posind],name = "True Pos"
                   ,mode = "markers",marker=list(size=10,symbol='cross',color='blue'))
    
  }
  X_temp<-X_heri[-c(Posind,Newind)]
  X_temp2<-X_edu[-c(Posind,Newind)]
  if(length(X_temp))
  {
    fig2<-plotly::add_trace(fig2,type='scatter',x=X_temp,y=X_temp2,name="True Neg",mode="markers"
                    ,marker=list(size=10,symbol='o',color='blue'))
  }
  if(length(NewPos))
  {
    fig2<-plotly::add_trace(fig2,type='scatter',x=X_heri[NewPos],y=X_edu[NewPos],name="False Neg",mode="markers"
                    ,marker=list(size=10,symbol='cross',color='black'))
  }
  X_temp<-X_heri[setdiff(Newind,NewPos)]
  X_temp2<-X_edu[setdiff(Newind,NewPos)]
  if(length(X_temp))
  {
    fig2<-plotly::add_trace(fig2,type='scatter',x=X_temp,y=X_temp2,name="False Pos",mode="markers"
                    ,marker=list(size=10,symbol='o',color='black'))

  }
  
  fig2<-plotly::layout(fig2,title='Debug using DUTI',xaxis=list(title='Magical Heritage')
               ,yaxis=list(title='Education'))
  
  x <- c(1:100)
  random_y <- rnorm(100, mean = 0)
  data <- data.frame(x, random_y)
  Contour2<-contourLines(x=1:100/100,y=1:100/100,z=t(newZ),levels = c(0))
  conx<-Contour2[[1]]$x
  cony<-Contour2[[1]]$y
  fig2<-plotly::add_trace(fig2,x=conx,y=cony,type='scatter',mode='lines',name="Classfier" )
  
  output$plot1<-plotly::renderPlotly(fig1)
  output$plot2<-plotly::renderPlotly(fig2)
  #output$tabletest<-DT::renderDataTable(datatable(cbind(newZ)))
}