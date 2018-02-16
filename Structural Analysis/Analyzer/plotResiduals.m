function [ ] = plotResiduals( RE_results, RG_results, timestamp, res_indices )
%PLOTRESIDUALS Iteratively plot residuals
%   Detailed explanation goes here

if size(RE_results.residuals,1)~=length(RG_results.res_gen_cell)
    error('Number of residual signals and residual generators must be equal')
end

if nargin<4
    res_indices = [];
end
if isempty(res_indices)
    res_indices = 1:length(RG_results.res_gen_cell);
end

for i=res_indices
    
    if isempty(RG_results.res_gen_cell{i})
        continue;
    end
    
    res_gen = RG_results.res_gen_cell{i};
    equ_ids = res_gen.gd.getEquations();
    equ_aliases = res_gen.gd.getAliasById(equ_ids);
    var_ids = res_gen.gi.getVariables(equ_ids);
    var_aliases = res_gen.gi.getAliasById(var_ids);
    
    titleString1 = sprintf('Residual plot for generator #%d',i);
    titleString2 = sprintf('Involved equations (IDs): ');
    for j=1:length(equ_ids)
        titleString2 = [titleString2 sprintf('%d, ',equ_ids(j))];
    end
    titleString3 = sprintf('Involved equations (aliases): ');
    for j=1:length(equ_aliases)
        titleString3 = [titleString3 sprintf('%s, ',equ_aliases{j})];
    end
    titleString4 = sprintf('Involved variables (IDs): ');
    for j=1:length(var_ids)
        titleString4 = [titleString4 sprintf('%d, ',var_ids(j))];
    end
    titleString5 = sprintf('Involved variables (aliases): ');
    for j=1:length(var_aliases)
        titleString5 = [titleString5 sprintf('%s, ',var_aliases{j})];
    end
    titleString = {titleString1, titleString2, titleString3, titleString4, titleString5};
    
    h = figure();
    time_vec = timestamp(2:end)-timestamp(1); % Start from 2 to hide error from uninitialized differentiators
    data_vec = RE_results.residuals(i,2:end);
    plot(time_vec, data_vec);
    xlabel('timestamp');
    
    title(titleString, 'interpreter', 'none');
    
    grid on
    
    input('Press enter to continue...');
    
    close(h)

end

