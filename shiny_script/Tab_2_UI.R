list(

  h1("Trap station location"),
  leafletOutput(outputId = "trap_list_GIS", height="100vh"),
  
  tags$hr(style="border-color: white_blue;"),
  tags$a(href="trap_station_list.gpkg", "Download GIS layer", download=NA, target="_blank"),
  
  tags$hr(style="border-color: black;"),
 
  h1("Trap station interval"),
  DTOutput(outputId = "trap_station_interval"),
  downloadButton("download_trap_station_interval", "Download .csv"),
  downloadButton("download_trap_station_interval_xls", "Download .xls"),
  
  tags$hr(style="border-color: black;"),
    
  h1("Trap station activity per month"),
  DTOutput(outputId = "trap_station_activity_per_month"),
  downloadButton("download_trap_station_activity_per_month", "Download .csv"),
  downloadButton("download_trap_station_activity_per_month_xls", "Download .xls"),
    
  tags$hr(style="border-color: black;"),
  
  h1("Trap station activity per month SUM"),
  DTOutput(outputId = "trap_station_activity_per_month_SUM"),
  downloadButton("download_trap_station_activity_per_month_SUM", "Download .csv"),
  downloadButton("download_trap_station_activity_per_month_xls_SUM", "Download .xls")
  
)
