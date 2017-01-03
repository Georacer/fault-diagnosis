function resGen = GenSimulationModel( model, name, varargin )
% GENSIMULATIONMODEL  (Experimental) Generate Matlab code for simulation
%                     model. Model must be low-index and exactly
%                     determined.
%
%    model.GenSimulationModel( name )  
%

%  The options are given as key/value pairs as
%
%  Key                Value
%    implementation   Can be 'discrete' or 'continuous' (currently only
%                     continuous is supported)
%    language         Defaults to Matlab but also C code will be possible in the future
%

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  if ~strcmp(model.type,'Symbolic')
    error('Generation of simulation model only possible for symbolic models');
  end
  
  p = inputParser;
  p.addOptional('implementation', 'continuous');
  p.addOptional('language', 'Matlab');
  p.addOptional('external', false);
  p.parse(varargin{:});
  opts = p.Results;
  
  if ~strcmp(opts.implementation,'continuous') && (strcmp(Gamma.type,'der') || strcmp(Gamma.type,'mixed'))
    error('Only continuous time implementation, for integral causality matchings, is currently available');
  end
    
  if nargin < 2
    name = [];
  end
  
  [diffCIdx, stateVars, dStateVars] = model.DifferentialConstraints();
  algModel = model.SubModel(diffCIdx, stateVars, 'remove', true);
  Gamma = algModel.Matching( 1:algModel.ne );
  
  % TODO: Make feasibility test
  fprintf('Generating simulation model %s:', name);

  % Generate code for exactly determined part of residual generator
  [resGen,iState, dState, integ] = GenerateExactlyDetermined( algModel, Gamma, opts.language );
  
  fprintf('\nFinished generating code!\n');
  fprintf('Generating source file...\n');
  if ~isempty(name)
    if strcmp(opts.language, 'Matlab')
      state = model.x(stateVars);
      dState = model.x(dStateVars);
      WriteMatlabSimModel( model, resGen, state, dState, integ, name );
      fprintf('File %s.m generated.\n', name);
%     elseif strcmp(opts.language, 'C')
%       if ~opts.batch
%         WriteCResGenFunction( model, resGen, iState, dState, integ, name, matchType, eqr, opts.external );
%       else
%         WriteCResGenFunctionBatch( model, resGen, iState, dState, integ, name, matchType, eqr, opts.external );
%       end
%       fprintf('File %s.cc generated.\n', name);
    else
      error('Unsupported language %s', opts.language);
    end
  end
end

function WriteMatlabSimModel( model, resGen, state, dState, integ, name )
  mfileName = sprintf('%s.m',name); 
  fid = fopen(mfileName,'w');

  eqr = 1:model.ne;
  
  if fid~=-1
    % Write function header
    fprintf( fid, 'function dx = %s(x,z,params)\n', name );

    fprintf( fid, '%% %s Simulation model', upper(name));
    if ~isempty(model.name)
      fprintf( fid, ' for model ''%s''\n', model.name);
    else
      fprintf( fid, '\n');
    end
    
    fprintf( fid, '%% Example of basic usage:\n');
    fprintf( fid, '%%   Let z be the inputs and t the corresponding time vector, then\n');
    fprintf( fid, '%%   the continuous model can be simulated by:\n');
    fprintf( fid, '%%\n');
    fprintf( fid, '%% [t, x] = ode15s(@(ts,x) %s( x, interp1(t,z,ts), params ), Tend, x0);\n', name);
    fprintf( fid, '%%\n');

    if ~isempty(state)
      fprintf( fid, '%%   where x0 is the initial state, a column vector with\n');
      fprintf( fid, '%%   signal order: ');
      for k=1:length(state)-1
        fprintf( fid, '%s, ', state{k});
      end
      fprintf( fid, '%s\n', state{end});
    end

    fprintf( fid, '\n%% File generated %s\n\n', datestr(now));

    % Extract parameter values
    if ~isempty(model.parameters)
     fprintf( fid, '  %% Parameters\n');

      % Determine parameters used
      pIdx = [];
      for l=1:numel(eqr)
        if ~IsDifferentialConstraint(model.syme{eqr(l)})
          sVar = symvar(model.syme{eqr(l)});
          for k=1:length(sVar)
            [pMember,pi]=ismember(char(sVar(k)),model.parameters);
            if pMember
              pIdx(end+1) = pi;
            end
          end
        end
      end
      pIdx = unique(pIdx);
      for k=pIdx
        fprintf( fid, '  %s = params.%s;\n', model.parameters{k}, model.parameters{k});
      end
      fprintf( fid, '\n');
    end

    % Extract known values
    if ~isempty(model.z)
     fprintf( fid, '  %% Known variables\n');
      % Determine observations used
      zIdx = [];
      for l=1:numel(eqr)
        if ~IsDifferentialConstraint(model.syme{eqr(l)})
          sVar = symvar(model.syme{eqr(l)});
          for k=1:length(sVar)
            [zMember,zi]=ismember(char(sVar(k)),model.z);
            if zMember
              zIdx(end+1) = zi;
            end
          end
        end
      end
      zIdx = unique(zIdx);
      for k=zIdx
        fprintf( fid, '  %s = z(%d);\n', model.z{k},k);
      end
     fprintf( fid, '\n');
    end

    % Initialize state variables
    if ~isempty(state)
     fprintf( fid, '  %% Initialize state variables\n');
     for k=1:length(state)
       fprintf( fid, '  %s = x(%d);\n', state{k}, k);
     end
     fprintf( fid, '\n');
    end

    % Write function body
    fprintf( fid, '  %% Simulation model body\n');
    for k=1:length(resGen)
     fprintf( fid, '  %s\n', resGen{k} );
    end

    % Write integrator update equations
    if ~isempty(integ)
      fprintf( fid, '\n');
      fprintf( fid, '  %% Update integrator variables\n');
      for k=1:length(integ)
       fprintf( fid, '  %s\n', integ{k} );
      end      
    end
    
    % Update state variables
    if ~isempty(state)
      fprintf( fid, '\n');
      fprintf( fid, '  %% Collect output\n');
      fprintf( fid, '  dx = [');
      for k=1:length(state)-1
        fprintf( fid, '%s, ', dState{k});
      end
      fprintf( fid, '%s];\n', dState{end});
    end
    fprintf( fid, 'end\n');

    fclose( fid );
  else
   warning('Error creating file %s', mfileName);
  end 
end

function [resGen, iState, dState, integ] = GenerateExactlyDetermined( model, Gamma,language )
  resGen = {};
  iState = {};
  dState = {};
  integ = {};

  if IsMatlab(language)
    langDeclaration = '';
  elseif IsC(language)
%    langDeclaration = 'double ';
    langDeclaration = '';
  else
    error('Language %s not supported', language );
  end

  
  % Generate exactly determined part
  for k=1:length(Gamma.matching)
    fprintf('.');
    if strcmp(Gamma.matching{k}.type,'algebraic')
      resGen = [resGen{:} AlgebraicHallComponent(model, Gamma.matching{k}, language)];
    elseif strcmp(Gamma.matching{k}.type,'int') && length(Gamma.matching{k}.row)>1
      [aRes, aState,aInt] = IntegralHallComponent(model, Gamma.matching{k},language);
      resGen = [resGen{:} aRes];
      iState = [iState aState];
      integ = [integ{:} aInt];
    elseif strcmp(Gamma.matching{k}.type,'int') && length(Gamma.matching{k}.row)==1
      diffConstraint = model.syme{Gamma.matching{k}.row};
      matForm = sprintf('%s = ApproxInt(%s,state.%s,Ts); %s %s', ...
        diffConstraint{2},diffConstraint{1}, diffConstraint{2}, ...
        CommentSymbol(language), ...
        model.e{Gamma.matching{k}.row});
      integ{end+1} = matForm;
      iState = [iState diffConstraint{2}];
    elseif strcmp(Gamma.matching{k}.type,'der')
      diffConstraint = model.syme{Gamma.matching{k}.row};
      resGen{end+1} = sprintf('%s%s = ApproxDiff(%s,state.%s,Ts);  %s %s', ...
        langDeclaration,...
        diffConstraint{1},diffConstraint{2},diffConstraint{2},...
        CommentSymbol(language),model.e{Gamma.matching{k}.row});
      dState = [dState diffConstraint{2}];
    elseif strcmp(Gamma.matching{k}.type,'mixed')
      [aRes, aiState,adState,aInt] = MixedHallComponent(model, Gamma.matching{k}, language);
      resGen = [resGen{:} aRes];
      iState = [iState aiState];
      dState = [dState adState];
      integ = [integ{:} aInt];
    else
      error('Unknown Hall component type');
    end
  end
end

function [resGen, iState, dState, integ] = MixedHallComponent(model, Gamma, language)
  symF = cellfun( @(x) sym(x), model.f,'UniformOutput', false);
  nf = length(model.f);
  
  % Get symbolic equations and subsititute f_i=0
  symE = cell(1,length(Gamma.row));
  for k=1:length(symE)
    if isa(model.syme{Gamma.row(k)},'sym')
      symE{k} = subs(model.syme{Gamma.row(k)},symF,zeros(1,nf));
    else
      symE{k} = model.syme{Gamma.row(k)};
    end
  end
  
  iState = {};
  dState = {};
  resGen = {};
  integ = {};

  if IsMatlab(language)
    langDeclaration = '';
  elseif IsC(language)
%    langDeclaration = 'double ';
    langDeclaration = '';
  else
    error('Language %s not supported', language );
  end
  
  symV = cellfun( @(x) sym(x),model.x(Gamma.col),'UniformOutput', false);  
  for k=1:length(Gamma.row)  
     if isa(symE{k},'sym')
       % Solve according to matching
      sol = solve(symE{k}, symV{k});
      if length(sol)>1
        warning('Multiple solutions, using first one');
        sol = sol(1);
      end
      % Ensure consistent output format
      sol = struct(model.x{Gamma.col(k)},sol);
       
      matForm = sprintf('%s%s; %s %s', ...
        langDeclaration,...
        ExprToCode( model, symV{k}==sol.(char(symV{k})), 0,false, language ), ...
        CommentSymbol( language ), ...
        model.e{Gamma.row(k)});
      resGen{end+1} = matForm;
     elseif IsDifferentialConstraint(symE{k}) && strcmp(IVar(symE{k}),model.x{Gamma.col(k)})
       % Integrate according to matching

       diffConstraint = symE{k};
       dv = DVar( diffConstraint );
       iv = IVar( diffConstraint );
       
       matForm = sprintf('%s = ApproxInt(%s,state.%s,Ts); %s %s', ...
         iv,dv, iv, CommentSymbol(language), model.e{Gamma.row(k)});
       integ{end+1} = matForm;
       iState = [iState iv];
     elseif IsDifferentialConstraint(symE{k}) && strcmp(DVar(symE{k}),model.x{Gamma.col(k)})
       % Differentiate according to matching

       diffConstraint = symE{k};
       dv = DVar( diffConstraint );
       iv = IVar( diffConstraint );

       matForm = sprintf('%s%s = ApproxDiff(%s,state.%s,Ts); %s %s', ...
         langDeclaration,...
         dv,iv, iv, CommentSymbol(language), model.e{Gamma.row(k)});
       resGen{end+1} = matForm;
       dState = [dState iv];
     else
       error('Unknown type of constraint');
     end    
  end
end

function [resGen, state, integ] = IntegralHallComponent(model, Gamma, language)
  symF = cellfun( @(x) sym(x), model.f,'UniformOutput', false);
  nf = length(model.f);

  % Get symbolic equations and subsititute f_i=0
  symE = cell(1,length(Gamma.row));
  for k=1:length(symE)
    if isa(model.syme{Gamma.row(k)},'sym')
      symE{k} = subs(model.syme{Gamma.row(k)},symF,zeros(1,nf));
    else
      symE{k} = model.syme{Gamma.row(k)};
    end
  end
  
  state = {};
  resGen = {};
  integ = {};

  if IsMatlab(language)
    langDeclaration = '';
  elseif IsC(language)
%    langDeclaration = 'double ';
    langDeclaration = '';
  else
    error('Language %s not supported', language );
  end
  
  symV = cellfun( @(x) sym(x),model.x(Gamma.col),'UniformOutput', false);
  for k=1:length(Gamma.row)  
     if isa(symE{k},'sym')
       % Solve according to matching
      sol = solve(symE{k}, symV{k});
      if length(sol)>1
        warning('Multiple solutions, using first one');
        sol = sol(1);
      end
      % Ensure consistent output format
      sol = struct(model.x{Gamma.col(k)},sol);
       
      matForm = sprintf('%s%s; %s %s', ...
        langDeclaration,...
        ExprToCode( model, symV{k}==sol.(char(symV{k})), 0,false, language ), ...
        CommentSymbol( language ), ...
        model.e{Gamma.row(k)});
      resGen{end+1} = matForm;
     elseif IsDifferentialConstraint(symE{k})
       % Integrate according to matching

       diffConstraint = symE{k};
       matForm = sprintf('%s = ApproxInt(%s,state.%s,Ts); %s %s', ...
         diffConstraint{2},diffConstraint{1}, diffConstraint{2}, ...
         CommentSymbol(language),...
         model.e{Gamma.row(k)});
       integ{end+1} = matForm;
       state = [state diffConstraint{2}];
     else
       error('Unknown type of constraint');
     end    
  end
end

function resGen = AlgebraicHallComponent(model, Gamma, language)
  symF = cellfun( @(x) sym(x), model.f,'UniformOutput', false);
  nf = length(model.f);
  
  % Generate symbolic variables
  symV = cellfun( @(x) sym(x),model.x(Gamma.col),'UniformOutput', false);  
  
  % Get symbolic equations and subsititute f_i=0
  symE = cellfun(@(x) subs(x,symF,zeros(1,nf)), model.syme(Gamma.row),...
    'UniformOutput', false);
  
  % Solve algebraic loop
  sol = solve(symE{:}, symV{:});  
  if length(sol)>1
    warning('Multiple solutions, using first one');
    sol = sol(1);
  end
  if length(Gamma.col)==1 % Ensure output format is consistent
    sol = struct(model.x{Gamma.col},sol);
  end
  
  if IsMatlab(language)
    langDeclaration = '';
  elseif IsC(language)
%    langDeclaration = 'double ';
    langDeclaration = '';
  else
    error('Language %s not supported', language );
  end
  
  % Generate Matlab Code
  resGen = cell(1,length(Gamma.col));
  for l=1:length(Gamma.col)
    matForm = sprintf('%s%s; %s %s', ...
      langDeclaration,...
      ExprToCode( model, symV{l}==sol.(char(symV{l})), 0,false, language), ...
      CommentSymbol( language ), ...
      model.e{Gamma.row(l)});
    resGen{l} = matForm;
  end
end

function WriteIntFunction( fid, language )
  if nargin < 2
    language = 'Matlab';
  end
  if IsMatlab( language )
    fprintf( fid, '\n');
    fprintf( fid, 'function x1=ApproxInt(dx,x0,Ts)\n');
    fprintf( fid, '  x1 = x0 + Ts*dx;\n');
    fprintf( fid, 'end\n');
  elseif IsC( language )
    fprintf( fid, '\n');
    fprintf( fid, 'double ApproxInt(double dx, double x0, double Ts)\n');
    fprintf( fid, '{\n');
    fprintf( fid, '  return x0 + Ts*dx;\n');
    fprintf( fid, '}\n');
  else
    error('Language %s not supported',language);
  end
end

function r = IsDifferentialConstraint( e )
  r = iscell(e) && length(e)==3 && strcmp(e{3},'diff');    
end

function v = DVar( e )
  v = '';
  if IsDifferentialConstraint(e)
    v = e{1};
  end
end

function v = IVar( e )
  v = '';
  if IsDifferentialConstraint(e)
    v = e{2};
  end
end

function r = IsIfConstraint( eq )
  r = (iscell(eq) && length(eq)==4 && ...
    strcmp(eq{4},'if'));
end

function s = ExprToCode( model, e, type, fault, language )
  % type = 0: equation, type ~= 0: expression
  % fault = false: set all fault variables to 0
  if nargin < 5
    language='Matlab';
  end
  if nargin < 4
    fault = 0;
  end
  if nargin < 3
    type = 0;
  end
  
  if ~fault
    symF = cellfun( @(x) sym(x), model.f,'UniformOutput', false);
    e = subs( e, symF, zeros(1,length(model.f)));
  end

  if strcmp(language,'Matlab')
    s = char(feval(symengine,'generate::MATLAB',e,'NoWarning'));
    % Remove leading spaces
    k=1;
    while s(k)==' '
      k = k+1;
    end
    s = strrep(s(k:end),'\n','');
  elseif strcmp(language,'C')
    s = char(feval(symengine,'generate::C',e,'NoWarning'));
    % Remove leading spaces
    k=1;
    while s(k)==' '
      k = k+1;
    end
    s = strrep(s(k:end),'\n','');
  else
    error('Language %s not supported', language);
  end    
  
  if type~=0 % not an equation, just an expression. Strip intro.
    s = s(6:end);
  end
  s = s(1:end-1); % Remove closing ';'
end
  
function s = CommentSymbol( language )
  if strcmp(language,'Matlab')
    s = '%';
  elseif strcmp(language,'C')
    s = '//';
  else
    error('Language %s not supported', language);
  end
end

function b = IsMatlab(language)
  b = strcmp(language,'Matlab');
end

function b = IsC(language)
  b = strcmp(language,'C');
end
