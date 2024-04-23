list(

h1("Species activity per months"),
DTOutput(outputId = "species_activity_per_months"),
downloadButton("download_species_activity_per_months", "Download .csv"),
downloadButton("download_species_activity_per_months_xls", "Download .xls"),

tags$hr(style="border-color: black;"),

h1("species_activity_per_sum_months"),
DTOutput(outputId = "species_activity_per_sum_months"),
downloadButton("download_species_activity_per_sum_months", "Download .csv"),
downloadButton("download_species_activity_per_sum_months_xls", "Download .xls"),

tags$hr(style="border-color: black;"),

h1("species_activity_per_years"),
DTOutput(outputId = "species_activity_per_years"),
downloadButton("download_species_activity_per_years", "Download .csv"),
downloadButton("download_species_activity_per_years_xls", "Download .xls"),

tags$hr(style="border-color: black;"),

h1("Graph - per years"),
selectizeInput(inputId = "species_input", 
               label = NULL,
               # placeholder is enabled when 1st choice is an empty string
               choices = c("Please choose a species" = "", species), 
               multiple = TRUE),

selectizeInput(inputId = "value_input", 
               label = NULL,
               # placeholder is enabled when 1st choice is an empty string
               choices = c("Please choose a value" = "", c("sighting_per_30_days",
                                                           "animals_per_30_days",
                                                           "subadult_animals_per_30_days")),
               selected = "sighting_per_30_days",
               multiple = FALSE),

plotlyOutput(outputId = "p"),

tags$hr(style="border-color: black;"),


h1("Graph - per month"),
plotlyOutput(outputId = "p2"),

tags$hr(style="border-color: black;"),

h1("Graph - per month/year"),
plotlyOutput(outputId = "p3"),

tags$hr(style="border-color: black;"),

h1("Graph daily activity"),
plotlyOutput(outputId = "p4", height="60vh")

)
