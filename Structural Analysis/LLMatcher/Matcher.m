classdef Matcher < matlab.mixin.Copyable
    %MATCHER Class for handling graph matching
    %   Detailed explanation goes here
    
    properties
        gi = GraphInterface.empty;
        matchedVarArray = [];
        matchedEquArray = [];
        matchedEdgeArray = [];
        causality = 'None'; % None, Integral, Differential, Mixed, Realistic
        causalitySet = {'None', 'Integral', 'Differential', 'Mixed', 'Realistic'}
        matcherSet = {'Murty', 'WeightedElimination', 'ValidJust', 'Valid', 'BBILP'};
        matchingSet = []; % Set of edge IDs
    end
    
    methods
        function obj = Matcher(gi)
            % Class constructor
            obj.gi = gi;
            obj.matchedEquArray = gi.getMatchedEqus();
            obj.matchedVarArray = gi.getMatchedVars();
            obj.matchedEdgeArray = gi.getMatchedEdges();
        end
        function resp = setCausality(this,causality)
            resp = false;
            if ~ismember(causality,this.causalitySet)
                error('Tried to set a non-existing causality %s',causality);
            end
            this.causality = causality;
            resp = true;
        end
        function resp = match(this,matcher,varargin)
            resp = false;
            if ~ismember(matcher,this.matcherSet)
                error('Tried to use a non-existing matcher %s',matcher);
            end
            switch matcher
                case 'Murty'
                    resp = matchMurty(this,varargin{:});
                    this.gi.applyMatching(resp(1,:));
                    this.matchingSet = resp;
                case 'WeightedElimination'
                    resp = weightedElimination(this,varargin{:});
                    this.matchingSet = resp;
                case 'ValidJust'
                    resp = matchValidJust(this,varargin{:});
                    this.gi.applyMatching(resp);
                    this.matchingSet = resp;
                case 'Valid'
                    resp = matchValid(this,varargin{:});
                    this.gi.applyMatching(resp);
                    this.matchingSet = resp;
                case 'BBILP'
                    resp = matchBBILP(this);
                    this.gi.applyMatching(resp(1,:));
                    this.matchingSet = resp;
                otherwise
                    error('Unhandled matcher case');
            end
        end
        function [ resp ] = isMatchable( mh, id )
            %ISMATCHABLE Decide if an edge can be matched
            %   Detailed explanation goes here
            if ~mh.gi.isEdge(id)
                error('Only edges can pass this test');
            end
            
            resp = true;
            
            edgeIndex = mh.gi.getIndexById(id);
            
            derOK = strcmp(mh.causality,'None') || strcmp(mh.causality,'Mixed') || strcmp(mh.causality,'Differential') || strcmp(mh.causality,'Realistic');
            intOK = strcmp(mh.causality,'None') || strcmp(mh.causality,'Mixed') || strcmp(mh.causality,'Integral') || strcmp(mh.causality,'Realistic');
            niOK = strcmp(mh.causality,'None');
            
            if mh.gi.isMatched(id)
                resp = false;
            end
            if mh.gi.graph.edges(edgeIndex).isDerivative && ~derOK
                resp = false;
            end
            if mh.gi.graph.edges(edgeIndex).isIntegral && ~intOK
                resp = false;
            end
            if mh.gi.graph.edges(edgeIndex).isNonSolvable && ~niOK
                resp = false;
            end
            
            varId = mh.gi.getVariables(id);
            varIndex = mh.gi.getIndexById(varId);
            
            if mh.gi.isKnown(varId);
                % No operation
            end
            if mh.gi.graph.variables(varIndex).isMeasured
                resp = false;
            end
            if mh.gi.graph.variables(varIndex).isInput
                resp = false;
            end
            if mh.gi.graph.variables(varIndex).isOutput
                % No operation
            end
        end
        
    end
    
end
