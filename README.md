---
title: "IGRF Calculator"
author: "Joshua Poirier"
date: "April 2016"
---
*** 
#### An Interactive Web App using R's **shiny** package

## Introduction
This repository contains code using the **R** language and the **shiny** package to calculate the IGRF (International Geomagnetic Reference Field) at a user-provided location in space-time.  The IGRF is a model of the Earth's main magnetic field originating from within the Earth.  This excludes components of the magnetic field due to magnetic material in the Earth's crust as well as those caused by internal eddy currents induced by external magnetic fields (i.e. the solar wind).  The description of this main geomagnetic field and its secular variation is put forth by the IAGA (International Association of Geomagnetism and Aeronomy).  It is presented in terms of spherical harmonic models which are published at epochs of 5 years.  

IGRF version 12 includes models for the years 1900 through 2015 at 5 year epochs and is valid for calculating the IGRF from January 1, 1900 through December 31, 2019.  Please consult the **References** section for details on how the models were calculated.

## Mathematical Description of the IGRF
The magnetic field **B** is defined as the negative gradient of the scalar potential function *V*.  While a simple dipole model gives a good approximation, the geomagnetic field can be more closely modeled using a spherical harmonic model of the scalar potential described below.

$$V(r, \theta, \lambda) = a \sum_{n=1}^k \left(\frac{a}{r} \right)^{n+1} \sum_{m=0}^n (g_n^m \cos m\lambda + h_n^m \sin m\lambda) P_n^m(\cos \theta)$$

Where,

$a \equiv$ reference radius of the Earth (constant; 6371.2 km)  
$r \equiv$ radial distance to the center of the Earth (in kilometers)  
$\theta \equiv$ geocentric co-latitude in spherical coordinates  
$\lambda \equiv$ user-input east longitude measured from Greenwich  
$g_n^m, h_n^m \equiv$ Gaussian coefficients put forth by IAGA for the IGRF relating to $P_n^m$ ...  
$P_n^m \equiv$ Schmidt Quasi-Normalized Associated Legendre polynomial of degree *n* and order *m*  

This application calculates the magnetic field strength by computing the partial derivatives of this scalar potential *V* described below in geocentric spherical coordinates.

$$B_r = \frac{-\partial V}{\partial r} = \sum_{n=1}^k \left(\frac{a}{r} \right)^{n+2}(n+1) \sum_{m=0}^n (g_n^m \cos m \lambda + h_n^m \sin m \lambda) P_n^m(\cos \theta)$$
$$B_\theta = \frac{-1}{r} \frac{\partial V}{\partial \theta} = - \sum_{n=1}^k \left(\frac{a}{r} \right)^{n+2} \sum_{m=0}^n (g_n^m \cos m \lambda + h_n^m \sin m \lambda) \frac{\partial P_n^m(\theta)}{\partial \theta}$$
$$B_\lambda = \frac{-1}{r \sin \theta} \frac{\partial V}{\partial \lambda} = \frac{-1}{\sin \theta} \sum_{n=1}^k \left(\frac{a}{r} \right)^{n+2} \sum_{m=0}^n m (-g_n^m \sin m \lambda + h_n^m \cos m \lambda) P_n^m(\theta)$$

Since the Earth more closely resembles an oblate spheroid than a sphere it is customary to take this into account.  We convert the user-supplied oblate-spheroidal geographic coordinates into the spherical coordinates before evaluating the above scalar potential partial derivatives.  This is because the models making the IGRF are a series of solid **spherical** harmonics and their derivatives.  The geocentric latitude ($\theta$), flattening ($f$), and geocentric radius ($r$) are described below.

$$\cos \theta = \frac{\sin \phi}{\left(f \cos^2 \phi + \sin^2 \phi \right)^{\frac{1}{2}}}$$
$$f = \frac{(h[A^2-(A^2-B^2) \sin^2 \phi]^{\frac{1}{2}} + A^2)^2}{(h[A^2-(A^2-B^2) \sin^2 \phi]^{\frac{1}{2}}+B^2)^2}$$
$$r^2 = \frac{h^2 + 2h \left[A^2 - (A^2-B^2) \sin^2 \phi \right]^{\frac{1}{2}} + [A^4-(A^4-B^4) \sin^2 \phi]}{[A^2-(A^2-B^2) \sin^2 \phi]}$$

Where,

$\theta \equiv$ geocentric latitude in spherical coordinates  
$\phi \equiv$ user-input geographic latitude in oblate-spheroidal coordinates  
$f \equiv$ flattening  
$A \equiv$ equatorial radius of the Earth (constant; approximately 6'378 km)  
$B \equiv$ polar radius of the Earth (constant; approximately 6'357 km)  
$h \equiv$ user-input elevation above mean sea level (in kilometers)  
$r \equiv$ radial distance from the center of the Earth (in kilometers)  

To calculate the scalar potential partial derivatives ($B_r$, $B_\theta$, and $B_\lambda$) we must first calculate the Schmidt quasi-normalized associated Legendre functions $P_n^m$.  Legendre polynomials are a set of orthogonal polynomials satisfying the zero mean condition.  Regular Legendre polynomials ($P_n(v)$) are calculated to satisfy the below equation.  

$$(1-2vx+x^2)^{-\frac{1}{2}} = \sum_{n=0}^\infty P_n(v) x^n$$

These regular Legendre polynomials can then be used to calculate the Associated Legendre polynomials ($P_{n,m}$) through the following relation.  **Note**: For all $m > n$, the Associated Legendre polynomial equals 0.

$$P_{n,m}(v) = (1-v^2)^{\frac{1}{2m}} \frac{d^m}{dv^m} (P_n(v))$$

Next we show how to normalize the above equation to compute the Gaussian Normalized Associated Legendre polynomials ($P^{n,m}$).  

$$P^{n,m} = \frac{2^n!(n-m)!}{(2n)!} P_{n,m}$$

Finally, we can calculate the Schmidt Quasi-Normalized Associated Legendre polynomials ($P_n^m$) by multiplying the Gaussian Normalized Associated Legendre polynomials by the Schmidt Quasi-Normalization Factors ($S_{n,m}$).

$$P_n^m = S_{n,m} P_{n,m}$$
$$S_{n,m} = \left[\frac{(2-\delta_m^0)(n-m)!}{n+m)!} \right]^{\frac{1}{2}} \frac{(2n-1)!!}{n-m)!}$$

$\delta_i^j$ is the Kronecker Delta and is defined as $\delta_i^j = 1$ if $i=j$ and $\delta_i^j = 0$ otherwise.  

## Computational Description of the IGRF
Since the normalization values are not dependent on $\theta$ we can actually simply normalize the model coefficients $g_n^m$ and $h_n^m$ and use the normalized coefficients to calculate the field strength at multiple locations instead of calculating it over and over again for each location.  So we improve the computational efficiency by not calculating the Schmidt Quasi-Normalized Associated Legendre polynomials by instead computing and applying the Schmidt Quasi-Normalization factors to the Gaussian coefficients of the model and proceeding with the Gaussian Normalized Associated Legendre polynomials.

The Gaussian Normalized Associated Legendre polynomials are then calculated recursively for insertion into the scalar potential partial derivative equations $B_r$, $B_\theta$, and $B_\lambda$.

$$P^{0,0} = 1$$
$$P^{n,n} = \sin \theta P^{n-1,m-1}$$
$$P^{n,m} = \cos \theta P^{n-1,m} - K^{n,m}P^{n-2,m}$$

Where, $K^{n,m} = \frac{(n-1)^2-m^2}{(2n-1)(2n-3)}, n > 1$.  Furthermore, the derivatives of the Gaussian Normalized Associated Legendre polynomials are calculated recursively.

$$\frac{\partial P^{0,0}}{\partial \theta} = 0$$
$$\frac{\partial P^{n,n}}{\partial \theta} = \sin \theta \frac{\partial P^{n-1,n-1}}{\partial \theta} + \cos \theta P^{n-1,n-1}, n\geq1$$
$$\frac{\partial P^{n,m}}{\partial \theta} = \cos \theta \frac{\partial P^{n-1,m}}{\partial \theta} - \sin \theta P^{n-1,m} - K^{n,m} \frac{\partial P{n-2,m}}{\partial \theta}$$

The Schmidt Quasi-Normalization factors are also calculated recursively as follows.

$$S_{0,0} = 1$$
$$S_{n,0} = S_{n-1,0} [\frac{2n-1}{n}]$$
$$S_{n,m} = S_{n,m-1} \sqrt{\frac{(n-m+1)(\delta_m^1+1)}{n+m}}$$

Those Schmidt Quasi-Normalization factors are then applied to the Gaussian model coefficients.

$$g^{n,m} = S_{n,m} g_n^m$$
$$h^{n,m} = S_{n,m} h_n^m$$

We then take the Gaussian Normalized Associated Legendre polynomials (and their derivatives) along with the Schmidt Quasi-Normalized model coefficients and insert them into the scalar potential partial derivatives (shown again below for emphasis).  We then convert these partial derivatives from local tangential coordinates into more user-friendly and familiar local tangential Cartesian coordinates (X - North, Y - East, Z - Down) referring to an oblate-spheroidal Earth.

$$B_r = \frac{-\partial V}{\partial r} = \sum_{n=1}^k \left(\frac{a}{r} \right)^{n+2}(n+1) \sum_{m=0}^n (g_n^m \cos m \lambda + h_n^m \sin m \lambda) P_n^m(\cos \theta)$$
$$B_\theta = \frac{-1}{r} \frac{\partial V}{\partial \theta} = - \sum_{n=1}^k \left(\frac{a}{r} \right)^{n+2} \sum_{m=0}^n (g_n^m \cos m \lambda + h_n^m \sin m \lambda) \frac{\partial P_n^m(\theta)}{\partial \theta}$$
$$B_\lambda = \frac{-1}{r \sin \theta} \frac{\partial V}{\partial \lambda} = \frac{-1}{\sin \theta} \sum_{n=1}^k \left(\frac{a}{r} \right)^{n+2} \sum_{m=0}^n m (-g_n^m \sin m \lambda + h_n^m \cos m \lambda) P_n^m(\theta)$$
$$B_x = -B_\theta \cos d - B_r \sin d$$
$$B_y = B_\lambda$$
$$B_z = B_\theta \sin d - B_r \cos d$$

Where, $d = \phi + \theta - 90^{\circ}$ where, $\phi \equiv$ geographic latitude, $\theta \equiv$ geocentric co-latitude.

## References

Barraclough, David R.  International Geomagnetic Reference Field: the fourth generation.  Physics of the Earth and Planetary Interiors, 48 (1987) 279-292.  Elsevier Science Publishers B.V., Amsterdam.  [ftp://ftp.spacecenter.dk/pub/cfinl/IGRF_papers/IGRF4_Barraclough_1987.pdf](ftp://ftp.spacecenter.dk/pub/cfinl/IGRF_papers/IGRF4_Barraclough_1987.pdf).

British Geological Survey.  IGRF (12th Generation, revised 2014) Synthesis Form.  [http://www.geomag.bgs.ac.uk/data_service/models_compass/igrf_form.shtml](http://www.geomag.bgs.ac.uk/data_service/models_compass/igrf_form.shtml).

Davis, Jeremy.  Mathematical Modeling of Earth's Magnetic Field Technical Note.  Virginia Tech.  May 12, 2004.  [http://hanspeterschaub.info/Papers/UnderGradStudents/MagneticField.pdf](http://hanspeterschaub.info/Papers/UnderGradStudents/MagneticField.pdf).

Hinze, William J. et al.  Gravity and Magnetic Exploration.  Cambridge University Press.  2013.  ISBN 978-0-521-97101-3 Hardback.

Peddie, Norman W.  International Geomagnetic Reference Field: the Third Generation.  J. Geomag. Geoelectr., **34**: 309-326, 1982.  [ftp://ftp.spacecenter.dk/pub/cfinl/IGRF_papers/IGRF3_Peddie_1982.pdf](ftp://ftp.spacecenter.dk/pub/cfinl/IGRF_papers/IGRF3_Peddie_1982.pdf).

Thébault, Erwan and National Oceanic and Atmospheric Administration.  International Geomagnetic Reference Field.  [http://www.ngdc.noaa.gov/IAGA/vmod/igrf.html](http://www.ngdc.noaa.gov/IAGA/vmod/igrf.html).

Thébault et al.  International Geomagnetic Reference Field: the 12th generation.  Earth, Planets and Space (2015) 67: 79.  DOI 10.1186/s40623-015-0228-9.  [http://download.springer.com/static/pdf/654/art%253A10.1186%252Fs40623-015-0228-9.pdf?originUrl=http%3A%2F%2Fearth-planets-space.springeropen.com%2Farticle%2F10.1186%2Fs40623-015-0228-9&token2=exp=1460651092~acl=%2Fstatic%2Fpdf%2F654%2Fart%25253A10.1186%25252Fs40623-015-0228-9.pdf*~hmac=e650dd210d9e91777045c4630f257ed7461037fb36f9d25e618d53b6a2f4006f](http://download.springer.com/static/pdf/654/art%253A10.1186%252Fs40623-015-0228-9.pdf?originUrl=http%3A%2F%2Fearth-planets-space.springeropen.com%2Farticle%2F10.1186%2Fs40623-015-0228-9&token2=exp=1460651092~acl=%2Fstatic%2Fpdf%2F654%2Fart%25253A10.1186%25252Fs40623-015-0228-9.pdf*~hmac=e650dd210d9e91777045c4630f257ed7461037fb36f9d25e618d53b6a2f4006f).

Winch et al.  Geomagnetism and Schmidt quasi-normalization.  Geophys. J. Int. (2005) **160**, 487-504.  DOI 10.1111/j.1365-246X.2004.02472.x.  [https://gji.oxfordjournals.org/content/160/2/487.full](https://gji.oxfordjournals.org/content/160/2/487.full).