function [ M, exitcode] = matchValidJust( matcher )
%MATCHVALID Summary of this function goes here
% Assumes that there exists at least one matching which takes into account
% the non-invertibilities (i.e. The E2V adjacency graph is a square system)
% exitcode:  0 - No warning
%           -1 - Integral edge in path
%           -2 - Differential edge in closed lopp
%           -3 - No valid matching found in one of the KH components
%            1 - Integral edge in closed loop

debug = false;
% debug = true;

max_num_matchings = 1e1;

gi = matcher.gi;

binary_blob = getByteStreamFromArray(gi);

% % Get the corresponding adjacency matrices
% [AV2E, varIds, eqIndices, varIndices] = gi.getSubmodel(equIds,'direction','V2E');
% [AE2V, varIds, eqIndices, varIndices] = gi.getSubmodel(equIds,'direction','E2V');

AE2V = gi.adjacency.E2V;
AV2E = gi.adjacency.V2E;

assert(size(AE2V,1)==size(AE2V,2),'Provided model is not just-constrained');

% Get the K-H components
equIds = gi.reg.equIdArray;
varIds = gi.reg.varIdArray;
KH = getKHComps(gi, AV2E', equIds, varIds);

% sort K-H blocks to deal with singular ones first
KHsizes = zeros(1,length(KH));
for i=1:length(KH)
    KHsizes(i) = length(KH{i}.equIds);
end
[~,pivot] = sort(KHsizes);

M = {};
exitcode = 0;

% For each K-H
for i=pivot
    KHedges = KH{i}.edgegroup;
    
    % if |K-H|=1
    if length(KHedges)==1
        edgeIndex = gi.getIndexById(KHedges);
        if ~gi.isMatchable(KHedges)
            if debug fprintf('matchValid: Failure: Found non-invertible edge in path\n'); end
            exitcode = -3;
            M = {};
            break % It's impossible not to match this invalid edge
        elseif gi.isIntegral(KHedges)
            if debug fprintf('matchValid: Failure: Found integral edge in path\n'); end
            exitcode = -1;
            M = {};
            break % It's impossible not to match this integral edge
        end
%         fprintf('*** Adding a single edge\n');
        M(end+1) = {KHedges}; % Add the singular SCC to the matching
        
    else % Run Murty to deal with loops
        foundValid = false;
        
        % Create temporary graph for Murty matching
        currEquIds = KH{i}.equIds;
        currVarIds = KH{i}.varIds;
%         tempGI = copy(gi);
        tempSG = SubgraphGenerator(gi, binary_blob);
        tempGI = tempSG.buildSubgraph(currEquIds, currVarIds,'postfix','temp');
        tempMatcher = Matcher(tempGI);
        Mmurty = tempMatcher.match('Murty', max_num_matchings); % Find all possible matchings in increasing cost
        
        % For every matching sequence
        for j=1:size(Mmurty,1)
            hasIntegral = false;
            hasDifferential = false;
            edgeIds = Mmurty(j,:);
            
            % Check if all edges comply to restrictions
            for k=1:length(edgeIds)
                if tempGI.isIntegral(edgeIds(k))
                    %                             fprintf('*** Note: Found integral edge in CL component\n');
                    hasIntegral = true;
                end
                if tempGI.isDerivative(edgeIds(k))
                    %                             fprintf('*** Failure: Found differential edge in CL component\n');
                    hasDifferential = true;
                    break % This matching candidate is invalid, it includes a differential edge
                end
            end
            
            if ~hasDifferential % Found the first valid matching
%                 fprintf('*** Adding multiple edges\n');
                M(end+1) = {Mmurty(j,:)};
                foundValid = true;
                if hasIntegral
                    exitcode = 1;
                end
                break
            end
        end
        
        % Murty found no matching without a differential edge
        if hasDifferential
            exitcode = -2;
            M = {};
            return
        end
        % If Murty found no valid matching in this KH component
        if ~foundValid
            exitcode = -3;
            M = {};
            return
        end
    end
end

% Flatten the cell array
M = cell2mat(M);

% Verify matching dimension
if ~isequal(size(M),[1, gi.graph.numEqs]) && debug; warning('Non complete matching found'); end
if debug; fprintf('Edgelist: '); fprintf('%d, ',M); fprintf('\n'); end

end

