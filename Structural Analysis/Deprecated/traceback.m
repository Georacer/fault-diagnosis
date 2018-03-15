function [ output_args ] = traceback( argname, Graph, matching )
%TRACEBACK DEPRECATED Extract the calculation tree for a variable
%   Depends upon PARSETREE(), probably only used for non-looping matchings
%   Prints onto a MATLAB plot the graph

node = isMatched(argname, Graph, matching);

if ~node.matched
    if node.type == 2
        disp('This argument is a constraint!');
        % Fill the output
        return;
    end
    disp('This variable is not matched!');
    % Fill the output
    return;
end
    
map = parseTree(argname,[],Graph,matching);

reducedAdj = Graph.adjacency(map.conData(:,1),map.varData(:,1));
reducedCons = Graph.constraints(map.conData(:,1));
reducedVars = Graph.vars(map.varData(:,1));
numCons = length(reducedCons);
numVars = length(reducedVars);

extendedAdj = [eye(numVars) reducedAdj';...
    reducedAdj eye(numCons)];

coords = zeros(numVars+numCons,2);

figure();
hold on;

% Plot variables first
records = zeros(max(map.varData(:,2))+1,1);
spans = records;
for i=1:length(spans)
    spans(i) = sum(map.varData(:,2)==i);
end
for i=1:numVars
    rank = map.varData(map.varData(:,1)==find(ismember(Graph.vars,reducedVars{i})),2);
    coords(i,2) = rank;
    coords(i,1) = floor(records(rank+1) - spans(rank+1)/2);
    text(coords(i,1)+0.05,coords(i,2)+0.05,reducedVars{i},'FontSize',14);
    records(rank+1) = records(rank+1) + 1;
end

% Then proceed to plot constraints
records = zeros(max(map.varData(:,2))+1,1);
spans = records;
for i=1:length(spans)
    spans(i) = sum(map.conData(:,2)==i);
end
for i=1:numCons
    rank = map.conData(map.conData(:,1)==find(ismember(Graph.constraints,reducedCons{i})),2);
    coords(i+numVars,2) = rank+0.5;
    coords(i+numVars,1) = floor(records(rank+1) - spans(rank+1)/2)+0.6;
    text(coords(i+numVars,1)+0.05,coords(i+numVars,2)+0.05,reducedCons{i},'FontSize',14);   
    records(rank+1) = records(rank+1) + 1;
end

gplot(extendedAdj,coords,'-o');
grid on
set(gca,'Ytick',[0:1:(max(map.varData(:,2))+1)]);
set(gca,'Xtick',[]);

end

