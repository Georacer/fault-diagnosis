function [ matching ] = matchingRanking( Graph )
%MATCHINGRANKING Matching of a graph using ranking of constraints
%   As presented in the book "Diagnosis and Fault Tolerant Control" by
%   Blanke, Kinnaert, Lunze, Staroswiecki, p142.

 % Set valid causality to follow during matching. Valid entries are the
 % value of variable 'mark' in file 'lineParser.m'. Some valid optiosn are
 % 1=char(49), D=char(68)...
causality = [49];
% causality = [49 68];

numVars = length(Graph.vars);
rankVar = inf*ones(1,numVars);
numCons = size(Graph.adjacency,1)-numVars;
if numCons~=length(Graph.constraints)
    error('!!! Error in matrix dimensions');
end
rankCon = inf*ones(1,numCons);
residuals = zeros(1,size(Graph.constraints,2));
adjacency = Graph.adjacency;
m = 1;

k=0;
% knownIndices = find(ismember(Graph.vars,Graph.knownVars)); % Mark measurend/input variables as rank 0
rankVar(Graph.isInput==1) = 0;

while ((max(rankVar) == inf) && (max(rankCon) == inf)) % While there are unmatched variables
    disp(sprintf('Matched Variables:%d/%d, Constraints:%d/%d', nnz(find(rankVar~=inf)),length(rankVar),nnz(find(rankCon~=inf)),length(rankVar) ));
    rankVarPrev = rankVar;
    rankConPrev = rankCon;
    
    for i=find(rankCon==inf); % Among the unmatched constraints
%         varMask = ismember(Graph.adjacency(i,:),causality);
        % Find those with only 1 unmatched variable UP TO THIS rank:
        % Find those who have unmatched variables
        unmatchedVars = find(rankVarPrev.* (adjacency(numVars+i,1:numVars)|(Graph.adjacency(1:numVars,numVars+i))') ==inf);
%         disp(sprintf('Rank %d: I am at equation %s which has %d unmatched variables',k, Graph.constraints{i},length(unmatchedVars)));
        % if we found only one unmatched variable for this constraint
        booltest = (length(unmatchedVars)==1)...
            && adjacency(numVars+i,unmatchedVars(1))~=0 ... %... % and this one can be solved for
            && rankVar(unmatchedVars(1,1))==inf; % and this variable has not been matched by another constraint in this rank
        if booltest 
            rankCon(i)=k; % Match this constrain
            rankVar(unmatchedVars)=k+1; % And the variable
            edges(m,1) = unmatchedVars; % and update the matching edge record
            edges(m,2) = i;
            m = m+1;
        end
    end

    if k==0 % Run once to catch rank0 residuals
        tempCon = find(rankCon==inf); % For all the unmatched constraints
        for i = tempCon
            relVars = find(rankVarPrev.*Graph.adjacency(1:numVars,numVars+i)'==inf); 
            if size(relVars,2)==0 % Find those with all their variables matched
                rankCon(i)=k; % assign this constraint as matched in the next rank
                residuals(i)=1; % And assign a residual generator onto them
            end
        end
        
    end
    
    tempCon = find(rankCon==inf); % For all the unmatched constraints
    for i = tempCon
        relVars = find(rankVar.*Graph.adjacency(1:numVars,numVars+i)'==inf);
        if size(relVars,2)==0 % Find those with all their variables matched
            rankCon(i)=k+1; % assign this constraint as matched in the next rank
            residuals(i)=1; % And assign a residual generator onto them
        end
    end
    k=k+1;
    if (isequal(rankConPrev,rankCon) && isequal(rankVarPrev,rankVar)) % Did anything new happen in this loop?
        disp(sprintf('Nothing new in rank %d',k));
        break;
    end
end
disp(sprintf('Matched Variables:%d/%d, Constraints:%d/%d', nnz(find(rankVar~=inf)),length(rankVar),nnz(find(rankCon~=inf)),length(rankCon) ));

matching.rankVar = rankVar;
matching.rankCon = rankCon;
matching.residuals = residuals;
matching.edges = edges;

%% Check matching characteristics

% Check for just-, over-, under- constraining
if (size(edges,1)==length(Graph.constraints)) && (size(edges,1)==length(find(Graph.isInput==0)))
    disp('*The graph is just-constrained');
elseif size(edges,1)==length(Graph.constraints)
    disp('*The graph is under-constrained');
elseif size(edges,1)==length(find(Graph.isInput==0))
    disp('*The graph is over-constrained');
else
    disp('*Cannot decide on constraining type!');
end

% Check for structural observability
if size(edges,1)==length(find(Graph.isInput==0))
    disp('*The graph is structurally observable');
else
    disp('*The graph is NOT structurally observable');
end

%% Investigate residual signatures

sig = [];
if sum(residuals)>0
    sig = zeros(sum(residuals),numCons);
    k = 1;
    oldSig = sig(1,:);

% Initialize the residual signature vectors
    seedVect = find(residuals);
    for i=1:sum(residuals)
        sig(i,seedVect(i))=1;
    end
    for k=1:sum(residuals)
            % for each residual
            while ~isequal(oldSig,sig(k,:)); 
                oldSig = sig(k,:); % update comparison vector
                conInd = find(sig(k,:)); % find all the affected constraints
                % find all related variables
                varVect = zeros(1,numVars); 
                for j = conInd
                    varInd = find(adjacency(j,:));
                    varVect(varInd)=1;
                end
                % for each variable find matched constraints
                for varInd=find(varVect) 
                    consIndex = find(edges(:,1)==varInd);
                    sig(k,edges(consIndex,2)) = 1;
                end
            end

            oldSig = zeros(1,numCons);
            k = k+1;
    end

else
    disp('No residuals available');

end
matching.signatures = sig;
%% Plot the ranking matching graph
% adjacencyCut = Graph.adjacency(numVars+1:end,1:numVars) | (Graph.adjacency(1:numVars,numVars+1:end))';
% size(adjacencyCut)
% Graph.adjacency = adjacencyCut;
% matchingPlot(Graph,residuals,rankVar,rankCon);

end