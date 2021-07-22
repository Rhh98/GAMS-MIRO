mirorenderer_assign_resultOutput <- function(id, height = NULL, options = NULL, path = NULL){
    ns <- NS(id)
    if (is.null(height)) {
        height <- 700
    }
    tagList(fluidRow(column(12, plotOutput(ns("plot1"), height = height))))
}
 
 renderMirorenderer_assign_result <- function(input, output, session, data, options = NULL, path = NULL, rendererEnv = NULL, views = NULL, outputScalarsFull = NULL, ...){
    # rename data column (need to change to id in our model)
    names(data)[names(data) == "id"] <- "district"

    #convert column s to double for merge later
    data$s <- as.double(data$s)

    #get the centroids to mark them in the map
    centroids <- unique(data$district)

    #get current path to read in shape data
    shape_data <- read.csv(paste0(path, "/milwaukee_shape.csv", 
        sep = ""))

    #convert column s to double for merge later
    shape_data$s <- as.double(shape_data$s)

    #join coordinate data and assignment data
    plot_data <- inner_join(shape_data, data, by = c("s"), suffix = c("_coord", 
        "_assign"))
    #write.csv(plot_data, paste0(path, "/test.csv", sep = ""))


    # Change district to a better form ex. D1, D2, ......
    district_order = 1
    for (j in sort(unique(plot_data$district))) {
        plot_data[plot_data$district == j, ]$district = paste0("", 
            district_order)
        district_order = district_order + 1
    }

    #start ploting 
    p <- ggplot2::ggplot(data = plot_data, mapping = ggplot2::aes(x = x, 
        y = y, group = s, fill = district))

    pp <- p + ggplot2::geom_polygon(color = "gray90", size = 0.1) + 
        ggplot2::geom_polygon(color="black", data = filter(plot_data, i %in% centroids))+
        ggplot2::guides(fill=ggplot2::guide_legend())

    output$plot1 <- renderPlot({pp})
}
