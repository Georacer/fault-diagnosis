function [ resp ] = validateMatching( gh, M )
%% DELETEME
%VERIFYMATCHING Summary of this function goes here
%   Detailed explanation goes here

resp = true;

for i=1:length(M)
   KHcomp = M{i};
   if length(KHcomp)==1 % This is a path edge
       if ~gh.isMatchable(KHcomp)
           resp = false;
           return
       end
   else % This is a loop edge
       for j=1:length(KHcomp)
           edgeIndex = gh.getIndexById(KHcomp(j));
           if (~gh.isMatchable(KHcomp(j))) || (gh.edges(edgeIndex).isDerivative)
               resp = false;
               return
           end
       end
   end
end

end

