====================
Graph Representation
====================

.. _sec-graph-class:

The graph class
===============
The basic data structure in `fault-diangosis` is a bipartite structural graph, encoded in the ``GraphBipartite`` class.
It contains equation vertices, variable vertices and edges which connect the first two.

The ``GraphBipartite`` class is meant to serve only as a data structure, not as an API. All operations on the ``GraphBipartite`` object should be handles by the parent ``GraphInterface`` object.

All of the vertice and edge classes are subclasses of the ``GraphElement`` superclass. The basic property of each ``GraphElement`` is its unique **id**. The ``IDProvider`` class objects provides unique IDs for every new ``GraphElement``.
A unique ID allows for continuous tracking of graph elements throughout any graph transformations.

Vertex class
============
Each vertex, either an equation or a variable includes the following properties:

 * alias - a human readable name
 * edgeIDArray - an array containing the IDs of the edges adjacent to the vertex
 * neighbourArray - an array containing the IDs of the immediate neighbouring vertices to this vertex
 * matchedTo - the ID of the vertex this vertex is (potentially) matched to

Equations
---------
``Equation`` is a subclass of the ``Vertex`` class.

.. _sec-graph-variables:

Variables
---------
``Variables`` is a subclass of the ``Vertex`` class. They carry qualitative information via the (non-exclusive) properties:

 * isKnown - whether this variable is known
 * isMeasured - whether this variable is a known system measurement
 * isInput, isOutput - whether this variable is a system IO
 * isResidual - whether this variable is a residual signal

.. _sec-graph-edges:

Edge class
==========
The ``Edge`` class encodes most of the structural information of the class, through the following properties:

 * weight - weight information reflecting the cost of the solution of the adjacent variable by the adjacent equation
 * isDerivative, isIntegral, isNonSolvable - These properties carry the causality information
