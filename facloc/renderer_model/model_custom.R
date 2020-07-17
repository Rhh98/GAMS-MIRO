resOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here
    textOutput(ns('test')),
    fluidRow(column(4,selectInput(ns('select'),label='Select Product Flow',choices = 
                                     c('P1 Old Flow','P2 Old Flow','P3 Old Flow','P1 New Flow','P2 New Flow','P3 New Flow')))),
    plotlyOutput(ns('fig'),height=height)
  ) 
}

renderRes <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
   
   
   if (data$status[1]>1)  
   {output$test<-renderText('The problem is infeasible.')
   output$res1<-renderPlot(c())
    output$res2<-renderLeaflet(c())
   }

   else if (data$status[1]==1)  
   {
    x<-data$x[c(1,4,7,10)]
    y<-data$y[c(1,4,7,10)]
    mach<-c('CNC','Mill','Drill','Punch')
    from<-c('Receive','CNC','Drill','Punch',
            'Receive','Mill','Drill','Punch',
            'Receive','CNC','Drill','Mill','Punch')
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
    cost_old=round(cost_old)
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
     cost_new=round(cost_new)
   from_old<-from
   from_old[from_old!='Receive']<-paste(from_old[from_old!='Receive'],'old')
   from_new<-from
   from_new[from_new!='Receive']<-paste(from_new[from_new!='Receive'],'new')
   to_old<-to
   to_old[to_old!='Ship']<-paste(to_old[to_old!='Ship'],'old')
   to_new<-to
   to_new[to_new!='Ship']<-paste(to_new[to_new!='Ship'],'new')
       Ver<-data.frame(c(paste(mach,'old'),'Receive','Ship',paste(mach,'new')),c(x,data$xr[1],data$xs[1],newx),c(y,data$yr[1],data$ys[1],newy))
       edge_all<-data.frame(c(from_old,from_new),c(to_old,to_new))
      
 output$test<-renderText("Result of relocating the facilities. The cost of
                         transporting products from one facility to another in original and new layouts.")
 output$fig<-renderPlotly({
    fig<-plot_ly()
    fig<-add_trace(fig,type='scatter',mode='markers',x=x,y=y,hovertext=paste(mach,'old'),hoverinfo='x+y+text',
                   showlegend=FALSE,marker=list(size=30,color='grey'))
    fig<-add_trace(fig,type='scatter',mode='markers',x=newx,y=newy,hovertext=paste(mach,'new'),hoverinfo='x+y+text',
                   showlegend=FALSE,marker=list(size=30,color='green'))
    fig<-add_trace(fig,type='scatter',mode='markers',x=c(data$xr[1],data$xs[1]),y=c(data$yr[1],data$ys[1]),hoverinfo='x+y+text'
                   ,hovertext=c('receiving','shipping'),showlegend=FALSE,marker=list(size=30,color='yellow',symbol='square')
                   )
   if (input$select == 'P1 Old Flow')
    {fig<-add_trace(fig,type='scatter',mode='lines',
                   x=c(data$xr[1],data$x[c(1,7,10)],data$xs[1]),hoverinfo='x+y+text'
                   ,y=c(data$yr[1],data$y[c(1,7,10)],data$ys[1]),line=list(wdth=2,color='orange'),text =paste('P1 total cost:',sum( cost_old[1:4])))}
   if(input$select == 'P2 Old Flow')
     {fig<-add_trace(fig,type='scatter',mode='lines',
                   x=c(data$xr[1],data$x[c(4,7,10)],data$xs[1]),hoverinfo='x+y+text'
                   ,y=c(data$yr[1],data$y[c(4,7,10)],data$ys[1]),line=list(wdth=2,color='green'),text = paste('P2 total cost:',sum(cost_old[5:8])),name='P2 Old Flow')}
    if (input$select == 'P3 Old Flow')
    {fig<-add_trace(fig,type='scatter',mode='lines',
                   x=c(data$xr[1],data$x[c(1,4,7,10)],data$xs[1]),hoverinfo='x+y+text'
                   ,y=c(data$yr[1],data$y[c(1,4,7,10)],data$ys[1]),line=list(wdth=2,color='red'),hovertext = paste('P3 total cost:',sum(cost_old[9:13])),name='P3 Old Flow')}
   if (input$select == 'P1 New Flow')
     {fig<-add_trace(fig,type='scatter',mode='lines',
                   x=c(data$xr[1],data$newx[c(1,7,10)],data$xs[1]),hoverinfo='x+y+text'
                   ,y=c(data$yr[1],data$newy[c(1,7,10)],data$ys[1]),line=list(wdth=2,color='orange'),hovertext = paste('P1 total cost:',sum(cost_new[1:4])),name='P1 New Flow')}
    if (input$select == 'P2 New Flow')
    {fig<-add_trace(fig,type='scatter',mode='lines',
                   x=c(data$xr[1],data$newx[c(4,7,10)],data$xs[1]),hoverinfo='x+y+text'
                   ,y=c(data$yr[1],data$newy[c(4,7,10)],data$ys[1]),line=list(wdth=2,color='green'),hovertext = paste('P2 total cost:',sum(cost_new[5:8])),name='P2 New Flow')}
    if (input$select == 'P3 New Flow')
     {fig<-add_trace(fig,type='scatter',mode='lines',
                   x=c(data$xr[1],data$newx[c(1,4,7,10)],data$xs[1]),hoverinfo='x+y+text'
                   ,y=c(data$yr[1],data$newy[c(1,4,7,10)],data$ys[1]),line=list(wdth=2,color='red'),hovertext = paste('P3 total cost:',sum(cost_new[9:13])),name='P3 New Flow')}
    fig
    
 })
   }
}

costOutput <- function(id, height = NULL, options = NULL, path = NULL){
   ns <- NS(id)
   
   # set default height
   if(is.null(height)){
      height <- 700
   } 
   tagList( 
      #define rendererOutput function here 
      plotlyOutput(ns('bar'),height = height)
   ) 
}

renderCost <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
   #renderer 
   output$bar<-renderPlotly({
      fig<-plot_ly(type='bar',x=c('Old','New'),showlegend=FALSE)
    l<-length(data$products)
    for (i in 1:l) {
       fig<-add_trace(fig,type='bar',y=c(data$old[i],data$new[i]),name=paste('P',i),showlegend=TRUE)
    }
    fig<-add_trace(fig,type='bar',y=c(0,data$machine[1]),name='Cost of Moving Machines',showlegend=TRUE)
    fig<-layout(fig,yaxis=list(title='Cost'),barmode = 'stack')
   })
}

