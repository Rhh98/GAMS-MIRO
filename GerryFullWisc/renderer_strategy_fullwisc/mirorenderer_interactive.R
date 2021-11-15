mirorenderer_interactiveOutput <- function(id, height = NULL, options = NULL, path = NULL){
    ns <- NS(id)
    if (is.null(height)) {
        height <- 500
    }
    fluidRow(   
    column(6,
          plotOutput(ns("plot1"), click = ns("plot1_click"),height=height)
    	),
    column(5,
          htmlOutput(ns("x_value")),
          imageOutput(ns("map_visual"))
          
          )
    )

}
 
renderMirorenderer_interactive <- function(input, output, session, data, options = NULL, path = NULL, rendererEnv = NULL, views = NULL, outputScalarsFull = NULL, ...){
  #output$dataT <- renderDataTable(datatable(data))

  #output$textT <- renderText({as.character(data[data$i=='F1',]$value)})

  popBound <- c("low","mid","high") # get the population choice
  popIndex <- data[data$i=='F1',]$value
  popChoice <- popBound[popIndex]


  compactnessPath <- normalizePath(paste0(path,"/",popChoice,"_compactness.csv"))
  compactness <- read.csv(compactnessPath) # read in compactness data
  winLossPath <- normalizePath(paste0(path,"/",popChoice,"_winLoss.csv"))
  winLoss <- read.csv(winLossPath) # read in winLoss data

  winLoss[winLoss$Val<0,]$Val <- 0
  winLossNew <- aggregate(winLoss$Val,by=list(s=winLoss$s),FUN=sum)
  names(winLossNew)[names(winLossNew) == "x"] <- 'R'
  winLossNew$D <- length(unique(winLoss$d)) - winLossNew$R #organized data that has column R or D
  winLossNew <- merge(x = winLossNew, y = compactness, by = "s", all.x = TRUE) # join compactness data
  names(winLossNew)[names(winLossNew) == "Val"] <- 'compactness' # change column name

  winLossNew <- winLossNew[order(winLossNew$R,-winLossNew$compactness,decreasing = TRUE),] #order using votes and compactness
#winLossNew <- winLossNew[order(winLossNew$R,decreasing = TRUE),] # align the number of votes
  
  space <- c(0.5) #deal with bar chart position

  for(i in 2:nrow(winLossNew)){
  	space <- c(space,0)
  }

  output$plot1 <- renderPlot({
    barplot(rbind(winLossNew$R,winLossNew$D),names=winLossNew$s, col = c("#FFCCCC","#99CCFF") ,legend = c('Republicans','Democrats'),beside = F,space=space,las=2)#(0.5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)) #create bar plot, some how it is required to manually specify space or 
    #lines(1:20, winLossNew$D, pch = 18, col = "blue", type = "b", lty = 2)
  })
  

  # Print the name of the x value
  output$x_value <- renderText({
    if (is.null(input$plot1_click$x)) return("")
    else {
      lvls <- winLossNew$s
      name <- lvls[round(input$plot1_click$x)]
      HTML("You've selected <code>", name, "</code>",
           "<br>Here is the assignment graph ")
           #"match that category:<br><img src='",
           #pic[round(input$plot1_click$x)],
           #"'>")
    }
  })
  
  

   output$map_visual <- renderImage({

  	   lvls <- winLossNew$s
       name <- lvls[round(input$plot1_click$x)] # get the correct scenario using click information
       f <- paste0(popChoice,'_',name,'.png')
       filename <- normalizePath(paste0(path,"/",popChoice,"_scene_plot/",f))
    
       list(src = filename,width = 300,height = 300)
    
     }
       , deleteFile = FALSE)


}
