function resGen = SeqResGen( model, Gamma, resEq, name, varargin )
% SeqResGen  (Experimental) Generate Matlab code for sequential residual generator
%
%    model.SeqResGen( Gamma, resEq, name, options )  
%
%  Given a matching and a residual equation, generate code implementing the
%  residual generator in Matlab.
%
%  Options are key/value pairs
%
%  Inputs:
%    Gamma    - Matching
%    resEq    - Index to equation to use as residual equation
%    name     - Name of residual equation. Will also be used as a basis for
%               filename.
%
%  The options are given as key/value pairs as
%
%  Key                Value
%    implementation   Can be 'discrete' or 'continuous' (currently only
%                     discrete is supported)
%    diffres          Can be 'Int' or 'Der' (default 'Int'). Determines how
%                     to treat differential constraints when used as a
%                     residual equation.

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  if ~strcmp(model.type,'Symbolic')
    error('Generation of sequential residual generators only for symbolic models');
  end
  
  p = inputParser;
  p.addOptional('implementation', 'discrete');
  p.addOptional('diffres', 'Int');
  p.parse(varargin{:});
  opts = p.Results;

  if ~strcmp(opts.implementation,'discrete') && (strcmp(Gamma.type,'Der') || strcmp(Gamma.type,'Mixed'))
    error('Continuous time implementation not available for derivative or mixed causality residual generators');
  end
  
  if ~strcmp(opts.implementation,'discrete') && strcmp(Gamma.type,'Int')
    error('Sorry, continiuous time implementation is not yet supported');
  end
  
  if length(resEq)>1
    error('Sorry, vector valued residual equations not yet supported');
  end
  
  if nargin < 4
    name = [];
  end

  % TODO: Make feasibility test

  fprintf('Generating residual generator %s', name);

  % Generate code for exactly determined part of residual generator
  [resGenM0,state] = GenerateExactlyDetermined( model, Gamma );
  
  % Generate code for residual equations
  [resGenRes,stater] = GenerateResidualEquations( model, resEq, opts.diffres );
  state = [state{:} stater];
  
  % Collect all generated code
  resGen = [resGenM0 {resGenRes}];
  
  % Find equations used in the residual generator
  eqr = resEq;
  for k=1:length(Gamma.matching)
    eqr = [eqr Gamma.matching{k}.row];    
  end
  
  matchType = SeqResGenCausality( Gamma, model.syme{resEq}, opts.diffres );  
  
  fprintf('Finished!\n');
  if ~isempty(name)
    WriteMatlabResGenFunction( model, resGen, state, name, matchType, eqr );
    fprintf('File %s.m generated.\n', name);
  end
end

function WriteMatlabResGenFunction( model, resGen, state, name, matchType, eqr )
  mfileName = sprintf('%s.m',name); 
  fid = fopen(mfileName,'w');

  if fid~=-1
    % Write function header
    fprintf( fid, 'function [r, state] = %s(z,state,params,Ts)\n', name );

    fprintf( fid, '%% %s Sequential residual generator', upper(name));
    if ~isempty(model.name)
      fprintf( fid, 'for model ''%s''\n', model.name);
    else
      fprintf( fid, '\n');
    end
    fprintf( fid, '%% Causality: %s\n', matchType );
    fprintf( fid, '%%\n');
    fprintf( fid, '%% Structurally sensitive to faults: ');
    [~,fidx] = find(model.FSM({eqr})>0);
    if ~isempty(fidx)
      for k=1:length(fidx)-1
        fprintf( fid, '%s, ', model.f{fidx(k)});
      end
      fprintf( fid, '%s\n', model.f{fidx(end)});
    end
    fprintf( fid, '%%\n');
    
    fprintf( fid, '%% Example of basic usage:\n');
    fprintf( fid, '%%   Let z be the observations and N the number of samples, then\n');
    fprintf( fid, '%%   the residual generator can be simulated by:\n');
    fprintf( fid, '%%\n');
    fprintf( fid, '%%   for k=1:N\n');
    fprintf( fid, '%%     [r(k), state] = %s( z(k,:), state, params, 1/fs );\n',name);
    fprintf( fid, '%%   end\n');

    if ~isempty(state)
      fprintf( fid, '%%   where state is a structure with the state of the residual generator.\n');
      fprintf( fid, '%%   The state has fieldnames: ');
      for k=1:length(state)-1
        fprintf( fid, '%s, ', state{k});
      end
      fprintf( fid, '%s\n', state{end});
    end

    fprintf( fid, '\n%% File generated %s\n\n', datestr(now));

    % Extract parameter values
    if ~isempty(model.parameters)
     fprintf( fid, '  %% Parameters\n');
     for k=1:length(model.parameters)
       fprintf( fid, '  %s = params.%s;\n', model.parameters{k}, model.parameters{k});
     end
     fprintf( fid, '\n');
    end

    % Extract parameter values
    if ~isempty(model.z)
     fprintf( fid, '  %% Known variables\n');
     for k=1:length(model.z)
       fprintf( fid, '  %s = z(%d);\n', model.z{k},k);
     end
     fprintf( fid, '\n');
    end

    % Initialize state variables
    if ~isempty(state)
     fprintf( fid, '  %% Initialize state variables\n');
     for k=1:length(state)
       fprintf( fid, '  %s = state.%s;\n', state{k}, state{k});
     end
     fprintf( fid, '\n');
    end

    % Write function body
    fprintf( fid, '  %% Residual generator body\n');
    for k=1:length(resGen)
     fprintf( fid, '  %s\n', resGen{k} );
    end

    % Update state variables
    if ~isempty(state)
     fprintf( fid, '\n');
     fprintf( fid, '  %% Update state variables\n');
     for k=1:length(state)
       fprintf( fid, '  if length(state.%s)==1\n', state{k});
       fprintf( fid, '    state.%s = %s;\n', state{k}, state{k});
       fprintf( fid, '  else\n');
       fprintf( fid, '    state.%s = [%s state.%s(1)];\n', state{k}, state{k},state{k});
       fprintf( fid, '  end\n');
     end
    end
    fprintf( fid, 'end\n');

    if strcmp(matchType,'Der')||strcmp(matchType,'Mixed')
     WriteDiffFunction( fid );
    end
    if strcmp(matchType,'Int')||strcmp(matchType,'Mixed')
     WriteIntFunction( fid );     
    end


    fclose( fid );
  else
   warning('Error creating file %s', mfileName);
  end 
end

function r = IsDifferentialConstraint( e )
  r = iscell(e) && length(e)==3 && strcmp(e{3},'diff');    
end

function [resGenRes,state] = GenerateResidualEquations( model, resEq, diffres )
  % TODO: support multiple output residuals

  if ~IsDifferentialConstraint( model.syme{resEq} )
    symF = cellfun( @(x) sym(x), model.f,'UniformOutput', false);
    resExpression = sym('r')==feval(symengine,'lhs', model.syme{resEq})-feval(symengine,'rhs', model.syme{resEq});
    resExpression = subs( resExpression, symF, zeros(1,length(model.f)));
    matForm = char(feval(symengine,'generate::MATLAB',resExpression));
    matForm = strrep(matForm(3:end),'\n','');
    matForm = sprintf('%s %% %s', matForm, model.e{resEq});
    state = {};
  elseif strcmp(diffres,'Der')
    e = model.syme{resEq};
    matForm = sprintf('r = %s-ApproxDiff(%s, state.%s,Ts); %% %s',e{1},e{2},e{2},model.e{resEq});  
    state = e(2);
  else 
    e = model.syme{resEq};
    matForm = sprintf('r = %s-ApproxInt(%s, state.%s,Ts); %% %s',e{2},e{1},e{2},model.e{resEq});  
    state = e(2);
  end
  resGenRes = matForm;
end

function [resGen, state] = GenerateExactlyDetermined( model, Gamma )
  resGen = {};
  state = {};
  % Generate exactly determined part
  for k=1:length(Gamma.matching)
    fprintf('.');
    if strcmp(Gamma.matching{k}.type,'Algebraic')
      resGen = [resGen{:} AlgebraicHallComponent(model, Gamma.matching{k})];
    elseif strcmp(Gamma.matching{k}.type,'Int') && length(Gamma.matching{k}.row)>1
      [aRes, aState] = IntegralHallComponent(model, Gamma.matching{k});
      resGen = [resGen{:} aRes];
      state = [state aState];
    elseif strcmp(Gamma.matching{k}.type,'Int') && length(Gamma.matching{k}.row)==1
      diffConstraint = model.syme{Gamma.matching{k}.row};
      matForm = sprintf('%s = ApproxInt(%s,state.%s,Ts); %% %s', ...
        diffConstraint{2},diffConstraint{1}, diffConstraint{2}, ...
        model.e{Gamma.matching{k}.row});
      resGen{end+1} = matForm;
      state = [state diffConstraint{2}];
    elseif strcmp(Gamma.matching{k}.type,'Der')
      diffConstraint = model.syme{Gamma.matching{k}.row};
      resGen{end+1} = sprintf('%s = ApproxDiff(%s,state.%s,Ts);  %% %s', ...
        diffConstraint{1},diffConstraint{2},diffConstraint{2},model.e{Gamma.matching{k}.row});
      state = [state diffConstraint{2}];
    else
      error('Unknown Hall component type');
    end
  end
end

function [resGen, state] = IntegralHallComponent(model, Gamma)
  symF = cellfun( @(x) sym(x), model.f,'UniformOutput', false);
  nf = length(model.f);
  
  % TODO: Should test for high-index problem

  % Get symbolic equations and subsititute f_i=0
  symE = cell(1,length(Gamma.row));
  for k=1:length(symE)
    if isa(model.syme{Gamma.row(k)},'sym')
      symE{k} = subs(model.syme{Gamma.row(k)},symF,zeros(1,nf));
    else
      symE{k} = model.syme(Gamma.row(k));
    end
  end
  
  s = symengine;
  resGen = {};
  % Solve for highest order derivatives
  symV = cellfun( @(x) sym(x),model.x(Gamma.col),'UniformOutput', false);  
  for k=1:length(Gamma.hod)  
    % Generate symbolic variables

    sol = solve(symE{Gamma.hod{k}.row}, symV{Gamma.hod{k}.col});
    if length(sol)>1
      warning('Multiple solutions, using first one');
      sol = sol(1);
    end
    if length(Gamma.hod{k}.col)==1 % Ensure output format is consistent
      sol = struct(model.x{Gamma.col(Gamma.hod{k}.col)},sol);
    end

    % Generate Matlab Code
    for l=1:length(Gamma.hod{k}.col)      
      matForm = char(feval(s,'generate::MATLAB',...
        symV{Gamma.hod{k}.col(l)}==sol.(char(symV{Gamma.hod{k}.col(l)}))));
      matForm = strrep(matForm(3:end),'\n','');
      matForm = sprintf('%s %% %s', matForm, model.e{Gamma.hod{k}.row(l)});
      resGen{end+1} = matForm;
    end
  end
  
  state = {};
  % Integrate state variables
  for k=1:length(Gamma.int.row)
    diffConstraint = model.syme{Gamma.row(Gamma.int.row(k))};
    matForm = sprintf('%s = ApproxInt(%s,state.%s,Ts); %% %s', ...
      diffConstraint{2},diffConstraint{1}, diffConstraint{2}, ...
      model.e{Gamma.int.row(k)});
    resGen{end+1} = matForm;
    state = [state diffConstraint{2}];
  end
end

function resGen = AlgebraicHallComponent(model, Gamma)
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
  
  % Generate Matlab Code
  s = symengine;
  resGen = cell(1,length(Gamma.col));
  for l=1:length(Gamma.col)
    matForm = char(feval(s,'generate::MATLAB',symV{l}==sol.(char(symV{l}))));
    matForm = strrep(matForm(3:end),'\n','');
    matForm = sprintf('%s %% %s', matForm, model.e{Gamma.row(l)});
    resGen{l} = matForm;
  end
end

function WriteDiffFunction( fid )
 fprintf( fid, '\n');
 fprintf( fid, 'function dx=ApproxDiff(x,xold,Ts)\n');
 fprintf( fid, '  if length(xold)==1\n');
 fprintf( fid, '    dx = (x-xold)/Ts;\n');
 fprintf( fid, '  elseif length(xold)==2\n');
 fprintf( fid, '    dx = (3*x-4*xold(1)+xold(2))/2/Ts;\n');
 fprintf( fid, '  else\n');
 fprintf( fid, '    error(''Differentiation of order higher than 2 not supported'');\n');
 fprintf( fid, '  end\n');
 fprintf( fid, 'end\n');
end

function WriteIntFunction( fid )
 fprintf( fid, '\n');
 fprintf( fid, 'function x1=ApproxInt(dx,x0,Ts)\n');
 fprintf( fid, '  x1 = x0 + Ts*dx;\n');
 fprintf( fid, 'end\n');
end

function s=SeqResGenCausality( Gamma, e, diffres )
  if ~IsDifferentialConstraint(e)
    s = Gamma.type;
  elseif strcmp(diffres,'Int')
    % Treat differential residual constraint in integral causality
    switch Gamma.type
      case 'Der'
        s = 'Mixed';
      case {'Int','Mixed'}
        s = Gamma.type;
      case 'Algebraic'
        s = 'Int';
      otherwise
        error('Unknown type of matching');
    end
  else % Treat differential residual constraint in derivative causality
    switch Gamma.type
      case 'Int'
        s = 'Mixed';
      case {'Der','Mixed'}
        s = Gamma.type;
      case 'Algebraic'
        s = 'Der';
      otherwise
        error('Unknown type of matching');
    end
  end
end
