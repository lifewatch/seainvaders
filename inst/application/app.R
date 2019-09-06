###################
### STATIC PART ###

#Import libraries
library(shiny)
library(leaflet)
library(data.table)
library(leaflet.extras)
library(shinythemes)
library(shinyjs)
library(shinyalert)
library(DT)
library(findingdemo)

rasters <- load_rasters()


######################
### USER INTERFACE ###

ui <- fluidPage(

  #function for submit-popup
  useShinyalert(),

  #Theme of the application
  theme = shinytheme("cosmo"),


  #Tab 1 with information over the concept
  tabsetPanel(
    tabPanel("About",
             htmlOutput("Abouttext")),

    #Tab 2 with the content of the application
    tabPanel("Application",
             titlePanel("Sea Invaders! (made by the FindingDemo Team)"),
             br(),
             fluidRow(
                      column(width = 9,
                             offset = 0,
                             actionButton(inputId = "Locationinput",
                                          label = "Trace location",
                                          onClick = "shinyjs.geoloc()"),
                             h4(textOutput(outputId = "Clickonmap")),
                             textOutput(outputId = "Coordinates"),
                             br(),
                             br(),
                             leafletOutput(outputId ="Map"),
                             br(),
                             tableOutput(outputId = "Invasive")),

                      column(width = 3,
                             offset = 0,
                             htmlOutput(outputId = "Introduction"),
                             br(),
                             textInput(inputId = "Name",
                                       label = "Name"),
                             textInput(inputId = "Mail",
                                       label = "Email address"),
                             dateInput(inputId = "Date",
                                       label = "Date of sighting"),
                             actionButton(inputId = "Submit",
                                          label = "SUBMIT"))
             ))
  )
)

########################
### SERVER FUNCTIONS ###

server <- function(input, output) {


  # create a character vector of shiny inputs for checkboxes
  shinyInput = function(FUN, len, id, ...) {
    inputs = character(len)
    for (i in seq_len(len)) {
      inputs[i] = as.character(FUN(paste0(id, i), label = NULL, ...))
    }
    inputs
  }

  ####################
  #### REACTIVITY ####
  ####################

  #Reactive values for user location
  data_of_click <- reactiveValues(clicked=NULL)
  longitude_click <- reactiveValues(lng=NULL)
  lattitude_click <- reactiveValues(lat=NULL)

  #IF user clicks on map, new coordinates are saved and map is adjusted
  observeEvent(input$Map_click, {
    data_of_click$clicked <- input$Map_click
    longitude_click <- input$Map_click$lng
    lattitude_click <- input$Map_click$lat
    leafletProxy('Map') %>%
      clearMarkers()%>%
      addMarkers(lng = input$Map_click$lng,
                 lat = input$Map_click$lat,
                 popup = paste("Longitude=",round(input$Map_click$lng,2),"and", "Lattitude=", round(input$Map_click$lat,2)))
  })


  #If user clicks track location its gps location is saved and the map is adjusted
  observeEvent(input$Locationinput, {
    leafletProxy('Map') %>%
      clearMarkers() %>%
      addControlGPS(options = gpsOptions(position = "topleft", activate = TRUE, autoCenter = TRUE, maxZoom = 60, setView = TRUE))
    data_of_click$clicked <- input$Map_gps_located
  })

  #If user submits, a popup is generated
  observeEvent(input$Submit, {
    shinyalert(
      title = "Thanks",
      text = paste("Sightings saved for", input$Name,"(", input$Mail, ")", "on", input$Date, "at", round(data_of_click$clicked$lng,2),"Longitude","and",round(data_of_click$clicked$lat,2),"Lattitude"),
      closeOnEsc = TRUE,
      closeOnClickOutside = TRUE,
      html = FALSE,
      type = "success",
      showConfirmButton = TRUE,
      showCancelButton = FALSE,
      confirmButtonText = "Done",
      confirmButtonCol = "#E0AB8B",
      imageUrl = "",
      animation = TRUE
    )
  })


  #######################
  #### VISUALIZATION ####
  #######################


  #Information underneath location button
  output$Clickonmap <- renderText({
    text <- "or click on the map below"
  })

  #Generation of base map
  output$Map <- renderLeaflet({
    map <- leaflet(options = leafletOptions(minZoom = 3))%>%
      addProviderTiles("OpenStreetMap.Mapnik")
    map <- map %>% setView(9, 50, zoom = 4)
  })


  #Explanatory text in application tab
  output$Introduction <- renderUI({
  HTML("<p align='justify'>Hi diver!
    <br>
    <br>
    Please provide us your location by clicking 'Trace location' or by pinpointing your location on the map.
    We will show you a list of harmful invasive species that have not yet been found on your location,
    but could potentially show up uninvited in the near future. Keep an eye out for these species while diving here!
    If you see any of the species in this list, check the box and submit to let us know.
    It is crucial for the health of our ecosystems that we trace these invaders as early as possible.
    <br>
    <br>
    Thank you for protecting our seas!
    </p>
    "
  )
  })


  output$Invasive <- renderTable({
                                    if (!is.null(data_of_click$clicked)) {
                                      res <- make_ranking(rasters, data_of_click$clicked$lng, data_of_click$clicked$lat)
                                      dtable <- data.table(res)
                                      dtable[,Seen := shinyInput(checkboxInput,nrow(dtable),'Seen_', value = FALSE, width="10")]
                                      dtable[,"Not seen" := shinyInput(checkboxInput,nrow(dtable),'Unseen_', value = FALSE, width="10")]
                                      dtable[,"Not checked" := shinyInput(checkboxInput, nrow(dtable), "Unchecked_", value = FALSE, width="10")]
                                      dtable <- subset(dtable, select= c(1:2,4:9,3))
                                      dtable <- dtable[1:5,]

                                    }
                                  },
                                server = FALSE,
                                escape = FALSE,
                                selection = 'none',
                                options = list(preDrawCallback = JS('function() { Shiny.unbindAll(this.api().table().node()); }'),
                                               drawCallback = JS('function() { Shiny.bindAll(this.api().table().node()); } ')),
                                sanitize.text.function = function(x) x)

  #Display coordinates in app
  output$Coordinates <- renderText({
    paste("Lattitude =", data_of_click$clicked$lat," ---------- ","Longitude =", data_of_click$clicked$lng)
  })

  #Text on the about page
  output$Abouttext <- renderUI({
    HTML("<h1><strong>Sea Invaders!</strong></h1>

    <p><img src='https://github.com/iobis/findingdemo/blob/master/images/SeaInvaders_small.png?raw=true' style=''></p>

    <h2>Concept</h2>
    <p align='justify'>
    <i>Sea Invaders!</i> provides recreational divers with a 'most wanted' list of invasive species!
    Based on their location, the service compiles a list of known troublemakers
    that are most likely to start invading their favourite diving spot.
    The risk of invasion by given species is based on local habitat suitability and distance to the nearest occurrence.
    This citizen science tool lets the diving community know what species they need to look out for
    and acts as a network of early detection for invasive species across Europe.
    </p>

    <h2>Pipeline</h2>
    <img src='https://github.com/iobis/findingdemo/blob/master/images/scheme.png?raw=true' style='width:700px;height:700px;'>
    <br/>
    <br/>
    <br/>
    <img src='https://github.com/iobis/findingdemo/blob/master/images/cercopagis_pengoi.png?raw=true' style='width:800px; height:500px;'>
    <img src='https://github.com/iobis/findingdemo/blob/master/images/distance.png?raw= true' style='width:800px; height:500px;'>

    <h2>Repository</h2>
    <a href='https://github.com/iobis/findingdemo'>github.com/iobis/findingdemo</a>
    <br>
    <br>
    "
         )
  })
  }

#######################
### RUN APPLICATION ###

shinyApp(ui = ui, server = server)
