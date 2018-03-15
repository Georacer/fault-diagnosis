Installation instructions
---
Full installation instructions can be found in the provided user manual. Basic installation consists of two steps

1. Unzip the source archive
2. Add the path to your Matlab search path, either via the addpath command or using the search path configuration.

There are two algorithms that, in addition to their Matlab implementations, have C++ implementations. It is not necessary to compile these files, but it could lead to significantly reduced computational times in some analyses. This assumes that you have a working mex environment installed for your Matlab installation.

To compile the source code, first cd to the ``src`` directory of the installation. The minimal hitting set algorithm is compiled by writing ``mex MHScompiled.cc`` at the Matlab prompt. The MSO algorithm is compiled in two steps, first run ``make`` in the ``CSparse`` directory to compile the sparse matrix routines (from http://faculty.cse.tamu.edu/davis/suitesparse.html). When that is finished, go to Matlab and run the ``msocompile.m`` script.

Done!
