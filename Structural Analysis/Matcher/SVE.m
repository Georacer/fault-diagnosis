function M = SVE( mh, varargin )
%WEIGHTEDELIMINATION Single-Variable Elimination, following the cheapest path
%   Returns a single matching
%   Right now disregards causality

% obeyCausality = true;

p = inputParser;

p.addRequired('mh',@(x) true);

p.parse(mh, varargin{:});
opts = p.Results;

debug = true;
% debug = false;

% Edge types
DEF_INT = 2;
DEF_DER = 3;
DEF_NI = 4;
DEF_AE = 5;

% Build adjacency tables, cols: variables, rows:equations
V2E_types = mh.gi.adjacency.V2E_types'; % Disregard causality
% V2E_types = mh.gi.adjacency.V2E_types';

% Build the packed matrix including IDs

var_ids = mh.gi.getVariablesUnknown();
var_idx = mh.gi.getIndexById(var_ids);

equ_ids = mh.gi.getEquations();
equ_idx = mh.gi.getIndexById(equ_ids);

V2E_types = V2E_types(equ_idx,var_idx);
A = [0 var_ids; equ_ids' V2E_types];
%   A: An adjacency matrix with ids concatenated, [0 v; e E2V]
%       v: a 1xn_v row with variable IDs
%       e: a n_ex1 column with equation IDs
%       E2V: the corresponding adjacency matrix

% Initialize a container for incomplete matchings
M_r = containers.Map;

% Initialize a container for finished matchings
M_f = containers.Map;

% Initialize the recursive matching procedure
M_r('') = A;

while ~isempty(M_r.keys)
    buildMatching(mh, M_r, M_f);
end

% Allocate and build result
matching_strs = M_f.keys;
M = cell(1,length(matching_strs));
for i=1:length(matching_strs)
    M{i} = str2num(matching_strs{i});
end


end

function buildMatching(mh, M_r, M_f)
% buildMatching Recursive function, expanding the matching tree given a matching collection M and an adjacency A
% Inputs:
%   mh: The matcher handle
%   M_r: A map container storing the current threads of matchings
%   M_f: A map container storing the finished matching threads

keys_cell = M_r.keys;
next_key = keys_cell{end}; % Pop an incomplete matching, use DFS
current_matching = str2num(next_key);
% Get the adjacency matrix
A = M_r(next_key);
var_ids = A(1,2:end);
equ_ids = A(2:end,1);
E2V = A(2:end,2:end);

% Delete this key
M_r.remove(next_key);

equ_idx = find(sum(E2V>0,2)==1); % Find the equations with only one unmatched variable

if isempty(equ_idx)
% No matchable edge exists
     M_f(num2str(current_matching)) = A; % Store this final matching
else
% Edges available for matching
    % Find the corresponding variables
    var_idx = zeros(size(equ_idx));
    for i=1:length(equ_idx)
        var_idx(i) = find(sum(E2V(equ_idx(i),:),1));
    end

    equ_ids_to_match = equ_ids(equ_idx);
    var_ids_to_match = var_ids(var_idx);

    edge_ids = mh.gi.getEdgeIdByVertices(equ_ids_to_match, var_ids_to_match);

    for i=1:length(edge_ids)
        edge_id = edge_ids(i);
        new_matching = sort([current_matching edge_id]);
        new_var_ids = var_ids;
        new_equ_ids = equ_ids;
        new_E2V = E2V;
        % Eliminate the equation-variable pair
        new_equ_ids(equ_idx(i)) = [];
        new_var_ids(var_idx(i)) = [];
        new_E2V(equ_idx(i),:) = [];
        new_E2V(:,var_idx(i)) = [];
        new_A = [0 new_var_ids; new_equ_ids new_E2V];
        M_r(num2str(new_matching)) = new_A;
    end
end

end
