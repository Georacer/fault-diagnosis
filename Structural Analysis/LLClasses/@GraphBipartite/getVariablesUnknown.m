function [ id ] = getVariablesUnknown( gh, id )
%GETVARIABLESUNKNOWN Return the uknown variables of a constraint
%   Detailed explanation goes here

id = gh.getVariables(id);

knownVars = zeros(size(id));
for index = 1:length(id)   
    if gh.isKnown(id(index))
        knownVars(index) = 1;
    end    
end

id(logical(knownVars)) = [];

end

