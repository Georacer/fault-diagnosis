function setRank( obj, id, rank )
%SETKNOWN Set a variable property known to true
%   Detailed explanation goes here

    % Search for item id in equations
    index = find(obj.equationIdArray == id);
    if length(index)>1
        error('More than one equation with id %d found',id);
    end
    if ~isempty(index)
        obj.equationArray(index).rank = rank;
    else % Otherwise look it up in the variables
        found = false;
        for i=1:obj.numEqs
            index = find(obj.equationArray(i).variableIdArray == id);
            for j=index
                found = true;
                obj.equationArray(i).variableArray(j).rank = true;
            end
        end
        if ~found
            error('Variable with id %d not found',id);
        end
    end
end

