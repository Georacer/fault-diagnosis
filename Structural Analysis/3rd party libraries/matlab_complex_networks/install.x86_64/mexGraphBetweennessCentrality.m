function [Betweenness, NodeIDs]= mexGraphBetweennessCentrality(Graph, Direction, ShowProgress)
% Efficiently computes betweenness centrality of all nodes of graph.
%
% Receives:
%   Graph       -   struct      -   Graph, created with GraphLoad
%   Direction   -   string      -   (optional) The way the passes are followed: 'direct','inverse' or 'both'. Default: 'direct' 
%   ShowProgress-   boolean     -   (optional) Since the execution time may be very long, this option will cause the mex-file
%                                   to produce output in the MatLab prompt that update the user on the computation progress 
%                                   and execution time forecast.
%
% Returns:
%   Betweenness -   array of double     -   Computed betweenness of each node
%   NodeIDs     -   array of integers   -   (optional) List of node IDs. 
%
% Algorithm:
%   http://www.inf.uni-konstanz.de/algo/publications/b-fabc-01.pdf an  algorithm which devoloped by Ulrik brands
%
%
% Example:
%	[BetweennessCentrality, Nodes] = mexGraphBetweennessCentrality(Graph,'inverse');
%
%
% See Also:
%       mexGraphSqueeze
%
% Created:
% by inspiration of graph tool box which created Lev Muchnik 
% Royi Itzhak - Bar Ilan University ,Isreal
% royi.its@gmail.com
%
% Major Update:
%   Code optimization and other improvements case 40-60% reduction in overall computation time.

