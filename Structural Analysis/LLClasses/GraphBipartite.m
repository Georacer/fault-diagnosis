classdef GraphBipartite < handle
    %GRAPHBIPARTITE Bipartite graph class definition
    %   Detailed explanation goes here
    
    properties
        equationArray = Equation.empty; % Array with equations contained in the graph
        variableArray = Variable.empty; % Array with viariables contained in the graph
        coords = [];
    end
    
    properties (SetAccess = private)
        variableAliasArray = {};
        equationAliasArray = {};
        equationIdArray = [];
        variableIdArray = [];
        adjacency = []; % The adjacency matrix
        adjacencyUndir = []; % Undirected copy of the adjacency matrix
        adjacencyCtrl = []; % The controlability adjacency matrix
        adjacencyObsrv = []; % The observability adjacency matrix
        ph % Plot handle
    end
    
    properties (Hidden = true)
        debug = false;
%         debug = true;
        constructing = false;
    end
    
    
    methods
        
        function obj = GraphBipartite(model,coords)
            % Constructor
            
            obj.constructing = true; % Begin construction
            % Read model file and store related equations and variables
            groupsNum = size(model,1); % Number of equation groups in model
            for groupIndex=1:groupsNum % For each group
                group = model{groupIndex,1};
                grEqNum = size(group,1);
                grPrefix = model{groupIndex,2};
                grEqAliases = cell(1,grEqNum);
                for i=1:grEqNum
                    tempEquation = Equation([],group{i,1},grEqAliases{i},grPrefix);
                    obj.equationArray(end+1) = tempEquation;
                end
            end
            
            obj.updateEquationAliasArray();
            obj.updateEquationIdArray();
            obj.updateVariableArray();
            obj.createAdjacency();
            
            % Store external nodes coordinates input
            if nargin>=2
                obj.coords = coords;
            end
            
            obj.constructing = false; % End construction
        end
        
        
        function set.variableArray(obj,value)
        % Set the VariableArray property and update the VariableAliaArray property
            obj.variableArray = value;
            if ~obj.constructing
                obj.updateVariableAliasArray(); % Update the variable aliases array
            end
        end
        
        function updateVariableArray(obj)
        % Re-build the variableArray from the contents of equationArray
            obj.constructing = true;
            obj.variableArray = Variable.empty;
            obj.variableAliasArray = cell(0,0);
            for i=1:length(obj.equationArray) % For each equation
                for j=1:length(obj.equationArray(i).variableArray) % For each variable
                    prAlias = obj.equationArray(i).variableArray(j).prAlias;
                    index = find(strcmp(obj.variableAliasArray,prAlias));
                    if isempty(index) % This variable is not stored yet
                        obj.variableArray(end+1) = obj.equationArray(i).variableArray(j); %TODO decide on propertyOR method
                        obj.variableAliasArray{end+1} = prAlias;
                        obj.variableIdArray(end+1) = obj.equationArray(i).variableArray(j).id;
                        if obj.debug fprintf('GRA: Parsed new variable %s\n',prAlias); end
                    else
                        if obj.debug fprintf('GRA: Already have variable %s stored\n',prAlias); end
                    end
                end
            end
            obj.constructing = false;
            if obj.debug fprintf('variableArray length = %d\n',length(obj.variableArray)); end;
        end
        
        function updateVariableAliasArray(obj)
        % Update the array holding the variable objects
            obj.variableAliasArray = cell(size(obj.variableArray));
            for i=1:length(obj.variableAliasArray)
                obj.variableAliasArray{i} = [obj.variableArray(i).prefix obj.variableArray(i).alias];
            end
        end
        
        function set.equationArray(obj,value)
        % Set the equationArray property and update the equationAliasArray property
            obj.equationArray = value;
            if ~obj.constructing
                obj.updateEquationAliasArray(); % Update the variable aliases array
            end
        end
        
        function updateEquationAliasArray(obj)
        % Update the array holding the equation objects aliases
            obj.equationAliasArray = cell(size(obj.equationArray));
            for i=1:length(obj.equationAliasArray)
                obj.equationAliasArray{i} = [obj.equationArray(i).prefix obj.equationArray(i).alias];
            end
        end
        
        function updateEquationIdArray(obj)
        % Update the array holding the equation objects IDs
            obj.equationIdArray = zeros(size(obj.equationArray));
            for i=1:length(obj.equationIdArray)
                obj.equationIdArray(i) = obj.equationArray(i).id;
            end
        end        
        
        function createAdjacency(obj)
        % Create the graph adjacency matrix
            numVars = length(obj.variableArray);
            numEqs = length(obj.equationArray);
            numEls = numVars + numEqs;
            obj.adjacency = zeros(numEls,numEls);
            for i=1:length(obj.equationArray)
                for j=1:length(obj.variableArray)
                    varId = obj.variableIdArray(j);
                    index = find(obj.equationArray(i).variableIdArray==varId); % Check if variable is contained in this equation
                    if obj.debug fprintf('GRA: (%d,%d) Found %d instance(s) of %s in %s\n',i,j,length(index), obj.variableArray(j).prAlias,obj.equationArray(i).prAlias); end
                    if ~isempty(index) % If yes, fill the corresponding cells accordingly
                        % General case
                        obj.adjacency(numVars+i,j) = 1;
                        obj.adjacency(j,numVars+i) = 1;
                        if obj.equationArray(i).variableArray(index).isKnown % TODO specify mutually exclusive properties
                            obj.adjacency(j,numVars+i) = 1;
                        end
                        if obj.equationArray(i).variableArray(index).isMeasured
                            obj.adjacency(j,numVars+i) = 1;
                        end
                        if obj.equationArray(i).variableArray(index).isInput
                            obj.adjacency(j,numVars+i) = 1;
                        end
                        if obj.equationArray(i).variableArray(index).isOutput
                            obj.adjacency(numVars+i,j) = 1;
                        end
                        if obj.equationArray(i).variableArray(index).isMatched
                            obj.adjacency(j,numVars+i) = 1;
                        end
                        if obj.equationArray(i).variableArray(index).isDerivative
                            obj.adjacency(numVars+i,j) = 1;
                            obj.adjacency(j,numVars+i) = 1;
                        end
                        if obj.equationArray(i).variableArray(index).isIntegral
                            obj.adjacency(numVars+i,j) = 1;
                            obj.adjacency(j,numVars+i) = 1;
                        end
                        if obj.equationArray(i).variableArray(index).isNonSolvable
                            obj.adjacency(j,numVars+i) = 1;
                        end
                    end
                end
            end
            
        end
        
        function plotG4M(obj)
            % Plot graph using Graphviz4Matlab library
            
            gray = [0.3 0.3 0.3];
            yellow = [1.0 1.0 0.0];
            blue = [0.0 0.2 1.0];
            
            numVars = length(obj.variableArray);
            numCons = length(obj.equationArray);
            numEls = numVars + numCons;
            
            nodeLabels = [obj.variableAliasArray obj.equationAliasArray];
            
            % Colour nodes
            nodeColors = zeros(numEls,3);
            for i=1:numVars
                nodeColors(i,:) = yellow;
                if obj.variableArray(i).isInput
                    nodeColors(i,:) = gray;
                end
            end
            for i=(numVars+1):numEls
                nodeColors(i,:) = blue;
            end
            
            % disp(size(adjacency));
            % disp(size(nodeLabels));
            
            obj.ph = drawNetwork(obj.adjacency, '-nodeLabels', nodeLabels, '-nodeColors', nodeColors);
            
            if (~isempty(obj.coords))
                obj.ph.setNodePositions(obj.coords);
            end
            
            for i=(numVars+1):numEls % Make constraints square
                obj.ph.nodeArray(i).curvature = [0,0];
            end
            
            % TODO: Colour matched nodes
            
            obj.ph.tightenAxes;
            diameter = max([obj.ph.nodeArray(:).width]); % Place nodes on grid
            aspectRatio = 14/9;
            
            obj.coords = obj.ph.getNodePositions();
            
            obj.coords = obj.coords*(1-aspectRatio*diameter);
            obj.coords(:,1) = obj.coords(:,1)*(1-aspectRatio*diameter); % Correcting for tight display bug
            obj.coords = obj.coords+0.5*aspectRatio*diameter;
            obj.ph.setNodePositions(obj.coords);
            obj.ph.increaseFontSize;
            obj.ph.increaseFontSize;
            
        end
        
    end
    
end

