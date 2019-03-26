function [ SA_results ] = deleteInvalidMatchings(SA_results, valid_pso_array)
%DELETEINVALIDMATCHINGS Delete those matchings which are not valid
%   Detailed explanation goes here

for subgraph_idx=1 % TODO when valid_pso_array will gain another dimension for spanning multiple disconnected subgraphs, then this will activate
    
    for pso_idx = 1:length(valid_pso_array) % for each PSO
        
        if ~valid_pso_array(pso_idx) % if matching is not valid
            SA_results.matchings_set{subgraph_idx}(pso_idx) = {[]}; % Delete the matching
        end
        
    end
    
end

end

