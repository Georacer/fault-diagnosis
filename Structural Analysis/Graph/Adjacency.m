classdef Adjacency < matlab.mixin.Copyable
    %ADJACENCY Adjacency class definition
    %   Detailed explanation goes here
    
    properties
        gi
        BD % Variables indexed first, then equations
        BD_types % Adjacency matrix mask holding the edge types
        
        % Edge types
        DEF_INT = 2;
        DEF_DER = 3;
        DEF_NI = 4;
        DEF_AE = 5;
        
        % Edge costs
        integrationCost = 100;
        differentiationCost = 100;
        nonInvertibleCost = 1;
        
        numVars
        numEqs
        eqNames
        eqIds
        varNames
        varIds
    end
    
    properties (Dependent)
        E2V
        E2V_types
        V2E
        V2E_types
    end
    
    methods
        
        function obj = Adjacency(gi, type)
            % Arguments:
            %   type: 'force' will create non-invertible E2V edges and mark them as such in BD_types matrix
            obj.gi = gi;
            if nargin<2
                type = [];
            end
            obj.parseModel(type);
        end
        
        function parseModel(this, type)
            
            if nargin<2
                type = [];
            end
            
            % Create the graph adjacency matrix and other related objects
            this.numVars = this.gi.graph.numVars;
            this.numEqs = this.gi.graph.numEqs;
            numEls = this.numVars + this.numEqs;
            this.BD = zeros(numEls,numEls);
            this.BD_types = this.BD;
            
            if strcmp(type,'force')
                E = this.gi.getEdgeList('force');
            else
                E = this.gi.getEdgeList();
            end
            
            for i=1:size(E,1)
                id1 = E(i,1);
                id2 = E(i,2);
                if this.gi.isVariable(id1) % V2E edge
                    varIndex = this.gi.getIndexById(id1);
                    equIndex = this.gi.getIndexById(id2);
                    this.BD(varIndex,this.numVars+equIndex) = 1;
                    this.BD_types(varIndex,this.numVars+equIndex) = 1;
                else % E2V edge
                    equIndex = this.gi.getIndexById(id1);
                    varIndex = this.gi.getIndexById(id2);
                    this.BD(this.numVars+equIndex,varIndex) = E(i,3); % TODO Do I throw out edge cost by mistake here?
                    edgeId = this.gi.getEdgeIdByVertices(id1, id2);
                    if this.gi.isIntegral(edgeId)
                        this.BD(this.numVars+equIndex, varIndex) = this.integrationCost;
                        this.BD_types(this.numVars+equIndex, varIndex) = 2;
                    elseif this.gi.isDerivative(edgeId)
                        this.BD(this.numVars+equIndex, varIndex) = this.differentiationCost;
                        this.BD_types(this.numVars+equIndex, varIndex) = 3;
                    elseif this.gi.isNonSolvable(edgeId) 
                        this.BD(this.numVars+equIndex, varIndex) = this.nonInvertibleCost;
                        this.BD_types(this.numVars+equIndex, varIndex) = 4;
                    else
                        this.BD_types(this.numVars+equIndex, varIndex) = 1;
                    end
                end
            end
            
            this.eqIds = this.gi.reg.equIdArray;
            this.eqNames = this.gi.reg.equAliasArray;
            this.varIds = this.gi.reg.varIdArray;
            this.varNames = this.gi.reg.varAliasArray;
            
        end

        function array = get.E2V(obj)
            array = obj.BD((obj.numVars+1):end,1:obj.numVars);
        end
        
        function array = get.V2E(obj)
            array = obj.BD(1:obj.numVars,(obj.numVars+1):end);
        end
        
        function array = get.E2V_types(obj)
            array = obj.BD_types((obj.numVars+1):end,1:obj.numVars);
        end
        
        function array = get.V2E_types(obj)
            array = obj.BD_types(1:obj.numVars,(obj.numVars+1):end);
        end
        
        function table = getTable(this,selection)
            switch selection
                case 'BD'
                    header = [this.varNames this.eqNames];
                    table = array2table(this.BD,'RowNames',header,'VariableNames',header);
                case 'E2V'
                    table = array2table(this.E2V,'RowNames',this.eqNames,'VariableNames',this.varNames);
                case 'V2E'
                    table = array2table(this.V2E,'RowNames',this.varNames,'VariableNames',this.eqNames);
                otherwise
                    error('Available adjacency types are: BD, E2V and V2E');
            end        
        end
        
    end
    
end

