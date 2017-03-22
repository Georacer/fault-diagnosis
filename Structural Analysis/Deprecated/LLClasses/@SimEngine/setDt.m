function setDt( eh, dt )
%SETDT Set dt object-wide
%   Detailed explanation goes here

eh.dt = dt;

for i=1:length(eh.functionArray)
    for j=1:length(eh.functionArray{i})
        eh.functionArray{i}{j}.dt = dt;
    end
end

end

