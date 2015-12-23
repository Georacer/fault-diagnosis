function setKnown( this, id, value )
%SETKNOWN Set a variable property known to true
%   Detailed explanation goes here

if nargin<3
    value = true;
end

% Set property in variableArray
index = this.getVarIndexById(id);
if ~isempty(id)
    this.variableArray(index).isKnown = value;
else
    error('Variable with id %d not found',id);
end

% Search for item id in equationArray
found = false;
for i=1:this.numEqs
    index = find(this.equationArray(i).variableIdArray == id);
    for j=index
        found = true;
        this.equationArray(i).variableArray(j).isKnown = value;
    end
end
if ~found
    error('Variable with id %d not found',id);
end

end

