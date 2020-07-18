
CournotOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    textOutput(ns('cour2text')),
    #define rendererOutput function here
    fluidRow(column(4,selectInput(ns('select'),label = 'Select Firm',choices =paste('firm',1:10))),
             column(8,sliderInput(
               inputId = ns("Selectfirm"),
               label = 'Selected Firm Quantity (*NE)',
               min = 0.5,
               max= 1.5,
               value = 1,
               step=0.1))),
    fluidRow(column(6, plotlyOutput(ns('cour2'),height=height)),
             column(6,plotlyOutput(ns('cour22'),height=height)))
  )
}

renderCournot <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  output$cour2text<-renderText(paste("The picture shows when one of the firm change quantities and the other
                               firms remain the same, how the profit of each firm will change. The below picture
                               gives an example when the firm",input$select," change quantities and others remain the same.
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
  CourMember<-data$courmember==1
  output$cour2<-renderPlotly({
    ii<-which(paste('firm',1:10)==input$select)
    xx<-rep(quantity[ii]*input$Selectfirm,l)
    yy<-xx
    pp<-xx
    pp[ii]<-(dbar/(rep(1,l)%*%quantity-quantity[ii]+xx[ii]))^(1/gamma)
    yy[ii]<-xx[ii]*pp[ii]-cost[ii]*xx[ii]-
      ((beta[ii]/(beta[ii]+1))*L[ii]^(1/beta[ii]))*xx[ii]^((1+beta[ii])/beta[ii])
    for (i in setdiff(1:l,ii)){
      pp[i]<-(dbar/(rep(1,l)%*%quantity-quantity[ii]+xx[ii]))^(1/gamma)
      yy[i]<-quantity[i]*pp[i]-cost[i]*quantity[i]-
        ((beta[i]/(beta[i]+1))*L[i]^(1/beta[i]))*quantity[i]^((1+beta[i])/beta[i])
    }
    yy2=rep(0,l)
    yy2[CourMember]=yy[CourMember]
    fig2<-plot_ly(type = 'bar',x=paste('firm',1:l)
                  ,y=yy2,name = "Cournot Member")
    yy2=rep(0,l)
    yy2[!CourMember]=yy[!CourMember]
    fig2<-add_trace(fig2,y=yy2,name = "Price Taking")
    fig2<-layout(fig2,title = paste("Profits with respect to quantities of firm",ii),
                 xaxis=list(title='Firm'),yaxis=list(title="Profits",range=c(0,1.3*max(profit))))
    
    
  })
    output$cour22<-renderPlotly({
        ii<-which(paste('firm',1:10)==input$select)
    xx<-rep(1,l)
    xx<-t(t(xx)) %*% rep(1,100)
    yy<-xx
    pp<-xx

    for (j in 1:100)
    {
      xx[ii,j]<-quantity[ii]/2+j*quantity[ii]/100
      pp[ii,j]<-(dbar/(rep(1,l)%*%quantity-quantity[ii]+xx[ii,j]))^(1/gamma)
      yy[ii,j]<-xx[ii,j]*pp[ii,j]-cost[ii]*xx[ii,j]-
        ((beta[ii]/(beta[ii]+1))*L[ii]^(1/beta[ii]))*xx[ii,j]^((1+beta[ii])/beta[ii])
    }
    for (i in setdiff(1:l,ii)){
      for (j in 1:100)
      {
        xx[i,j]<-quantity[ii]/2+j*quantity[ii]/100
        pp[i,j]<-(dbar/(rep(1,l)%*%quantity-quantity[ii]+xx[ii,j]))^(1/gamma)
        yy[i,j]<-quantity[i]*pp[i,j]-cost[i]*quantity[i]-
          ((beta[i]/(beta[i]+1))*L[i]^(1/beta[i]))*quantity[i]^((1+beta[i])/beta[i])
      }
    }
    cols=1:l
    fig2<-plot_ly()
    for (i in 1:l)
   {  if(CourMember[i])
     { fig2<-add_trace(fig2,type='scatter',mode='lines',x=xx[i,],y=yy[i,],
                    line=list(width=2,color=cols[i],dash='dash'),name=paste('firm',i,'Cournot Member'))}
      
    if(!CourMember[i]){ fig2<-add_trace(fig2,type='scatter',mode='lines',x=xx[i,],y=yy[i,],
                     line=list(width=2,color=cols[i]),name=paste('firm',i,'Price Taking'))}
      }
   
     fig2
    xx<-rep(quantity[ii]*input$Selectfirm,l)
    yy<-xx
    pp<-xx
    pp[ii]<-(dbar/(rep(1,l)%*%quantity-quantity[ii]+xx[ii]))^(1/gamma)
    yy[ii]<-xx[ii]*pp[ii]-cost[ii]*xx[ii]-
      ((beta[ii]/(beta[ii]+1))*L[ii]^(1/beta[ii]))*xx[ii]^((1+beta[ii])/beta[ii])
    for (i in setdiff(1:l,ii)){
      pp[i]<-(dbar/(rep(1,l)%*%quantity-quantity[ii]+xx[ii]))^(1/gamma)
      yy[i]<-quantity[i]*pp[i]-cost[i]*quantity[i]-
        ((beta[i]/(beta[i]+1))*L[i]^(1/beta[i]))*quantity[i]^((1+beta[i])/beta[i])
    }
    for (i in 1:l)
    {
      fig2<-add_trace(fig2,type='scatter',mode='markers',x=xx[i],y=yy[i],
                      marker=list(size=15,symbol='o',color=cols[i]),showlegend=FALSE,name=i)
    }


    fig2<-layout(fig2,title = paste("Profits with respect to quantities of firm",ii),
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
    textOutput(ns('leadtext')),
   fluidRow(
     column(6,sliderInput(ns('lquantity'),
                          label='Quantity of leader Firm (*NE)',
                          value = 1,
                          min = 0.5,
                          max = 1.5,
                          step = 0.05),)
   ), 

    fluidRow(column(6,plotlyOutput(ns('bar'),height=height)),
             column(6,plotlyOutput(ns('plot'),height=height)))
  )
}

renderLead <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  l<-length(unique(data$i))
  cols=1:l
  ind<-which(is.na(data$lquantity))
  lead<-which(1:l==unique(data$i[-ind]))
  output$leadtext<-renderText(paste('The picture below shows the profits of the',l,' firms when firm',lead,' is a leader firm or not a leader firm.'))
  
  output$plot<-renderPlotly({
    x<-data$lquantity[-ind]
    yl<-data$lprofit[-ind]
    yn<-data$nprofit[-ind]
    xind<-(input$lquantity-0.45)/0.05
    fig<-plot_ly()
    fig<-add_trace(fig,type='scatter',mode='lines',x=x,y=yl,
                   line=list(width=2,color=cols[lead]),name=paste('Firm',lead,' L'))
    fig<-add_trace(fig,type='scatter',mode='lines',x=x,y=yn,
                   line=list(width=2,dash='dash',color=cols[lead]),name=paste('Firm',lead,' N'))
    fig<-add_trace(fig,type='scatter',mode='markers',x=x[xind],y=yl[xind],
                   marker=list(size=15,color=cols[lead]),showlegend=FALSE)
    fig<-add_trace(fig,type='scatter',symbol='x',mode='markers',x=x[xind],y=yn[xind],
                   marker=list(size=15,color=cols[lead]),showlegend=FALSE)
    for(i in setdiff(1:l,lead))
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
  output$bar<-renderPlotly({
    x<-data$lquantity[-ind]
    yl<-data$lprofit[-ind]
    yn<-data$nprofit[-ind]
    xind<-(input$lquantity-0.45)/0.05
    y1=rep(0,l)
    y2=y1
    y1[lead]=yl[xind]
    y2[lead]=yn[xind]
    for(i in setdiff(1:l,lead))
    {
      ind<-data$i == i
      yl<-data$lprofit[ind]
      yn<-data$nprofit[ind]
      y1[i]=yl[xind]
      y2[i]=yn[xind]
    }
    fig<-plot_ly(type='bar',x=paste('firm',1:l),y=y1,name=paste("Firm",lead,'as leader firm'))
    fig<-add_trace(fig,y=y2,name=paste('Firm',lead,'as Cournot member'))
    fig<-layout(fig,xaxis=list(title='firm'),yaxis=list(title='profit',range=c(0,1.3*max(max(data$lprofit),max(data$nprofit)))))
  })
}
stacQuanOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    textOutput(ns('text')),
    fluidRow(
      column(6,sliderInput(ns('lquantity'),
                           label='Quantity of leader Firm (*NE)',
                           value = 1,
                           min = 0.5,
                           max = 1.5,
                           step = 0.05),)
    ), 
    fluidRow(column(6,plotlyOutput(ns('bar'),height=height)),
             column(6,plotlyOutput(ns('plot'),height=height)))
  ) 
}

renderStacQuan <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  l<-length(unique(data$i))
  cols=1:l
  ind<-which(is.na(data$lquantity))
  lead<-which(1:l==unique(data$i[-ind]))
  x<-data$lquantity[-ind]
  y<-data$nquantity[ind]
  output$text<-renderText(paste('The picture below shows the Quantity of each firm will decide to produce with repect to the quantity of the leader firm: firm.',lead))
  output$bar<-renderPlotly({
    xind<-(input$lquantity-0.45)/0.05
    yy<-rep(0,l)
    yy[lead]=0;
    yy[setdiff(1:l,lead)]<-y[(1:(l-1))*21-21+xind]
    fig<-plot_ly(type='bar',x=paste('firm',1:l),y=yy,name = 'Cournot Member')
    yy[1:l]=0
    yy[lead]=x[xind]
    fig<-add_trace(fig,y=yy,name="Leader Firm")
    fig<-layout(fig,axis=list(title='firm'),yaxis=list(title='quantity',range=c(0,1.3*max(data$nquantity))),barmode='stack')
  })
  output$plot<-renderPlotly({
    xind<-(input$lquantity-0.45)/0.05
    fig<-plot_ly()
    fig<-add_trace(fig,type='scatter',mode='lines',x=x,y=x,
                   line=list(width=2,color=cols[lead]),name=paste('Leader Firm'))
    fig<-add_trace(fig,type='scatter',mode='markers',x=x[xind],y=x[xind],
                   marker=list(size=15,color=cols[lead]),showlegend=FALSE)
    for(i in setdiff(1:l,lead))
    {
      ind<-data$i == i
      yn<-data$nquantity[ind]
      fig<-add_trace(fig,type='scatter',mode='lines',x=x,y=yn,
                     line=list(width=2,color=cols[i]),name=paste('Firm',i))
      fig<-add_trace(fig,type='scatter',mode='markers',x=x[xind],y=yn[xind],
                     marker=list(size=15,color=cols[i]),showlegend=FALSE)
    }
    fig<-layout(fig,xaxis=list(title='quantity of lead firm'),yaxis=list(title='quantity'))
  })
}
resOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    textOutput(ns('text')),
    fluidRow(
      column(6,plotlyOutput(ns('quantity'),height=height)),
      column(6,plotlyOutput(ns('profit'),height = height))
    )
    
  ) 
}

renderRes <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  output$text<-renderText('This output shows the different quantities and profits a firm will produce and gain when it acts as a leader firm or not.')
  
  
  output$quantity<-renderPlotly({
    fig<-plot_ly(type = 'bar',x=paste('firm',data$i),name = 'Cournot Member',y=data$courquantity)
    fig<-add_trace(fig,y=data$stacquantity,name = 'Stackelberg Leader Firm')
    fig<-layout(fig,title="Quantity Comparison",xaxis=list(title='firm'),yaxis=list(title='quantity'),barmode='group')
  })
  output$profit<-renderPlotly({
    fig<-plot_ly(type = 'bar',x=paste('firm',data$i),name = 'Cournot Member',y=data$courprofit)
    fig<-add_trace(fig,y=data$stacprofit,name = 'Stackelberg Leader Firm')
    fig<-layout(fig,title="Profit Comparison",xaxis=list(title='firm'),yaxis=list(title='profit'),barmode='group')
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


# Cournot2Output <- function(id, height = NULL, options = NULL, path = NULL){
#   ns <- NS(id)
#   
#   # set default height
#   if(is.null(height)){
#     height <- 700
#   } 
#   tagList( 
#     #define rendererOutput function here 
#     
#     sidebarLayout(
#       sidebarPanel (textOutput(ns('cour1text')),
#         sliderInput(inputId = ns("firm1"),
#                                 label = 'Firm 1 Quantity (*NE)',
#                                 min = 0.5,
#                                 max= 1.5,
#                                 value = 1,
#                                 step=0.1),
#         sliderInput(inputId = ns("firm2"),
#                     label = 'firm 2 Quantity (*NE)',
#                     min = 0.5,
#                     max= 1.5,
#                     value = 1,
#                     step = 0.1),
#         sliderInput(inputId = ns("firm3"),
#                     label = 'firm 3 Quantity (*NE)',
#                     min = 0.5,
#                     max= 1.5,
#                     value = 1,
#                     step = 0.1)
# 
#       ),
#       mainPanel(
#                 plotlyOutput(ns('cour1'),height=height),)
#      ),
#     sidebarLayout(
#       sidebarPanel (textOutput(ns('cour11text')),
#                     sliderInput(inputId = ns("firm11"),
#                                 label = 'Firm 1 Quantity (*NE)',
#                                 min = 0.5,
#                                 max= 1.5,
#                                 value = 1,
#                                 step=0.1),
#                     sliderInput(inputId = ns("firm21"),
#                                 label = 'firm 2 Quantity (*NE)',
#                                 min = 0.5,
#                                 max= 1.5,
#                                 value = 1,
#                                 step = 0.1),
#                     sliderInput(inputId = ns("firm31"),
#                                 label = 'firm 3 Quantity (*NE)',
#                                 min = 0.5,
#                                 max= 1.5,
#                                 value = 1,
#                                 step = 0.1)
#                     
#       ),
#       mainPanel(
#         plotlyOutput(ns('cour11'),height=height))
#     )
#   ) 
# }
# 
# 
# renderCournot2 <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
#   #renderer
#   output$cour1text<-renderText("The picture shows the relationship between the profits and the quantities
#                                of firms. While a firm changes its quantity and the other firms' quantities are
#                                set to the solution of the Nash Equilibrium. ")
#   output$cour11text<-renderText("The picture shows the relationship between the profits and the quantities
#                                of firms. While a firm changes its quantity and the other firms' quantities are
#                                set to the solution of the Nash Equilibrium. ")
#   ind<-data$i
#   l<-length(ind)
#   quantity<-data$quantity
#   price<-unique(data$price)
#   cost<-data$cost
#   beta<-data$beta
#   profit<-data$profit
#   gamma<-unique(data$gamma)
#   dbar<-unique(data$dbar)
#   L<-data$l
#   
# 
#   output$cour1<-renderPlotly({
#     x<-rep(1,l)
#     y<-x
#     p<-x
#     x[1]<-quantity[1]*input$firm1
#     p[1]<-(dbar/(rep(1,l)%*%quantity-quantity[1]+x[1]))^(1/gamma)
#     y[1]<-x[1]*p[1]-cost[1]*x[1]-
#       ((beta[1]/(beta[1]+1))*L[1]^(1/beta[1]))*x[1]^((1+beta[1])/beta[1])
#     x[2]<-quantity[2]*input$firm2
#     p[2]<-(dbar/(rep(1,l)%*%quantity-quantity[2]+x[2]))^(1/gamma)
#     y[2]<-x[2]*p[2]-cost[2]*x[2]-
#       ((beta[2]/(beta[2]+1))*L[2]^(1/beta[2]))*x[2]^((1+beta[2])/beta[2])
#     x[3]<-quantity[3]*input$firm3
#     p[3]<-(dbar/(rep(1,l)%*%quantity-quantity[3]+x[3]))^(1/gamma)
#     y[3]<-x[3]*p[3]-cost[3]*x[3]-
#       ((beta[3]/(beta[3]+1))*L[3]^(1/beta[3]))*x[3]^((1+beta[3])/beta[3])
#     fig1<-plot_ly(type = 'bar',x=c('firm 1','firm 2','firm 3')
#             ,y=y)
#     fig1<-layout(fig1,title = "Profits with respect to quantities of each firm",
#                  xaxis=list(title='Firm'),yaxis=list(title="Profits"))
# 
# 
# 
#   })
#   
#   output$cour11<-renderPlotly({
#     x<-rep(1,l)
#     x<-t(t(x)) %*% rep(1,100)
#     y<-x
#     p<-x
#     for (i in 1:l){
#       for (j in 1:100)
#       {
#         x[i,j]<-quantity[i]/2+j*quantity[i]/100
#         p[i,j]<-(dbar/(rep(1,l)%*%quantity-quantity[i]+x[i,j]))^(1/gamma)
#         y[i,j]<-x[i,j]*p[i,j]-cost[i]*x[i,j]-
#           ((beta[i]/(beta[i]+1))*L[i]^(1/beta[i]))*x[i,j]^((1+beta[i])/beta[i])
#       }
#     }
#     fig2<-plot_ly()
#     cols=c('green','blue','red')
#     fig2<-add_trace(fig2,type='scatter',mode='lines',x=x[1,],y=y[1,],name='firm 1'
#                     ,line=list(width=2,color='green'))
#     fig2<-add_trace(fig2,type='scatter',mode='lines',x=x[2,],y=y[2,],name = 'firm 2'
#                     ,line=list(width=2,color='blue'))
#     fig2<-add_trace(fig2,type='scatter',mode='lines',x=x[3,],y=y[3,],name= 'firm 3'
#                     ,line=list(width=2,color='red'))
#     x<-rep(1,3)
#     y<-x
#     p<-x
#     
#     x[1]<-quantity[1]*input$firm11
#     p[1]<-(dbar/(rep(1,l)%*%quantity-quantity[1]+x[1]))^(1/gamma)
#     y[1]<-x[1]*p[1]-cost[1]*x[1]-
#       ((beta[1]/(beta[1]+1))*L[1]^(1/beta[1]))*x[1]^((1+beta[1])/beta[1])
#     x[2]<-quantity[2]*input$firm21
#     p[2]<-(dbar/(rep(1,l)%*%quantity-quantity[2]+x[2]))^(1/gamma)
#     y[2]<-x[2]*p[2]-cost[2]*x[2]-
#       ((beta[2]/(beta[2]+1))*L[2]^(1/beta[2]))*x[2]^((1+beta[2])/beta[2])
#     x[3]<-quantity[3]*input$firm31
#     p[3]<-(dbar/(rep(1,l)%*%quantity-quantity[3]+x[3]))^(1/gamma)
#     y[3]<-x[3]*p[3]-cost[3]*x[3]-
#       ((beta[3]/(beta[3]+1))*L[3]^(1/beta[3]))*x[3]^((1+beta[3])/beta[3])
#     fig2
#       fig2<-add_trace(fig2,type='scatter',mode='marker',x=x[1],y=y[1],
#                       marker=list(size=15,symbol='o',color=cols[1]),showlegend=FALSE)
#       fig2<-add_trace(fig2,type='scatter',mode='marker',x=x[2],y=y[2],
#                       marker=list(size=15,symbol='o',color=cols[2]),showlegend=FALSE)
#       fig2<-add_trace(fig2,type='scatter',mode='marker',x=x[3],y=y[3],
#                       marker=list(size=15,symbol='o',color=cols[3]),showlegend=FALSE)
#       fig2<-layout(fig2,title = "Profits with respect to quantities of each firm",
#                    xaxis=list(title='Firm'),yaxis=list(title="Profits"))
#       
#       })
# }  
