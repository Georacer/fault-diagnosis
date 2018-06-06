.. _basic-functionality:

===================
Basic functionality
===================

In this demo you will learn how to load a graph, generate its plot and search through it.

Create and examine a graph
==========================

First, load a structural system model

.. code-block:: matlab

    model = g007();

Create a new GraphInterface object to host the graph

.. code-block:: matlab

    initialGraph = GraphInterface();

Then, read the model

.. code-block:: matlab

    initialGraph.readModel(model);

Build the adjacency matrices

.. code-block:: matlab

    initialGraph.createAdjacency();

The initial graph has a GraphBipartite, a Registry and an Adjacency member

.. code-block:: matlab

    disp(initialGraph);

    GraphInterface with properties:

          graph: [1x1 GraphBipartite]
            reg: [1x1 Registry]
     idProvider: [1x1 IDProvider]
      adjacency: [1x1 Adjacency]
    formulaList: []
           name: 'g007'

The graph member contains all of the graph element arrays

.. code-block:: matlab

    disp(initialGraph.graph);

    GraphBipartite with properties:

    equations: [1x17 Equation]
    variables: [1x19 Variable]
        edges: [1x45 Edge]
         name: 'g007'
       coords: []
           gi: [1x1 GraphInterface]
      numVars: 19
       numEqs: 17
     numEdges: 45

The adjacency member contains the bidirectional, the equation-to-veriable and variable-to-equation adjacency matrices

.. code-block:: matlab

    disp(initialGraph.adjacency);

    Adjacency with properties:

          gi: [1x1 GraphInterface]
          BD: [36x36 double]
     numVars: 19
      numEqs: 17
     eqNames: []
       eqIds: []
    varNames: []
      varIds: []
         E2V: [17x19 double]
         V2E: [19x17 double]

Create a new plotter object

.. code-block:: matlab

    plotter = Plotter(initialGraph);

Create a dot graph and compile it

.. code-block:: matlab

    plotter.plotDot('initial');

The output .ps image is in the g008 folder.
This is the resulting image. Open it in a new tab to view it in full resolution.

.. image:: basic.png

Note how every equation is a rectrangle and every variable is a circle. All graph elements display their ID below them.

Graph elements discovery
========================

Get the IDs of all the variables in the graph

.. code-block:: matlab

    variableIdArray = initialGraph.getVariables()

    variableIdArray =

     2     4     6     8    10    13    15    19    22    28    32    35    38    41    44    47    71    75    79

Get the names of all the variables

.. code-block:: matlab

    variableNames = initialGraph.getAliasById(variableIdArray)

    variableNames =

    Columns 1 through 12

    'dot_x1'    'x1'    'x3'    'x4'    'x6'    'dot_x2'    'x2'    'x7'    'dot_x3'    'dot_x4'    'dot_x5'    'x5'

    Columns 13 through 19

    'dot_x6'    'u1'    'dot_x7'    'u2'    'y1'    'y2'    'y3'

Get the equations which use the first variable

.. code-block:: matlab

    equ1 = initialGraph.getEquations(variableIdArray(1))

    equ1 =

     1    49

Get the edge between the first variable and the first equation

.. code-block:: matlab

    edge1 = initialGraph.getEdgeIdByVertices(equ1(1),variableIdArray(1))

    edge1 =

     3


Discover elements by property
=============================

Find all of the known variables

.. code-block:: matlab

    knownVars = initialGraph.getVariablesKnown;
    initialGraph.getAliasById(knownVars)

    ans =

    'u1'    'u2'    'y1'    'y2'    'y3'

Find all of the inputs

.. code-block:: matlab

    inputVars = initialGraph.getVarIdByProperty('isInput');
    initialGraph.getAliasById(inputVars)

    ans =

    'u1'    'u2'
