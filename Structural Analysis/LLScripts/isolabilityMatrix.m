function [ im ] = isolabilityMatrix( fsm )
%ISOLABILITYMATRIX Summary of this function goes here
%   Detailed explanation goes here

nr = size(fsm,1);
nf = size(fsm,2);

im = ones(nf, nf);

for i=1:nr
    im(fsm(i,:)>0,fsm(i,:)==0)=0;
end

end

