function resp = hasCycles(obj)
% Answer whether the provided graph has cycles or not. Uses the
% matlab_networks_routines library
n = num_loops(obj.adjacency.BD);
if n==0
    resp = false;
else
    resp = true;
end
end