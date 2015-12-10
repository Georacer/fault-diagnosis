function [STDs,Means] = mexSlidingSTD(Data, WindowSize)
% Computes STD and Mean (optional) of the neighbourhood for each point in the Data vector.
% 
% Rececieves:
%		Data		-	vector, Mx1 or 1xM	-	Vector of data elements to process.
%						struct				-	If struct, the Data.Data field is processed.
%
%		WindowSize  -	scalar				-   Size of the sliding window. The Window is defined as (WindowSize-1)/2 
%												to the left and to the right of the point as long as it is not exceeding 
%												the input data dimentions.
%												If Window size is even it is added 1. 
%
% Returns
%		STDs		-	vector				-	vector of the size of Data with standard deviation computed for each data point.
%		Means		-	vector				-	(optional) vector of the size of Data with average computed for each data point.
%
% Algorithm:
%	http://mathworld.wolfram.com/StandardDeviation.html
%
