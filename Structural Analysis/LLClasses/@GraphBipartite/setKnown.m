function setKnown( obj, id )
%SETKNOWN Set a variable property known to true
%   Detailed explanation goes here

    for i=1:obj.numEqs
        index = find(obj.equationArray(i).variableIdArray == id);
        if ~isempty(index)
            for j=index
                obj.equationArray(i).variableArray(j).isKnown = true;
            end
        else
            error('No variable with id %d found',id);
        end
    end

end

