% function R = mexVectorMatrixMultiplier(V,A) 
% /********************************************************************************************************
% 	This is a MatLab MEX function. The function effectively multiplies every column(row) of matrix by the
% 	same column(row) vector without extending the vector with repmat.									
% 	normally this operation can be done in MatLab like this:												
% 																										
%  m = 50;																								
%  n = 50;																								
%  A = rand([m n]);																						
%  V = rand([m 1]);																						
%  R = repmat(V,[1 n]).*A;																				
% 																										
% 	If the vector is a row vector, it multiplies every row of the matrix.								
% 	The function is especially effective for large vectors/matrises. It's run time is about 30% lower	
% 	than that of the classical MatLab .* with repmat.													
% 																										
%  Receives:																							
% 	V		-	vector	-	column or row vecor.														
% 	A		-	matrix	-	if the vector is column(row) vector, the matrix must have the same number of
% 							columns (rows).																
%  Returns:																								
% 	Result	-	matrix	-	The same size as A.																
% 																										
% *********************************************************************************************************/
