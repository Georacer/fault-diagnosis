function [ varnames, fh_cell ] = model( paramMap )
%MODEL Summary of this function goes here
%   y = ceil(a*x);

    a = paramMap('a');
    
    varnames = {'y','x'};

    fh_cell = {@solutiony @solutionx @solution0};
    
    function result = solutiony(x)
        result = ceil(a*x);
    end

    function result = solutionx(y)
        result = inf;
    end

    function result = solution0(x,y)
        result = y-ceil(a*x);
    end

end

