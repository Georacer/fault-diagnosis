classdef SubgraphGenerator < matlab.mixin.Copyable
    %SUBGRAPHGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gi = GraphInterface.empty;
        liUSM = DiagnosisModel.empty;
        MSOs = {};
        MTESs = {};
    end
    
    methods
        function obj = SubgraphGenerator(gi)
            % Constructor
            obj.gi = gi;
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
                warning('MTESs not initialized yet');
            end
            MTESs = this.MTESs;
            return            
        end
        function gi = buildSubgraph(this,varargin)
            
            p = inputParser;
            
            p.addRequired('this',@(x) true);
            p.addRequired('equIds',@(x) all(isnumeric(x)));
            p.addOptional('varIds',[],@(x) all(isnumeric(x)));
            p.addParameter('postfix', '_submodel' ,@isstr);
            p.addParameter('pruneKnown',false,@islogical);
            
            p.parse(this, varargin{:});
            opts = p.Results;

            equIds = opts.equIds;
            varIds = opts.varIds;
            postfix = opts.postfix;
            pruneKnown = opts.pruneKnown;
            
            gi = copy(this.gi);
            
            % Delete equations
            allIds = this.gi.reg.equIdArray;
            ids2Del = setdiff(allIds,equIds);
            for i=1:length(ids2Del)
                gi.deleteEquations(ids2Del(i));
            end
            
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
            
            gi.createAdjacency();
            gi.name = [gi.name postfix];
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

