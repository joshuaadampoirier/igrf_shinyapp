a <- 6371.2             # reference radius of Earth

# following radii (A & B) are used for transforming between geodetic and geocentric coordinates
A <- 40680631.59 ^ 0.5  # semi-major axe of reference spheroid (equatorial radius of Earth, WGS84)
B <- 40408299.89 ^ 0.5  # semi-minor axe of reference spheroid (polar radius of Earth, WGS84)

# main function returning magnetic field components given:
#   h - height above sea level in km
#   lat - geodetic latitude
#   lon - geodetic longitude
#   date - date for which to calculate magnetic field components
# returns data frame containing:
#   dec - declination in degrees
#   inc - inclination in degrees
#   Bh - horizontal component of magnetic field in nanoteslas
#   Bx - north/south component of magnetic field in nanoteslas
#   By - east/west component of magnetic field in nanoteslas
#   Bz - vertical component of magnetic field in nanoteslas
#   TF - total field intensity in nanoteslas
main <- function(h, lat, lon, date) {    
    
    # convert lat/lon from degrees to radians
    lambda <- lon * pi / 180
    phi <- lat * pi / 180
    
    # convert geographic coords to spherical coords
    # flattening
    f <- (h * (A^2 - (A^2 - B^2) * (sin(lat))^2)^0.5 + A^2)^2 /
        (h * (A^2 - (A^2 - B^2) * (sin(lat))^2)^0.5 + B^2)^2
    
    # geocentric latitude
    theta <- acos(sin(phi) /
                      (f * (cos(phi))^2 + (sin(phi))^2)^0.5)
    
    # geocentric radius
    r <- ((h^2 + 2 * h * (A^2 - (A^2 - B^2) * (sin(phi))^2)^0.5 + 
               (A^4 - (A^4 - B^4) * (sin(phi))^2)) /
              (A^2 - (A^2 - B^2) * (sin(phi))^2))^0.5
    
    delta <- phi + theta - pi / 2
    
    # avoid singularities at the poles
    if (theta > -0.00000001 & theta < 0.00000001) theta <- 0.00000001
    if (theta < pi & theta > (pi - 0.00000001)) theta <- pi - 0.00000001
    
    # compute Schmidt Quasi-Normalized Gaussian coefficients and normalize model coefficients
    year <- as.numeric(format(date, "%Y"))
    tidyData <- normalizeCoeff(year)
    
    # date of preceding DGRF/IGRF model
    d1 <- as.Date(paste0("01/01/", 5 * floor(year / 5)), "%m/%d/%Y")
    
    # calculate g and h values at specified time (extrapolate if 2015 or later, interpolate otherwise)
    ifelse(year >= 2015, tidyData <- extrapCoeff(tidyData, date, d1), tidyData <- interpCoeff(tidyData, date, d1))
    
    # compute the Gaussian normalized associated Legendre polynomials & derivatives of associated Legendre polynomials
    tidyData$P <- apply(tidyData[,c('n','m')], 1, function(x) Pnm(x['n'], x['m'], theta))
    tidyData$dP <- apply(tidyData[,c('n','m')], 1, function(x) dPnm(x['n'], x['m'], theta))
    
    # calculate components of DGRF/IGRF
    igrf(tidyData, r, theta, lambda, delta)
}

# linearly interpolate model coefficients to user-selected date
interpCoeff <- function(data, date, d1) {
    d2 <- as.Date(paste0("12/31/", 4 + 5 * floor(as.numeric(format(date, "%Y")) / 5)), "%m/%d/%Y")
    t <- as.numeric(date - d1) / as.numeric(d2 - d1)
    
    data$gt <- data$g_ini + t * (data$g_fin - data$g_ini)
    data$ht <- data$h_ini + t * (data$h_fin - data$h_ini)
    data
}

# linearly extrapolate model coefficients to user-selected date
extrapCoeff <- function(data, date, d1) {
    t <- as.numeric(date - d1) / 
        as.numeric((as.Date("01/01/2016", "%m/%d/%Y") - d1))
    
    data$gt <- data$g_ini + t * data$gSV
    data$ht <- data$h_ini + t * data$hSV 
    print(head(data))
    data
}

# calculate the derivatives of the scalar potential function
igrf <- function(data, r, theta, lambda, delta) {
    
    # radial component
    data$Br <- (data$gt * cos(data$m * lambda) + data$ht * sin(data$m * lambda)) * data$P
    Br <- data.frame(matrix(unlist(aggregate(data$Br, by=list(n=data$n), FUN=sum)), ncol=2, byrow=F))
    Br$BrC <- ((a / r)^(Br[,1] + 2)) * (Br[,1] + 1) * Br[,2]
    Br <- sum(Br$BrC)
    
    # theta component
    data$Bt <- (data$gt * cos(data$m * lambda) + data$ht * sin(data$m * lambda)) * data$dP
    Bt <- data.frame(matrix(unlist(aggregate(data$Bt, by=list(n=data$n), FUN=sum)), ncol=2, byrow=F))
    Bt$BtC <- ((a / r)^(Bt[,1] + 2)) * Bt[,2]
    Bt <- -1 * sum(Bt$BtC)
    
    # lambda component
    data$Bl <- data$m * (-1 * data$gt * sin(data$m * lambda) + data$ht * cos(data$m * lambda)) * data$P
    Bl <- data.frame(matrix(unlist(aggregate(data$Bl, by=list(n=data$n), FUN=sum)), ncol=2, byrow=F))
    Bl$BlC <- ((a / r)^(Bl[,1] + 2)) * Bl[,2]
    Bl <- (-1/sin(theta))*sum(Bl$BlC)
    
    # convert to local tangential coordinates
    Bxc <- -Bt   # north-south
    Byc <- Bl    # east-west
    Bzc <- -Br   # vertical
    
    # convert to local cartesian coordinates
    Bx <- Bxc * cos(delta) + Bzc * sin(delta)
    By <- Byc
    Bz <- -1 * Bxc * sin(delta) + Bzc * cos(delta)
    
    # return data frame containing dec, inc, Bh, Bx, By, Bz, and TF
    data.frame(dec=atan(By/Bx)*180/pi,
               inc=atan(Bz/(Bx^2+By^2)^0.5)*180/pi,
               Bh=(Bx^2+By^2)^0.5,
               Bx=Bx,
               By=By,
               Bz=Bz,
               TF=(Bx^2+By^2+Bz^2)^0.5)
}

# normalize model coefficients
normalizeCoeff <- function(year=2015) {
    library(dplyr)
    
    # download and load data
    data <- loadData()
    
    # reshape and filter data
    tidyData <- cleanData(data, year)
    
    # compute Schmidt quasi-normalization factors
    tidyData$Snm <- apply(tidyData[,c('n','m')], 1, function(x) Snm(x['n'], x['m']))
    tidyData <- tidyData[c(1,2,7,3:6)]
    
    # normalize coefficients with Schmidt quasi-normalization factors
    tidyData[-(1:3)] <- tidyData[["Snm"]] * tidyData[-(1:3)]
    
    # return tidyData dataframe
    tidyData %>% select(-Snm)
}

# recursively calculate derivatives of associated Legendre Polynomials
dPnm <- function(n, m, theta) {
    
    # calculate K
    K <- ((n-1)^2-m^2) / ((2*n-1)*(2*n-3))
    
    # compute dPnm
    if (n == 0 && m == 0) dP <- 0
    else if (n == m) dP <- sin(theta) * dPnm(n-1,m-1,theta) + cos(theta) * Pnm(n-1, m-1,theta)
    else dP <- ifelse(K == 0, cos(theta) * dPnm(n-1, m, theta) - sin(theta) * Pnm(n-1, m, theta),
                      cos(theta) * dPnm(n-1, m, theta) - sin(theta) * Pnm(n-1, m, theta) - K * dPnm(n-2, m, theta))
    
    dP
}

# recursively calculate Associated Legendre Polynomials
Pnm <- function(n, m, theta) { 
    
    # calculate K
    K <- ((n-1)^2-m^2) / ((2*n-1)*(2*n-3))
    
    # compute Pnm
    if (n == 0 && m == 0) P <- 1
    else if (n == m) P <- sin(theta) * Pnm(n-1, m-1, theta)
    else P <- ifelse(K == 0, cos(theta) * Pnm(n-1, m, theta), cos(theta) * Pnm(n-1, m, theta) - K * Pnm(n-2, m, theta))
    
    P
}

# recursively calculate Schmidt quasi-normalization factors
Snm <- function(n, m) {
    # Kronecker delta is defined as dij = 1 if i = j, and dij = 0 otherwise
    #   our formula for the Schmidt quasi-normalization factors in recursive form
    #   uses dm1 - so if m = 1, dm1 = 1 otherwise dm1 = 0
    kdelta <- ifelse(m==1, 1, 0)
    
    if (n == 0 && m == 0) S <- 1
    else if (m == 0) S <- Snm(n-1,0) * (2 * n - 1) / n
    else S <- Snm(n, m-1) * (((n - m + 1)*(kdelta + 1))/(n + m))^0.5
}

# filter and clean data
cleanData <- function(data, year) {
    library(reshape2)
    library(tidyr)
    
    # select only relevant DGRF/IGRF model(s)
    ifelse(year >= 2015, mods <- c("GRF2015"), mods <- c(paste0("GRF", 5 * floor(year/5)), paste0("GRF", 5 + 5 * floor(year/5))))
    fields <- append(c("n", "m", "SV"), mods)
    
    # split and subset data, rename coefficient fields appropriately
    g <- data %>% filter(gh == "g") %>% select(one_of(fields)) %>% rename_("gSV"="SV")
    h <- data %>% filter(gh == "h") %>% select(one_of(fields)) %>% rename_("hSV"="SV")
    
    if (year >= 2015) {
        # rename cols using suffix "ini" denoting model immediately before given date (ie IGRF2015)
        names(g) <- sub("GRF2015", "g_ini", names(g))
        names(h) <- sub("GRF2015", "h_ini", names(h))
    } else {
        # rename cols using suffixes "ini" and "fin" denoting models immediately before/after the given date
        # also don't need SV values unless forecasting from latest IGRF model
        names(g) <- sub(paste0("GRF", 5 * floor(year/5)), "g_ini", names(g))
        names(g) <- sub(paste0("GRF", 5 + 5 * floor(year/5)), "g_fin", names(g))
        names(h) <- sub(paste0("GRF", 5 * floor(year/5)), "h_ini", names(h))
        names(h) <- sub(paste0("GRF", 5 + 5 * floor(year/5)), "h_fin", names(h))
        g <- g %>% select(-gSV)
        h <- h %>% select(-hSV)
    }
    
    # join g and h coefficient data frames
    data <- full_join(g, h, by=c("n", "m"))
    data <- replace(data, is.na(data), 0)
}

# load IGRF 12 coefficients - if not already present
loadData <- function(file="igrf12coeffs.txt") {
    
    # load DGRF/IGRF coefficients  
    igrf <- read.table(paste0("./data/", file), header=FALSE, skip=4,
                       col.names = c("gh", "n", "m", "GRF1900", "GRF1905", "GRF1910", "GRF1915", "GRF1920",
                                     "GRF1925", "GRF1930", "GRF1935", "GRF1940", "GRF1945", "GRF1950",
                                     "GRF1955", "GRF1960", "GRF1965", "GRF1970", "GRF1975", "GRF1980",
                                     "GRF1985", "GRF1990", "GRF1995", "GRF2000", "GRF2005", "GRF2010",
                                     "GRF2015", "SV"),
                       colClasses = c("character", rep("numeric", 27)))
}