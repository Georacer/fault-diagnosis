classdef Vertex < GraphElement
    %NODE Vertex class definition
    %   Detailed explanation goes here
    
    properties
        alias = '';
        name
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

    end
    
end

