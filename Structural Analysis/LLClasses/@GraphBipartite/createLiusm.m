function [ liusm ] = createLiusm( gh )
%CREATELIUSM Wrapper for the Li.U. DiagnosisModel constructor

model.type = 'MatrixStruc';

% Prepare unknown variable information
Xid = gh.getVarIdByProperty('isKnown',false);
Xindex = gh.getIndexById(Xid);
model.x = gh.variableAliasArray(Xindex);
V2E = logical(gh.adjacency.V2E); % Convert all weights to 1s
model.X = V2E(Xindex,:)';
diffId = gh.getEdgeIdByProperty('isDerivative');
for id=diffId
    edgeIndex = gh.getIndexById(id);
    equIndex = gh.getIndexById(gh.edges(edgeIndex).equId);
    varIndex= gh.getIndexById(gh.edges(edgeIndex).varId);
    model.X(equIndex,find(Xindex==varIndex)) = 3;
end
intId = gh.getEdgeIdByProperty('isIntegral');
for id=intId
    edgeIndex = gh.getIndexById(id);
    equIndex = gh.getIndexById(gh.edges(edgeIndex).equId);
    varIndex= gh.getIndexById(gh.edges(edgeIndex).varId);
    model.X(equIndex,find(Xindex==varIndex)) = 2;
end

% Prepare known variable information
Zid = gh.getVarIdByProperty('isKnown',true);
Zindex = gh.getIndexById(Zid);
model.z = gh.variableAliasArray(Zindex);
model.Z = gh.adjacency.V2E(Zindex,:)';

% Prepare fault information
Fid = gh.getEquIdByProperty('isFaultable',true);
Findex = gh.getIndexById(Fid);
model.f = cell(1,length(Fid));
model.F = zeros(gh.numEqs,length(Fid));
i=1;
for ind=Findex
    model.f{i} = ['f' gh.equationAliasArray{ind}];
    model.F(ind,i) = 1;
    i = i+1;
end

model.rels = cell(1,gh.numEqs);
for i=1:gh.numEqs
    varId = gh.getVariables(gh.equations(i).id);
    varArray = gh.getAliasById(varId);
    if gh.getPropertyById(gh.equations(i).id,'isFaultable');
        varArray = [varArray {sprintf('f%s',gh.equationAliasArray{i})}];
    end
    model.rels(i) = {varArray};
end

% size(model.X)
% model.X
% size(model.Z)
% model.Z
% size(model.F)
% model.F

gh.liusm = DiagnosisModel(model);

% Override default equation name generator
gh.liusm.e = gh.equationAliasArray;

gh.liusm.name = gh.name;

end

