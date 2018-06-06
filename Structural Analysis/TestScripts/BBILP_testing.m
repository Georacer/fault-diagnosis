%% CEP-BBILP
% CEP-BBILP - Script showcasing the Branch and Bound Binary ILP
% Author: George Zogopoulos-Papaliakos
% Control Systems Laboratories, School of Mechanical Engineering, National
% Technical University of Athens
% email: gzogop@mail.ntua.gr
% Website: https://github.com/Georacer
% March 2018; Last revision: May 2018

% This demo script involves: FIXME
% * Generation of the Structural Model
% * Extraction of PSOs for maximum fault isolation
% * Finding valid matchings for each subgraph
% * Implementation of every residual generator
% * Calculation of the residuals using a stored log

% INSTRUCTIONS:


close all
clear
clc

%% Setup program execution

% Select the mode of operation
opMode = 'continuous';
% opMode = 'breaking';

% Select the MAVLink model for processing
modelArray = {};

% Benchmarks:
% ---------------------
% * g014e(weR1)
% * ThreeTankAnalysis(FDT)(g008)
% * Commault(FDT)(g021)
% * Damadics(FDT)(g022)
% * ElectricMotor(FDT)(g023)
% * InductionMotor(FDT)(g024)
% * Raghuraj(FDT)(g025)
% * SmallLinear(FDT)(g026)

% modelArray{end+1} = g008();
% modelArray{end+1} = g021();
% modelArray{end+1} = g022();
% modelArray{end+1} = g023();
% modelArray{end+1} = g024();
% modelArray{end+1} = g025();
% modelArray{end+1} = g026();

% modelArray{end+1} = g035();
% modelArray{end+1} = g036();

% modelArray{end+1} = g014g();
modelArray{end+1} = g005a();

matchMethod = 'BBILP';
% matchMethod = 'Exhaustive';

SOType = 'MTES';
% SOType = 'MSO';

% branchMethod = 'cheap';
branchMethod = 'DFS';
% branchMethod = 'BFS';

% Build the options structure
SA_settings.matchMethod = matchMethod;
SA_settings.SOType = SOType;
SA_settings.branchMethod = branchMethod;
SA_settings.plotGraphInitial = true;
SA_settings.plotGraphOver = true;
SA_settings.plotGraphRemaining = true;
SA_settings.plotGraphDisconnected = true;
SA_settings.plotGraphPSO = true;
SA_settings.plotGraphMatched = true;

% For each model
for modelIndex=1:length(modelArray)
    
    close all;
    
    %% Read the model description and create the initial graph
    model = modelArray{modelIndex};
    
    %% Perform Structural Analsysis and Matching, extract residual generators
    SA_results = structural_analysis(model, SA_settings);
    
    %% Display the total number of residual generators found
    
    fprintf('Matching Statistics\n');
    fprintf('===================\n');
    counter = 0;
    for i=1:length(SA_results.matchings_set)
        for j=1:length(SA_results.matchings_set{i})
            if ~isempty(SA_results.matchings_set{i}{j})
                counter = counter + 1;
            end
        end
    end
    
    fprintf('Total number of valid residuals found: %d\n',counter);
    
%     length(graphInitial.getEdgeIdByProperty('isDerivative'))
%     length(graphInitial.getEdgeIdByProperty('isNonSolvable'))

    graphName = SA_results.gi.name;
    
    % Average PSO size
    numSets = 0;
    for i=1:length(SA_results.stats.(graphName).ResGenSets)
        numSets = numSets + length(SA_results.stats.(graphName).ResGenSets{i});
    end
    fprintf('Total number of PSOs: %d\n',numSets);
    
    total = 0;
    for j=1:length(SA_results.stats.(graphName).ResGenSets)    
        for i=1:length(SA_results.stats.(graphName).ResGenSets{j})
            total = total+length(SA_results.stats.(graphName).ResGenSets{j}{i});
        end
    end
    avgSize = total/numSets;
    fprintf('Average PSO size: %g\n',avgSize);

    % Average matching size    
    total = 0;
    counterValid = 0;
    counterEmpty = 0;
    for i=1:length(SA_results.stats.(graphName).matchingSets)
        for j=1:length(SA_results.stats.(graphName).matchingSets{i})
            matching = SA_results.stats.(graphName).matchingSets{i}{j};
            if ~isempty(matching)
                total = total+length(matching);
                counterValid = counterValid + 1;
            else
                counterEmpty = counterEmpty + 1;
            end
        end
    end
    avgSize = total/counterValid;
    fprintf('Number of valid matchings: %d\n',counterValid);
    fprintf('Mean matching size: %g\n',avgSize);
    fprintf('Number of invalid matchings: %d\n',counterEmpty);

    if strcmp(opMode,'breaking')
        input('Press Enter to proceed to the next step...');
        clc
    end
    
    % Initial PSO matching statistics
    if exist('offendingInitial','var')
        validInitial = sum(cellfun(@(x) isempty(x),offendingInitial));
        fprintf('Number of valid initial, relaxed matchings: %d\n', validInitial);
        
        counterInt = 0;
        counterDer = 0;
        counterNI = 0;
        for i=1:length(offendingInitial)
            edgesOffending = offendingInitial{i};
            if isempty(edgesOffending)
                continue;
            end
            if any(SA_results.gi.isDerivative(edgesOffending))
                counterDer = counterDer+1;
            end
            if any(SA_results.gi.isIntegral(edgesOffending))
                counterInt = counterInt+1;
            end
            if any(SA_results.gi.isNonSolvable(edgesOffending))
                counterNI = counterNI+1;
            end
        end
        
        fprintf('Number of initial matching containing invalid derivative edges: %d\n',counterDer);
        fprintf('Number of initial matching containing invalid integral edges: %d\n',counterInt);
        fprintf('Number of initial matching containing invalid non-invertible edges: %d\n',counterNI);
        
    end
    
    
    %% Do detectability analysis
    
    % Create the Fault Signature Matrix and related information
    FSStruct = generateFSM(SA_results.gi, SA_results.res_gens_set, SA_results.matchings_set);
    
    fprintf('Faults not covered:\n');
    SA_results.gi.getExpressionById(SA_results.gi.getEquations(FSStruct.non_detectable_fault_ids))
    
    %% Do isolability analysis
    
    % Create the Isolation Matrix and related information
    IMStruct = generateIM(SA_results.gi, FSStruct);
    plotIM(IMStruct);
    
    if strcmp(opMode,'breaking')
        input('Press Enter to proceed to the next step...');
        clc
    end
    
    return
    
    %% Process statistics and save
    stats = SA_results.stats;
    fileName = sprintf('%s_%s_%s.mat',matchMethod, branchMethod,SOType);
    
    % If no statistics have previously been saved
    if ~exist(fileName)
        fieldNames = fieldnames(stats);
        for i=1:length(fieldNames)
            stats.(fieldNames{i}).samples = 1;
        end
        save(fileName,'stats');
        
    else % Load existing statistics and add another sample
        loadedData = load(fileName,'stats');
        oldStats = loadedData.stats;
        oldFieldNames = fieldnames(oldStats);
        
        newFieldNames = fieldnames(stats);
        for i=1:length(newFieldNames)
            newFieldName = newFieldNames{i};
            if ismember(newFieldName,oldFieldNames) % Existing graph model
                recordedSamples = oldStats.(newFieldName).samples + 1;
                oldStats.(newFieldName).samples = recordedSamples;
                assert(all(cellfun(@(x,y) isequal(x,y),stats.(newFieldName).ResGenSets,oldStats.(newFieldName).ResGenSets)),'Newer version of graph has different ResGenSets');
                assert(all(cellfun(@(x,y) isequal(x,y),stats.(newFieldName).matchingSets,oldStats.(newFieldName).matchingSets)),'Newer version of graph has differente matchingSets');
                oldStats.(newFieldName).timeSetGen = stats.(newFieldName).timeSetGen/recordedSamples + oldStats.(newFieldName).timeSetGen*(recordedSamples-1)/recordedSamples;
                oldStats.(newFieldName).timeMakeSG = stats.(newFieldName).timeMakeSG/recordedSamples + oldStats.(newFieldName).timeMakeSG*(recordedSamples-1)/recordedSamples;
                oldStats.(newFieldName).timeSolveILP = stats.(newFieldName).timeSolveILP/recordedSamples + oldStats.(newFieldName).timeSolveILP*(recordedSamples-1)/recordedSamples;
            else % New graph model
                oldStats.(newFieldName) = stats.(newFieldName);
                oldStats.(newFieldName).samples = 1;
            end
        end
        stats = oldStats;
        save(fileName,'stats');
    end
    

end

return