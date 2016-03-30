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
        p('This tool calculates the IGRF (International Geomagnetic Reference Field).  The IGRF model is put forth every five years by the IAGA (International Association of Geomagnetism and Aeronomy and is a description of the main geomagnetic field and its secular variation in terms of spherical harmonic models.  The tool calculates dec-declination, inc-inclination, Bh-horizontal component, Bx-north/south component, By-east/west component, Bz-vertical component, and TF-total field intensity.  dec and inc are reported in degrees, the remaining fields are presented in units nanotesla.  For further details click the link below.'),
        a(href="http://www.ngdc.noaa.gov/IAGA/vmod/igrf.html", "IGRF Description by NOAA"),
        plotOutput('map', click="map_click"),
        tableOutput('igrf')
        )
    ))