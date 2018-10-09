.. mavlink-inspector documentation master file, created by
   sphinx-quickstart on Wed Sep 16 16:56:01 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root ``toctree`` directive.

===============================================
Welcome to the documentation of fault-diagnosis
===============================================
MATLAB libraries for fault-diangosis in dynamic, large-scale systems
====================================================================

`fault-diagnosis` is research software in MATLAB, targeted for fault diagnosis in large-scale systems. It employs methodologies of Structural Analysis for qualitative abstraction and efficient extraction of residual-generators.

Overview
========
`fault-diangosis` uses the methodology of Structural Analysis to perform Fault Diagnosis, which performs a qualitative abstraction of the mathematical model of a system into a bipartite Structural Graph. Graph methodologies are then applied onto that graph for the extraction of residual generators.

Graph representation of the bipartite graph is favoured, against the biadjacency matrix one, to allow more natural handling and processing of graph meta-information.

The codebase is split into several logical parts. There is dedicated documentation for each one:

 * Structural Graph
 * Graph Interface
 * Display engine
 * Subgraph Generator
 * Matcher

:ref:`chap-demos` are available in the dedicated section.

System Compatibility
====================
This software is developed and tested under Ubuntu Linux

External Software Requirements
==============================
`fault-diagnosis` requires the following software to operate:

 1. `Fault Diagnosis Toolbox <https://faultdiagnosistoolbox.github.io/>`_ - Research software on fault diagnosis using structural graphs. Used for the generation of PSO sets and its interface of the Dulmage-Mendelsohn decomposition.
 2. `matlab_networks_routines <http://strategic.mit.edu/downloads.php?page=matlab_networks>`_ - Library for graph operations.
 3. `munkres <https://www.mathworks.com/matlabcentral/fileexchange/20652-hungarian-algorithm-for-linear-assignment-problems--v2-3->`_  - Fast implementaiton of the Hungarian weighted assignment algorithm.

The above software is distributed alognside `fault-diagnosis`, according to the copyright set by their respective authors/owners. Licence files for each software are included in the corresponding directories.

Also the following software is required to be installed on the system:

 1. The *dot* language compiler, part of the GraphViz package - Used for graph visualization.

Related Publications
====================
`fault-diagnosis` was developed alongside and was part of the research included in the following publications:

 * Zogopoulos Papaliakos, G., & Kyriakopoulos, K. J. (2016). On the selection of calculable residual generators for UAV fault diagnosis. In MED’16: The 24th Mediterranean Conference on Control and Automation (pp. 0–5). IEEE. http://doi.org/10.1109/MED.2016.7536003
 * Zogopoulos-Papaliakos, G., & Kyriakopoulos, K. J. (2017). Generating Semi-Explicit DAEs with Structural Index 1 for Fault Diagnosis Using Structural Analysis. In 2017 IEEE International Conference on Robotics and Automation (ICRA). ΙΕΕΕ.

Licence
=======
The `fault-diagnosis` software project uses the `Apache 2.0 <https://www.apache.org/licenses/LICENSE-2.0>`_ licence.

.. toctree::
	:hidden:

	model/index
	graph/index
	graph_interface/index
	display/index
	subgraph_generator/index
	matcher/index
	demos/index
	contributors

