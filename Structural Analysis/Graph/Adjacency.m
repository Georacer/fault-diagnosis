classdef Adjacency < matlab.mixin.Copyable
    %ADJACENCY Adjacency class definition
    %   Detailed explanation goes here
    
    properties
        gi
        BD % Variables indexed first, then equations
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
        
        function obj = Adjacency(gi)
            obj.gi = gi;
            obj.parseModel();
        end
        
        function parseModel(this)
            % Create the graph adjacency matrix and other related objects
            this.numVars = this.gi.graph.numVars;
            this.numEqs = this.gi.graph.numEqs;
            numEls = this.numVars + this.numEqs;
            this.BD = zeros(numEls,numEls);
            E = this.gi.getEdgeList();
            
            for i=1:size(E,1)
                id1 = E(i,1);
                id2 = E(i,2);
                if this.gi.isVariable(id1) % V2E edge
                    varIndex = this.gi.getIndexById(id1);
                    equIndex = this.gi.getIndexById(id2);
                    this.BD(varIndex,this.numVars+equIndex) = 1;
                else% E2V edge
                    equIndex = this.gi.getIndexById(id1);
                    varIndex = this.gi.getIndexById(id2);
                    this.BD(this.numVars+equIndex,varIndex) = E(i,3);
                end
            end
            
        end

        function array = get.E2V(obj)
            array = obj.BD((obj.numVars+1):end,1:obj.numVars);
        end
        
        function array = get.V2E(obj)
            array = obj.BD(1:obj.numVars,(obj.numVars+1):end);
        end
        
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

