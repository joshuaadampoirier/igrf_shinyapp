shinyUI(pageWithSidebar(
    # Application title
    headerPanel("IGRF Calculator"),
    
    # User inputs
    sidebarPanel(
        
        # latitude input
        sliderInput('Latitude', 'Input Latitude', value=45,
                    min=-90, max=90, step=0.05),
        
        # longitude input
        sliderInput('Longitude', 'Input Longitude', value=45,
                    min=-180, max=180, step=0.05),
        
        # date input
        dateInput('IGRFDate', 'Select Date', Sys.Date(), min='1900-01-01', max='2019-12-31', width='100%'),
        
        # elevation input
        sliderInput('Elevation', 'Input Elevation (km above sea level)', value=0,
                    min=-10, max=31856, step=0.1)
        ),
    
    # Map and outputs
    mainPanel(
        plotOutput('map', click="map_click"),
        verbatimTextOutput("selectedDate"),
        verbatimTextOutput("latlon")
        )
    ))