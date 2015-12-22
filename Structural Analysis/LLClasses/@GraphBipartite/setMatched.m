function setMatched( obj, id )
%SETKNOWN Set a variable property known to true
%   Detailed explanation goes here

    for i=1:obj.numEqs
        index = find(obj.equationArray(i).variableIdArray == id);
        if ~isempty(index)
            for j=index
                obj.equationArray(i).variableArray(j).isMatched = true;
            end
        else
            error('No variable with id %d found',id);
        end
    end

end

