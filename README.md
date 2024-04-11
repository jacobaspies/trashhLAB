# trashhLAB
A collection of data acquisition scripts for performing time-resolved anisotropic solid-state high harmonic generation (TRASHH) spectroscopy [1] and terahertz time-domain spectroscopy (THz-TDS) [2,3]. Future udpates will include a graphical user interface (GUI) for interactive data acquisition and in-line data processing for THz measurements using Nelly [4].

Data acquisition scripts were developed in MATLAB 2020b and have been deployed in the newest version (MATLAB 2023b). Code is not guaranteed to be free from bugs.

# Currently Supported Hardware
- Andor spectrometer
  - Communication via USB
  - Currently implemented for a Kymera 328i spectrometer and iDus camera 
- Stanford Research Systems SR810/SR830 lock-in amplifier
  - Communication via USB-GPIB with one of the following adapters:
    - Agilent/Keysight 82357B
    - National Instruments GPIB-USB-HS
  - Currently implemented using 'instrfind' and 'gpib', which will be discontinued in later versions of MATLAB. Communication via 'visadev' in development.
- Thorlabs BBD30X controller for DDS direct-drive delay stages
  - Communication via USB
- Zaber X-MCC series multi-axis universal controller
  - Communcation via ethernet
- Lakeshore Model 335 cryogenic temperature controller
  - Communication via USB-GPIB with one of the following adapters:
    - Agilent/Keysight 82357B
    - National Instruments GPIB-USB-HS

# Hardware Support In Development
- Thorlabs K10CR1 motorized rotation mount
  - Communication via USB
  - Code is available, but not deployed in the main package.
- Thorlabs M30X motorized linear translation stage
  - Communication via USB
  - Code is available, but not deployed in the main package.

# References
1.) Zong, A.; Nebgen, B. R.; Lin, S.-C.; Spies, J. A.; Zuerch, M. "Emerging Ultrafast Techniques for Studying Quantum Materials" _Nat. Rev. Mater._ **2023**, _8_, 224.

2.) Neu, J.; Schmuttenmaer, C. A. "Tutorial: An Introduction to Terahertz Time-Domain Spectroscopy (THz-TDS)" _J. Appl. Phys._ **2018**, _124_, 231101.

3.) Spies, J. A.; Neu, J.; Tayvah, U. T.; Capobianco, M. D.; Pattengale, B.; Ostresh, S.; Schmuttenmaer, C. A. "Terahertz Spectroscopy of Emerging Materials" _J. Phys. Chem. C_ **2020**, _124_, 22335.

4.) Tayvah, U. T.; Spies, J. A.; Neu, J.; Schmuttenmaer, C. A. "Nelly: A User-Friendly and Open-Source Implementation of Tree-Based Complex Refractive Index Analysis for Terahertz Spectroscopy" _Anal. Chem._ **2021**, _93_, 11243.
