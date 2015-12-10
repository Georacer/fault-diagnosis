function	[Ts Hs] = mexReturns(Times,Prices);
%This is a MatLab MEX function. It effectively computes price returns over the 1-Dimentional irregular (not equally spaced) time sequence.
%																										
%Receives:																							
%	Times		-	1D real vector	-	Times of the Series vector
%	Prices		-	1D real vector	-	The Prices to be processed.
%	dT			-	integer			-	the period over wich the returns are computed.
%
%	
% Returns:																								
%	Ts			-	1D real vector	-	(optional) Vector times of the returns
%	Returns		-	1D real vector	-	Returns
%																										
