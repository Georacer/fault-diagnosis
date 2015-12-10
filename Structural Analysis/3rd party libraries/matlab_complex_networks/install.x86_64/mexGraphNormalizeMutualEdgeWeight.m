function C = mexGraphNormalizeMutualEdgeWeight(Graph,Nodes,Direction)
% Remarks:
% - The function does not assume that nodes are adjusted (no missing nodes) or even sorted (=>performance penalty)
% - The function oerates on weights.
% -
% computes normalized weights based on the deffinition of normalizedMutualEdgeWeight at http://jung.sourceforge.net/doc/api/edu/uci/ics/jung/algorithms/metrics/StructuralHoles.html#normalizedMutualEdgeWeight(V, V)
% 
%
% Receives:	
%	Graph		-	Graph Struct	-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%
% Returns: 
% Graph		-	Graph Struct	-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%
% See Also:
%	ObjectCreateGraph , GraphLoad, EvaluateGraphConstraint
%																										
