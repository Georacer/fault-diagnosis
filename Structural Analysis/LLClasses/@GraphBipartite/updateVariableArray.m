function updateVariableArray(obj)
% Re-build the variableArray from the contents of equationArray
obj.constructing = true;
obj.variableArray = Variable.empty;
obj.variableAliasArray = cell(0,0);
for i=1:length(obj.equationArray) % For each equation
    for j=1:length(obj.equationArray(i).variableArray) % For each variable
        alias = obj.equationArray(i).variableArray(j).alias;
        index = find(strcmp(obj.variableAliasArray,alias));
        if isempty(index) % This variable is not stored yet
            obj.variableArray(end+1) = obj.equationArray(i).variableArray(j).copy(); % Modify variable objects only via their equation array
            obj.variableAliasArray{end+1} = alias;
            obj.variableIdArray(end+1) = obj.equationArray(i).variableArray(j).id;
            if obj.debug fprintf('GRA: Parsed new variable %s\n',alias); end
        else
            % We are not interested in merging is* properties.
            % This wouldn't make sense.
            if obj.debug fprintf('GRA: Already have variable %s stored\n',alias); end
        end
    end
end
obj.constructing = false;
if obj.debug fprintf('variableArray length = %d\n',length(obj.variableArray)); end;
end