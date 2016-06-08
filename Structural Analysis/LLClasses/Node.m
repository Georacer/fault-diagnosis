classdef Node < matlab.mixin.Copyable
    %NODE Node class definition
    %   Detailed explanation goes here
    
    properties
        id = 0;
        alias = '';
        name
        description
        isMatched = false;
        matchedTo = [];
        coordinates = [];
        rank = inf;
        edgeIdArray = [];
        neighbourArray = [];
    end
        
    methods
    end
    
end

