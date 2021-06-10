#redistricted map layout
GerryOutput <- function(id, height = NULL, options = NULL, path = NULL){
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
  #colnames(data)[2] <- 'district'
  i = 1
  for (entry in sort(unique(data$district))){
    data[data$district == entry,]$district = paste("d",as.character(i),sep="")
    i = i + 1
  }
  #df_assign <- cbind(c(data$nodes),c(data[,2]))
  df_assign <- cbind(c(data$nodes),c(data$district))
  

  output$dataT<-DT::renderDataTable(datatable(df_assign,colnames=c('County','District Assigned')))

#-----------------------------------ggplot ---------------------------------  
  #test_data <- tibble(nodes = c('04001','04009','04011','04017','04003','04019','04023','04005','04007','04015','04025','04013','04021','04012','04027'),
  #                    district = c('d1','d2','d1','d1','d1','d1','d1','d2','d2','d1','d1','d1','d2','d3','d3'))
  test_data <- data

  #st_df <- ggplot2::map_data('state','arizona')
  ## get the state name we want 
  st_mapping <- read.csv(paste(path,"/st_mapping.csv",sep=""))

  state_code <- as.integer(substr(test_data[1,1],start = 1,stop = 2))
  state_chosen <- st_mapping[st_mapping$fips == state_code,]$state
  state_chosen <- as.character(state_chosen)
  if(length(state_chosen) > 1){
    state_chosen <- state_chosen[1]
  }
  state_chosen <- strsplit(state_chosen,':')[[1]][1]
  
  ## get the state name we want  get the state, counties and fips data we want
  st_df <- read.csv(paste(path,"/states.csv",sep=""))
  st_df <- subset(st_df, region == state_chosen)
  st_county <- read.csv(paste(path,"/counties.csv",sep=""))
  st_county <- subset(st_county , region == state_chosen)
  county_fips <- read.csv(paste(path,"/fips.csv",sep=""))
  
  
  fips_coverted = as.integer(test_data$nodes)
  test_data$fips_code = fips_coverted
  st_fips = county_fips[county_fips$fips %in% fips_coverted,]$fips
  st_subregion = strsplit(county_fips[county_fips$fips %in% fips_coverted,]$polyname, ',')
  sub_vector <- c()
  for(sub in st_subregion){
    second_split <- sub[2]
    #deal with colon
    third_split <- strsplit(second_split,':')[[1]][1]  
    sub_vector <- c(sub_vector,third_split)
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

#redistricted map layout2

gerryPlusWordOutput <- function(id, height = NULL, options = NULL, path = NULL){
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

#redistricted map logic2
renderGerryPlusWord <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  #output$status<-renderText(names(data))
  #output$status<-renderText(path)
  i = 1
  for (entry in sort(unique(data$district))){
    data[data$district == entry,]$district = paste("d",as.character(i),sep="")
    i = i + 1
  }
  df_assign <- cbind(c(data$nodes),c(data$district))
  output$dataT<-DT::renderDataTable(datatable(df_assign,colnames=c('County','District Assigned')))

#-----------------------------------ggplot ---------------------------------  
  #test_data <- tibble(nodes = c('04001','04009','04011','04017','04003','04019','04023','04005','04007','04015','04025','04013','04021','04012','04027'),
  #                    district = c('d1','d2','d1','d1','d1','d1','d1','d2','d2','d1','d1','d1','d2','d3','d3'))
  test_data <- data

  #st_df <- ggplot2::map_data('state','arizona')
  st_mapping <- read.csv(paste(path,"/st_mapping.csv",sep=""))

  state_code <- as.integer(substr(test_data[1,1],start = 1,stop = 2))
  state_chosen <- st_mapping[st_mapping$fips == state_code,]$state
  state_chosen <- as.character(state_chosen)
  if(length(state_chosen) > 1){
    state_chosen <- state_chosen[1]
  }
  state_chosen <- strsplit(state_chosen,':')[[1]][1]

  st_df <- read.csv(paste(path,"/states.csv",sep=""))
  st_df <- subset(st_df, region == state_chosen)
  st_county <- read.csv(paste(path,"/counties.csv",sep=""))
  st_county <- subset(st_county , region == state_chosen)
  county_fips <- read.csv(paste(path,"/fips.csv",sep=""))

  fips_coverted = as.integer(test_data$nodes)
  test_data$fips_code = fips_coverted
  st_fips = county_fips[county_fips$fips %in% fips_coverted,]$fips
  st_subregion = strsplit(county_fips[county_fips$fips %in% fips_coverted,]$polyname, ',')
  sub_vector <- c()
  for(sub in st_subregion){
    second_split <- sub[2]
    #deal with colon
    third_split <- strsplit(second_split,':')[[1]][1]  
    sub_vector <- c(sub_vector,third_split)
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

 #start : create text for each county
  cnames <- aggregate(cbind(long, lat) ~ nodes, data=visualize_data, 
                    FUN=function(x)mean(range(x)))
  append_vec <- c()
  for( nodeName in cnames$nodes){
    if(test_data[test_data$nodes==nodeName,"rord"][[1]] == 1){
      append_vec <- c(append_vec,'R')
    }
    else{
      append_vec <- c(append_vec,'D')
    }
  }
  cnames$RD <- append_vec
 
 #end : create text for each county
  
  elbow_room1 <- st_base + 
    ggplot2::geom_polygon(data = visualize_data, ggplot2::aes(fill = district), color = "white") +
    ggplot2::geom_polygon(color = "black", fill = NA) +
    ggplot2::geom_text(data=cnames, ggplot2::aes(long, lat, label = RD), size=6,inherit.aes = FALSE)
    ggplot2::theme_bw() +ditch_the_axes

  #
  output$plot1 <- renderPlot({elbow_room1})
}

#########################################################################

gerryPlusFipsOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    textOutput(ns('status')),
    fluidRow(
      #column(4,dataTableOutput(ns('dataT'),height=height)),
      column(12, plotOutput(ns('plot1'),height=height))
    )
    
  )
}

#redistricted map logic2
renderGerryPlusFips <- function(input, output, session, data, options = NULL, path = NULL, ...){ 
  #renderer 
  #output$status<-renderText(names(data))
  #output$status<-renderText(path)
  #df_assign <- cbind(c(data$nodes),c(data$district))
  #output$dataT<-DT::renderDataTable(datatable(df_assign,colnames=c('County','District Assigned')))

#-----------------------------------ggplot ---------------------------------  
  #test_data <- tibble(nodes = c('04001','04009','04011','04017','04003','04019','04023','04005','04007','04015','04025','04013','04021','04012','04027'),
  #                    district = c('d1','d2','d1','d1','d1','d1','d1','d2','d2','d1','d1','d1','d2','d3','d3'))
  i = 1
  for (entry in sort(unique(data$district))){
    data[data$district == entry,]$district = paste("d",as.character(i),sep="")
    i = i + 1
  }
  test_data <- data

  #st_df <- ggplot2::map_data('state','arizona')
  st_mapping <- read.csv(paste(path,"/st_mapping.csv",sep=""))

  state_code <- as.integer(substr(test_data[1,1],start = 1,stop = 2))
  state_chosen <- st_mapping[st_mapping$fips == state_code,]$state
  state_chosen <- as.character(state_chosen)
  if(length(state_chosen) > 1){
    state_chosen <- state_chosen[1]
  }
  state_chosen <- strsplit(state_chosen,':')[[1]][1]

  st_df <- read.csv(paste(path,"/states.csv",sep=""))
  st_df <- subset(st_df, region == state_chosen)
  st_county <- read.csv(paste(path,"/counties.csv",sep=""))
  st_county <- subset(st_county , region == state_chosen)
  county_fips <- read.csv(paste(path,"/fips.csv",sep=""))
  
  fips_coverted = as.integer(test_data$nodes)
  test_data$fips_code = fips_coverted
  st_fips = county_fips[county_fips$fips %in% fips_coverted,]$fips
  st_subregion = strsplit(county_fips[county_fips$fips %in% fips_coverted,]$polyname, ',')
  sub_vector <- c()
  for(sub in st_subregion){
    second_split <- sub[2]
    #deal with colon
    third_split <- strsplit(second_split,':')[[1]][1]  
    sub_vector <- c(sub_vector,third_split)
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

 #start : create text for each county
  cnames <- aggregate(cbind(long, lat) ~ nodes, data=visualize_data, 
                    FUN=function(x)mean(range(x)))
  append_vec <- c()
  for( nodeName in cnames$nodes){
    if(test_data[test_data$nodes==nodeName,"rord"][[1]] == 1){
      append_vec <- c(append_vec,'R')
    }
    else{
      append_vec <- c(append_vec,'D')
    }
  }
  cnames$RD <- append_vec
 
 #end : create text for each county
  
  elbow_room1 <- st_base + 
    ggplot2::geom_polygon(data = visualize_data, ggplot2::aes(fill = district), color = "white") +
    ggplot2::geom_polygon(color = "black", fill = NA) +
    ggplot2::geom_text(data=cnames, ggplot2::aes(long, lat, label = nodes), size=6,inherit.aes = FALSE)
    ggplot2::theme_bw() +ditch_the_axes

  #
  output$plot1 <- renderPlot({elbow_room1})
}

## population bar chart

avgPopOutput <- function(id, height = NULL, options = NULL, path = NULL){
  ns <- NS(id)
  
  # set default height
  if(is.null(height)){
    height <- 700
  } 
  tagList( 
    #define rendererOutput function here 
    textOutput(ns('status')),
    fluidRow(
      column(12, plotly::plotlyOutput(ns('plot1'),height=height))
    )
    
  )
}
                            
renderAvgPop <- function(input, output, session, data, options = NULL, path = NULL, views = NULL, ...){ 
    i = 1
    for (entry in sort(unique(data$district))){
     data[data$district == entry,]$district = paste("d",as.character(i),sep="")
     i = i + 1
    }
    test_data <- data
    #test_data <- data.frame(value = c(10,20,30,25),
    #                  district = c('d12','d1','d3','d4'))
    #output$status<-renderText(names(test_data))

    # reordering the rows by district
    test_data$sort_col = as.numeric(substring(test_data$district,2,4))
    test_data <- arrange(test_data,sort_col)

    fig <- plotly::plot_ly(
    x = test_data$district,
    y = test_data$value,
    name = "Population Distribution",
    type = "bar",
    text = test_data$value,
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
                     color = 'Black'),shapes = hline(sum(test_data$value)/length(test_data$value)))

    output$plot1 <- plotly::renderPlotly(fig)

}