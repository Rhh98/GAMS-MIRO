mirorenderer_population_resultOutput <- function(id, height = NULL, options = NULL, path = NULL){
    ns <- NS(id)
     # set default height
	if(is.null(height)){
	  height <- 700
	} 
	tagList( 
	#define rendererOutput function here 
	  textOutput(ns('status')),
	  fluidRow(
	  	#column(3,dataTableOutput(ns('dataT'),height=height))
	    column(12, plotly::plotlyOutput(ns('plot1'),height=height))
	  )
	    
	)

}
 
 renderMirorenderer_population_result <- function(input, output, session, data, options = NULL, path = NULL, rendererEnv = NULL, views = NULL, outputScalarsFull = NULL, ...){

	plot_data<-data

	# replace centroid with district representation
	district_order = 1
    for (j in sort(unique(plot_data$id))) {
        plot_data[plot_data$id == j, ]$id = paste0("D", 
            district_order)
        district_order = district_order + 1
    }

    fig <- plotly::plot_ly(
    x = plot_data$id,
    y = plot_data$value,
    name = "Population Distribution",
    type = "bar",
    text = plot_data$value,
    textposition = 'auto') 

    # horizontal line function
    hline <- function(y = 0, color = "black") {
        list(
            type = "line", 
            x0 = 0, 
            x1 = 1, 
            xref = "paper",
            y0 = y, 
            y1 = y, 
            line = list(color = color)
            )
    }

    fig<-plotly::layout(fig,title = "Population Distribution",
        xaxis = list(title = "District",
                     zeroline = FALSE,
                     color = 'Black',
                     categoryorder='trace'),
        yaxis = list(title = "Population",
                     zeroline = FALSE,
                     color = 'Black'),shapes = hline(sum(plot_data$value)/length(plot_data$value)))

    output$plot1 <- plotly::renderPlotly(fig)


}
