function [ faults_excluded ] = excludeFaults( FSStruct, triggered_residuals )
%FINDSINGLEFAULT Summary of this function goes here
%   Detailed explanation goes here

faults_excluded = cell(1,size(triggered_residuals,2));
FSM = FSStruct.FSM;
valid_matchings_mask = FSStruct.valid_matchings_mask;
fault_ids = FSStruct.fault_ids;

% For each time sample
for i=1:length(faults_excluded)
    actual_fault_signature = triggered_residuals(:,i);
    
    
    non_explaining_faults = [];
    % For each residual
    for j=1:length(actual_fault_signature)
        
        % Check if it was actually implemented
        if ~valid_matchings_mask(j)
            continue;
        end
        
        if ~actual_fault_signature(j)
            % This residual did not trigger
            related_fault_mask = FSM(j,:);
            related_fault_ids = fault_ids(logical(related_fault_mask));
            non_explaining_faults = union(non_explaining_faults, related_fault_ids);
        end
    end
    faults_excluded{i} = non_explaining_faults;
    
    % Also exclude non-detectable faults
    faults_excluded{i} = union(faults_excluded{i}, FSStruct.non_detectable_fault_ids);
end


end

