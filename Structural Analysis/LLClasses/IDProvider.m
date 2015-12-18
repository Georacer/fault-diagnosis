classdef IDProvider < handle
    %IDPROVIDER Provides unique IDs on demand
    
    properties (SetAccess = private)
        idCounter = 1; % Increasing counter
        idArray = []; % Given IDs array
        prAliasArray = {}; % Aliases of objects who have been give IDs
    end
    
    properties (Hidden = true)
%         debug = true; % Debug messages flag
        debug = false;
    end
    
    methods
        
        function obj = IDProvider()
            % No arguments required
        end
        
        function id = giveID(obj, requester)
            % Return a unique ID if requested from a new alias. Otherwise, return the ID given to said alias in the past
            prAlias = requester.prAlias; % Get the prefix alias of the requester
            index = find(strcmp(obj.prAliasArray,prAlias)); % Look it up in the alias array
            if isempty(index) || isa(requester,'Equation') % We got a new variable or an equation
                id = obj.idCounter;
                obj.idCounter = obj.idCounter+1;
                obj.idArray(end+1) = id;
                obj.prAliasArray{end+1} = prAlias;
                
                if obj.debug fprintf('IDP: Giving new ID %d to %s\n',id,prAlias); end
                
            else % This object has been parsed in the past
                id = obj.idArray(index);
                
                if obj.debug fprintf('IDP: Found another instance of %s with ID %d\n',obj.prAliasArray{index},obj.idArray(index)); end
                
            end
        end
        
    end
    
end

