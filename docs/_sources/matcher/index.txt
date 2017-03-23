======================
Graph matching methods
======================

Graph matching is an indispensable part of Fautl Diagnosis via Structural Analysis. `fault-diagnosis` provides 6 different algorithms for matching, through the ``Matcher`` class.

Matcher instantiation
=====================

The ``Matcher`` object is instantiated by providing the ``GraphInterface`` object it should act upon.

.. warning::

 The ``Matcher`` functionality applies changes directly onto the provided ``GraphInterface``. If you want to preserve the original graph create a copy with the ``copy`` function.

Call the ``setCausality(causality)`` method to choose the causality setting (among `None`, `Integral`, `Differential`, `Mixed` and `Realistic`) for the mather algorithms which use it.

Matching algorithms
===================

The matching algorithms which are offered by `fault-diangosis` are presented below.
The member ``matchingSet`` is filled with the matching(s) the matching procedures uncover.

Murty
-----

**Arguments**
numMatchings: number of matchings to return

Uses Murty's algorithm which returns the k-cheapest matchings of a *just-constrained* graph, in order of increasing cost. The cheapest matching is applied.

.. _weighted-elimination:

WeighedElimination
-------------------

**Arguments**
maxRank: The maximum rank up to which variables must be matched
maxMatchings: The maximum number of matchings that are allowed to be performed

This is a modifiation of the *Ranking* matching algorithm. It matches a variable to an equation only if is the only unknown variable. Also, the matchings are performed in the order of increasing cost.

Due to its nature, the weighted matching algorithm does not create loops in the matched directed graph.

ValidJust
---------

This algorithm applies only to *just-constrained* graphs. It produces all possible matchings in order of increasing cost and then filters them according to *realistic* causality. The cheapest valid matching is returned and applied.

Valid
-----

This is similar to ``ValidJust`` but is applicable only to MSO graphs.

It runs ``ValidJust`` to all just-constrained subgraphs and selects the cheapest valid matching, which is returned and applied.

Valid2
------

This is an extension of ``Valid`` which is applicable to all graphs. It produces the set of MSOs which are parsed for their cheapest valid matching, similar to the previous algorithm. The cheapest valid mathing across all MSOs is returned and applied. Useful for matching PSO graphs.

.. _BBILP:

BBILP
-----

**Arguments**
branchMethod: cheap, BFS, DFS

This algorithm is applicable to PSO graphs and poses the valid matching problem as a Branch-and-Bound Integer Linear Programming (BBILP) problem. It initially relaxes the problem into a simple assignment problem which is solved by the Hungarian algorithm. The relaxed solution is then verified. Any violating edge is used as a branching node in a search tree which is parsed in search of the cheapest valid solution.

This algorithm is designed to perform much faster (most of the time) in constrained matching problems with exponentially many constraints, where traditionally all candidate matchings must be checked for validity before the cheapest one is selected (as the ``Valid2`` algorithm does).