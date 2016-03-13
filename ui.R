shinyUI(pageWithSidebar(
    headerPanel("Example plot"),
    sidebarPanel(
        sliderInput('Latitude', 'Input Latitude', value=45,
                    min=-90, max=90, step=0.05),
        sliderInput('Longitude', 'Input Longitude', value=45,
                    min=-180, max=180, step=0.05)
        ),
    mainPanel(
        h3('Hello world')
        )
    ))