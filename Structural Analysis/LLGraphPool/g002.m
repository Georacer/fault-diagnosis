function [ constraints, coords ] = g002( )
%G001 Model of the lateral response of an airplane
%   Detailed explanation goes here

con = [...
    {'msr da_c da'};...
    {'da Va l'};...
    {'Va msr Va_m'};...
    {'l p'};...
    {'p msr p_m'};...
    ];
    
constraints = [{con},{'c'}];

% coords = [];
coords = [...
    0.1738    0.5731;...
    0.3872    0.3928;...
    0.5947    0.5681;...
    0.8032    0.3991;...
    0.3882    0.7371;...
    0.1627    0.1873;...
    0.5927    0.1923;...
    0.1708    0.7383;...
    0.3878    0.5694;...
    0.1655    0.3928;...
    0.7992    0.5681;...
    0.5887    0.4004;...
    ];


end

