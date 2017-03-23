function [ constraints, coords ] = randomGraph( numEqu, numVar )
%RANDOMGRAPH Generator a random system description
%   Detailed explanation goes here

numEls = numEqu+numVar;
density = 0.3;
niChance = 20;
derChance = 10;
% A = sprandsym(numEls, density);
A = sprand(numEqu, numVar, density);
% A = A .* (ones(numEls,numEls) - eye(numEls));

con = {};

for i=1:numEqu
    
    if any(A(i,:))        
        newline = '';
        
        for j=1:numVar
            
            prefix = '';
            if rand<(1/derChance)
                prefix = 'dot ';
            elseif rand<(1/niChance)
                prefix = 'ni ';
            end
            
            if A(i,j)
                newline = [newline prefix sprintf('v%d ',j)];
            end
            
        end
        con(end+1,1) = {strtrim(newline)};
    end
end

constraints = [{con},{'c'}];

coords = [];

end

