function [ liusm ] = createLiusm( gh )
%CREATELIUSM Wrapper for the Li.U. DiagnosisModel constructor

model.type = 'MatrixStruc';

% Prepare unknown variable information
Xid = gh.getVarIdByProperty('isKnown',false);
Xindex = gh.getIndexById(Xid);
model.x = gh.reg.varAliasArray(Xindex);
V2E = logical(gh.adjacency.V2E); % Convert all weights to 1s
model.X = V2E(Xindex,:)';
diffId = gh.getEdgeIdByProperty('isDerivative');
for id=diffId
    edgeIndex = gh.getIndexById(id);
    equIndex = gh.getIndexById(gh.graph.edges(edgeIndex).equId);
    varIndex= gh.getIndexById(gh.graph.edges(edgeIndex).varId);
    model.X(equIndex,find(Xindex==varIndex)) = 3;
end
intId = gh.getEdgeIdByProperty('isIntegral');
for id=intId
    edgeIndex = gh.getIndexById(id);
    equIndex = gh.getIndexById(gh.graph.edges(edgeIndex).equId);
    varIndex= gh.getIndexById(gh.graph.edges(edgeIndex).varId);
    model.X(equIndex,find(Xindex==varIndex)) = 2;
end

% Prepare known variable information
Zid = gh.getVarIdByProperty('isKnown',true);
Zindex = gh.getIndexById(Zid);
model.z = gh.reg.varAliasArray(Zindex);
model.Z = gh.adjacency.V2E(Zindex,:)';

% Prepare fault information
Fid = gh.getEquIdByProperty('isFaultable',true);
Findex = gh.getIndexById(Fid);
model.f = cell(1,length(Fid));
model.F = zeros(gh.graph.numEqs,length(Fid));
i=1;
for ind=Findex
    model.f{i} = ['f' gh.reg.equAliasArray{ind}];
    model.F(ind,i) = 1;
    i = i+1;
end
if isempty(model.F)
    error('Called createLiusm without any faultable equation');
end

model.rels = cell(1,gh.graph.numEqs);
for i=1:gh.graph.numEqs
    varId = gh.getVariables(gh.graph.equations(i).id);
    varArray = gh.getAliasById(varId);
    if gh.getPropertyById(gh.graph.equations(i).id,'isFaultable');
        varArray = [varArray {sprintf('f%s',gh.reg.equAliasArray{i})}];
    end
    model.rels(i) = {varArray};
end

% size(model.X)
% model.X
% size(model.Z)
% model.Z
% size(model.F)
% model.F

liusm = DiagnosisModel(model);

% Override default equation name generator
liusm.e = gh.reg.equAliasArray;

liusm.name = gh.graph.name;

end

