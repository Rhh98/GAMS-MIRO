outputOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here
    plotOutput(ns('plott'),height=height),
    dataTableOutput(ns('tabletest'),height=height)
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
  newZ<-matrix(data$newz[-which(is.na(data$newz))],nrow = 100)
  rank<-data$ranking[-which(is.na(data$ranking))]
   output$plott<-renderPlot({
     # plot(c(),c(),xlim = c(0,1),ylim=c(0,1))
     par(mfrow=c(1,2))
     contour(Z,levels = c(0,0),lwd = 2,main = "Training and Trusted item", xlab="Magic Heritage", ylab="Education")
     for (i in 1:length(Posind)){
     points(X_heri[Posind[i]],X_edu[Posind[i]],bg='blue',col='blue',pch=3,cex=1.5)
     }
     X_temp<-X_heri[-Posind]
     X_temp2<-X_edu[-Posind]
     for (i in 1:100-length(Posind))
     {
     points(X_temp[i],X_temp2[i],bg='blue',col='blue',pch=21,cex=1.5)
     }
  Posind<-which(T_label>0)
  for (i in 1:length(Posind)){
    points(T_heri[Posind[i]],T_edu[Posind[i]],bg='red',col='red',pch=3,cex=1.5)
  }
  T_temp<-T_heri[-Posind]
  T_temp2<-T_edu[-Posind]
  for (i in 1:100-length(Posind))
  {
    points(T_temp[i],T_temp2[i],col='red',bg='red',pch=21,cex=1.5)
  }
  legend(0.8,1,legend=c("Train Pos","Train Neg","Trust Pos","Trust Neg"),pch=c(3,21,3,21)
          ,col=c("blue","blue","red","red"),pt.bg=c("blue","blue","red","red"))
#debug output
  Posind<-which(X_label > 0)
  Newind<-which(rank<41)
  NewPos<-setdiff(Newind,Posind)
  Posind<-setdiff(Posind,Newind)
  contour(newZ,levels = c(0,0),lwd = 2,main = "Debugging", xlab="Magic Heritage", ylab="Education")
  if(length(Posind)){
  for (i in 1:length(Posind)){
    points(X_heri[Posind[i]],X_edu[Posind[i]],bg='blue',col='blue',pch=3,cex=1.5)
  }
  }
  X_temp<-X_heri[-c(Posind,Newind)]
  X_temp2<-X_edu[-c(Posind,Newind)]
  if(length(X_temp))
  {
  for (i in 1:length(X_temp))
  {
    points(X_temp[i],X_temp2[i],bg='blue',col='blue',pch=21,cex=1.5)
  }
  }
  if(length(NewPos))
  {for (i in 1:length(NewPos)){
    points(X_heri[NewPos[i]],X_edu[NewPos[i]],bg='black',col='black',pch=21,cex=1.5)
  }}
  X_temp<-X_heri[setdiff(Newind,NewPos)]
  X_temp2<-X_edu[setdiff(Newind,NewPos)]
  if(length(X_temp))
  {for (i in 1:length(X_temp))
  {
    points(X_temp[i],X_temp2[i],bg='black',col='black',pch=3,cex=1.5)
  }}
  legend(0.8,1,legend=c("True Pos","True Neg","False Pos","False Neg"),pch=c(3,21,3,21)
         ,col=c("blue","blue","black","black"),pt.bg=c("blue","blue","black","black"))
 })
  output$tabletest<-DT::renderDataTable(datatable(cbind(newZ)))
}