classdef Registry < matlab.mixin.Copyable
    %REGISTRY Class for auxiliary data storage
    %   Detailed explanation goes here
    
    properties
        graph = GraphBipartite.empty
        
        varAliasArray = {}; % Index-indexed
        equAliasArray = {}; % Index-indexed
        
        varIdArray = []; % Index-indexed
        equIdArray = []; % Index-indexed
        edgeIdArray = []; % Index-indexed
        
        equIdToIndexArray = []; % Id-indexed
        varIdToIndexArray = []; % Id-indexed
        edgeIdToIndexArray = []; % Id-indexed
        
        subsystems = {}; % List of all included subsystems
        
    end
    
    methods
        function setGraph(this,graph)
            this.graph = graph;
        end
        
        function update(this)
            if isempty(this.graph)
                warning('Attempting to update registry when graph is empty');
                return
            end
            
            % Update varAliasArray
            arrayNew = cell(1,this.graph.numVars);
            for i=1:length(arrayNew)
                arrayNew{i} = this.graph.variables(i).alias;
                this.varAliasArray = arrayNew;
            end            
            % Update equAliasArray
            arrayNew = cell(1,this.graph.numEqs);
            for i=1:length(arrayNew)
                arrayNew{i} = this.graph.equations(i).alias;
                this.equAliasArray = arrayNew;
            end
            %%            
            % Update varIdArray
            arrayNew = zeros(1,this.graph.numVars);
            for i=1:length(arrayNew)
                arrayNew(i) = this.graph.variables(i).id;
                this.varIdArray = arrayNew;
            end
            % Update equIdArray
            arrayNew = zeros(1,this.graph.numEqs);
            for i=1:length(arrayNew)
                arrayNew(i) = this.graph.equations(i).id;
                this.equIdArray = arrayNew;
            end
            % Update edgeIdArray
            arrayNew = zeros(1,this.graph.numEdges);
            for i=1:length(arrayNew)
                arrayNew(i) = this.graph.edges(i).id;
                this.edgeIdArray = arrayNew;
            end
            
            %%
            % Update edgeIdToIndexArray
            arrayNew = zeros(1,max(this.edgeIdArray));
            arrayNew(this.edgeIdArray) = 1:this.graph.numEdges;
            this.edgeIdToIndexArray = arrayNew;  
            
            % Update equIdToIndexArray
            arrayNew = zeros(1,max(this.equIdArray));
            arrayNew(this.equIdArray) = 1:this.graph.numEqs;
            this.equIdToIndexArray = arrayNew;  
            
            % Update varIdToIndexArray
            arrayNew = zeros(1,max(this.varIdArray));
            arrayNew(this.varIdArray) = 1:this.graph.numVars;
            this.varIdToIndexArray = arrayNew;
            
            %% Update submodel list
            for i=1:length(this.graph.equations)
                systemName = this.graph.equations(i).subsystem;
                if isempty(systemName)
                    break
                end
                if ~ismember(systemName, this.subsystems)
                    this.subsystems{end+1} = systemName;
                end
            end
            this.subsystems = sort(this.subsystems);
        end
        
    end
    
end

