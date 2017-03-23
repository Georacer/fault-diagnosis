==================
Subgraph Generator
==================

There is often the need to keep only a part of an original structural graph, for further processing and investigation. The ``SubgraphGenerator`` class provides such functionality through the following methods:

 * ``setGraphInterface(gi)`` - Set the ``GraphInterface`` object which the ``SubgraphGenerator`` should manipulate
 * ``graphInterface = buildSubgraph(varargin)`` - Get a ``GraphInterface`` object which contains only the provided equation and variable IDs.
 * ``graphInterface = getOver()`` - Return a ``GraphInterface`` object containing only the overdetermined part of the graph.
 * ``buildLiUSM()`` - Populate the ``liUSM`` member with a ``DiagnosisModel`` object from the *Fault Diagnosis Toolbox*.
 * ``buildMSOs()``,``buildMTESs()`` - Request the ``liUSM`` member to build the sets of MSOs or MTESs respectively.
