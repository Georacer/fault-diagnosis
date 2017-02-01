classdef EqClass
    %EQCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        variables = {};
        exprSymb = '';
        functions = function_handle.empty;
    end
    
    methods
        function obj = EqClass(varnames, functions)
            obj.variables = varnames;
            obj.functions = functions;
        end
        
        function result = calculate(this,varname,arguments)
            index = find(ismember(this.variables,varname));
            result = this.functions{index}(arguments);
        end
    end
    
end

