###################
### STATIC PART ###

library(shiny)
library(leaflet)
library(data.table)
library(shinythemes)
library(shinyjs)
library(shinyalert)
library(DT)



######################
### USER INTERFACE ###

ui <- fluidPage(

    useShinyalert(),

    theme = shinytheme("cosmo"),

    titlePanel("FindingDemo Application for EMODNet Open Sea Lab"),
    br(),
    fluidRow(column(width = 7,
                    offset = 1,
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
                    offset = 1,
                    textOutput(outputId = "Introduction"),
                    br(),
                    br(),
                    br(),
                    textInput(inputId = "Name",
                              label = "Name"),
                    textInput(inputId = "Mail",
                              label = "Email address"),
                    dateInput(inputId = "Date",
                              label = "Date of sighting"),
                    actionButton(inputId = "Submit",
                                 label = "SUBMIT"))
             )
)

########################
### SERVER FUNCTIONS ###

server <- function(input, output) {

    # create a character vector of shiny inputs
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

    data_of_click <- reactiveValues(clicked=NULL)

    observeEvent(input$Map_click, {
        data_of_click$clicked <- input$Map_click
        leafletProxy('Map') %>%
            clearMarkers()%>%
            addMarkers(lng = input$Map_click$lng,
                       lat = input$Map_click$lat,
                       popup = paste("Longitude=",round(input$Map_click$lng,2),"and", "Lattitude=", round(input$Map_click$lat,2)))
    })

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
            confirmButtonCol = "#AEDEF4",
            imageUrl = "",
            animation = TRUE
        )
    })


    #######################
    #### VISUALIZATION ####
    #######################


    output$Clickonmap <- renderText({
        text <- "or click on the map below"
    })

    output$Map <- renderLeaflet({
        map <- leaflet(options = leafletOptions(maxZoom = 8))%>%
            addProviderTiles("Stamen.Watercolor")
    })


    output$Introduction <- renderText({
        text <- "During three days, in the vibrant and historical city of Ghent (Belgium),
        teams will compete and bring their expertise to develop novel marine and maritime applications using EMODnet,
        ICES and Copernicus Marine’s wealth of marine data and services.
        No previous experience is required! Experts in European marine data management and digital innovation will help build your team (if you don't already have one),
        lead workshops and coach you to bring your innovative ideas into working solutions."
        })

    res <- data.table(
        Species = 1:3,
        Probability = 1:3,
        Seen = shinyInput(checkboxInput,3,'Seen_', value = FALSE),
        Unseen = shinyInput(checkboxInput,3,'Unseen_', value = FALSE),
        NotChecked = shinyInput(checkboxInput, 3,'Unchecked_', value = FALSE),
        stringsAsFactors = FALSE)

    output$Invasive = renderTable({res},
        server = FALSE, escape = FALSE, selection = 'none', options = list(
            preDrawCallback = JS('function() { Shiny.unbindAll(this.api().table().node()); }'),
            drawCallback = JS('function() { Shiny.bindAll(this.api().table().node()); } '),
            sanitize.text.function = function(x) x)
    )

    output$Coordinates <- renderText({
        paste("Lattitude =", data_of_click$clicked$lat," ---------- ","Longitude =", data_of_click$clicked$lng)
    })
}

#######################
### RUN APPLICATION ###

shinyApp(ui = ui, server = server)
