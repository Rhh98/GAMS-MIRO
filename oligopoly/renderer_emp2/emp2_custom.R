CournotOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    
    sidebarLayout(
      sidebarPanel (textOutput(ns('cour1text')),
        sliderInput(inputId = ns("firm1"),
                                label = 'Firm 1 Quantity (*NE)',
                                min = 0.5,
                                max= 1.5,
                                value = 1,
                                step=0.1),
        sliderInput(inputId = ns("firm2"),
                    label = 'firm 2 Quantity (*NE)',
                    min = 0.5,
                    max= 1.5,
                    value = 1,
                    step = 0.1),
        sliderInput(inputId = ns("firm3"),
                    label = 'firm 3 Quantity (*NE)',
                    min = 0.5,
                    max= 1.5,
                    value = 1,
                    step = 0.1)

      ),
      mainPanel(
                plotlyOutput(ns('cour1'),height=height),)
     ),
    sidebarLayout(
      sidebarPanel (textOutput(ns('cour11text')),
                    sliderInput(inputId = ns("firm11"),
                                label = 'Firm 1 Quantity (*NE)',
                                min = 0.5,
                                max= 1.5,
                                value = 1,
                                step=0.1),
                    sliderInput(inputId = ns("firm21"),
                                label = 'firm 2 Quantity (*NE)',
                                min = 0.5,
                                max= 1.5,
                                value = 1,
                                step = 0.1),
                    sliderInput(inputId = ns("firm31"),
                                label = 'firm 3 Quantity (*NE)',
                                min = 0.5,
                                max= 1.5,
                                value = 1,
                                step = 0.1)
                    
      ),
      mainPanel(
        plotlyOutput(ns('cour11'),height=height))
    )
  ) 
}


renderCournot <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer
  output$cour1text<-renderText("The picture shows the relationship between the profits and the quantities
                               of firms. While a firm changes its quantity and the other firms' quantities are
                               set to the solution of the Nash Equilibrium. ")
  output$cour11text<-renderText("The picture shows the relationship between the profits and the quantities
                               of firms. While a firm changes its quantity and the other firms' quantities are
                               set to the solution of the Nash Equilibrium. ")
  ind<-data$i
  l<-length(ind)
  quantity<-data$quantity
  price<-unique(data$price)
  cost<-data$cost
  beta<-data$beta
  profit<-data$profit
  gamma<-unique(data$gamma)
  dbar<-unique(data$dbar)
  L<-data$l
  

  output$cour1<-renderPlotly({
    x<-rep(1,l)
    y<-x
    p<-x
    x[1]<-quantity[1]*input$firm1
    p[1]<-(dbar/(rep(1,l)%*%quantity-quantity[1]+x[1]))^(1/gamma)
    y[1]<-x[1]*p[1]-cost[1]*x[1]-
      ((beta[1]/(beta[1]+1))*L[1]^(1/beta[1]))*x[1]^((1+beta[1])/beta[1])
    x[2]<-quantity[2]*input$firm2
    p[2]<-(dbar/(rep(1,l)%*%quantity-quantity[2]+x[2]))^(1/gamma)
    y[2]<-x[2]*p[2]-cost[2]*x[2]-
      ((beta[2]/(beta[2]+1))*L[2]^(1/beta[2]))*x[2]^((1+beta[2])/beta[2])
    x[3]<-quantity[3]*input$firm3
    p[3]<-(dbar/(rep(1,l)%*%quantity-quantity[3]+x[3]))^(1/gamma)
    y[3]<-x[3]*p[3]-cost[3]*x[3]-
      ((beta[3]/(beta[3]+1))*L[3]^(1/beta[3]))*x[3]^((1+beta[3])/beta[3])
    fig1<-plot_ly(type = 'bar',x=c('firm 1','firm 2','firm 3')
            ,y=y)
    fig1<-layout(fig1,title = "Profits with respect to quantities of each firm",
                 xaxis=list(title='Firm'),yaxis=list(title="Profits"))



  })
  
  output$cour11<-renderPlotly({
    x<-rep(1,l)
    x<-t(t(x)) %*% rep(1,100)
    y<-x
    p<-x
    for (i in 1:l){
      for (j in 1:100)
      {
        x[i,j]<-quantity[i]/2+j*quantity[i]/100
        p[i,j]<-(dbar/(rep(1,l)%*%quantity-quantity[i]+x[i,j]))^(1/gamma)
        y[i,j]<-x[i,j]*p[i,j]-cost[i]*x[i,j]-
          ((beta[i]/(beta[i]+1))*L[i]^(1/beta[i]))*x[i,j]^((1+beta[i])/beta[i])
      }
    }
    fig2<-plot_ly()
    cols=c('green','blue','red')
    fig2<-add_trace(fig2,type='scatter',mode='lines',x=x[1,],y=y[1,],name='firm 1'
                    ,line=list(width=2,color='green'))
    fig2<-add_trace(fig2,type='scatter',mode='lines',x=x[2,],y=y[2,],name = 'firm 2'
                    ,line=list(width=2,color='blue'))
    fig2<-add_trace(fig2,type='scatter',mode='lines',x=x[3,],y=y[3,],name= 'firm 3'
                    ,line=list(width=2,color='red'))
    x<-rep(1,3)
    y<-x
    p<-x
    
    x[1]<-quantity[1]*input$firm11
    p[1]<-(dbar/(rep(1,l)%*%quantity-quantity[1]+x[1]))^(1/gamma)
    y[1]<-x[1]*p[1]-cost[1]*x[1]-
      ((beta[1]/(beta[1]+1))*L[1]^(1/beta[1]))*x[1]^((1+beta[1])/beta[1])
    x[2]<-quantity[2]*input$firm21
    p[2]<-(dbar/(rep(1,l)%*%quantity-quantity[2]+x[2]))^(1/gamma)
    y[2]<-x[2]*p[2]-cost[2]*x[2]-
      ((beta[2]/(beta[2]+1))*L[2]^(1/beta[2]))*x[2]^((1+beta[2])/beta[2])
    x[3]<-quantity[3]*input$firm31
    p[3]<-(dbar/(rep(1,l)%*%quantity-quantity[3]+x[3]))^(1/gamma)
    y[3]<-x[3]*p[3]-cost[3]*x[3]-
      ((beta[3]/(beta[3]+1))*L[3]^(1/beta[3]))*x[3]^((1+beta[3])/beta[3])
    fig2
      fig2<-add_trace(fig2,type='scatter',mode='marker',x=x[1],y=y[1],
                      marker=list(size=15,symbol='o',color=cols[1]),showlegend=FALSE)
      fig2<-add_trace(fig2,type='scatter',mode='marker',x=x[2],y=y[2],
                      marker=list(size=15,symbol='o',color=cols[2]),showlegend=FALSE)
      fig2<-add_trace(fig2,type='scatter',mode='marker',x=x[3],y=y[3],
                      marker=list(size=15,symbol='o',color=cols[3]),showlegend=FALSE)
      fig2<-layout(fig2,title = "Profits with respect to quantities of each firm",
                   xaxis=list(title='Firm'),yaxis=list(title="Profits"))
      
      })
}  
cour2Output <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here
    sidebarLayout(
      sidebarPanel (textOutput(ns('cour2text')),
        sliderInput(
          inputId = ns("firm11"),
                    label = 'Firm 1 Quantity (*NE)',
                    min = 0.5,
                    max= 1.5,
                    value = 1,
                    step=0.1),
        
        
      ),
      mainPanel(
                plotlyOutput(ns('cour2'),height=height))
    ),
  
  sidebarLayout(
    sidebarPanel (textOutput(ns('cour22text')),
                  sliderInput(
                    inputId = ns("firm1"),
                    label = 'Firm 1 Quantity (*NE)',
                    min = 0.5,
                    max= 1.5,
                    value = 1,
                    step=0.1),
                  
                  
    ),
    mainPanel(
      plotlyOutput(ns('cour22'),height=height))
  )
  )
}

renderCour2 <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  output$cour2text<-renderText(paste("The picture shows when one of the firm change quantities and the other
                               firms remain the same, how the profit of each firm will change. The below picture
                               gives an example when the firm 1 change quantities and others remain the same.
                                     The 3 points represent the profits at the solution to the Nash Equilibrium."))
  ind<-data$i
  l<-length(ind)
  quantity<-data$quantity
  price<-unique(data$price)
  cost<-data$cost
  beta<-data$beta
  profit<-data$profit
  gamma<-unique(data$gamma)
  dbar<-unique(data$dbar)
  L<-data$l
  output$cour2<-renderPlotly({
    
    xx<-rep(quantity[1]*input$firm11,l)
    yy<-xx
    pp<-xx
    pp[1]<-(dbar/(rep(1,l)%*%quantity-quantity[1]+xx[1]))^(1/gamma)
    yy[1]<-xx[1]*pp[1]-cost[1]*xx[1]-
      ((beta[1]/(beta[1]+1))*L[1]^(1/beta[1]))*xx[1]^((1+beta[1])/beta[1])
    for (i in 2:l){
      pp[i]<-(dbar/(rep(1,l)%*%quantity-quantity[1]+xx[1]))^(1/gamma)
      yy[i]<-quantity[i]*pp[i]-cost[i]*quantity[i]-
        ((beta[i]/(beta[i]+1))*L[i]^(1/beta[i]))*quantity[i]^((1+beta[i])/beta[i])
    }
    fig2<-plot_ly(type = 'bar',x=c('firm 1','firm 2','firm 3')
                  ,y=yy)
    fig2<-layout(fig2,title = "Profits with respect to quantities of firm 1",
                 xaxis=list(title='Firm'),yaxis=list(title="Profits"))
    
    
  })
  output$cour22text<-renderText(paste("The picture shows when one of the firm change quantities and the other
                               firms remain the same, how the profit of each firm will change. The below picture
                               gives an example when the firm 1 change quantities and others remain the same.
                                     The 3 points represent the profits at the solution to the Nash Equilibrium."))
  
  output$cour22<-renderPlotly({
    
    xx<-rep(1,l)
    xx<-t(t(xx)) %*% rep(1,100)
    yy<-xx
    pp<-xx

    for (j in 1:100)
    {
      xx[1,j]<-quantity[1]/2+j*quantity[1]/100
      pp[1,j]<-(dbar/(rep(1,l)%*%quantity-quantity[1]+xx[1,j]))^(1/gamma)
      yy[1,j]<-xx[1,j]*pp[1,j]-cost[1]*xx[1,j]-
        ((beta[1]/(beta[1]+1))*L[1]^(1/beta[1]))*xx[1,j]^((1+beta[1])/beta[1])
    }
    for (i in 2:l){
      for (j in 1:100)
      {
        xx[i,j]<-quantity[1]/2+j*quantity[1]/100
        pp[i,j]<-(dbar/(rep(1,l)%*%quantity-quantity[1]+xx[1,j]))^(1/gamma)
        yy[i,j]<-quantity[i]*pp[i,j]-cost[i]*quantity[i]-
          ((beta[i]/(beta[i]+1))*L[i]^(1/beta[i]))*quantity[i]^((1+beta[i])/beta[i])
      }
    }
    cols=c('green','blue','red')
    fig2<-plot_ly()
    for (i in 1:l)
   { fig2<-add_trace(fig2,type='scatter',mode='lines',x=xx[i,],y=yy[i,],
                    line=list(width=2,color=cols[i]),name=paste('firm',i))}
    fig2
    xx<-rep(quantity[1]*input$firm1,l)
    yy<-xx
    pp<-xx
    pp[1]<-(dbar/(rep(1,l)%*%quantity-quantity[1]+xx[1]))^(1/gamma)
    yy[1]<-xx[1]*pp[1]-cost[1]*xx[1]-
      ((beta[1]/(beta[1]+1))*L[1]^(1/beta[1]))*xx[1]^((1+beta[1])/beta[1])
    for (i in 2:l){
      pp[i]<-(dbar/(rep(1,l)%*%quantity-quantity[1]+xx[1]))^(1/gamma)
      yy[i]<-quantity[i]*pp[i]-cost[i]*quantity[i]-
        ((beta[i]/(beta[i]+1))*L[i]^(1/beta[i]))*quantity[i]^((1+beta[i])/beta[i])
    }
    for (i in 1:l)
    {
      fig2<-add_trace(fig2,type='scatter',mode='markers',x=xx[i],y=yy[i],
                      marker=list(size=15,symbol='o',color=cols[i]),showlegend=FALSE)
    }
    
    
    fig2<-layout(fig2,title = "Profits with respect to quantities of firm 1",
                 xaxis=list(title='Firm'),yaxis=list(title="Profits"))
    
    
  })
}
leadOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here
    sidebarLayout(
      sidebarPanel(sliderInput(ns('lquantity'),
                               label='Quantity of Firm 1 (*NE)',
                               value = 1,
                               min = 0.5,
                               max = 1.5,
                               step = 0.05)
                   ),
      mainPanel(textOutput(ns('leadtext')),
                plotlyOutput(ns('lead'),height=height))
    )
    
  ) 
}

renderLead <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  output$leadtext<-renderText(paste('The picture below shows the profits of the 3 firms when firm 1 is a leader firm or not a leader firm.'))
  cols=c('green','blue','red')
  
  output$lead<-renderPlotly({
    ind<-which(is.na(data$lquantity))
    x<-data$lquantity[-ind]
    yl<-data$lprofit[-ind]
    yn<-data$nprofit[-ind]
    xind<-(input$lquantity-0.45)/0.05
    fig<-plot_ly()
    fig<-add_trace(fig,type='scatter',mode='lines',x=x,y=yl,
                   line=list(width=2,color=cols[1]),name='Firm 1 L')
    fig<-add_trace(fig,type='scatter',mode='lines',x=x,y=yn,
                   line=list(width=2,dash='dash',color=cols[1]),name='Firm 1 N')
    fig<-add_trace(fig,type='scatter',mode='markers',x=x[xind],y=yl[xind],
                   marker=list(size=15,color=cols[1]),showlegend=FALSE)
    fig<-add_trace(fig,type='scatter',symbol='x',mode='markers',x=x[xind],y=yn[xind],
                   marker=list(size=15,color=cols[1]),showlegend=FALSE)
    for(i in 2:3)
    {
      ind<-data$i == i
      yl<-data$lprofit[ind]
      yn<-data$nprofit[ind]
      fig<-add_trace(fig,type='scatter',mode='lines',x=x,y=yl,
                     line=list(width=2,color=cols[i]),name=paste('Firm',i,'L'))
      fig<-add_trace(fig,type='scatter',mode='lines',x=x,y=yn,
                     line=list(width=2,dash='dash',color=cols[i]),name=paste('Firm',i,'N'))
      fig<-add_trace(fig,type='scatter',mode='markers',x=x[xind],y=yl[xind],
                     marker=list(size=15,color=cols[i]),showlegend=FALSE)
      fig<-add_trace(fig,type='scatter',symbol='x',mode='markers',x=x[xind],y=yn[xind],
                     marker=list(size=15,color=cols[i]),showlegend=FALSE)
    }
    fig<-layout(fig,xaxis=list(title='quantity of lead firm'),yaxis=list(title='profits'))
  })
}



BertOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    textOutput(ns('berttext')),
    plotOutput(ns('bert'),height=height)
    
  ) 
}

renderBert <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  dd<-unique(data$d)
  x<-unique(data$price)
  y1<-rep(1,2)
  y1<-t(t(y1)) %*% rep(1,20)
  y2<-y1
  for (ii in 1:2)
  {
    temp1<-data$quantity[data$d==dd[ii]]
    temp2<-data$profit[data$d==dd[ii]]
    for(jj in 1:20)
    {
      y1[ii,jj]=temp1[jj]
      y2[ii,jj]=temp2[jj]
    }
  }
  output$berttext<-renderText(paste("This output gives the result of the toy example for the Bertrand 
                                      model, where the firm changes stragies by changing the price. The two pictures 
                                      below show the relation ship between the price of the frim 1 and the quantity and profit of
                                       the 2 firms. The price of the firm 2 is fixed to the solution of the Nash Equilibrium in both pictures."))
  output$bert<-renderPlot({
    par(mfrow=c(1,2))
    plot(x,y1[1,],ylim=c(min(y1),max(y1)+5),col=1,lwd=2,lty=1,xlab='price',ylab = 'quantity'
         ,main='Quantites w.r.t price of firm 1',type='l')
    lines(x,y1[2,],col=2,lty=2,lwd=2)
    legend(min(x),max(y1)+5,legend=c('firm 1','firm 2'),lty=1:2,col=1:2)
    points(c(x[10],x[10]),c(y1[1,10],y1[2,10]),cex=2,col=1:2)
    text(c(x[10],x[10]),c(y1[1,10]+2,y1[2,10]-2),c('Nash Equilibrium','Nash Equilibrium'),col=1:2)
    
    plot(x,y2[1,],ylim=c(min(y2),max(y2)+5),col=1,lwd=2,lty=1,xlab='price',ylab = 'profit'
         ,main='Profits w.r.t price of firm 1',type='l')
    lines(x,y2[2,],col=2,lty=2,lwd=2)
    legend(min(x),max(y2),legend=c('firm 1','firm 2'),lty=1:2,col=1:2)
    points(c(x[10],x[10]),c(y2[1,10],y2[2,10]),cex=2,col=1:2)
    text(c(x[10],x[10]),c(y2[1,10]-2,y2[2,10]+2),c('Nash Equilibrium','Nash Equilibrium'),col=1:2)
  })
}



nonleadOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    textOutput(ns('nonleadtext')),
    plotOutput(ns('nonlead'),height=height)
  ) 
}

renderNonlead <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  ind<-unique(data$i)
  x<-unique(data$lquantity)
  len<-length(ind)
  y<-rep(1,len)
  y<-t(t(y)) %*% rep(1,20)
  y2<-y
  for (ii in 1:len)
  {
    templ<-data$lprofit[data$i==ind[ii]]
    tempn<-data$nprofit[data$i==ind[ii]]
    for (j in 1:20)
    {
      y[ii,j]=templ[j]
      y2[ii,j]=tempn[j]
      
    }
  }
  output$nonleadtext<-renderText(paste("This output shows the effect of the leader firm on other firms. When there is
                                       a leader firm, other firm will make decision based on the decision(production quantity) 
                                       made by the leader firm, while if there is no leader firm other firms will make the 'best possible decision',
                                       which is the result to the equilibrium problem before as the Cournot model. The picture below shows the profits of those are not 
                                       the leader firm when the leader firm choose different production quantity."))
  output$nonlead<-renderPlot({
    
    par(mfrow=c(floor(sqrt(len)),ceiling(len/floor(sqrt(len)))))
    for (i in 1:len)
    {
      plot(x,y[i,],col=1,lwd=2,ylim=c(min(cbind(y[i,],y2[i,])),max(cbind(y[i,],y2[i,]))),main = paste("Firm ",ind[i],
                                                                                                      "'s profit w.r.t quantity of the leader firm"),type='l',lty=1,xlab='quantity',ylab = 'profit')
      lines(x,y2[i,],col=2,lwd=2,lty=2)
      legend(min(x)+(max(x)-min(x))*0.65,max(cbind(y[i,],y2[i,])),legend=c('When leader firm exists','none leader firm exists'),lty=1:2,col=1:2)
      
    }
  })
}

