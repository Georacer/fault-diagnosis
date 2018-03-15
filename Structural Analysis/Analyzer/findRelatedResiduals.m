function [ residuals_indices ] = findRelatedResiduals( SA_results, FSStruct, fault_id )
%FINDRELATEDRESIDUALS Find all the residuals related to a fault
%   Detailed explanation goes here

equ_id = SA_results.gi.getEquations(fault_id);

residuals_indices = [];
for i=1:length(FSStruct.residual_constraints)
if ismember(equ_id, FSStruct.residual_constraints{i})
    residuals_indices(end+1) = i;
end

end

