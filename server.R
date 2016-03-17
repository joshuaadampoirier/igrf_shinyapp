library(ggplot2)
source('helper.R')

shinyServer(
    function(input, output, session) {
        output$map <- renderPlot({
            # get user input
            lat <- input$Latitude
            lon <- input$Longitude
                        
            # plot map of world with user-selected lat/long
            map <- borders("world", colour="#5762AC", fill="#51BE69", alpha=0.6)
            ggplot() + map + scale_x_continuous(limits=c(-180,180), expand=c(0,0)) + 
                scale_y_continuous(limits=c(-90,90), expand=c(0,0)) +
                geom_vline(xintercept=lon, colour="#D71400") + 
                geom_hline(yintercept=lat, colour="#D71400") +
                xlab("Longitude") + ylab("Latitude") + labs(title="IGRF Location") +
                theme(legend.position="none")
            
        }, height=360, width=720)
        
        #output$selectedDate <- renderPrint(input$IGRFDate)
        
        output$igrf <- renderTable({
            round(main(input$Elevation, input$Latitude, input$Longitude, input$IGRFDate), 2)
        })
        
        observe({
            # get user-selected lat/lon via clicking the map
            lat <- input$map_click$y
            lon <- input$map_click$x
            
            # update the latitude slider with map click value
            updateSliderInput(session, "Latitude",
                              value = lat)    
            
            # update the longitude slider with map click value
            updateSliderInput(session, "Longitude",
                              value = lon)
        })       
    }
)