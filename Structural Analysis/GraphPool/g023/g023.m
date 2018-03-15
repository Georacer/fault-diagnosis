classdef g023 < model
    % Model of electric motor, taken from Fault Diagnosis Toolbox%
    methods
        function this = g023()
            this.name = 'g023';
            this.description = 'Model of electric motor, taken from Fault Diagnosis Toolbox';

%   V == I*(R+fR) + L*dI + Ka*I*w,... % e1
%   Tm == Ka*I^2, ...                 % e2
%   J*dw == DT-b*w, ...               % e3
%   DT == Tm-Tl, ...                  % e4
%   dth == w, ...                     % e5
%   dw == alpha, ...                  % e6
%   yi == I + fi, ...                 % e7
%   yw == w + fw, ...                 % e8
%   yd == DT + fD, ...                % e9
            con = [...
                {'msr V I dI w R par Ka par L expr -V+I*R+L*dI+Ka*I*w'};...
                {'Tm I par Ka expr -Tm+Ka*I^2'};...
                {'dw DT w par b par J expr -J*dw+DT-b*w'};...
                {'DT Tm Tl expr -DT+Tm-Tl'};...
                {'dth w expr -dth+w'};...
                {'dw alpha expr -dw+alpha'};...
                ];
            
            der = [...
                {'int dI dot I expr differentiator'};...
                {'int dw dot w expr differentiator'};...
                {'int dth dot th expr differentiator'};...
                ];
            
            msr = [...
                {'fault R par R0 expr -R+R0'};...
                {'fault msr yi I expr -yi+I'};...
                {'fault msr yw w expr -yw+w'};...
                {'fault msr yd DT expr -yd+Dt'};...
                ];
                
            this.constraints = [...
                {con},{'c'};...
                {der},{'d'};...
                {msr},{'s'};...
                ];
            
            this.coordinates = [];
            
        end
        
    end
    
end