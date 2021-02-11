#redistricted map layout
gerryOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    textOutput(ns('status')),
    fluidRow(
      column(4,dataTableOutput(ns('dataT'),height=height)),
      column(8, plotOutput(ns('plot1'),height=height))
    )
    
  )
}

#redistricted map logic
renderGerry <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  #output$status<-renderText(names(data))
  #output$status<-renderText(path)
  df_assign <- cbind(c(data$nodes),c(data$district))
  output$dataT<-DT::renderDataTable(datatable(df_assign,colnames=c('County','District Assigned')))

#-----------------------------------ggplot ---------------------------------  
  #st_df <- ggplot2::map_data('state','arizona')
  st_df <- read.csv(paste(path,"/states.csv",sep=""))
  st_df <- subset(st_df, region == "arizona")
  st_county <- read.csv(paste(path,"/counties.csv",sep=""))
  st_county <- subset(st_county , region == "arizona")
  county_fips <- read.csv(paste(path,"/fips.csv",sep=""))
  
  #test_data <- tibble(nodes = c('04001','04009','04011','04017','04003','04019','04023','04005','04007','04015','04025','04013','04021','04012','04027'),
  #                    district = c('d1','d2','d1','d1','d1','d1','d1','d2','d2','d1','d1','d1','d2','d3','d3'))
  test_data <- data
  fips_coverted = as.integer(test_data$nodes)
  test_data$fips_code = fips_coverted
  st_fips = county_fips[county_fips$fips %in% fips_coverted,]$fips
  st_subregion = strsplit(county_fips[county_fips$fips %in% fips_coverted,]$polyname, ',')
  sub_vector <- c()
  for(sub in st_subregion){
    sub_vector <- c(sub_vector,sub[2])
  }
  fip_subregion_map = tibble(fips_code=st_fips,subregion = sub_vector)
  data_ready <- inner_join(fip_subregion_map, test_data, by = "fips_code")
  visualize_data<-inner_join(st_county, data_ready, by = "subregion")
  
  ditch_the_axes <- ggplot2::theme(
    axis.text = ggplot2::element_blank(),
    axis.line = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank(),
    panel.border = ggplot2::element_blank(),
    panel.grid = ggplot2::element_blank(),
    axis.title = ggplot2::element_blank()
  )
  st_base <- ggplot2::ggplot(data = st_df, mapping = ggplot2::aes(x = long, y = lat, group = group)) + 
    ggplot2::coord_fixed(1.3) + 
    ggplot2::geom_polygon(color = "black", fill = "gray")
  
  elbow_room1 <- st_base + 
    ggplot2::geom_polygon(data = visualize_data, ggplot2::aes(fill = district), color = "white") +
    ggplot2::geom_polygon(color = "black", fill = NA) +
    ggplot2::theme_bw() +ditch_the_axes
  #
  output$plot1 <- renderPlot({elbow_room1})
}

oldWinLossOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    textOutput(ns('debug')),
    fluidRow(
      #column(4,dataTableOutput(ns('dataT'),height=height)),
      column(12, plotOutput(ns('plot1'),height=height))
    )
    
  )
}

renderOldWinLoss <- function(input, output, session, data, options = NULL, path = NULL, views = NULL, ...){ 
  #renderer 
  output$debug <- output$status<-renderText(names(data))
  
  st_df <- read.csv(paste(path,"/states.csv",sep=""))
  st_df <- subset(st_df, region == "arizona")
  st_county <- read.csv(paste(path,"/counties.csv",sep=""))
  st_county <- subset(st_county , region == "arizona")
  county_fips <- read.csv(paste(path,"/fips.csv",sep=""))
  
  #test_data <- tibble(nodes = c('04001','04009','04011','04017','04003','04019','04023','04005','04007','04015','04025','04013','04021','04012','04027'),
  #                                         value = c(1,1,1,-1,1,1,1,-1,1,1,-1,1,-1,1,1))
  
  test_data <- data
  fips_coverted = as.integer(test_data$nodes)
  test_data$fips_code = fips_coverted
  st_fips = county_fips[county_fips$fips %in% fips_coverted,]$fips
  st_subregion = strsplit(county_fips[county_fips$fips %in% fips_coverted,]$polyname, ',')
  sub_vector <- c()
  for(sub in st_subregion){
    sub_vector <- c(sub_vector,sub[2])
  }
  
  winLossCol = c()
  for(i in test_data$value){
    if(i==1){
      winLossCol = c(winLossCol,'Republicans Win')
    }
    else{
      winLossCol = c(winLossCol,'Democrats Win')
    }
  }
  test_data$winLoss <- winLossCol
  fip_subregion_map = tibble(fips_code=st_fips,subregion = sub_vector)
  data_ready <- inner_join(fip_subregion_map, test_data, by = "fips_code")
  visualize_data<-inner_join(st_county, data_ready, by = "subregion")
  
  ditch_the_axes <- ggplot2::theme(
    axis.text = ggplot2::element_blank(),
    axis.line = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank(),
    panel.border = ggplot2::element_blank(),
    panel.grid = ggplot2::element_blank(),
    axis.title = ggplot2::element_blank()
  )
  st_base <- ggplot2::ggplot(data = st_df, mapping = ggplot2::aes(x = long, y = lat, group = group)) + 
    ggplot2::coord_fixed(1.3) + 
    ggplot2::geom_polygon(color = "black", fill = "gray")
  
  elbow_room1 <- st_base + 
    ggplot2::geom_polygon(data = visualize_data, ggplot2::aes(fill = winLoss), color = "white") +
    ggplot2::geom_polygon(color = "black", fill = NA) +
    ggplot2::theme_bw() +ditch_the_axes
  #
  output$plot1 <- renderPlot({elbow_room1})
  
}