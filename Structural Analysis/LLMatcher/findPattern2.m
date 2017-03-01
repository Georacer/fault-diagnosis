function start = findPattern2(array, pattern)
%findPattern2 Locate a pattern in an array.
%
%   indices = findPattern2(array, pattern) finds the starting indices of
%   pattern within array.
%
%   Example:
%   a = [0 1 4 9 16 4 9];
%   patt = [4 9];
%   indices = findPattern2(a,patt)
%   indices =
%        3     6

% Let's assume for now that both the pattern and the array are non-empty
% VECTORS, but there's no checking for this. 
% For this algorithm, I loop over the pattern elements.
len = length(pattern);
% First, find candidate locations; i.e., match the first element in the
% pattern.
start = find(array==pattern(1));
% Next remove start values that are too close to the end to possibly match
% the pattern.
endVals = start+len-1;
start(endVals>length(array)) = [];
% Next, loop over elements of pattern, usually much shorter than length of
% array, to check which possible locations are valid still.
for pattval = 2:len
    % check viable locations in array
    locs = pattern(pattval) == array(start+pattval-1);
    % delete false ones from indices
    start(~locs) = [];
end