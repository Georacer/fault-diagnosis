=======================
The graph interface API
=======================

The core class of this toolbox is the ``GraphInterface``. It wraps around the :ref:`sec-graph-class` data structure and provides functionality for its creation, parsing and editing.

Provided methods
================

The main functionality of this class is:

Model creation
--------------
 * ``readModel(model)``

Graph search
------------
 * ``getEquations(ids)``
 * ``getVariables(ids)``
 * ``getVariablesKnown(id)``
 * ``getVariablesUnknown(id)``
 * ``getVarIdByAlias(alias)``
 * ``getEdges(ids)``
 * ``getEdgeWeight(ids)``
 * ``getEdgeIdByVertices(equIds,varIds)``
 * ``getAliasById(ids)``
 * ``getMatchedEqus()``
 * ``getMatchedVars()``
 * ``getMathedEdges()``

Logical tests
-------------
 * ``isEquation(ids)``
 * ``isVariable(ids)``
 * ``isEdge(ids)``
 * ``isMatched(ids)``
 * ``isKnown(ids)``
 * ``isIntegral(ids)``
 * ``isDerivative(ids)``
 * ``isNonSolvable(ids)``

Graph element editing
---------------------
 * ``setEdgeWeight(ids, weights)``
 * ``setMathed(ids)``
 * ``setKnown(ids)``

Graph manipulation
------------------
 * ``applyMatching(M)``

Adjacency matrices
==================
Traditionally, structural methods used adjacency matrices for model representation. ``GraphInterface`` creates such a matrix based on its graph with ``createAdjacency()`` and adds it to its members, as an ``Adjacency`` class.

This class provides the bidirectional (``BD``), equation-to-variable (``E2V``) and variable-to-equations (``V2E``) matrices as its members, with weighted entries.
