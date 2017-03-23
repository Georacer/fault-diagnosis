clear

%% Specify installation directory for CSparse
CSPARSEDIR = '/Users/frisk/sw/CSparse';

% Derive include and lib directory
CSPARSEINC=['-I' fullfile(CSPARSEDIR, '/Include')]; 
CSPARSELIB=['-L' fullfile(CSPARSEDIR, '/Lib')]; 

%% Compile sources and link mex-file

mex('-c', '-largeArrayDims', CSPARSEINC,'MSOAlg.cc');
mex('-c', '-largeArrayDims', CSPARSEINC,'SparseMatrix.cc');
mex('-c', '-largeArrayDims', CSPARSEINC,'StructuralAnalysisModel.cc');
mex('-c', '-largeArrayDims', CSPARSEINC,'FindMSOcompiled.cc');

% Link 
mex(CSPARSELIB, 'FindMSOcompiled.o', 'SparseMatrix.o', 'StructuralAnalysisModel.o', 'MSOAlg.o', '-lcsparse');

