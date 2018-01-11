Fault Diagnosis Toolbox - A Matlab toolbox for fault diagnosis
--------

Fault Diagnosis Toolbox is a Matlab toolbox for analysis and design of fault diagnosis systems for dynamic systems, primarily described by differential equations. In particular, the toolbox is focused on techniques that utilize structural analysis, i.e., methods that analyze and utilize the model structure. The model structure is the interconnections of model variables and is often described as a bi-partite graph or an incidence matrix. Key features of the toolbox are

* Finding overdetermined sets of equations (MSO sets), which are minimal submodels that can be used to design fault detectors
* Diagnosability analysis - analyze a given model to determine which faults that can be detected and which faults that can be isolated
* Sensor placement - determine minimal sets of sensors needed to be able to detect and isolate faults
* Code generation (Matlab and C) for residual generators. Two different types of residual generators are supported, sequential residual generators based on a matching in the model structure graph, and observer based residual generators.

The toolbox relies on the object-oriented functionality of the Matlab language and is freely available under a MIT license. The latest version can always be downloaded from our website at http://www.fs.isy.liu.se/Software/FaultDiagnosisToolbox/ and links to relevant publications can be found also at our list of publications http://www.fs.isy.liu.se/Publications.
