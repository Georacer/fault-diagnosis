classdef Registry
    %REGISTRY Class for auxiliary data storage
    %   Detailed explanation goes here
    
    properties
        gr = GraphBipartite.empty
        
        varAliasArray % Index-indexed
        equAliasArray % Index-indexed
        
        varIdArray % Index-indexed
        equIdArray % Index-indexed
        edgeIdArray % Index-indexed
        
        equIdToIndexArray % Id-indexed
        varIdToIndexArray % Id-indexed
        edgeIdToIndexArray % Id-indexed
    end
    
    methods
        function obj = Registry(graph)
            gr = graph;
        end
        
        function update(this)
            % Update varAliasArray
            arrayNew = cell(1,this.gr.numVars);
            for i=1:length(arrayNew)
                arrayNew{i} = this.gr.variables(i).alias;
                this.varAliasArray = arrayNew;
            end            
            % Update equAliasArray
            arrayNew = cell(1,this.gr.numEqs);
            for i=1:length(arrayNew)
                arrayNew{i} = this.gr.equations(i).alias;
                this.equAliasArray = arrayNew;
            end
            %%            
            % Update varIdArray
            arrayNew = cell(1,this.gr.numVars);
            for i=1:length(arrayNew)
                arrayNew{i} = this.gr.variables(i).id;
                this.varIdArray = arrayNew;
            end
            % Update equIdArray
            arrayNew = cell(1,this.gr.numEqs);
            for i=1:length(arrayNew)
                arrayNew{i} = this.gr.equations(i).id;
                this.equIdArray = arrayNew;
            end
            % Update edgeIdArray
            arrayNew = cell(1,this.gr.numEdges);
            for i=1:length(arrayNew)
                arrayNew{i} = this.gr.edges(i).id;
                this.edgeIdArray = arrayNew;
            end
            
            %%
            % Update edgeIdToIndexArray
            arrayNew = zeros(1,max(this.gr.edgeIdArray));
            arrayNew(this.gr.edgeIdArray) = 1:gh.numEdges;
            this.edgeIdToIndexArray = arrayNew;  
            
            % Update equIdToIndexArray
            arrayNew = zeros(1,max(this.gr.equationIdArray));
            arrayNew(this.gr.equationIdArray) = 1:this.gr.numEqs;
            this.equIdToIndexArray = arrayNew;  
            
            % Update varIdToIndexArray
            arrayNew = zeros(1,max(this.gr.variableIdArray));
            arrayNew(this.gr.variableIdArray) = 1:this.gr.numVars;
            this.varIdToIndexArray = arrayNew;
        end
        
    end
    
end

