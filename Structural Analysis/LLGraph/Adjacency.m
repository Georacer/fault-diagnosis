classdef Adjacency < matlab.mixin.Copyable
    %ADJACENCY Adjacency class definition
    %   Detailed explanation goes here
    
    properties
        BD
        numVars
        numEqs
        eqNames
        eqIds
        varNames
        varIds
    end
    
    properties (Dependent)
        E2V
        V2E
    end
    
    methods
        
        %%
        function obj = Adjacency(array,eqNames,eqIds,varNames,varIds)
            obj.BD = array;
            obj.eqNames = eqNames;
            obj.eqIds = eqIds;
            obj.numEqs = length(eqNames);
            obj.varNames = varNames;
            obj.varIds = varIds;
            obj.numVars = length(varNames);
        end

        %%
        function array = get.E2V(obj)
            array = obj.BD((obj.numVars+1):end,1:obj.numVars);
        end
        
        %%
        function array = get.V2E(obj)
            array = obj.BD(1:obj.numVars,(obj.numVars+1):end);
        end
        
        %%
        function table = getTable(this,selection)
            switch selection
                case 'BD'
                    header = [this.varNames this.eqNames];
                    table = array2table(this.BD,'RowNames',header,'VarNames',header);
                case 'E2V'
                    table = array2table(this.E2V,'RowNames',this.eqNames,'VarNames',this.varNames);
                case 'V2E'
                    table = array2table(this.V2E,'RowNames',this.varNames,'VarNames',this.eqNames);
                otherwise
                    error('Available adjacency types are: BD, E2V and V2E');
            end        
        end
        
    end
    
end

