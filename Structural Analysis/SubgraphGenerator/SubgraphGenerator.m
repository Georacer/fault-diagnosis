classdef SubgraphGenerator < matlab.mixin.Copyable
    %SUBGRAPHGENERATOR Summary of this class goes here
    %   Does not edit passed GraphInterface gi
    
    properties
        gi = GraphInterface.empty;
        liUSM = DiagnosisModel.empty;
        MSOs = {};
        MTESs = {};
        parent_blob = [];
    end
    
    methods
        function obj = SubgraphGenerator(gi, parent_blob)
            % Constructor
            obj.gi = gi;
            % Bring in parent blob
            if nargin==2
                obj.parent_blob = parent_blob;
            end
        end
        function resp = setGraphInterface(this,gi)
            % Change the graph interface pointer
            this.gi = gi;
        end
        function resp = buildLiUSM(this)
            % Construct the LiUSM object
            this.liUSM = createLiusm(this.gi);
        end
        function resp = buildMSOs(this)
            % Use liUSM to build the MSO set
            this.liUSM.CompiledMSO();
            liUMSOs = this.liUSM.MSO();
            this.MSOs = cell(size(liUMSOs));
            for i=1:length(this.MSOs)
                this.MSOs{i} = this.gi.reg.equIdArray(liUMSOs{i});
            end
            resp = true;
        end
        function MSOs = getMSOs(this)
            % Return the set of MSOs containing equation IDs
            if isempty(this.MSOs)
                warning('MSOs not initialized yet');
            end
            MSOs = this.MSOs;
            return
        end
        function resp = buildMTESs(this)
            % Use LiUSM to build the MTES set
            liUMTESs = this.liUSM.MTES();
            this.MTESs = cell(size(liUMTESs));
            for i=1:length(this.MTESs)
                this.MTESs{i} = this.gi.reg.equIdArray(liUMTESs{i});
            end
        end
        function MTESs = getMTESs(this)
            % Return the set of MTESs containing equation IDs
            if isempty(this.MTESs)
                warning('MTESs not initialized yet or zero in number');
            end
            MTESs = this.MTESs;
            return            
        end
        function gi = buildSubgraph(this,varargin)
            
            p = inputParser;
            
            p.addRequired('this', @(x) true);
            p.addRequired('equIds', @(x) all(isnumeric(x)));
            p.addOptional('varIds', [], @(x) all(isnumeric(x)));
            p.addParameter('postfix', '_submodel', @isstr);
            p.addParameter('pruneKnown', false, @islogical);
            p.addParameter('pruneUnmatched', false, @islogical);
            
            p.parse(this, varargin{:});
            opts = p.Results;

            equIds = opts.equIds;
            varIds = opts.varIds;
            postfix = opts.postfix;
            pruneKnown = opts.pruneKnown;
            pruneUnmatched = opts.pruneUnmatched;
            
            % Create a deep copy of the input graph
            if isempty(this.parent_blob)
                gi = copy(this.gi);
            else
                gi = getArrayFromByteStream(this.parent_blob);
            end
            
            % Delete equations
            allIds = this.gi.reg.equIdArray;
            ids2Del = setdiff(allIds,equIds);
            gi.deleteEquations(ids2Del);
            
            % Keep only required variables
            if ~isempty(varIds)
                ids2Del = setdiff(gi.reg.varIdArray,varIds);
                for i=1:length(ids2Del)
                    gi.deleteVariables(ids2Del(i),false);
                end
                
            end
            
            if pruneKnown
                % Delete known variables
                ids2Del = gi.getVariablesKnown();
                for i=1:length(ids2Del)
                    gi.deleteVariables(ids2Del(i),false);
                end
            end
            
            if pruneUnmatched
                % Delete unmatched variables
                ids2Del = gi.getVarIdByProperty('isMatched',false);
                for i=1:length(ids2Del)
                    gi.deleteVariables(ids2Del(i),false);
                end                
            end
            
            gi.reg.update();
            gi.createAdjacency();
            gi.name = [gi.name postfix];
        end
        function Splus = flaugergues(this)
            % Flaugergues: Monitorable system derivation from Flaugergues2009
            % V. Flaugergues, V. Cocquempot, M. Bayart, and M. Pengov, “Structural Analysis for FDI: a modified, 
            % invertibility-based canonical decomposition,” in Proceedings of the 20th International Workshop on 
            % Principles of Diagnosis, DX09, 2009, pp. 59–66.

            % Generate LiUSM model
            this.buildLiUSM();
            
            % Capture G+
            Splus = this.getOver();
            
            % Create S+*
            SplusStar = copy(Splus);
            
            % Delete non-invertible edges to get S+*
            edge_ids = SplusStar.getEdgeIdByProperty('isNonSolvable');
            if ~isempty(edge_ids)
                SplusStar.deleteEdges(edge_ids);
                SplusStar.createAdjacency(); % Update the adjacency matrix
            end
            
            % Compute DM on S+*
            sg = SubgraphGenerator(SplusStar);
            sg.buildLiUSM();
            dm = GetDMParts(sg.liUSM.X); % Get DM parts anew
            
            % IF S+*- == [] DONE
            if isempty(dm.Mm.row) % Mm has no equations
                return;
            % ELSE
            else
            % Find non-reachable variables VNR
                varInd_nr = dm.Mm.col; % Get nonreachable variable Ids
                varIds_unknown = SplusStar.getVariablesUnknown();
                varIds_nr = varIds_unknown(varInd_nr);
            % Find corresponding equations CNR of the original graph
                equIds_nr = unique(Splus.getEquations(varIds_nr));
                
            % Form S+R by subtracting them
                Splus.deleteVariables(varIds_nr);
                Splus.deleteEquations(equIds_nr);
                Splus.createAdjacency();
            % Start over
                this.setGraphInterface(Splus);
                Splus = this.flaugergues();
                return;
            end
                
            
        end
        function [ gi ] = getOver( this )
            %GETOVER Over-constrained partition
            %   Return a new graph object, which contains only the over-constrained
            %   partiotion of the input graph object
            
            dm = GetDMParts(this.liUSM.X);
            equInd2Keep = dm.Mp.row;
            ids = this.gi.reg.equIdArray(equInd2Keep);
            
            if isempty(ids)
                error('Tried to produce overconstrained part, but it was empty');
            end
            
            gi = this.buildSubgraph(ids,'postfix','_overconstrained');
%             equInd2Del = setdiff(1:this.numEqs, equInd2Keep);
%             equIds2Del = this.equationIdArray(equInd2Del);
%             
%             graph = this.copy();
%             graph.deleteEquation(equIds2Del);
            
        end
        
        
    end
    
end

