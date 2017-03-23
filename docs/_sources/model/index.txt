===========
Model Input
===========

Bipartite structural graph
==========================

The functionality of `fault-diangosis` revolves around structural representation of mathamatical system models. According to this methodology, the system model is abstracted into a qualitative bipartite graph representation where:

 * Every equation is assigned a vertex in the "equations" set
 * Every variable is assigned a vertex in the "variables" set
 * A variable which participates in an equation is connected to it with an edge

Traditionally, no other information is encoded into the structural graph. However, more modern approaches require a bit more information to produce valid and causal results. For that reason:

 * :ref:`sec-graph-variables` vertices are embelished with information on whether they are known, measured, inputs, outputs or residual generators.
 * :ref:`Edges <sec-graph-edges>` are embelished with information on their calculation cost and whether they represent a differentiation, an integration or a non-solvable variable-equation relation
 * All derivative variables must be declared through explicit differentiation equations

Model input format
==================

Currenlty `fault-diagnosis` only accepts structural model input, instead of mathematical equations. Examples of structural model specificaiton can be found in the ``GraphPool`` folder.

Each line of the model description file represents one equation. The indentifier ``fault`` at the start of the line signifies that the equation is subject to a fault. All subsequent words, space-separated are unique variable names, except for the following identifiers:

 * ``msr`` sets the following variable to a known measurement
 * ``inp`` sets the following variable to a known input
 * ``ni`` restricts this equation to be evaluated for this variable
 * ``int`` signifies the use of that variable in an explicit differentiation as integration, i.e. this is the derivative of the state
 * ``dot`` signifies the use of that variable in an explicit differentiation is differentiaton, i.e. this is the original state

Below is a short model description. ``g007`` is the name of the model. The separation of equations to the ``con``, ``der`` and ``msr`` cells is only visual and serves better readability purposes.

.. code-block:: matlab

	classdef g007 < model
	    %% Linear T.I. airplane model found in
	    % Izadi-Zamanabadi, R. (2002).
	    % Structural analysis approach to fault diagnosis with application to fixed-wing aircraft motion.
	    % Proceedings of the 2002 American Control Conference (IEEE Cat. No.CH37301), 5, 3949–3954. doi:10.1109/ACC.2002.1024546

	    % x1dot = a11 x1 + a13 x3 + a14 x4 + a16 x6
	    % x2dot = a21 x1 + a22 x2 + a23 x3 + a27 x7
	    % x3dot = a31 x1 + a33 x3 + a36 x6
	    % x4dot = x2
	    % x5dot = x3 + a55 x5
	    % x6dot = a66 x6 + b61 u1
	    % x7dot = a77 x7 + b72 u2
	    % y1 = x1
	    % y2 = x4
	    % y3 = x5
	    methods
	        function this = g007()
	            this.name = 'g007';
	            this.description = 'Linear T.I. airplane model found in "Structural analysis approach to fault diagnosis with application to fixed-wing aircraft motion"';

	            con = [...
	                {'dot_x1 x1 x3 x4 x6'};...
	                {'dot_x2 x2 x1 x3 x7'};...
	                {'dot_x3 x1 x3 x6'};...
	                {'dot_x4 x2'};...
	                {'dot_x5 x3 x5'};...
	                {'fault dot_x6 x6 inp u1'};...
	                {'fault dot_x7 x7 inp u2'};...
	                ];

	            der = [...
	                {'dot x1 int dot_x1'};...
	                {'dot x2 int dot_x2'};...
	                {'dot x3 int dot_x3'};...
	                {'dot x4 int dot_x4'};...
	                {'dot x5 int dot_x5'};...
	                {'dot x6 int dot_x6'};...
	                {'dot x7 int dot_x7'};...
	                ];

	            msr = [...
	                {'fault msr y1 x1'};...
	                {'fault msr y2 x4'};...
	                {'fault msr y3 x5'};...
	                ];

	            this.constraints = [...
	                {con},{'c'};...
	                {der},{'d'};...
	                {msr},{'s'};...
	                ];

	            this.coordinates = [];

	        end

	    end

	end
