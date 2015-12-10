function Boxes = mexGraphBoxCounting(Graph, MaxDistance, ShowProgress)
% Computes number of boxes, their sizes and (optionaly) their content according to box counting algorithm.
%
% Receives:
%   Graph			-   struct					-   Graph, created with GraphLoad
%	MaxDistance		-	integer, <=255			-	(optional) The maximal distance between box elements. Should not exceed (2^8-1) and must be positive.
%													Graph covering with boxes at up to thise distance is returned. Default: [] - returns all distances 
%													at which more then one box is required to cover the graph. Number of returned distancies will not
%													exceed 255.
%   ShowProgress	-   scalar, boolean			-   (optional) Since the execution time may be very long, this option will cause the mex-file
%													to produce output in the MatLab prompt that update the user on the computation progress 
%													and execution time forecast. Default: false (0)
%
% Returns:
%	Boxes			-	array of structs		-	For each distance, a struct is created which contains box covering details for that distance.
%			.Distance		-	integer				-	the maximal distance for the current list of boxes
%			.NumberOfBoxes	-	integer				-	number of boxes, required to cover the graph at this distance
%			.BoxSizes		-	vector of integers	-	vector of the (size .NumberOfBoxes), containing number of elements in each box. 
% BoxSize	-	vector of integer				-	(optional) number of boxes at each distance
%
% Algorithm:
%	"Self-similarity of complex networks", Chaoming Song, Shlomo Havlin & Herna'n A. Makse.
%	Nature 433, 392-395 (27 January 2005)
%	http://www.nature.com/nature/journal/v433/n7024/pdf/nature03248.pdf
%	
%
% Example:
%
%
%
% See Also:
%	 GraphLoad
%
