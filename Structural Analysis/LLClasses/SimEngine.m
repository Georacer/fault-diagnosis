classdef SimEngine < matlab.mixin.Copyable
    %SIMENGINE Simulation Engine object
    %   Uses a graph object to evaluate its matchings
    
    properties
        gh = GraphBipartite.empty;
        functionArray = Function.empty;
        dt = 0.01;
    end
    
    methods
        function this = SimEngine(GH)
            this.gh = GH;
            s = sprintf('functions_%s',this.gh.name);
            if (~exist([s '.m'],'file')) % Functions file does not exist. Create it
                fileID = fopen([s '.m'],'wt');
                % Write header
                fprintf(fileID,'function fArray = %s()\n',s);
                fprintf(fileID,'\t%% %s Function evaluations for graph model %s\n',s,this.gh.name);
                
                for equId = this.gh.equationIdArray
                    for varId = this.gh.getVariables(equId)
                        this.assignHandle(fileID, equId, varId);
                    end                    
                end                
                
                for equId = this.gh.equationIdArray
                    for varId = this.gh.getVariables(equId)
                        this.generateEntry(fileID, equId, varId);
                    end                    
                end
                
                fprintf(fileID,'\nend');
                fclose(fileID);
                disp('Please fill in the %s file and create me again');
                return                
            else
                this.functionArray = feval(sprintf('functions_%s',this.gh.name));
                
            end
            
        end
        
        % Generate a new function entry for one function evaluation
        function generateEntry(this, fileID, equId, varId)
            % Write first row            
            varAlias = this.gh.getAliasById(varId);
            s = sprintf('\nfunction %s = f_%d_%d(',varAlias{:},equId,varId);
            edgeId = this.gh.getEdgeIdByVertices(equId,varId);            
            equIndex = this.gh.getIndexById(equId);
            equAlias = this.gh.getAliasById(equId);
            varIds = this.gh.getVariables(equId);
            numVars = length(varIds);
            otherVars = setdiff(varIds,varId);
            varNames = this.gh.getAliasById(otherVars);
            
            if length(varNames)>1
                s = [s sprintf('%s,',varNames{1:end-1})];
            end
            s = [s sprintf('%s', varNames{end})];
            s = [s sprintf(')\n')];
            fprintf(fileID,s);
            
            % Write comments
%             s = [s sprintf('%% Evaluation definition for equation %s with id %d\n',equAlias{:}, equId)];
            fprintf(fileID,'%% Evaluation definition for equation %s with id %d\n',equAlias{:}, equId);
            fprintf(fileID,'%% Equation structural description: %s\n',this.gh.equations(equIndex).expressionStructural);
            fprintf(fileID,'%% Evaluate for variable: %s\n\n', varAlias{:});
            
            s = '';
            if this.gh.isMatchable(edgeId)
                % Write placeholder text
                fprintf(fileID,'%% Write calculation here\n');
            else
                % Write error message
                fprintf(fileID,'error(''This evaluation is not possible'');\n');
            end
            
            % Close the function
            fprintf(fileID,'end\n');
        end
        
        % Assing the function handle in the fh cell array
        function assignHandle(this, fileID, equId, varId)
            equIndex = this.gh.getIndexById(equId);
            varIds = this.gh.getVariables(equId);
            varIndex = find(varIds==varId);
            funName = sprintf('f_%d_%d',equId,varId);
            s = sprintf('fArray{%d}{%d} = @%s;\n',equIndex, varIndex, funName);
            fprintf(fileID,s);
        end
        
        % Evaluate the requested function
        function val = evaluate(this, equId, varId, args)
            equIndex = this.gh.getIndexById(equId);
            varIds = this.gh.getVariables(equId);
            varIndex = find(varIds==varId);
            val = feval(this.functionArray{equIndex}{varIndex},args{:});            
        end
        
        
    end
    
end
