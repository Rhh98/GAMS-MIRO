CournotOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    textOutput(ns('cour1text')),
    plotOutput(ns('cour1'),height=height),
    textOutput(ns('cour2text')),
    plotOutput(ns('cour2'),height=height),
    #define rendererOutput function here 
  ) 
}

renderCournot <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer
  output$cour1text<-renderText("The picture below shows the relationship between the profits and the quantities 
                               of firms. While a firm changes its quantity and the other firms' quantities are 
                               set to the solution of the Nash Equilibrium. 
                               \n The three marked points in the figure is exact the solution 
                               to the Nash Equilibrium.")
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
  output$cour1<-renderPlot({
    #par(mfrow=c(1,1),oma=c(3,3,8,3))
    plot(c(),c(),type='l',xlim=c(min(x),max(x)),ylim=c(min(y),max(y)+20),xlab='quantities',ylab='profit',
         main = 'Profits with respect to quantities of each firm')
    for (i in 1:l)
    {
      lines(x[i,],y[i,],lty=i,col=i,lwd=2)
      text(quantity[i],profit[i]+5,paste('quantity:',round(quantity[i],2),'\nprofit:',round(profit[i],2)))
      points(quantity[i],profit[i],col=i,cex=3,pch=16)
    }
    legend(min(x),max(y)+20,legend = paste(rep('firm ',l),ind),lty=1:l,col=1:l)
    
  })
  output$cour2text<-renderText(paste("The picture below shows when one of the firm change quantities and the other
                               firms remain the same, how the profit of each firm will change. The below picture 
                               gives an example when the firm ",ind[1]," change quantities and others remain the same.
                                     The 3 points represent the profits at the solution to the Nash Equilibrium."))
  xx<-rep(1,l)
  xx<-t(t(xx)) %*% rep(1,100)
  yy<-xx
  pp<-xx
  
  for (j in 1:100)
  {
    xx[1,j]<-quantity[1]/2+j*quantity[1]/100
    pp[1,j]<-(dbar/(rep(1,l)%*%quantity-quantity[1]+x[1,j]))^(1/gamma)
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
  output$cour2<-renderPlot({
    plot(c(),c(),type='l',xlim=c(min(xx),max(xx)),ylim=c(min(yy),max(yy)+20),xlab='quantities',ylab='profit',
         main = paste('Profits with respect to quantities of firm', ind[1]))
    for (i in 1:l)
    {
      lines(xx[i,],yy[i,],lty=i,col=i,lwd=2)
      points(xx[i,50],profit[i],col=i,cex=3,pch=16)
      text(xx[i,50],profit[i]+5,paste('profit:',round(profit[i],2)))
    }
    lines(rep(xx[i,50],2),c(0,max(yy[,50])+10),col='grey',lty=2,lwd=1.5)
    text(xx[i,50],max(yy[,50])+12,paste('quantity:',round(quantity[1],2)),cex=1.2)
    legend(min(x),max(yy)+20,legend = paste(rep('firm ',l),ind),lty=1:l,col=1:l)
    
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
    textOutput(ns('leadtext')),
    plotOutput(ns('lead'),height=height)
  ) 
}

renderLead <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  output$leadtext<-renderText(paste('The picture below shows the profits of firm ',unique(data$lead), 
                                    ' as a leader firm or not as a leader firm.'))
  x<-data$lquantity
  yl<-data$lprofit
  yn<-data$nprofit
  output$lead<-renderPlot({
    plot(x,yl,ylim = c(min(cbind(yl,yn)),max(cbind(yl,yn))+10),type='l',xlab = 'quantity',ylab = 'profit',lty=1,col=1,
         main=paste('Profit of firm ',unique(data$lead),' as leader and non-leader firm w.r.t quantity'),lwd=2)
    lines(x,yn,lty=2,col=2)
    legend(min(x),max(cbind(yl,yn))+5,legend = c('As leader firm','Not leader firm'),lty=1:2,col=1:2)
    points(c(x[10],x[yn==max(yn)]),c(yl[10],max(yn)),cex=2,col=1:2)
    text(c(x[10],x[yn==max(yn)]),c(yl[10]+1,max(yn)-1),c('Solution as leader firm','Nash Equilibrium'),col=1:2)
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


