resOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here
    textOutput(ns('test')),
    plotOutput(ns('res'),height=900,width = 900 )
  ) 
}

renderRes <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 

    
    x<-data$x[c(1,4,7,10)]
    y<-data$y[c(1,4,7,10)]
    mach<-c('CNC','Mill','Drill','Punch')
    from<-c('Recieve','CNC','Drill','Punch',
            'Recieve','Mill','Drill','Punch',
            'Recieve','CNC','Drill','Mill','Punch')
    to<-c('CNC','Drill','Punch','Ship',
          'Mill','Drill','Punch','Ship',
          'CNC','Drill','Mill','Punch','Ship')
    fromx<-rep(1,length(from))
    fromy<-fromx
    tox<-fromx
    toy<-fromx
   fromx[c(1,5,9)]=data$xr[1]
   fromx[c(2,10)]=data$x[1]
   fromx[c(3,7,11)]=data$x[7]
   fromx[c(4,8,13)]=data$x[10]
   fromx[c(6,12)]=data$x[4]
   fromy[c(1,5,9)]=data$yr[1]
   fromy[c(2,10)]=data$y[1]
   fromy[c(3,7,11)]=data$y[7]
   fromy[c(4,8,13)]=data$y[10]
   fromy[c(6,12)]=data$y[4]
   tox[c(4,8,13)]=data$xs[1]
   tox[c(1,9)]=data$x[1]
   tox[c(2,6,10)]=data$x[7]
   tox[c(3,7,12)]=data$x[10]
   tox[c(5,11)]=data$x[4]
   toy[c(4,8,13)]=data$ys[1]
   toy[c(1,9)]=data$y[1]
   toy[c(2,6,10)]=data$y[7]
   toy[c(3,7,12)]=data$y[10]
   toy[c(5,11)]=data$y[4]
    cost_old<-rep(1,length(from))
  for (i in 1:4)
  {
    cost_old[i]=unique(data$ch[data$products=='P1'])*sqrt((fromx[i]-tox[i])^2+(fromy[i]-toy[i])^2)
      
  }
   for (i in 5:8)
   {
     cost_old[i]=unique(data$ch[data$products=='P2'])*sqrt((fromx[i]-tox[i])^2+(fromy[i]-toy[i])^2)
   }
   for (i in 9:13)
   {
     cost_old[i]=unique(data$ch[data$products=='P3'])*sqrt((fromx[i]-tox[i])^2+(fromy[i]-toy[i])^2)
   }
   newx<-data$newx[c(1,4,7,10)]
   newy<-data$newy[c(1,4,7,10)]
   fromx[c(2,10)]=data$newx[1]
   fromx[c(3,7,11)]=data$newx[7]
   fromx[c(4,8,13)]=data$newx[10]
   fromx[c(6,12)]=data$newx[4]
   fromy[c(2,10)]=data$newy[1]
   fromy[c(3,7,11)]=data$newy[7]
   fromy[c(4,8,13)]=data$newy[10]
   fromy[c(6,12)]=data$newy[4]
   tox[c(1,9)]=data$newx[1]
   tox[c(2,6,10)]=data$newx[7]
   tox[c(3,7,12)]=data$newx[10]
   tox[c(5,11)]=data$newx[4]
   toy[c(1,9)]=data$newy[1]
   toy[c(2,6,10)]=data$newy[7]
   toy[c(3,7,12)]=data$newy[10]
   toy[c(5,11)]=data$newy[4]
     cost_new<-rep(1,length(from))
   for (i in 1:4)
   {
     cost_new[i]=unique(data$ch[data$products=='P1'])*sqrt((fromx[i]-tox[i])^2+(fromy[i]-toy[i])^2)
   }
   for (i in 5:8)
   {
     cost_new[i]=unique(data$ch[data$products=='P2'])*sqrt((fromx[i]-tox[i])^2+(fromy[i]-toy[i])^2)
   }
   for (i in 9:13)
   {
     cost_new[i]=unique(data$ch[data$products=='P3'])*sqrt((fromx[i]-tox[i])^2+(fromy[i]-toy[i])^2)
   }
   from_old<-from
   from_old[from_old!='Recieve']<-paste(from_old[from_old!='Recieve'],'old')
   from_new<-from
   from_new[from_new!='Recieve']<-paste(from_new[from_new!='Recieve'],'new')
   to_old<-to
   to_old[to_old!='Ship']<-paste(to_old[to_old!='Ship'],'old')
   to_new<-to
   to_new[to_new!='Ship']<-paste(to_new[to_new!='Ship'],'old')
       Ver<-data.frame(c(paste(mach,'old'),'Recieve','Ship',paste(mach,'new')),c(x,data$xr[1],data$xs[1],newx),c(y,data$yr[1],data$ys[1],newy))
       edge_all<-data.frame(c(from_old,from_new),c(to_old,to_new))
      
 output$test<-renderText("Rusult of relocating the facilities. The cost of moving machines from the old location to the new location and the cost 
                         when transporting products from one facility to another is displayed.")
  
 output$res<-renderPlot({
     gra<-graph_from_data_frame(d=edge_all,
                                vertices=Ver)
     par(mfrow=c(1,1),oma=c(1,1,4,1))
     plot(gra,vertex.size=25,vertex.color=c('grey','grey','grey','grey','green','red','yellow','yellow','yellow','yellow')
          ,edge.width=3,edge.color=c(rep(1,4),rep(2,4),rep(3,5),rep(4,4),rep(5,4),rep(6,5)),
          edge.label=round(c(cost_old,cost_new)),main = "Comparison of Cost of Transporting Products Before and After Facility Relocation")
    ProdCost<-rep(1,6)
    ProdCost[1]<-round(sum(cost_old[1:4]))
    ProdCost[2]<-round(sum(cost_old[5:8]))
    ProdCost[3]<-round(sum(cost_old[9:13]))
    ProdCost[4]<-round(sum(cost_new[1:4]))
    ProdCost[5]<-round(sum(cost_new[5:8]))
    ProdCost[6]<-round(sum(cost_new[9:13]))
      legend('topright',legend = c(paste('P1 old, cost:',ProdCost[1]),paste('P2 old, cost:',ProdCost[2]),paste('P3 old, cost:',ProdCost[3]),
                                   paste('P1 new, cost:',ProdCost[4]),paste('P2 new, cost:',ProdCost[5]),paste('P3 new, cost:',ProdCost[6])),lty=1,pt.bg=1:6,col=categorical_pal(6),lwd=2.2)
    mindex<-c(1,4,7,10)
    machinecost<-round(sum(data$cm[mindex]*sqrt((data$newx[mindex]-data$x[mindex])^2+(data$newy[mindex]-data$y[mindex])^2)))
    mtext(paste('Total cost of moving machines:',machinecost),outer = TRUE,side=3,adj=0,cex=1.5,line = 0)
    })
  
  
}