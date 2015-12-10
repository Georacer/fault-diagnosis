function Components = mexGraphConnectedComponents(Graph)
% Finds all strongly connected components in directed graph. 
% All Nodes belonging to the same cluster can be reached one from another. 
% That is: u and v belong to the same component if and only if there are paths (u,v) and (v,u).
% Only components larger then 1 are returned.
%
% Receives:
%   Graph			-   struct					-   Graph, created with GraphLoad
%
% Returns:
%	Components		-	cell array				-	List of strongly connected components (SCC). Each cell lists the nodes in the component.
%
% Algorithm:
%	Kosaraju's algorithm
%	The implementation is recursive and may exceed the application stack size (recursion deapth for huge networks may exceed 80,000). 
%	The symptom: in that case MatLab crashes and closes without reporting error.
%	ms-help://MS.VSCC.v80/MS.MSDN.v80/MS.VisualStudio.v80.en/dv_vccomp/html/73283660-e4bd-47cc-b5ca-04c5d739034c.htm
%	Stack size parameter is defined by the application (exe) and can not be changed programmatically from DLL. 
%	However, one can use EDITBIN tool to change MatLab's stack size: ms-help://MS.VSCC.v80/MS.MSDN.v80/MS.VisualStudio.v80.en/dv_vccomp/html/efdda03b-3dfc-4d31-90e6-caf5b3977914.htm
%		Default MatLab stack size:
%				Version							Size of Stack Reserve         	Size of Stack Commit
%				7.2 (2006b), 32 bits				00800000h (8MB)					00001000h (4KB)
%				7.4 (2007a), 64 bits			  0000000000800000h	(8MB)		 0000000000001000h (4KB)
%	One can change the stack size with the following command line:
%	editbin /STACK:33554432 "D:\Program Files\MATLAB\R2007a\bin\win64\Matlab.exe"
%	which will set the maximal stack size to 32MB.
%
% References:
%	 Rao S. Kosaraju. Unpublished. 1978.
%    Alfred V. Aho, John E. Hopcroft, Jeffrey D. Ullman. The Design and Analysis of Computer Algorithms. Addison-Wesley, 1974.
%    Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, Clifford Stein. Introduction to Algorithms, 2nd edition. The MIT Press, 2001. ISBN 0-262-03293-7.
%
%
% Example:
%
%
%
% See Also:
%	 GraphLoad
%
% Major Update:
%		Dramatically optimized - factor of 8 in speed, even more for larger graphs. 
%		Memory requirements reduced
%		The function does not return components of size 1.
%
%		Lev Muchnik, 27/07/2007
%		Further optimization. Computation time reduced by ~40%		

%{
Data = [ [1 2]; [ 2 3]; [3 4]; [4 3]; [5 1]; [2 5]; [5 6]; [2 6]; [6 7]; [7 6]; [3 7]; [7 8]; [4 8]; ];
Graph = ObjectCreateGraph(Data);
Components = mexGraphConnectedComponents(Graph);
%}