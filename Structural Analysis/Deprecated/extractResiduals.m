function [ Mvalid ] = extractResiduals( graph, MSOs )
%EXTRACTRESIDUALS Find valid residuals in provided MSOs
%   Detailed explanation goes here

% NOTE TO SELF: Most of this functionality has been migrated to
% matchValid()

debug = false;
% Initialize valid matchings container
Mvalid = {};

h = waitbar(0,'Processed MSOs');

for indexMTES = 1:length(MSOs)

    waitbar(indexMTES/length(MSOs),h,sprintf('Found %d residual generators',length(Mvalid)));
    fprintf('*** Examining MSO %d\n',indexMTES);
    MSOcurr = MSOs{indexMTES};

    % Loop over available just-constrained submodels
    M0weights = ones(1,length(MSOcurr))*inf;
    M0pool = cell(1,length(MSOcurr));
    indexIntegral = [];
    for i=1:length(MSOcurr)

        if debug fprintf('*** Examining new M0\n'); end
        SMjust = MSOcurr(setdiff(1:length(MSOcurr),i));
        SMjustIds = graph.equationIdArray(SMjust);
        if debug fprintf('with equation ids: ');  fprintf('%d, ',SMjustIds); fprintf('\n'); end
        if debug fprintf('and aliases: ');  fprintf('%s, ',graph.equations(graph.getIndexById(SMjustIds)).prAlias ); fprintf('\n'); end
        % Find a valid matching for that M0
        A = graph.getSubmodel(SMjustIds,'direction','E2V');
        if (size(A,1)~=size(A,2))
            if debug warning('Tried to match a non-square system'); end
            Mcurr = {};
        else
            [Mcurr] = graph.matchValid(SMjustIds);
        end
        % Count matching lenght
        counter = 0;
        for j=1:length(Mcurr)
            counter = counter + length(Mcurr{j});
        end
        % TODO: compare weights from all MCurrs
        if counter==length(SMjustIds)            
            if debug fprintf('A valid matching for that M0 is (edgeIds): ');  fprintf('%d, ',Mcurr{:}); fprintf('\n'); end
            M0pool(i) = {Mcurr};
            KHcomp = Mcurr(:);
            scc = [];
            for j=1:length(KHcomp)
                scc = [scc KHcomp{j}];
            end
            M0weights(i) = sum(graph.getEdgeWeight(scc));
            
%             % Select for existence of integral edge
%             edgeIndices = graph.getIndexById(scc);
%             foundIntegralEdge = false;
%             for j=edgeIndices
%                 if graph.edges(j).isIntegral
%                     foundIntegralEdge = true;
%                     fprintf('Found integral edge!\n');
%                     break;
%                 end
%             end
        
            
        elseif counter>0            
            if debug fprintf('Only partial matching found\n'); end
        else
            if debug fprintf('No valid matching found\n'); end
        end
    end
    if any(isfinite(M0weights)) %Process matching of this M0   

        % Search for cheapest matching weight
        [~, pivot] = sort(M0weights);
        i = pivot(1);
        Mvalid(end+1) = {[MSOcurr(i) M0pool(i)]};
        
        if debug fprintf('The selected matching for this MSO is (edgeIds): ');  fprintf('%d, ',M0pool{i}{:}); fprintf('\n'); end
    else
        if debug fprintf('No valid matching could be found for this MSO\n'); end
    end
end

close(h)

end

