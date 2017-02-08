function [ Mvalid ] = matchValid( matcher )
%MATCHVALID Find valid residuals in provided MSO
%   Detailed explanation goes here

debug = false;
% debug = true;

gi = matcher.gi;
numEqs = gi.graph.numEqs;

% Initialize valid matchings container
Mvalid = [];

% Loop over available just-constrained submodels
M0weights = ones(1,numEqs)*inf;
M0pool = cell(1,numEqs);

for i=1:numEqs
    
    if debug fprintf('*** Examining new M0\n'); end
    
    % Choose the equations of the M0 submodel
    equIdsJust = gi.reg.equIdArray(setdiff(1:numEqs,i));
    if debug fprintf('with equation ids: ');  fprintf('%d, ',equIdsJust); fprintf('\n'); end
    aliases = gi.getAliasById(equIdsJust);
    if debug fprintf('and aliases: ');  fprintf('%s, ',aliases{:}); fprintf('\n'); end
    
    % Create a temporary M0 submodel
    tempGI = copy(gi);
    tempSG = SubgraphGenerator(tempGI);
    tempGI = tempSG.buildSubgraph(equIdsJust,'postfix','temp');
    
    % Check if all equations can be matched to at least one variable
    A = tempGI.adjacency.E2V;
    if ~all(sum(A,2))
        if debug warning('Tried to match a non-square system'); end
        Mcurr = [];
    else
        tempMatcher = Matcher(tempGI);
        Mcurr = tempMatcher.match('ValidJust');
        % Keep only the cheapest matching
        if ~isempty(Mcurr)
            Mcurr = Mcurr(1,:);
        end
    end
    
    % Count matching length
    counter = length(Mcurr);
    
    % TODO: compare weights from all MCurrs
    if counter==length(equIdsJust)
        if debug fprintf('A valid matching for that M0 is (edgeIds): ');  fprintf('%d, ',Mcurr(:)); fprintf('\n'); end
        M0pool(i) = {Mcurr};
        M0weights(i) = sum(gi.getEdgeWeight(Mcurr));
        
        %             % Select for existence of integral edge
        %             edgeIndices = graph.getIndexById(scc);
        %             foundIntegralEdge = false;
        %             for j=edgeIndices
        %                 if graph.edges(j).isIntegral
        %                     foundIntegralEdge = true;
        %                     fprintf('Found integral edge!\n');
        %                     break;
        %                 end
        %             end        
        
    elseif counter>0
        if debug fprintf('Only partial matching found\n'); end
    else
        if debug fprintf('No valid matching found\n'); end
    end
end

if any(isfinite(M0weights)) %Process matching of this MS0    
    % Search for cheapest matching weight
    [~, pivot] = sort(M0weights);
    i = pivot(1);
    Mvalid = M0pool{i};
    
    if debug fprintf('The selected matching for this MSO is (edgeIds): ');  fprintf('%d, ',Mvalid); fprintf('\nPlease extend with a residual\n'); end
else
    warning('No valid matching could be found for this MSO\n');
end



end

