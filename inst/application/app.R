###################
### STATIC PART ###

library(shiny)
library(leaflet)
library(data.table)
library(shinythemes)

user_long <- 4
user_lat <- 51

######################
### USER INTERFACE ###

ui <- fluidPage(theme = shinytheme("cosmo"),
    titlePanel("FindingDemo Application for EMODNet Open Sea Lab"),
    br(),
    fluidRow(column(width = 7,
                    offset = 1,
                    actionButton(inputId = "Locationinput",
                                 label = "Trace location"),
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

    ####################
    #### REACTIVITY ####
    ####################

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

    observeEvent(input$Map_click, {
        click = input$Map_click
        user_long <- click$lng
        user_lat <- click$lat
        leafletProxy('Map') %>%
            clearMarkers()%>%
            addMarkers(lng = user_long, lat = user_lat)

    })


    output$Introduction <- renderText({
        text <- "During three days, in the vibrant and historical city of Ghent (Belgium),
        teams will compete and bring their expertise to develop novel marine and maritime applications using EMODnet,
        ICES and Copernicus Marine’s wealth of marine data and services.
        No previous experience is required! Experts in European marine data management and digital innovation will help build your team (if you don't already have one),
        lead workshops and coach you to bring your innovative ideas into working solutions."
        })

    output$Invasive <- renderTable({
        DT <- data.table(x = 1:3, y = 1:3)
    })

    output$Coordinates <- renderText({
        paste("Longitude","=", user_long, "Lattitude", "=", user_lat)
    })

}

#######################
### RUN APPLICATION ###

shinyApp(ui = ui, server = server)
