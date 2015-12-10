function	HurstData = mexHurst(Data,Scale);
%This is a MatLab MEX function. It effectively computes Hurst function of the 1-Dimentional irregular (not equally spaced) time sequence.
%																										
%Receives:						
%   Data    -   Time Series Struct   -   The data to be analyzed. The Data can be sampled arbitrary - not only with regular dT. The Data structure must posess two fields: Data.Data and Data.Time
%				Data Series Struct	 -   Same as time series structure, but without the Data.Time field present. The function assumes evenly spaced samples
%				array				 -	 Only the data is provided. In this case the function assumes evenly spaced samples.
%   Scale   -   array				 -	 The list values for which to compute the function. (Normaly,  generated with logspace(log10(From),log10(To),N)).
%	
% Returns:																								
%   HurstData-	Time Series Struct -	The result of the Hurst algorithm procesing of the Data. The Time represents the scale (dTs), it is
%										a vector of natural algorithm of time intervals of the Hirst function. the Data field is the Hurst function.
%
% See Also:
%	ObjectCreateTimeSeries, 
%																										
%  
%Major Updates:  
%	The function now supports the Complexity Toolbox data types.
%
