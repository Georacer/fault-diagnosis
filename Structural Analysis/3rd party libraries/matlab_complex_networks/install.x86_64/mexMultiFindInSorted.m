function Indeces = mexMultiFindInSorted(Data, Search)
% Searches 'Data' for each  of Search elements. 
% Unlike intersect, the function :
%	1. Assumes that both Data and Search are sorted. Otherwize, the results will be wrong!
%	However, if the arrays are sorted, this function requires O(Search+Data) and not O(Search*Data) as in  mexMultiFind.
%	
%	Notice, the the function can be used even if Search is unsorted:
%	
%		[SortedSearch SortOrder] = sort(Search); 
%		TempIndeces = mexMultiFindInSorted(Data,SortedSearch); 
%		Indeces(SortOrder) = TempIndeces;
%
%	In this case the time is: O(Search*log(Search) + Data)
% 
%	2. It returns indeces of each occurence of value in Search (not just one).
%	3. It returns index of first occurence of each element if Search in Data. 
%	4. The function in most cases is much faster then unique.
%	5. May be much faster then mexMultiFind since it assumes that Data and Search are sorted.
% 
% More function properties:
%	* Dimentions of the output is identical to the dimentions of Search.
%	* If element of search is not found in data, 0 is returned.
%	* If Data is a non-trivial matrix (not a vector), the function is applied iteratively for each column. Result is cell array of results
% 
% Rececieves:
%		Data		-	vector, Mx1 or 1xM	-	Vector of data elements to search. Indeces from that vector are returned.
%						MxN					-	in this case, the function will be applied separetely to each of the columns. Cell array 1xN will be returned. 
%		Search	   -	scalar				    - 	Element to search for. First occurency of this value are found in Data. 'Search' may have several occurencies of the same value.
%												Otherwize, use 'intersect'.												
%						vector/matrix		-	'Data' is searched for all occurencies of Search. The results will have the same dimentions as 'Search'. 
%
% Returns
%		Indeces -  scalar/vector/matrix	-	indeces of 'Data',  same size as of 'Search'
%						cell array, MxN
%
% Algorithm:
%	Efficiency: numel(Data)+numel(Sreach)
%
