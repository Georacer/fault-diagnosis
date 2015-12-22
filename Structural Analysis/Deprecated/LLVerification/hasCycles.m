function [ resp, cycles ] = hasCycles( Graph )
%HASCYCLES Check is the graph has cycles
%   Detailed explanation goes here

[rows, cols] = getEdges(Graph);
E = [rows cols];
cycles = grCycleBasis(E);
if (isempty(cycles))
    resp = false;
else
    resp = true;
end

end

