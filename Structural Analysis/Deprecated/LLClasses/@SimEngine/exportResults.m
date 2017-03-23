function exportResults( eh, row_num, evalValues, residualValues )
%EXPORTRESULTS Summary of this function goes here
%   Detailed explanation goes here

    global evaluations
    global residuals
    
    evaluations(row_num,:) = evalValues;
    residuals(row_num,:) = residualValues;

end

