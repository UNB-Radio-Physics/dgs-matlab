---
title: dgs-matlab - read Digisonde Ionosonde files
---

# dgs-matlab

Matlab library to read binary Digisonde files. Based on the FORTRAN code by Terry Bullett. Translated into native MATLAB.

## How to use:

The primary function is `read_dgs.m`, which takes as an input the path to the file to read. 
The output is a structure separated by mode containing the data found in the file.
Some Digisonde files contain multiple ionograms, in which case the output structure will be a vector.

This reader supports reading files with mixed block types. The following block types are supported:
* SBF
* RSF (Routine Scientific Format)
* MMM (Modified Maximum Method)

