a <- 6371.2             # reference radius of Earth

# following radii (A & B) are used for transforming between geodetic and geocentric coordinates
A <- 40680631.59 ^ 0.5  # semi-major axe of reference spheroid (equatorial radius of Earth, WGS84)
B <- 40408299.89 ^ 0.5  # semi-minor axe of reference spheroid (polar radius of Earth, WGS84)

shinyServer(
    function(input, output) {
        
        })