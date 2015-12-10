function DFAData = mexDFA(Data, Scale,Order)
% Performs Detranded Fluctuation Analysis (DFA). To be used with the Complexity toolbox. Can deal with irregular data sampling (arbitrary time scale)
%
% Receives:
%   Data    -   Time Series Struct   -   The data to be analyzed. The Data can be sampled arbitrary - not only with regular dT. The Data structure must posess two fields: Data.Data and Data.Time
%				Data Series Struct	 -   Same as time series structure, but without the Data.Time field present. The function assumes evenly spaced samples
%				array				 -	 Only the data is provided. In this case the function assumes evenly spaced samples.
%   Scale   -   array   -   The list values for which to compute the function. (Normaly,  generated with logspace(log10(From),log10(To),N)).
%   Order   -   integer -   (Optional) A positive integer which defines the order of the polynom, used to perform detrand. Default - 1 (linear). 
%
% Returns:
%   DFAData	-	Time Series Struct -	The result of the DFA algorithm procesing of the Data. The Time represents the scale (dTs)
%
% See Also:
%	ObjectCreateTimeSeries, 
%
% Algorithm:
%   See "Quantification of Scaling Exponents and Crossover Phenomena in Nonstationary Heartbeat Time Series" for detailes.
%
% 
%
