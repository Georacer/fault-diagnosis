function [ signatures, generator_id ] = getResidualSignatures( this )
%GETRESIDUALSIGNATURES Return the residual signatures array
%   Detailed explanation goes here

debug = true;

% Lookup the number of residual generators
generator_id = this.getEqIdByProperty('isResGenerator');

if ~isempty(generator_id)
    signatures = zeros(length(generator_id),this.numEqs); % Initialize the signature array
    
    for i=1:length(generator_id)
        id = generator_id(i);
        affectingIds = [id this.getAncestorEqs(id)];
        if debug
            fprintf('Equations affecting signature %d: ',i);
            for j=1:length(affectingIds)
            fprintf('%s, ',this.getAliasById(affectingIds(j)));
            end
            fprintf('\n');
        end
        eqIndices = this.getEqIndexById(affectingIds);
        signatures(i, eqIndices) = 1;        
    end
    
else
    signatures = [];
    fprintf('No residual generators are found in this graph\n');
end

end

