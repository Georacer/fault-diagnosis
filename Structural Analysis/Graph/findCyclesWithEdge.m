function [ cycles, edge_list ] = findCyclesWithEdge( adjacency_array, edge )
%FINDCYCLES Find all cycles of the undirected graph adjacency_array which contain edge
%   INPUTS:
%       adjacency_array: a N x N undirected adjacency array
%       edge: a 1 x 2 array, specifying an edge in the adjacency_array
%   OUTPUTS:
%       cycles: An |E| x |C| mask array, where E is the number of edges and C is the number of cycles
%       edge_list: An |E| x 2 array of edges which cycles refers to

% Make sure adjacency array is undirected
A = triu(symmetrize(adjacency_array));

% Sort edge pair edge = (v1, v2) s.t. v1 < v2
edge = sort(edge);

% Make sure edge is part of the graph
if ~A(edge(1),edge(2))
    error('Requested edge not part of the graph');
end

% Create the edge list
E = adj2edgeL(A);
E = E(:,1:2); % Drop edge weights
edge_list = E;

% Create the cycle basis
cycle_basis = grCycleBasis(E); % Returns a |E| x |C| array, where C is the cycle basis
% Create a unique bitstring for each cycle, current size |C| x |C|
bitstrings = zeros(size(cycle_basis,2), 1);
for i=1:length(bitstrings)
    bitstrings(i) = bitshift(1,i-1);
end

%% Combine the cycle basis to generate all cycles

% Find edge index
[~, edge_idx] = ismember(edge, E, 'rows');

% Find which basis cycles contain the requested edge
covered_basis_cycles_mask = logical(cycle_basis(edge_idx, :));

% Initialize the output
cycles = cycle_basis(:, covered_basis_cycles_mask);
bitstrings_cov = bitstrings(covered_basis_cycles_mask);

% Isolate the basis cycles which do not contain the edge
uncovered_basis_cycles_mask = ~covered_basis_cycles_mask;
cycles_uncovered = cycle_basis(:, uncovered_basis_cycles_mask);
bitstrings_uncov = bitstrings(uncovered_basis_cycles_mask);
num_uncovered = sum(uncovered_basis_cycles_mask);

% If no uncovered basis cycle exists, then all cycles have already been found
if num_uncovered==0
    return;
end

% Initialize the uncombined cycles index
process_idx = 1;

% Combine them with the  basis cycles which do not cover edge
while process_idx <= size(cycles,2) % While there are new cycles to combine

    cycle = cycles(:,process_idx); % Get current cycle
    bitstring = bitstrings_cov(process_idx);

    for i=1:num_uncovered % For each uncovered cycle
        cycle_2 = cycles_uncovered(:,i);
        bitstring_2 = bitstrings_uncov(i);
        % Check if the two cycles are disjoint
        common_edges = and(cycle, cycle_2);
        if sum(common_edges) == 0
            continue;
        end
        
        % Check if cycle_2 has already contributed to the creation of this cycle
        if bitand(bitstring, bitstring_2)
            continue;
        end

        % If not, proceed by creating a combined cycle and adding it in the result
        cycles(:,end+1) = xor(cycle, cycle_2);
        bitstrings_cov(end+1) = bitxor(bitstring, bitstring_2);
    end
    
    process_idx = process_idx + 1;

end

end

