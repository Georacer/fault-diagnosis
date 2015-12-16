clear all;
global IDProviderObj;
IDProviderObj = IDProvider();
expr = 'dot v1 int ni v2 inp v3 out msr v4';
myeq = Equation([],expr)
% myeq.dispVars();