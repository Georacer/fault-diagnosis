classdef Vertex < GraphElement
    %NODE Vertex class definition
    %   Detailed explanation goes here
    
    properties
        alias = '';
        name
        description = '';
        matchedTo = [];
        coordinates = [];
        rank = inf;
        edgeIdArray = [];
        neighbourIdArray = [];
    end
    
    properties (Access = private)
        
    end
    
    properties (Dependent)
    end
        
    methods
        function this = Vertex(id)
            this = this@GraphElement(id);
        end
    end
    
end

