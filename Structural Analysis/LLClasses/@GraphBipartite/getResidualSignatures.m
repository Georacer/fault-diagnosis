function [ signatures, generator_id ] = getResidualSignatures( gh )
%GETRESIDUALSIGNATURES Return the residual signatures array
%   Detailed explanation goes here

debug = true;

% Lookup the number of residual generators
generator_id = gh.getEquIdByProperty('isResGenerator');

if ~isempty(generator_id)
    signatures = zeros(length(generator_id),gh.numEqs); % Initialize the signature array
    
    for i=1:length(generator_id)
        id = generator_id(i);
        affectingIds = [id gh.getAncestorEqs(id)];
        if debug
            fprintf('getResidualSignatures: Equations affecting signature %d: ',i);
            for j=1:length(affectingIds)
                alias = gh.getAliasById(affectingIds(j));
            fprintf('%s, ', alias{:});
            end
            fprintf('\n');
        end
        eqIndices = gh.getIndexById(affectingIds);
        signatures(i, eqIndices) = 1;        
    end
    
else
    signatures = [];
    fprintf('getResidualSignatures: No residual generators are found in gh graph\n');
end

end

