function [ adjacency,UVars,KVars ] = lineParser( string, adjacency, UVars, KVars )
%LINEPARSER Parse a model equation coded string
%   Parse a model equation coded string and fill adjacency matrix and
%   symbolic arrays with corresponding information

%   Adjacency Matrix Specification
%   Columns with UVars come first
%   Columns with IVars come next
%   Columns with OVars come last

    debug = false;

    if nargin==1
        adjacency=[];
        UVars={};
%         IVars={};
%         OVars={};
        KVars={};
    end
    
    % Add a new row and column in the adjacency matrix to host the new
    % constraint
    if (isempty(adjacency))
        adjacency = [0];
    else
    adjacency = [adjacency zeros(size(adjacency,1),1);...
                    zeros(1,size(adjacency,2)) 0 ];
    end
    
    % Test input data validity
    UVarsNo = length(UVars);
%     IVarsNo = length(IVars);
%     OVarsNo = length(OVars);
    KVarsNo = length(KVars);
%     if (size(adjacency,2)~=(UVarsNo + KVarsNo))
%         error('INVALID INPUT DATA');
%     end
    
    % legend:
    % {} - normal term
    % dot - differential term
    % int - integral term
    % trig - trigonometric term
    % ni - general non-invertible term
    % inp - input variable % NOT SUPPORTED
    % out - output variable % NOT SUPPORTED
    % msr - measured variable
    operators = {'dot','int','trig','ni','inp','out','msr'};
    inputVar = false;
    outputVar = false;
    msrVar = false;
    markC2V = '1'; % char(49)
    markV2C = '1'; % char(49)
    
    words = strsplit(string,' ');
    for i=1:size(words,2)
        word = words{i};
        opIndex = find(strcmp(operators, word));
        if isempty(opIndex)
            opIndex = -1;
        end
        if debug disp(sprintf('opIndex=%i',opIndex)); end
        switch opIndex % Test if the word is an operator
            case 1
                markC2V = 'D';
                markV2C = 'D';
            case 2
                markC2V = 'I';
                markV2C = 'I';
            case 3
                markC2V = 'T';
                markV2C = 'T';
            case 4
                markC2V = 0;
            case 5
                error('Unsupported option: inp');
                break;
                inputVar = true; % NOT SUPPORTED
            case 6
                error('Unsupported option: out');
                break;
                outputVar = true; % NOT SUPPORTED
            case 7
                msrVar = true;
                markC2V = 0;
            otherwise % Found a variable
                % Lookup the variable
                exists = false;
                if (inputVar) % It is an input variable
%                     inputVar = false;
%                     varIndex = find(strcmp(IVars,word));
%                     if isempty(varIndex) % This input variable was not yet met
%                         IVars = {IVars{:},word};
%                         splitIndex = UVarsNo+IVarsNo;
%                         IVarsNo = IVarsNo + 1;
%                     else % This input variable already exists
%                         entryIndex = UVarsNo + varIndex;
%                         exists = true;
%                     end
                elseif (outputVar) % It is an output variable
%                     outputVar = false;
%                     varIndex = find(strcmp(OVars,word));
%                     if isempty(varIndex) % This output variable was not yet met
%                         OVars = {OVars{:},word};
%                         splitIndex = UVarsNo+IVarsNo+OVarsNo;
%                         OVarsNo = OVarsNo + 1;
%                     else % This input variable already exists
%                         entryIndex = UVarsNo + IVarsNo + varIndex;
%                         exists = true;
%                     end
                elseif (msrVar)
                    msrVar = false;
                    varIndex = find(strcmp(KVars,word)); % Check if the variable is already met
                    if isempty(varIndex) % This known variable was not yet met
                        KVars = [KVars,{word}];
                        splitIndex = UVarsNo+KVarsNo; % Place the new variable at the end
                        KVarsNo = KVarsNo + 1;
                    else % This input variable already exists
                        entryIndex = UVarsNo + varIndex; % Place the variable in its correct index
                        exists = true;
                    end                    
                else % It is an unknown variable
                    varIndex = find(strcmp(UVars,word)); % Check if the variable is already met
                    if isempty(varIndex) % This output variable was not yet met
                        UVars = [UVars, {word}];
                        splitIndex = UVarsNo; % Place the new variable at the end of the unknown variables list
                        UVarsNo = UVarsNo + 1;
                    else % This input variable already exists
                        entryIndex = varIndex;
                        exists = true;
                    end                   
                end
                
                % Update the adjacency table
                if (exists)
                    if debug disp(sprintf('entryIndex=%i',entryIndex)); end
                    adjacency(end,entryIndex) = markC2V;
                    adjacency(entryIndex,end) = markV2C;
                else
                    if debug disp(sprintf('splitIndex=%i',splitIndex)); end
                    newColumn = zeros(size(adjacency,1),1); %Prepare the new column
                    newColumn(end) = markC2V;
                    newRow = zeros(1,size(adjacency,2));
                    newRow(end) = markV2C;
                    
                    if (splitIndex==0)
                        adjacency = [newColumn adjacency]; % Add column
                        adjacency = [[0 newRow]; adjacency]; % Add row
                    else
                        adjacency = [adjacency(:,1:splitIndex) newColumn adjacency(:,(splitIndex+1):end)]; % Add column
                        adjacency = [adjacency(1:splitIndex,:); [0 newRow]; adjacency((splitIndex+1):end,:)]; % Add row
                    end
                    
                    
                end
                markC2V = '1';
                markV2C = '1';
        end
    end

end

