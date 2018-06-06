function [ fault_response_vector_set ] = getFaultResponseVector( res_gen_cell, fault_response_vector_set, tests_to_run )
%GETFAULTRESPONSEVECTOR Return the Fault Response Vector of given residuals
%   INPUTS:
%   res_gen_cell             : A cell array with ResidualGenerator objects
%   fault_response_vector_set: (Partially) pre-calculated fault_response_vector_set
%   tests_to_run             : A 1xlength(residuals) cell array. Contains
%       an 2 x n_fault array true/false vector. Top row is minimum resonse mask
%       Bottom row is maximum response mask. Overall specficies which tests to run

% Allow for pre-calculated fault response vectors
if nargin<2
    fault_response_vector_set = cell(1,length(res_gen_cell));
end

if isempty(fault_response_vector_set)
    fault_response_vector_set = cell(1,length(res_gen_cell));
end

if nargin<3
    tests_to_run = [];
end    

% Iterate over all residual generators
for i=1:length(res_gen_cell)
    if isempty(res_gen_cell{i})
        continue;
    end
    
%     % Find the affecting faults
%     equ_ids = res_gen_cell{i}.equIdArray;
%     var_ids = res_gen_cell{i}.gi.getVariables(equ_ids);
%     fault_mask = res_gen_cell{i}.gi.isFault(var_ids);
%     fault_ids = var_ids(fault_mask);
    
    if isempty(tests_to_run)    
        testMask = [];  % Test for all faults
    else
        testMask = tests_to_run{i};  % Test only for specific faults
    end
    
    pso_opt = ResidualSensitivity(res_gen_cell{i},'timeDetection',0.1, 'testMask', testMask);
    fault_response_vector = pso_opt.get_residual_sensitivity();
    
    if isempty(testMask)
        faultIndex = 1:length(fault_response_vector);
    else
        fautlIndex = find(any(testMask,1));
    end
    
    % Update results
    existing_fault_response_vector = fault_response_vector_set{i};
    if ~isempty(existing_fault_response_vector)
        for j=faultIndex
            current_min = fault_response_vector(1,j);
            if existing_fault_response_vector(1,j) > current_min
                existing_fault_response_vector(1,j) = current_min;
            end
            current_max = fault_response_vector(2,j);
            if existing_fault_response_vector(2,j) < current_max
                existing_fault_response_vector(2,j) = current_max;
            end
            fault_response_vector_set{i} = existing_fault_response_vector;
        end
    else
        fault_response_vector_set{i} = fault_response_vector;
    end
    
    fprintf('Final Fault Response Vector:\n');
    disp(fault_response_vector_set{i});
    
end

profile off

end

