function [ single_fault_ids ] = findSingleFault( FSStruct, triggered_residuals )
%FINDSINGLEFAULT Summary of this function goes here
%   Detailed explanation goes here

single_fault_ids = cell(1,size(triggered_residuals,2));
FSM = FSStruct.FSM;
fault_ids = FSStruct.fault_ids;

% For each time sample
for i=1:length(single_fault_ids)
    fault_signature = triggered_residuals(:,i);
    
    if ~any(fault_signature)
        continue;
    end
    
    explaining_faults = [];
    % For each fault signature
    for j=1:size(FSM,2)
        if all(fault_signature==FSM(:,j))
            explaining_faults(end+1) = fault_ids(j);
        end
    end
    single_fault_ids{i} = explaining_faults;
end

end

