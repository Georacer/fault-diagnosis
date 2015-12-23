function [ id ] = getIdByProperty(this,property,value,operator)
%GETIDBYPROPERTY Return an ID array with thisects with requested property
%   This applies and searches both equations and variables

if nargin<3
    value = true;
end
if nargin<4
    operator = '==';
end

id = [];

for i = 1:this.numEqs
    if isprop(this.equationArray(i),property)
        switch operator
            case '=='
                if (this.equationArray(i).(property) == value)
                    id(end+1) = this.equationArray(i).id;
                end
            case '<'
                if (this.equationArray(i).(property) < value)
                    id(end+1) = this.equationArray(i).id;
                end
            case '>'
                if (this.equationArray(i).(property) > value)
                    id(end+1) = this.equationArray(i).id;
                end
            case '<='
                if (this.equationArray(i).(property) <= value)
                    id(end+1) = this.equationArray(i).id;
                end
            case '>='
                if (this.equationArray(i).(property) >= value)
                    id(end+1) = this.equationArray(i).id;
                end
            case '~='
                if (this.equationArray(i).(property) ~= value)
                    id(end+1) = this.equationArray(i).id;
                end
            otherwise
                error('Unsupported operator %s\n',operator);
        end
        
    end
    varIds = this.equationArray(i).getIdByProperty(property,value,operator);
    if ~isempty(varIds)
        id = [id varIds];
    end
    
end

id = unique(id);

end