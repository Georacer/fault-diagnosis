function matchRanking( gh )
%MATCHRANKING Summary of this function goes here
%   Detailed explanation goes here

debug = true;

residualIdArray = [];

% Set the rank of known variables to 0
varId=gh.getVarIdByProperty('isKnown');
gh.setRank(varId,0);

k=1; % Set starting rank
numMatchedVars = length(varId);
numMatchedEqs = 0;

varId = gh.getVarIdByProperty('rank',inf);
equId = gh.getEquIdByProperty('rank',inf);
unmatchedObjIds = [varId equId];
while ~isempty(unmatchedObjIds) % While there are unmatched variables or constraints
    noChange = true;
    fprintf('Rank %d: Matched Variables:%d/%d, Constraints:%d/%d\n', k,numMatchedVars,gh.numVars,numMatchedEqs,gh.numEqs );
    
    % For each unmatched constraint
    for eqId=gh.getEquIdByProperty('rank',inf)
        eqIndex = gh.getIndexById(eqId);
        if debug fprintf('Examining equation %s: ',gh.equationAliasArray{eqIndex}); end
        
        % Find its unmatched variables
        varId1 = gh.getVariables(eqId);
        varId2 = gh.getVarIdByProperty('rank',inf);
        varId = intersect(varId1, varId2);
        if debug fprintf('it has %d unmatched variable(s)',length(varId)); end
        
        % Does this equation have only one unmatched variable?
        booltest1 = length(varId) == 1;
        
        % If yes, can it be solved for?
        if booltest1
            edgeId = gh.getEdgeIdByVertices(eqId,varId);
            booltest2 = gh.isMatchable(edgeId);
        end
        
        % Furthermore, can it be calculated by variables known in the
        % previous rank?
        booltest3 = false;
        if booltest1 && booltest2
            booltest3 = true;
            otherVarIds = setdiff(varId1, varId);
            for i=otherVarIds
                if debug fprintf('%s/%d, ',gh.getAliasById(i),gh.getPropertyById(i,'rank')); end
                if gh.getPropertyById(i,'rank') == k
                    booltest3 = false;
                end
            end
            if debug fprintf(') '); end
        end
            
        if booltest1
            if booltest2
                noChange = false;
                if booltest3
                    if debug fprintf(', which can be solved for now.\n'); end
                    % Match this constraint
                    gh.setRank(eqId,k);
                    numMatchedEqs = numMatchedEqs + 1;
                    gh.equations(eqIndex).isMatched = true;
                    gh.equations(eqIndex).matchedTo = varId;
                    % ... and the variable
                    varIndex = gh.getIndexById(varId);
                    gh.variables(varIndex).isMatched = true;
                    gh.setRank(varId,k);
                    gh.setKnown(varId);
                    gh.variables(varIndex).matchedTo = eqId;
                    numMatchedVars = numMatchedVars + 1;
                    % ... and the edge
                    edgeId = gh.getEdgeIdByVertices(eqId,varId);
                    edgeIndex = gh.getIndexById(edgeId);
                    gh.edges(edgeIndex).isMatched = true;
                else
                    if debug fprintf(', but it will be available in the next rank.\n'); end
                end
            else
                if debug fprintf(', but it cannot be solved for\n'); end
            end
        else
            if debug fprintf('.\n'); end
        end
        
    end
    
    % Look for residual generators
    % For each unmatched equation
    for eqId=gh.getEquIdByProperty('rank',inf)
        eqIndex = gh.getIndexById(eqId);
        % Find its unmatched variables
        varId1 = gh.getVariables(eqId);
        varId2 = gh.getVarIdByProperty('rank',inf);
        varId = intersect(varId1, varId2);
        
        % Does this equation have no unmatched variables?
        booltest1 = isempty(varId);
        
        % Furthermore, can it be calculated by variables known in the
        % previous rank?
        booltest2 = false;
        if booltest1
            booltest2 = true;
            for i=varId1
                if (gh.getPropertyById(i,'rank') == k)
                    booltest2=false;
                end
            end
        end        
        
        if booltest1 && booltest2 % Find those with all their variables matched in the previous rank
            if debug fprintf('Assigning a residual to equation %s\n',gh.equationAliasArray{eqIndex}); end
            gh.setRank(eqId,k); % assign this constraint as matched in this rank
            gh.equations(eqIndex).isMatched = true;
            numMatchedEqs = numMatchedEqs + 1;
            residualIdArray(end+1) = eqId; % And assign a residual generator onto them
            gh.equations(eqIndex).isResGenerator = true;
            gh.addResidual(eqId);
        end
        
    end

    if noChange % Did anything new happen in this loop?
        disp(sprintf('Nothing new in rank %d',k));
        break;
    end
    
    k = k+1;
    
    varId = gh.getVarIdByProperty('rank',inf);
    equId = gh.getEquIdByProperty('rank',inf);
    unmatchedObjIds = [varId equId];

end

%% Check matching characteristics

matchedEqs = length(gh.getEquIdByProperty('rank',inf,'~='));

matchedVars = length(gh.getVarIdByProperty('rank',inf,'~='));

numResiduals = length(residualIdArray);

fprintf('Matching results:\n');
fprintf('%d/%d variables matched\n',matchedVars,gh.numVars);
fprintf('%d residuals generated\n',numResiduals);
fprintf('%d equations used\n',matchedEqs);


end

