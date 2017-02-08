function [ node ] = isMatched( argname, Graph, matching )
%ISMATCHED Check whether a variable or constrain is matched
%   returns a node type with children:
%       matched:    this node is part of the matching
%       index:      the index of the node, either in vars or constraints
%       type:       1=variable, 2=constraint
%       rank:       the rank of the node in the ranking algorithm matching
%       pairIndex:  the pair of the node for this matching
%       name:       the name string of the node

node.matched = false;
node.index = 0;
node.rank = nan;
node.type = nan;

varIndex = find(ismember(Graph.vars,argname));
conIndex = find(ismember(Graph.constraints,argname));
if ~isempty(varIndex)
    node.rank = matching.rankVar(varIndex);
    node.matched = node.rank~=inf;
    node.index = varIndex;
    node.type = 1;
    node.pairIndex = matching.edges(matching.edges(:,1)==varIndex,2);
    node.name = Graph.vars{node.index};
    assert(length(node.pairIndex)<=1,'Variable matched with more than one constraint!');
elseif ~isempty(conIndex)
    node.rank = matching.rankCon(conIndex);
    node.matched = node.rank~=inf;
    node.index = conIndex;
    node.type = 2;
    node.pairIndex = matching.edges(matching.edges(:,2)==conIndex,1);
%     disp(node.pairIndex);
%     disp(size(node.pairIndex));
    node.name = Graph.constraints{node.index};
    assert(length(node.pairIndex)<=1,'Constraint matched with more than one constraint!');
end

end

