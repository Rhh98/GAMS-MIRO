mirorenderer_outputOutput <- function(id, height = NULL, options = NULL, path = NULL){
    ns <- NS(id)
    # set default height
	if(is.null(height)){
		height <- 700
	} 
	tagList( 
	#define rendererOutput function here
		fluidRow(
		  #column(5,dataTableOutput(ns('dataT'))),
		  column(9,plotOutput(ns('plot'),height=height))
		)
	) 
}
 
 renderMirorenderer_output <- function(input, output, session, data, options = NULL, path = NULL, rendererEnv = NULL, views = NULL, outputScalarsFull = NULL, ...){
 	
 	#output$dataT<-DT::renderDataTable(datatable(block))

 	initDF <- data[data['header']=='init',]
 	solDF <- data[data['header']=='sol',]
	blockDF <- data[data['header']=='blocked',]

 	reverse_coord <- function(row,col,h,w){
	  x <- 0.5 + (col - 1)
	  y <- (h - 0.5) - (row - 1)

	  return (c(x,y))
	}
 	output$plot<-renderPlot(
    {
    	h=6
    	w=6


		p <- plot(x=c(0.5), y = c(0.5), 
		     asp=1, xlim=c(0,w),ylim=c(0,h),xaxt="n",yaxt="n",xlab="",ylab="",
		     xaxs="i", yaxs="i", axes=F)

        par(mar=c(.5,.5,.5,.5))

		for( i in 1:(h+1)){
		  segments(x0=0,y0=i-1,x1=w,y1=i-1) 
		}

		# add vertical lines
		for( i in 1:(w+1)){
		  segments(x0=i-1,y0=0,x1=i-1,y1=h) 
		}

		for(i in 1:h){
		  for(j in 1:w){
		    points(x=0.5 + (j-1), y= 0.5 + (i-1),pch=19)
		  }
		}

		#add initial lines
		for (row in 1:nrow(initDF)){
			x0 = as.numeric(initDF[row,'i'])
			y0 = as.numeric(initDF[row,'j'])
			x1 = as.numeric(initDF[row,'k'])
			y1 = as.numeric(initDF[row,'l'])

			source = reverse_coord(x0,y0,h,w)
			dest = reverse_coord(x1,y1,h,w)
			segments(x0=source[1],y0=source[2],x1=dest[1],y1=dest[2],col='red') 
		} 

		for (row in 1:nrow(solDF)){
			x0 = as.numeric(solDF[row,'i'])
			y0 = as.numeric(solDF[row,'j'])
			x1 = as.numeric(solDF[row,'k'])
			y1 = as.numeric(solDF[row,'l'])

			source = reverse_coord(x0,y0,h,w)
			dest = reverse_coord(x1,y1,h,w)
			segments(x0=source[1],y0=source[2],x1=dest[1],y1=dest[2],col='black') 
		} 

		for (row in 1:nrow(blockDF)){
			x0 = as.numeric(blockDF[row,'i'])
			y0 = as.numeric(blockDF[row,'j'])

			source = reverse_coord(x0,y0,h,w)
			rect(source[1]-0.5,source[2]+0.5,source[1]+0.5,source[2]-0.5,col='black')
		} 

		      
    }
  )

}
