library(shiny)
library(DT)
library(tidyverse)
library(writexl)
library(sf)
library(leaflet)
library(plotly)

options(shiny.maxRequestSize = 30 * 1024^2)

# TAB 1, TAB 2, TAB 3 ******
full_export <- read.csv("full_export.csv")
trap_station_interval <- read.csv("trap_station_interval.csv")
trap_station_activity_per_month <- read.csv("trap_station_activity_per_month.csv")
trap_list_GIS <- st_read("trap_station_list.gpkg")
aggregation_events <- read.csv("aggregation_events.csv")
aggregation_events_full <- read.csv("aggregation_events_full.csv")
count_of_species <- read.csv("count_of_species.csv")

trap_station_activity_per_month_SUM <- trap_station_activity_per_month %>% 
  select(-c(X, GPS_Lat, GPS_Lon)) %>% 
  summarise(Count_Trap_Station = n(),
    across(where(is.numeric), sum))

# TAB 4 ######
species_activity_per_months <- read.csv("species_activity_per_months.csv")
species_activity_per_sum_months <- read.csv("species_activity_per_sum_months.csv")
species_activity_per_years <- read.csv("species_activity_per_years.csv")

species_activity_per_months <- species_activity_per_months %>% 
  mutate(month_year2 = parse_date_time(month_year, "%Y-%m")) %>% 
  rename(sighting_per_30_days = sighting_per_month,
         animals_per_30_days = animals_per_month,
         subadult_animals_per_30_days = subadult_animals_per_month)

species <- unique(species_activity_per_months$Species)


# ui object
ui <- fluidPage(
     mainPanel(h1("Reports and sheets from Camelot full export"),
               tabsetPanel(type = "tabs",
                           tabPanel("Original data", h1("Full_export"),
                                    DTOutput(outputId = "full_export"),
                                    downloadButton("download_full_export", "Download .csv"),
                                    downloadButton("download_full_export_xls", "Download .xls")),
                           tabPanel("Trap Stations", source(file = "Tab_2_UI.R", local = T)[1]),
                           tabPanel("Events/Species", source(file = "Tab_3_UI.R", local = T)[1]),
                           tabPanel("Abundance change / Activity", source(file = "Tab_4_UI.R", local = T)[1])
               )
))


# server()
server <- function(input, output) {
 
  
# TAB 1 *****************************************************
  # ******** full export tablica
  output$full_export <- renderDT(full_export)
  
  output$download_full_export <- downloadHandler(
    filename = "full_export.csv",
    content = function(file) {write.csv(full_export, file)})
  
  output$download_full_export_xls <- downloadHandler(
    filename = "full_export.xls",
    content = function(file) {write_xlsx(full_export, file)})
  
 
# TAB 2 ****************************************************  
  # ************* map trap stations
  output$trap_list_GIS <- renderLeaflet({
    leaflet(trap_list_GIS) %>%  addTiles() %>% setView(mean(trap_list_GIS$Camelot_GPS_Longitude), mean(trap_list_GIS$Camelot_GPS_Latitude), zoom = 8) %>% 
      addMarkers(label = trap_list_GIS$Trap_Station_Name)})

    # ******** trap station interval tablica
  output$trap_station_interval <- renderDT(trap_station_interval)
  
  output$download_trap_station_interval <- downloadHandler(
    filename = "trap_station_interval.csv",
    content = function(file) {write.csv(trap_station_interval, file)})
  
  output$download_trap_station_interval_xls <- downloadHandler(
    filename = "trap_station_interval.xls",
    content = function(file) {write_xlsx(trap_station_interval, file)})
  
  
  # ************* tablica Trap Station Activity per month
  output$trap_station_activity_per_month <- renderDT(trap_station_activity_per_month)
  
  output$download_trap_station_activity_per_month <- downloadHandler(
    filename = "trap_station_activity_per_month.csv",
    content = function(file) {write.csv(trap_station_activity_per_month, file)})
  
  output$download_trap_station_activity_per_month_xls <- downloadHandler(
    filename = "trap_station_activity_per_month.xls",
    content = function(file) {write_xlsx(trap_station_activity_per_month, file)})


  # ************* tablica Trap Station Activity per month SUM
  output$trap_station_activity_per_month_SUM <- renderDT(trap_station_activity_per_month_SUM)
  
  output$download_trap_station_activity_per_month_SUM <- downloadHandler(
    filename = "trap_station_activity_per_month_SUM.csv",
    content = function(file) {write.csv(trap_station_activity_per_month_SUM, file)})
  
  output$download_trap_station_activity_per_month_SUM_xls <- downloadHandler(
    filename = "trap_station_activity_per_month_SUM.xls",
    content = function(file) {write_xlsx(trap_station_activity_per_month_SUM, file)})
  
 
# ******************TAB 3 *********************************   
  # ******** list of species and counts
  output$count_of_species <- renderDT(count_of_species)
  
  output$download_count_of_species <- downloadHandler(
    filename = "count_of_species.csv",
    content = function(file) {write.csv(count_of_species, file)})
  
  output$download_count_of_species_xls <- downloadHandler(
    filename = "trap_station_activity_per_month.xls",
    content = function(file) {write_xlsx(count_of_species, file)})
  
  
  # ******** Aggregation events
  output$aggregation_events <- renderDT(aggregation_events)
  
  output$download_aggregation_events <- downloadHandler(
    filename = "aggregation_events.csv",
    content = function(file) {write.csv(aggregation_events, file)})
  
  output$download_aggregation_events_xls <- downloadHandler(
    filename = "aggregation_events.xls",
    content = function(file) {write_xlsx(aggregation_events, file)})


  # ******** Aggregation events_full
  output$aggregation_events_full <- renderDT(aggregation_events_full)
  
  output$download_aggregation_events_full <- downloadHandler(
    filename = "aggregation_events_full.csv",
    content = function(file) {write.csv(aggregation_events_full, file)})
  
  output$download_aggregation_events_full_xls <- downloadHandler(
    filename = "aggregation_events_full.xls",
    content = function(file) {write_xlsx(aggregation_events_full, file)})
  
  
  
  
# ***********************    TAB 4 *****************************
  # ******** species_activity_per_months
  output$species_activity_per_months <- renderDT(species_activity_per_months)
  
  output$download_species_activity_per_months <- downloadHandler(
    filename = "species_activity_per_months.csv",
    content = function(file) {write.csv(species_activity_per_months, file)})
  
  output$download_species_activity_per_months_xls <- downloadHandler(
    filename = "species_activity_per_months.xls",
    content = function(file) {write_xlsx(species_activity_per_months, file)})
  
  
  # ******** species_activity_per_sum_months
  output$species_activity_per_sum_months <- renderDT(species_activity_per_sum_months)
  
  output$download_species_activity_per_sum_months <- downloadHandler(
    filename = "species_activity_per_sum_months.csv",
    content = function(file) {write.csv(species_activity_per_sum_months, file)})
  
  output$download_species_activity_per_sum_months_xls <- downloadHandler(
    filename = "species_activity_per_sum_months.xls",
    content = function(file) {write_xlsx(species_activity_per_sum_months, file)})
  
  # ******** species_activity_per_years
  output$species_activity_per_years <- renderDT(species_activity_per_years)
  
  output$download_species_activity_per_years <- downloadHandler(
    filename = "species_activity_per_years.csv",
    content = function(file) {write.csv(species_activity_per_years, file)})
  
  output$download_species_activity_per_years_xls <- downloadHandler(
    filename = "species_activity_per_years.xls",
    content = function(file) {write_xlsx(species_activity_per_years, file)})
  
  # graph species per years
  output$p <- renderPlotly({
    req(input$species_input)
    if (identical(input$species_input, "")) return(NULL)
    
    p <- ggplot(data = filter(species_activity_per_years, Species %in% input$species_input), aes_string(x='year', y= input$value_input))+
      geom_line(aes(colour = factor(Species)), size = 1)+
      geom_point()
    ggplotly(p)})
  
  # graph species per month
  output$p2 <- renderPlotly({
    req(input$species_input)
    if (identical(input$species_input, "")) return(NULL)
    
    p2 <- ggplot(data = filter(species_activity_per_sum_months, Species %in% input$species_input), aes_string(x='month', y= input$value_input))+
      geom_line(aes(colour = factor(Species)), size = 0.5)+
      geom_point()+
      scale_x_continuous(breaks = seq(1, 12, by = 1))
    ggplotly(p2)})
  
  # graph species per month_year
  output$p3 <- renderPlotly({
    req(input$species_input)
    if (identical(input$species_input, "")) return(NULL)
    
    p3 <- ggplot(data = filter(species_activity_per_months, Species %in% input$species_input), aes_string(x='month_year2', y= input$value_input))+
      geom_line(aes(colour = factor(Species)), size = 0.5)+
      geom_point()
    ggplotly(p3)})

  # graph daily activity
  output$p4 <- renderPlotly({
    req(input$species_input)
    if (identical(input$species_input, "")) return(NULL)
    
    p4 <- ggplot(data = filter(aggregation_events, Species %in% input$species_input), aes(x=part_of_day3, colour=Species, fill=Species))+
      geom_density(colour = 'black', bounds = c(0, 1), alpha=0.4)
    ggplotly(p4)})
  
  
  
}


# shinyApp()
shinyApp(ui = ui, server = server)