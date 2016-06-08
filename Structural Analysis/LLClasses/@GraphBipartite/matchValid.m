function [ M, exitcode] = matchValid( gh, equIds, varIds )
%MATCHVALID Summary of this function goes here
%   Detailed explanation goes here
% exitcode:  0 - No warning
%           -1 - Integral edge in path
%           -2 - Differential edge in closed lopp
%           -3 - No valid matching found in one of the KH components
%            1 - Integral edge in closed loop

% Get the corresponding adjacency matrix
[A, varIds, eqIndices, varIndices] = gh.getSubmodel(equIds);

assert(size(A,1)==size(A,2),'Provided model is not just-constrained');

% Get the K-H components
KH = gh.getKHComps(A, equIds, varIds);

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
        edgeIndex = gh.getIndexById(KHedges);
        if gh.edges(edgeIndex).isIntegral
%             fprintf('*** Failure: Found integral edge in OL component\n');
            exitcode = -1;
            M = {};
            break % It's impossible not to match this invalid edge
        end
%         fprintf('*** Adding a single edge\n');
        M(end+1) = {KHedges}; % Add the singular SCC to the matching
        
    else % Run Murty to deal with loops
        foundValid = false;
        Mmurty = gh.matchMurty(KH{i}.equIds,KH{i}.varIds); % Find all possible matchings in increasing cost
        
        % For every matching sequence
        for j=1:size(Mmurty,1)
            hasIntegral = false;
            hasDifferential = false;
            edgeIndices = gh.getIndexById(Mmurty(j,:));
            
            % Check if all edges comply to restrictions
            for k=1:length(edgeIndices)
                if gh.edges(edgeIndices(k)).isIntegral;
                    %                             fprintf('*** Note: Found integral edge in CL component\n');
                    hasIntegral = true;
                end
                if gh.edges(edgeIndices(k)).isDerivative;
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

end

