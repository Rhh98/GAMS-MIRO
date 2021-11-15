mirorenderer_assignmentOutput <- function(id, height = NULL, options = NULL, path = NULL){
    ns <- NS(id)
    if (is.null(height)) {
        height <- 700
    }
    tagList(
    	fluidRow(
    		#column(3,dataTableOutput(ns('dataT'),height=height))
    		column(9, 
                textOutput(ns("textO")),
                plotOutput(ns("plot1"), height = 650)
                )
    		)
    	)
}
 
 renderMirorenderer_assignment <- function(input, output, session, data, options = NULL, path = NULL, rendererEnv = NULL, views = NULL, outputScalarsFull = NULL, ...){
    #output$dataT <- renderDataTable(datatable(data))

    names(data)[names(data) == "d" ] <- 'District'
    assign_dataframe <- data[data$header == "dist", ]
    centroid_dataframe <- data[data$header == "centroid", ]
    winLoss_dataframe <-  data[data$header == "winLoss", ] 
    scen_num <-  data[data$header == "choice", ] #get scenario number
    scen_num <-  scen_num[scen_num$i=="F1" & scen_num$District=="d1",]$value

    output$textO <- renderText({paste0("Scenario ",scen_num, " is chosen.")})

    centroid_dataframe['centroidID'] <- gsub("F", "", as.character(centroid_dataframe$i))
    centroid_dataframe['centroidID'] <- as.numeric(centroid_dataframe$centroidID)

    centroids <- sort(centroid_dataframe$centroidID)
    
    assign_dataframe["FID"] <- gsub("F", "", as.character(assign_dataframe$i))
    assign_dataframe["FID"] <- as.numeric(assign_dataframe$FID)

    winLoss_dataframe["FID"] <- gsub("F", "", as.character(winLoss_dataframe$i))
    winLoss_dataframe["FID"] <- as.numeric(winLoss_dataframe$FID)
    
    polygon_dataframe <- read.csv(paste0(path, "/wisconsin_df"))
    polygon_dataframe <- merge(x = polygon_dataframe, y = assign_dataframe, 
        by = "FID", all.x = TRUE)

    polygon_centroid <- polygon_dataframe[is.element(polygon_dataframe$FID,centroids),]

    centroid_coord <- aggregate(long ~ FID, polygon_centroid,mean)
    centroid_coord_lat <-aggregate(lat ~ FID, polygon_centroid,mean)
    centroid_coord$lat <- centroid_coord_lat$lat

    centroid_text <- c()

    for(i in centroids){
    	if (winLoss_dataframe[winLoss_dataframe$FID == i,]$value == 1){
    		centroid_text <- c(centroid_text,'R')
    	}

    	else if (winLoss_dataframe[winLoss_dataframe$FID == i,]$value == -1){
    		centroid_text <- c(centroid_text,'D')
    	}
    }

    centroid_coord$text <- centroid_text
    output$dataT <- renderDataTable(datatable(centroid_coord))
    p <- ggplot2::ggplot(data = polygon_dataframe, mapping = ggplot2::aes(x = long, y = lat, group = FID, fill = District)) +
         ggplot2::geom_polygon(color = "gray90", size = 0.1) +
		 ggplot2::geom_text(data=centroid_coord,mapping=ggplot2::aes(x= long, y=lat, label = text),inherit.aes = FALSE) +
		 ggplot2::theme(axis.title.x=ggplot2::element_blank(),
                  axis.text.x=ggplot2::element_blank(),
                  axis.ticks.x=ggplot2::element_blank(),
                  axis.title.y=ggplot2::element_blank(),
                  axis.text.y=ggplot2::element_blank(),
                  axis.ticks.y=ggplot2::element_blank())
    output$plot1 <- renderPlot({
         p
    })

}


