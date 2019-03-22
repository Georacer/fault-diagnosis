function [ results ] = parseEdgeMask( vertex_ids, edge_list, edge_mask )
%PARSEEDGEMASK Read a set of edges and return the sequence of vertices which they cover
%   Given a graph defined by the edge_list and whose vertices have ids vertex_ids, the function is give an edge_mask.
%   The columns of the edge_mask mark which edges from the edge_list belong to a sequence. This function orders the
%   sequence by order of vertex appearance and returns the pivot vector for the edge list and the sorted vertices.
% INPUTS:
%       vertex_ids: a 1 x |V| vector of vertex IDs
%       edge_list: a |E| x 2 array, representing the edge list
%       edge_mask: a |E| x N array, containing N columns selecting from the |E| edges
% OUTPUT:
%       

% Sanitize input
if size(edge_list,1) ~= size(edge_mask,1)
    error('height of edge_list does not agree with edge_mask');
end

% Initialize output
results = {};

% Iterate over each sequence
for i=1:size(edge_mask,2)
    edges = edge_list(logical(edge_mask(:,i)),:);
    sequence = zeros(1,sum(edge_mask(:,i)));
    seq_idx = 1;
    
    while any(edges(:,1))
        index = find(edges(:,1)>0, 1, 'first'); % Get the first remaining edge
        edge = edges(index,:);
        edges(index, :) = 0; % Remove it from the list
        
        % Add the starting vertex to the sequence
        start = edge(1);
        sequence(seq_idx) = start;
        seq_idx = seq_idx + 1;
        
        while edge(2)~=start
            % Find a neighbouring edge
            [row, col] = find(ismember(edges, edge(2))); % breaks on non-circular paths
            if isempty(row) % If no follow-up vertex could be found
                sequence(seq_idx) = edge(2); % Add the parent vertex
                seq_idx = seq_idx + 1;
                break;
            end
            edge = edges(row,:);
            edges(row, :) = 0; % Remove it from the list
            
            % If needed, invert its direction
            edge = circshift(edge, mod(col,2)+1);
            sequence(seq_idx) = edge(1); % Add the parent vertex
            seq_idx = seq_idx + 1;
            
            % Check if a cycle is closed
            if edge(2) == start
                sequence(seq_idx) = edge(2); % Add it again to the sequence for clarity
                seq_idx = seq_idx + 1;
            end
            
        end
    end
    
    results(i) = {vertex_ids(sequence)};
end

end

