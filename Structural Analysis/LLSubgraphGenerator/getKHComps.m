function [ KH ] = getKHComps( gi, A, equIds, varIds )
%GETKHCOMPS Summary of this function goes here
%   Detailed explanation goes here

% Perform a DM
dm = GetDMParts(A);

KH = cell(1,length(dm.M0));
for i=1:length(KH)
    KHrows = dm.M0{i}.row;
    KHcols = dm.M0{i}.col;
    KH{i}.equIds = equIds(KHrows);
    KH{i}.varIds = varIds(KHcols);
    edgegroup = []; % Improve by checking only nz elements in KH
    for j=1:length(KHrows)
        for k=1:length(KHcols)
            id = gi.getEdgeIdByVertices(KH{i}.equIds(j),KH{i}.varIds(k));
            if ~isempty(id)
                edgegroup(end+1) = id;
            end
        end
    end
    KH{i}.edgegroup = edgegroup; % and the edges corresponding to each one
end

end

