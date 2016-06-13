function storeReadings( eh, iteration )
%STOREREADINGS Store inputs and measurements
%   Read the known variable values (inptus and measurements) for this loop
%   iteration and store them on the appropriate array for the evaluation of
%   the next step

    global readings

    eh.readingsValues = readings(iteration,:);

end

