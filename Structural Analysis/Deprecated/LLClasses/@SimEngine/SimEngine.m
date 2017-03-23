classdef SimEngine < matlab.mixin.Copyable
    %SIMENGINE Simulation Engine object
    %   Uses a graph object to evaluate its matchings
    
    properties
        gh = GraphBipartite.empty;
        functionArray = Function.empty;
        dt = 0.01;
        
        inpIds % Holds the input ids
        msrIds % Holds the measurements ids
        readingsIdArray % Holds the readings ids
        readingsValues
        residualIds % Holds the residual ids
        residualValues
        evalIds % Holds the simulated variable ids        
        evalValues
    end
    
    methods
        
        function eh = SimEngine(GH)
            eh.gh = GH;
            
            % Get the inputs and readings of the model
            eh.inpIds = GH.getVarIdByProperty('isInput');
            eh.msrIds = GH.getVarIdByProperty('isMeasured');
            eh.readingsIdArray = [eh.inpIds eh.msrIds];
            eh.readingsValues = nan*ones(1,length(eh.readingsIdArray));
            eh.residualIds = GH.getVarIdByProperty('isResidual');
            eh.residualValues = nan*ones(1,length(eh.residualIds));
            
            % Initialize the variable values array
            eh.evalIds = setdiff(GH.variableIdArray, [eh.readingsIdArray eh.residualIds]);
            eh.evalValues = nan*ones(1,length(eh.evalIds));
                
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
                eh.setDt(0.01);
            end            
        end
                
        %% External methods declarations
        
        assignHandle(eh, fileID, equId, varId)
        val = evaluate(eh, equId, varId, args)
        evaluateSingle(eh, eqId, varId)
        exportResults(eh, i, evals, residuals)
        generateEntry(eh, fileID, equId, varId)
        val = getValue(eh, varId)
        resp = isAvailable(eh,varId)
        [residuals] = runDiagnoserSingle(eh)
        setDt(eh,dt)
        setValue(eh, varId, value)
        specification(eh)
        storeReadings( eh, readingsArray)
        
    end
    
end
