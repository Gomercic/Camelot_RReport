list(
  
  h1("Species list and counts"),
  DTOutput(outputId = "count_of_species"),
  downloadButton("download_count_of_species", "Download .csv"),
  downloadButton("download_count_of_species_xls", "Download .xls"),
  
  tags$hr(style="border-color: black;"),
  
  h1("Temporal discretization data"),
  DTOutput(outputId = "aggregation_events"),
  downloadButton("download_aggregation_events", "Download .csv"),
  downloadButton("download_aggregation_events_xls", "Download .xls"),
  
  tags$hr(style="border-color: black;"),
  
  h1("Temporal discretization data full"),
  DTOutput(outputId = "aggregation_events_full"),
  downloadButton("download_aggregation_events_full", "Download .csv"),
  downloadButton("download_aggregation_events_full_xls", "Download .xls")
  
)
  
