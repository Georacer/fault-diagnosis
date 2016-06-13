classdef SimEngine < matlab.mixin.Copyable
    %SIMENGINE Simulation Engine object
    %   Uses a graph object to evaluate its matchings
    
    properties
        gh = GraphBipartite.empty;
        functionArray = Function.empty;
        dt = 0.01;
        
        evaluations
        
    end
    
    methods
        
        function eh = SimEngine(GH)
            eh.gh = GH;
            
            % Initialize the variable values array
            evaluations = nan*ones(1,eh.gh.numVars);   
            
            s = sprintf('functions_%s',eh.gh.name);
            if (~exist([s '.m'],'file')) % Functions file does not exist. Create it
                fileID = fopen([s '.m'],'wt');
                % Write header
                fprintf(fileID,'function fArray = %s()\n',s);
                fprintf(fileID,'\t%% %s Function evaluations for graph model %s\n',s,eh.gh.name);
                
                for equId = eh.gh.equationIdArray
                    for varId = eh.gh.getVariables(equId)
                        eh.assignHandle(fileID, equId, varId);
                    end
                end
                
                for equId = eh.gh.equationIdArray
                    for varId = eh.gh.getVariables(equId)
                        eh.generateEntry(fileID, equId, varId);
                    end
                end
                
                fprintf(fileID,'\nend');
                fclose(fileID);
                disp('Please fill in the %s file and create me again');
                return
            else
                eh.functionArray = feval(sprintf('functions_%s',eh.gh.name));
                
            end            
        end
                
        %% External methods declarations
        
        [val] = evaluateSingle(eh, eqId, varId)
        generateEntry(eh, fileID, equId, varId)
        assignHandle(eh, fileID, equId, varId)
        val = evaluate(eh, equId, varId, args)
        storeReadings( eh, readingsArray)
        specification(eh)
        
    end
    
end
