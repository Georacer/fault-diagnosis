classdef GraphInterface
    %GRAPHINTERFACE Interface class for graph functionality
    %   Detailed explanation goes here
    
    properties
        graph = GraphBipartite.empty
        idProvider = IDProvider() % ID provider object
        formulaList
    end
    
    methods
        function this = GraphInterface(model)
            constraints = model.constraints;
            this.name = model.name;
            this.coords = model.coordinates;
            
            % Read model file and store related equations and variables
            groupsNum = size(constraints,1); % Number of equation groups in model
            for groupIndex=1:groupsNum % For each group
                group = constraints{groupIndex,1};
                grEqNum = size(group,1);
                grPrefix = constraints{groupIndex,2};
                grEqAliases = cell(1,grEqNum); % Create unique equation aliases
                for i=1:grEqNum
                    grEqAliases{i} = sprintf('eq%d',i);
                end
                for i=1:grEqNum
                    this.parseExpression(group{i,1},grEqAliases{i},grPrefix);
                end
            end
        end
        
        function [resp,id] = addFormula(this)
        end
        
        function [resp,id] = addVariable(this)
        end
        
        function [resp,id] = addEdge(this)
        end
        
        
    end
    
end

