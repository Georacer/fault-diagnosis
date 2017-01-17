function [ map ] = parseTree( argname, map, Graph, matching )
%PARSETREE Summary of this function goes here
%   Fills the map data structure which has members
%   varData = [varID, varRank]
%   conData = [conID, conRank]

verbose = false;

if isempty(map)
    map.varData = [];
    map.conData = [];
end

node = isMatched(argname,Graph,matching);
if verbose
    disp(sprintf('I am a node type %d, called %s, with rank %d',node.type, node.name, node.rank));
end
if node.type == 1 % This is a variable
    varData = [node.index node.rank];
    if isempty(map.varData) || (~isempty(map.varData) && ~ismember(node.index,map.varData(:,1))) % This variable has not been accessed yet; do so
        map.varData = [map.varData; varData]; % Add your data
        if node.rank>0 % If there is more below you
            if verbose
                disp(sprintf('Accessing constraint %s',Graph.constraints{node.pairIndex}));
            end
            map = parseTree(Graph.constraints{node.pairIndex}, map, Graph, matching); % Continue to matched constraint
        end
    else
        if verbose
            disp('Nothing to do here!');
        end
    end
elseif node.type == 2 % This is a constraint
    conData = [node.index node.rank];
    if isempty(map.conData) || (~isempty(map.conData) && ~ismember(node.index,map.conData(:,1))) % This constraint has not been accessed yet; do so
        map.conData = [map.conData; conData]; % Add your data
        relVarIDs = find(Graph.adjacency(node.index,:)); % and foor every relevant variable
        for i=1:length(relVarIDs)
            childNode = isMatched(Graph.vars{relVarIDs(i)},Graph,matching); % Find its data
            if childNode.rank <= node.rank % And if it is below you
                if verbose
                    disp(sprintf('Accessing variable %s',Graph.vars{childNode.index}));
                end
                map = parseTree(Graph.vars{childNode.index}, map, Graph, matching); % Continue onto it
            end
        end
    else
        if verbose
            disp('Nothing to do here!');
        end
    end
end

end

