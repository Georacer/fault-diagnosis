function [p,q]=plotDM(gh)
% PlotDM(SM)  Plots a Dulmage-Mendelsohn decomposition

% Uses Linkopping University Fault Diagnosis library

gh.liusm.PlotDM('eqclass',true,'fault',true);

end