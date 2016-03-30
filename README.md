---
title: "IGRF Calculator"
author: "Joshua Poirier"
date: "March 2016"
---
*** 
#### An Interactive Web App using R's **shiny** package

## Introduction
This repository contains code using the **R** language and the **shiny** package to calculate the IGRF version 12 at a user-provided location in space-time.  The IGRF (International Geomagnetic Reference Field) is a model of the Earth's main magnetic field originating from within the Earth.  This excludes components of the magnetic field due to magnetic material in the Earth's crust as well as those caused by internal eddy currents induced by external magnetic fields (i.e. the solar wind).  The description of this main geomagnetic field and its secular variation (henceforth referred to as IGRF) is put forth by the IAGA (International Association of Geomagnetism and Aeronomy).  It is presented in terms of spherical harmonic models and is published at epochs of 5 years.  

IGRF version 12 includes models for the years 1900 through 2015 at 5 year epochs and is valid for calculating the IGRF from January 1, 1900 through December 31, 2019.  Please consult the **References** section for details on how the models were calculated.

## References

Barraclough, David R.  International Geomagnetic Reference Field: the fourth generation.  Physics of the Earth and Planetary Interiors, 48 (1987) 279-292.  Elsevier Science Publishers B.V., Amsterdam.

British Geological Survey.  IGRF (12th Generation, revised 2014) Synthesis Form.  [http://www.geomag.bgs.ac.uk/data_service/models_compass/igrf_form.shtml](http://www.geomag.bgs.ac.uk/data_service/models_compass/igrf_form.shtml).

Davis, Jeremy.  Mathematical Modeling of Earth's Magnetic Field Technical Note.  Virginia Tech.  May 12, 2004.

Hinze, William J. et al.  Gravity and Magnetic Exploration.  Cambridge University Press.  2013.  ISBN 978-0-521-97101-3 Hardback.

Peddie, Norman W.  International Geomagnetic Reference Field: the Third Generation.  J. Geomag. Geoelectr., **34**: 309-326, 1982.

Thébault, Erwan and National Oceanic and Atmospheric Administration.  International Geomagnetic Reference Field.  [http://www.ngdc.noaa.gov/IAGA/vmod/igrf.html](http://www.ngdc.noaa.gov/IAGA/vmod/igrf.html).

Thébault et al.  International Geomagnetic Reference Field: the 12th generation.  Earth, Planets and Space (2015) 67: 79.  DOI 10.1186/s40623-015-0228-9.

Winch et al.  Geomagnetism and Schmidt quasi-normalization.  Geophys. J. Int. (2005) **160**, 487-504.  DOI 10.1111/j.1365-246X.2004.02472.x.