# MRI-strain-depth-fraction
A processing suite to analyze depth-dependent strains by fractional area and statistical testing. Originally made to use MRI-based strain maps. Only works with strains already calculated.

1) Save your n x m size strain maps & masks using MATLAB .mat files in the following format:
  - Strains: variable "strain" = <n pixels> x <m pixels> x <number of slices>
  - Principal Strains: "strainP" = <n pixels> x <m pixels> x <number of slices>
  - binary mask: "msk" = <n pixels> x <m pixels> x <number of slices>
 
2) Open DepthFraction_MS.m
  - Alter the %% SCRIPT PARAMTERS section to your needs
  - Alter the %% LOAD STRAINS main loop to load your strain maps (currently all strain maps must be the exact same size)
  - Alter the %% STATISTICAL TESTS section to your needs
  
3) Run DepthFraction_MS.m
