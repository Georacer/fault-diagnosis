classdef g007 < model
    %% Linear T.I. airplane model found in
    % Izadi-Zamanabadi, R. (2002).
    % Structural analysis approach to fault diagnosis with application to fixed-wing aircraft motion.
    % Proceedings of the 2002 American Control Conference (IEEE Cat. No.CH37301), 5, 3949–3954. doi:10.1109/ACC.2002.1024546
    
    % x1dot = a11 x1 + a13 x3 + a14 x4 + a16 x6
    % x2dot = a21 x1 + a22 x2 + a23 x3 + a27 x7
    % x3dot = a31 x1 + a33 x3 + a36 x6
    % x4dot = x2
    % x5dot = x3 + a55 x5
    % x6dot = a66 x6 + b61 u1
    % x7dot = a77 x7 + b72 u2
    % y1 = x1
    % y2 = x4
    % y3 = x5
    methods
        function this = g007()
            this.name = 'g007';
            this.description = 'Linear T.I. airplane model found in "Structural analysis approach to fault diagnosis with application to fixed-wing aircraft motion"';
            
            con = [...
                {'dot_x1 x1 x3 x4 x6'};...
                {'dot_x2 x2 x1 x3 x7'};...
                {'dot_x3 x1 x3 x6'};...
                {'dot_x4 x2'};...
                {'dot_x5 x3 x5'};...
                {'fault dot_x6 x6 inp u1'};...
                {'fault dot_x7 x7 inp u2'};...
                ];
            
            der = [...
                {'dot x1 int dot_x1'};...
                {'dot x2 int dot_x2'};...
                {'dot x3 int dot_x3'};...
                {'dot x4 int dot_x4'};...
                {'dot x5 int dot_x5'};...
                {'dot x6 int dot_x6'};...
                {'dot x7 int dot_x7'};...
                ];
            
            msr = [...
                {'fault msr y1 x1'};...
                {'fault msr y2 x4'};...
                {'fault msr y3 x5'};...
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
