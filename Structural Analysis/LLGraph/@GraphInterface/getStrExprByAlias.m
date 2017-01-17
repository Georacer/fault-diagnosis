function [ expr ] = getStrExprByAlias( gh, alias )
%GETSTREXPRBYALIAS Returns the str. expression of input alias
%   Detailed explanation goes here

equIndex = find(strcmp(gh.equationAliasArray,alias));
expr = gh.equations(equIndex).expressionStructural;

end

