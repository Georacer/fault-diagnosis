function [ list ] = createCostList( gh, zeroWeight )
%CREATECOSTLIST Creat a cost list for all edges
%   Detailed explanation goes here

if nargin<2
    zeroWeight = false;
end

% Initialize list: eqname, varname, weight
list = cell(gh.numEdges,5);

for i=1:gh.numEdges
   list{i,1} = gh.edges(i).equId;
   list{i,2} = gh.edges(i).varId;
   list{i,3} = gh.getAliasById(gh.edges(i).equId);
   list{i,4} = gh.getAliasById(gh.edges(i).varId);
   if zeroWeight
       list{i,5} = 0;
   else
       list{i,5} = gh.edges(i).weight;
   end
end


end

