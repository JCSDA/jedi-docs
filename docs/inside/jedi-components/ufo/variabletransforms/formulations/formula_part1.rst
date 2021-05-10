.. _Heights_to_pressure_ICAO:

================================================
Heights to pressures (using the ICAO atmosphere)
================================================

Converts heights to pressures (in :math:`hPa`) using the ICAO atmosphere.

The pressure (:math:`P`) is retrieved as follow:

- For :math:`Z < 11000` gpm

  .. math::

    P = 100.0- p_{b} \times P_{ICAO_{surface}}

  with

  .. math::

    p_{b} = (1.0 - p_{a})^{ZP_{11}}

  and 

  .. math::
    
    p_{a} = L_{ICAO_{11}} \times Z \times \frac{1.0}{T_{ICAO_{surface}}}

        
- For :math:`11000 \leq Z < 20000.0` gpm

  .. math::
    
    P = 100.0 \times 10^{p_{a}}

  with

  .. math::
    
    p_{a} = \log(P_{ICAO_{11}}) - p_{b}

and 

  .. math::
    
    p_{b} = \frac{g}{R_{d}} \times (Z - 11000) \times \frac{1.0}{T_{ICAO_{iso}}};

    

- For :math:`Z \geq 20000.0` gpm

  .. math::

    P = 100.0 \times P_{ICAO_{22}} \times (1.0 - P_{a})^{ZP_{22}};

  with  

  .. math::

    P_{a} = L_{ICAO_{22}} \times \frac{1.0}{T_{ICAO_{iso}}} \times (Z - 20000)
    

With:
 -  Temperature of isothermal layer: :math:`T_{ICAO_{iso}} = 216.65` K   
 -  The assume surface temperature: :math:`T_{ICAO_{surface}} = 288.15` K
 -  The assume surface pressure: :math:`P_{ICAO_{surface}} = 1013.25` hPa
 -  The assumed pressure at 11,000 gpm: :math:`P_{ICAO_{11}} = 226.32` hPa
 -  The assumed pressure at 22,000 gpm: :math:`P_{ICAO_{22}} = 54.7487` hPa
 -  The lapse rate for levels up to 11,000 gpm: :math:`L_{ICAO_{11}} = 6.5 \times 10^{-03}` K/m 
 -  The lapse rate from 11,000 gpm to 22,000 gpm: :math:`L_{ICAO_{22}} = -1.0 \times 10^{-03}` K/m 
 -  :math:`ZP_{11} = \frac{g}{R_{d} \times L_{ICAO_{11}}}`
 -  :math:`ZP_{22} = \frac{g}{R_{d} \times L_{ICAO_{22}}}`
 -  Specific gas constant for dry air: :math:`R_{d}` 
 -  Standard acceleration due to gravity: :math:`g` 

 .. _SatVaporPres_fromTemp:

===============================
Saturated Vapor Pressure from T
===============================
The various formulations available to derive :math:`e_{sat}` (Saturated Vapor Pressure) 
from :math:`T` (temperature or dew point temperature) are:
 

- **Rogers** | **default**: 
  Classical formula from Rogers and Yau (1989; Eq2.17)

  .. math::

      e_{sat} = 1000 \times 0.6112 \times \exp\left(17.67 \times \frac{T - 2.7315 \times 10^{2}}{T - 29.65}\right)
 
 
- **Sonntag**: 
  Eqn 7, Sonntag, D., Advancements in the field of hygrometry,
  Meteorol. Zeitschrift, N. F., 3, 51-66, 1994.
  Most radiosonde manufacturers use Wexler, or Hyland and Wexler
  or Sonntag formulations, which are all very similar (Holger Vomel,
  pers. comm., 2011)
 
  .. math::
 
      e_{sat} = \exp\left(\frac{-6096.9385}{T} + 21.2409642 - 2.711193 \times 10^{-2}
 
                   \times T + 1.673952 \times 10^{-5} \times T^{2} + 2.433502 \times \log(T)\right)
 
- **Walko**: 
  Polynomial fit of Goff-Gratch (1946) formulation (Walko, 1991). The Walko formulation is computationally 
  fastest of all methods, but becomes less accurate at extremely low temperatures, below roughly -70C.

  .. math::

    e_{sat} = c_{0}+x \times (c_{1}+x \times (c_{2}+x \times (c_{3}+x \times (c_{4}+
                            
              x \times (c_{5}+x \times (c_{6}+x \times (c_{7}+x \times c_{8})))))))
 
  with:
 
  .. math::
 
     c = [610.5851, 44.40316, 1.430341, 0.2641412 \times 10^{-1},
 
          0.2995057 \times 10^{-3}, 0.2031998 \times 10^{-5}, 0.6936113 \times 10^{-8}, 
 
          0.2564861 \times 10^{-11}, -0.3704404 \times 10^{-13}]
 
 
- **Murphy**: 
  Murphy and Koop, Review of the vapour pressure of ice 
  and supercooled water for atmospheric applications, Q. J. R. Meteorol. 
  Soc (2005), 131, pp. 1539-1565.
 
  .. math::
 
     e_{sat} = \exp\left(54.842763 - \frac{6763.22}{T} - 4.210 \times \log(T)

                   + 0.000367 \times T + tanh(0.0415 \times (T - 218.8))
                              
                   \times (53.878 - \frac{1331.22}{T} - 9.44523 \times \log(T)
 
                   + 0.014025 \times T)\right)
 

