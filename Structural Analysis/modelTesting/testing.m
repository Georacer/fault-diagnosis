clear
close all


syms x y a
f = y + a*x;

a = 2;

fx = matlabFunction(solve(subs(f),x));
fy = matlabFunction(solve(subs(f),y));
f0 = matlabFunction(subs(f));

varnames = arrayfun(@(x) char(x), [x y]);
functions = {fx, fy, f0};

eq1 = EqClass(varnames, functions);

params = containers.Map;
params('a') = 2;
[varnames, functions] = model(params);
eq2 = EqClass(varnames,functions);

params = containers.Map;
params('a') = 3;
[varnames, functions] = model(params);
eq3 = EqClass(varnames,functions);