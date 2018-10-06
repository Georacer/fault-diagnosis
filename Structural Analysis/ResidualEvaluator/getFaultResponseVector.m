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

    gi = res_gen_cell{i}.gi;
    fault_ids_max = gi.getVarIdByProperty('isFault');
    fault_ids_min = gi.getVarIdByProperty('isFault');
    fault_min_response_vector = inf*ones(size(fault_ids_min));
    fault_max_response_vector = zeros(size(fault_ids_max));
    
    if isempty(tests_to_run)
        testmask=[];
    else
        testmask = tests_to_run{i};
    end
    
    if isempty(testmask)    
        testmask = ones(2,length(fault_ids_max));
    end
    
    counter = 0;
    for tf = testmask(2,:)
        counter = counter + 1;
        if ~tf
            continue
        end
        pso_opt = ResidualResponse(res_gen_cell{i}, fault_ids_max(counter), 'timeDetection', 0.1);  
        fault_max_response_vector(counter) = pso_opt.get_max_response();
    end
    
    counter = 0;
    for tf = testmask(1,:)
        counter = counter + 1;
        if ~tf
            continue
        end
        pso_opt = ResidualResponse(res_gen_cell{i}, fault_ids_min(counter), 'timeDetection', 0.1, 'innerProblem', 'pso');  
        fault_min_response_vector(counter) = pso_opt.get_min_response();
    end
    
    % Update results
    existing_fault_response_vector = fault_response_vector_set{i};
    if ~isempty(existing_fault_response_vector)
        for j=1:length(fault_ids_min)
            current_min = fault_min_response_vector(j);
            if existing_fault_response_vector(1,j) > current_min
                existing_fault_response_vector(1,j) = current_min;
            end
        end
        for j=1:length(fault_ids_max)
            current_max = fault_max_response_vector(j);
            if existing_fault_response_vector(2,j) < current_max
                existing_fault_response_vector(2,j) = current_max;
            end
        end
        fault_response_vector_set{i} = existing_fault_response_vector;
    else
        fault_response_vector_set{i} = [fault_min_response_vector; fault_max_response_vector];
    end
    
    fprintf('Final Fault Response Vector:\n');
    disp(fault_response_vector_set{i});
    
end

profile off

end

