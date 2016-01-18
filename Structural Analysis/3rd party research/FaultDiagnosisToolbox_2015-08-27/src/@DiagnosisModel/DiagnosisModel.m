classdef DiagnosisModel < handle
  % DiagnosisModel - Model for diagnosis analysis and residual generator
  % design
  
  % Copyright Erik Frisk, 2015
  % Distributed under the MIT License.
  % (See accompanying file LICENSE or copy at
  %  http://opensource.org/licenses/MIT)

  properties %(Hidden)
    X = []; % Incidence matrix for unknown variables
    F = []; % Incidence matrix for fault variables
    Z = []; % Incidence matrix for known variables
    x = {}; % Unknown variables
    f = {}; % Fault variables
    z = {}; % Known variables
    e = {}; % Equation names
    P = []; % List (indices into x) of possible sensor locations
    Pfault = []; % Which sensor locations may be faulty
    syme = {}; % Symbolic equations
    parameters = {}; % List of model parameter names
    name = ''; % Model name
    % type - Model type
    %   Can have values 'Structural', 'Symbolic'
    type = ''; 
  end
  properties (Hidden)
    idGen = VariableIdGen();
    mhs = @MHS; % Default hitting-set function  
  end
  
  methods
    function obj=DiagnosisModel( modelDef )
      % DiagnosisModel - Main object constructor
      %
      %   m = DiagnosisModel( modelDef )
      %
      %   Constructs diagnosis model object based on a model definition
      %   structure modelDef.
      %   There are two types of model specifications
      %     - structural model
      %     - symbolic model
      %   A structural model only contains information about model 
      %   structure and does not need specifications on the underlying 
      %   symbolic expressions. Many of the analysis methods can be 
      %   applied to structural models and it is mainly the residual 
      %   generation methods that need the symbolic expressions. 
      %
      %   Defining a structural model can be done in two ways, either
      %   (S1) defining the incidence matrices directly or (S2) defining
      %   the modelstructure using variable names.
      %
      %   Read the manual for detailed information on how to create models.

      if nargin > 0
        obj.idGen.reset();
        obj.type = 'Structural';
        if strcmp(modelDef.type,'MatrixStruc')
          % Model definition by directly specifying incidence matrices
          [X,F,Z,x,f,z] = ModelXFZ(modelDef, obj.idGen);
        elseif strcmp(modelDef.type,'VarStruc')
          % Called with x,f,z,rels
          [X,F,Z,x,f,z] = ModelxfzRels(modelDef.x,modelDef.f,modelDef.z,modelDef.rels);
        elseif strcmp(modelDef.type,'Symbolic')
          [X,F,Z,x,f,z] = ModelxfzRels(modelDef.x,modelDef.f,modelDef.z,modelDef.rels);
          obj.type = 'Symbolic';
          obj.syme = modelDef.rels;
          if isfield(modelDef, 'parameters')
            obj.parameters = modelDef.parameters;
          end
        else
          error('Incorrect model specification');
        end

        ne = size(X,1);
        nx = size(X,2);
        nf = size(F,2);
        nz = size(Z,2);

        if size(F,1)~=ne || (size(Z,1)~= ne && ~isempty(Z)) || ...
            numel(x)~=nx || numel(f)~=nf || numel(z)~=nz
          error('Structural model matrices has inconsistent size');
        end
        if sprank(X) < size(X,2)
          warning('Structural model contains underdetermined parts');
        end

        if ~all(sum(F>0)==1)
          error('Fault variables must be included in one, and only one, equation. Rewrite model, it is simple!');
        end

        obj.X = X;
        obj.F = F;
        obj.Z = Z;
        obj.x = x;
        obj.f = f;
        obj.z = z;

        obj.e = cell(1,size(X,1));
        for ii=1:size(X,1)
          obj.e{ii} = obj.idGen.NewE();
        end      

        obj.P = 1:numel(obj.x);
      end
    end

    function CompiledMHS( obj, x )
      % Use the compiled minimal-hitting set algorithm if available
      if nargin < 2 || x>0
        if exist('MHScompiled', 'file')==3
          % C++ implemented MHS-algorithm in path, switch to this function
          obj.mhs = @MHScompiled;
          disp('Switching to compiled minimal hitting set implementation');
        else
          warning('No compiled minimal hitting set function found');
        end
      else
        disp('Switching to interpreted minimal hitting set implementation');
        obj.mhs = @MHS;
      end      
    end
    
    function PossibleSensorLocations( obj, x )
      % PossibleSensorLocations Set possible sensor locations
      %
      %   model.PossibleSensorLocations( x )
      %
      %   Input:
      %     x (optional)  Specification of possible sensor locations 
      %                   The sensor positions x can be given either as 
      %                   indices into model.x or variable names
      
      if nargin < 2
        obj.P = 1:numel(obj.x);
      elseif isa(x,'double')
        obj.P = x;
      else
        [~, obj.P] = ismember(x,obj.x);
      end
    end

    function SensorLocationsWithFaults( obj, x )
      % SensorLocationsWithFaults Set possible sensor locations that has faults in new sensors
      %
      %   model.SensorLocationsWithFaults( x )
      %
      %   Input:
      %     x (optional)  Index to those sensor locations that can become faulty.
      %                   If no input argument is given, no sensors may
      %                   become faulty. The sensor positions x can be
      %                   given either as indices into model.x or variable
      %                   names
      if nargin < 2
        obj.Pfault = [];
      elseif isa(x,'double')
        obj.Pfault = [];
        if length(x)>1
          obj.Pfault = x;
        elseif x>0
          obj.Pfault = 1:numel(obj.x);
        end
      else
        [~, obj.Pfault] = ismember(x,obj.x);
      end
    end
    
    function n = nx( model )
      % nx Number of unknown variables in model
      %
      %  n = model.nx
      n = size(model.X,2);
    end
    function n = nz( model )
      % nz Number of known variables in model
      %
      %  n = model.nz
      n = size(model.Z,2);
    end
    function n = nf( model )
      % nf Number of fault variables in model
      %
      %  n = model.nf
      n = size(model.F,2);
    end
    function n = ne( model )
      % ne Number of equations in model
      %
      %  n = model.ne
      n = size(model.X,1);
    end
    
    function msos = MSO( model )
      % MSO Compute the set of MSOs
      % 
      %   msos = model.MSO()
      % 
      % For details of the algorithm see the journal publication
      % Krysander, Mattias, Jan Aslund, and Mattias Nyberg. 
      % "An efficient algorithm for finding minimal overconstrained 
      % subsystems for model-based diagnosis." 
      % Systems, Man and Cybernetics, Part A: Systems and Humans, 
      % IEEE Transactions on 38.1 (2008): 197-206.
      msos = FindMSO(model.X,0);      
    end
    
    function fsm=FSM( model, eqs )
      % FSM Compute the fault signature matrix (FSM) 
      %
      %  fsm = model.FSM( eqs )
      %
      %  eqs        Cell array of sets of equations (indices)
      %             Note: No verification is made if it is 
      %                   possible to generate a residual
      %                   for each set of equations
      fsm = zeros(numel(eqs),size(model.F,2));
      for k=1:numel(eqs)
        fsm(k,:) = any(model.F(eqs{k},:));
      end
    end
    
    function r=srank(model)
      % srank Compute the structural rank of the incidence matrix
      %        for thte unknown variables
      %  
      %  r = model.srank()
      r = sprank(model.X);
    end
    
    function r = Redundancy(model)
      % REDUNDANCY Compute the structural degree of redundancy of a model
      %  
      %  r = model.Redundancy()
      dm = GetDMParts( model.X );
      r = length(dm.Mp.row)-length(dm.Mp.col);      
    end
    
    % Methods implemented in separate files
    m2 = copy( model ) 
    m2 = SubModel( model, eqs, varargin )
    ms = AddSensors( model, s, varargin )
    sm = LumpDynamics( model )
    sm = Structural( model )
    PlotModel( model )
    [p,q,P] = PlotDM( model, varargin )
    [df, ndf] = DetectabilityAnalysis( model )    
    [im,df,ndf] = IsolabilityAnalysis( model, varargin )
    [im,df,ndf] = IsolabilityAnalysisArrs( model, arrs, varargin )
    [im,df,ndf] = IsolabilityAnalysisFSM( model, fsm, varargin )    
    [s, sIdx] = SensorPlacementDetectability( model, fdet )
    [s, sIdx] = SensorPlacementIsolability( model )
    
    r = MSOCausalitySweep( model, msos, varargin )
    r = TestSelection( model, arr, varargin )
    
    r = IsHighIndex( model, eq ) 
    r = IsPSO( model, eq )
    
    Gamma=Matching(model,eq)
    resGen = SeqResGen( model, Gamma, resEq, name, varargin )
    [A,C] = ObserverResGen( model, eq, name, varargin )
    mtes = MTES( model )  
    
    BipartiteToLaTeX( model, name, varargin )
    
    Lint( model )
    
  end
end

function [X,F,Z,x,f,z] = ModelxfzRels(x,f,z,rels)
  if length(rels)>=1 && isa(rels{1},'cell')
    [X,x] = StrucDef(rels, x);
    [F,f] = StrucDef(rels, f);
    [Z,z] = StrucDef(rels, z);
  elseif length(rels)>=1 && isa(rels{1},'sym')
    [X,x] = SymModelStruc( rels, x );
    [F,f] = SymModelStruc( rels, f );
    [Z,z] = SymModelStruc( rels, z );
  else
    error('Unknown model declaration');
  end
  
  if any(any(F>1)) || any(any(Z>1))
    error('Differential constraints only allowed for the unknown variables');
  end
end

function [X,F,Z,x,f,z] = ModelXFZ(model, idGen)
  
  X = model.X;
  if isfield(model,'F')
    F = model.F;
  else
    F = [];
  end
  if isfield(model,'Z')
    Z = model.Z;
  else
    Z = [];
  end
  x = {};
  f = {};
  z = {};
  nx = size(X,2);
  nf = size(F,2);
  nz = size(Z,2);
  
  if nx>0 && ~isfield(model,'x')
    x = cell(1,nx);
    for ii=1:nx
      x{ii} = idGen.NewX();
    end
  elseif nx>0
    x = model.x;
  end

  if nf>0 && ~isfield(model,'f')
    f = cell(1,size(F,2));
    for ii=1:size(F,2)
      f{ii} = idGen.NewF();
    end
  elseif nf>0
    f = model.f;
  end

  if nz>0 && ~isfield(model,'z')
    z = cell(1,size(Z,2));
    for ii=1:size(Z,2)
      z{ii} = idGen.NewZ();
    end
  elseif nz>0
    z = model.z;
  end
end

function [M,v]=StrucDef(eq, vars)
  M = zeros(length(eq), length(vars));

  for ii=1:size(M,1)
    if ~isdiffconstraint(eq{ii})
      [r,c] = ismember(eq{ii},vars);  
      M(ii,c(r)) = 1;
    else
      [rd,cd] = ismember(eq{ii}{1},vars);
      [ri,ci] = ismember(eq{ii}{2},vars);
      M(ii,cd(rd)) = 3;
      M(ii,ci(ri)) = 2;
    end
  end
  vIdx = any(M,1);
  M = M(:,vIdx);
  v = vars(vIdx>0);
end

% function r=isdiffconstraint( eq )
%   r = (length(eq)==1 && iscell(eq) && length(eq{1})==3 && ...
%     strcmp(eq{1}{3},'diff'));
% end
% 
% function r=isifconstraint( eq )
%   r = (length(eq)==1 && iscell(eq) && length(eq{1})==4 && ...
%     strcmp(eq{1}{4},'if'));
% end

function r=isdiffconstraint( eq )
  r = (iscell(eq) && length(eq)==3 && ...
    strcmp(eq{3},'diff'));
end

% function r=isifconstraint( eq )
%   r = (iscell(eq) && length(eq)==4 && ...
%     strcmp(eq{4},'if'));
% end
