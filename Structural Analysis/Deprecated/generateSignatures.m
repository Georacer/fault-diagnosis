function [ signatures2, FSM ] = generateSignatures( graphMTES, graphOver, graphUndir, Mvalid, signatures, generator_id )
%GENERATESIGNATURES Generate signatures given residual generator
%   Detailed explanation goes here

MvalidFlat = cell(size(Mvalid));
for i=1:length(Mvalid)
    MvalidFlat{i}{1} = graphMTES.equationIdArray(Mvalid{i}{1});
    KHcomp = Mvalid{i}{2:end};
    scc = [];
    for j=1:length(KHcomp)
        scc = [scc KHcomp{j}];
    end
    MvalidFlat{i}{2} = scc;
end

signatures2 = cell(length(Mvalid)+length(generator_id),4); % Matching weight is the 3rd column, matching is 4th column

for i=1:size(signatures,1)
    affectingEqs = graphOver.equationIdArray(logical(signatures(i,:)));
    signatures2(i,1) = {generator_id(i)};
    signatures2(i,2) = {affectingEqs};
    matchingEqs = setdiff(affectingEqs,generator_id(i));
    eqIndices = graphOver.getIndexById(matchingEqs);
    matching = [];
    matchingWeight = 1; % Initial residual evaluation cost
    for j=1:length(eqIndices)
        varId = graphOver.equations(eqIndices(j)).matchedTo;
        edgeId = graphOver.getEdgeIdByVertices(matchingEqs(j),varId);
        matching(end+1) = edgeId;
        matchingWeight = matchingWeight + graphOver.getEdgeWeight(edgeId);
    end
    signatures2(i,3) = {matchingWeight};
    signatures2(i,4) = {matching};
end

for i=1:length(Mvalid)
    clear graphNew
    graphNew = graphUndir.copy();
    graphNew.applyMatching(MvalidFlat{i}{2});
    resGenId = MvalidFlat{i}{1};
    [affectingEqs, matching] = graphNew.getAncestorEqs(resGenId);
    affectingEqs = [resGenId affectingEqs];
    signatures2{i+length(generator_id),1} = resGenId;
    signatures2{i+length(generator_id),2} = affectingEqs;
    matchingWeight = sum(graphNew.getEdgeWeight(matching)) + 1;
%     matchingWeight = sum(graphOver.getEdgeWeight(MvalidFlat{i}{2})) + 1;
    signatures2{i+length(generator_id),3} = matchingWeight;
    signatures2{i+length(generator_id),4} = matching;
end

% Check if any Mvalid has an integral edge
integralEdges=[];
for i=1:length(MvalidFlat)
    edges = MvalidFlat{i}{2};
    for j=1:length(edges)
        if graphOver.edges(graphOver.getIndexById(edges(j))).isIntegral
            integralEdges(end+1,:)=[j,edges(j)];
        end
    end
end

% Convert to proper signature table

% clc

if isempty(signatures2)
    fprintf('No residuals could be found in the system - Finish\n');
    return;
end

FSM = zeros(size(signatures2,1),graphOver.numEqs);

for i=1:size(FSM,1)
    FSM(i,graphOver.equationIdToIndexArray(signatures2{i,2}))=1;
end

end

