function [A0,C0] = ObserverResGen( model, eq, name, varargin )
% OBSERVERRESGEN  (Experimental) Generate Matlab code for observer based residual generator
%
%    [A0,C0] = model.ObserverResGen( eq, name, options )  
%
%  Given a set of equations, generate code implementing an observer based
%  residual generator in Matlab. Currently, the approach only works for
%  low-index models. If a linearization point and parameter values are
%  provided, a pair of (A,C) matrices are computed to aid design of an
%  ad-hoc observer.
%
%  Options are key/value pairs
%
%  Inputs:
%    eq    - Index to equations to use in the residual generator
%    name  - Name of residual equation. Will also be used as a basis for
%            filename.
%
%  Outous:
%    A0   - A matrix for linearization point
%    C0   - C matrix for linearization point
%
%  The options are given as key/value pairs as
%
%  Key                Value
%    type             Currently only numerical solver is supported, i.e.,
%                     exploration of the symbolic solving capabilities of
%                     the symbolic toolbox in Matlab is not supported.
%    linpoint         Linearization point to compute the A0/C0 matrices
%    parameters       Parameter values for the computation of the A0/C0 matrices
%
 
% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  if ~strcmp(model.type,'Symbolic')
    error('Generation of obsevrer based residual generators only for symbolic models');
  end

  % Parse arguments
  p = inputParser;
  p.addOptional('type','numerical');
  p.addOptional('linpoint', [] );
  p.addOptional('parameters', [] );
  
  p.parse( varargin{:});
  opts = p.Results;

  % Initialize output variables
  A0 = [];
  C0 = [];

  % Determine highest order derivatives
  hod = HighestOrderDerivatives( model, eq );
  
  % Check if system is structurally low-index
  if IsHighIndexDAE(model.X(eq,:),hod)
    warning('Generating observers currently only works for problems with low (structural) differential index, sorry.');
    return;
  end

  % Partition model into dynaimc part, algebraic part, and residual part
  modelPartition = PartitionModel( model.X, eq, hod );
    
  if strcmp(opts.type,'numerical')
    % Output a numerical formulation of the observer
    % Let the numerical integration routine handle the algebraic
    % constraints
    
    % Solve for cdX1
    % 1. Get symbolic equations, subsititute f_i=0, and solve for cdX1
    fprintf( 'Generating residual generator %s...', name );

    symF = cellfun( @(x) sym(x), model.f,'UniformOutput', false);
    nf = length(model.f);

    n1 = length( modelPartition.g1Eq );
    symE = cell(1,n1);
    for k=1:n1
      symE{k} = subs(model.syme{modelPartition.g1Eq(k)},symF,zeros(1,nf));
    end
    symdX1 = cellfun( @(x) sym(x),model.x(hod.cdX1),'UniformOutput', false);  
    % 2. Solve
    sol = solve(symE{:}, symdX1{:});
    if n1==1 % Ensure output format is consistent
      sol = struct(model.x{hod.cdX1},sol);
    end
    
    % Generate code and write matlab function
    WriteMatlabNumObserver( model, sol, modelPartition, hod, name ); 
    fprintf( 'Finished!\n', name );
    fprintf( 'File %s.m created!\n', name );
    
    if ~isempty( opts.linpoint )
      % Generate matrices for constant gain observer feedback design
      % based on linearization
      [A0,C0] = ComputeLinearizationMatrices(model, sol, modelPartition, hod, opts);
      fprintf( 'For an ad-hoc constant gain observer design: Choose feedback gain K such that A0-K*C0 is stable\n');
    end    
  else
    error('Sorry, only numerical type observer is currently sopperted');
  end  
end

function [A0,C0] = ComputeLinearizationMatrices(model, sol, modelPartition, hod, opts )
  n1 = length( modelPartition.g1Eq );
  n2 = length( modelPartition.g2Eq );
  nr = length( modelPartition.grEq );

  xNames = model.x([hod.cX1;hod.cX2]);
  for k=1:nr
    xNames{end+1} = sprintf('r%d',k);
  end
  symV = cellfun( @(x) sym(x), xNames, 'UniformOutput', false );
  symF = cellfun( @(x) sym(x), model.f,'UniformOutput', false );

  symParams = cellfun( @(x) sym(x), model.parameters, 'UniformOutput', false );
  paramVals = zeros(1,length(model.parameters));
  for k=1:length(model.parameters);
    paramVals(k) = opts.parameters.(model.parameters{k});
  end

  nf = length(model.f);
  A = zeros(n1+n2,n1+n2);
  C = zeros( nr, n1+n2);
  for k=1:n1
    fk = subs(sol.(model.x{hod.cdX1(k)}), [symF{:} symParams{:}], [zeros(1,nf), paramVals]);
    for l=1:n1+n2
      A(k,l) = double(subs(diff( fk, symV{l} ),symV, opts.linpoint.x0));
    end
  end
  s = symengine; % Retrieve the symbolic computing engine
  for k=1:n2
    fk = feval(s,'lhs', model.syme{modelPartition.g2Eq(k)})-feval(s,'rhs', model.syme{modelPartition.g2Eq(k)});
    fk = subs(fk,[symF{:} symParams{:}], [zeros(1,nf), paramVals]);
    for l=1:n1+n2
      A(k+n1,l) = double(subs(diff( fk, symV{l} ),symV, opts.linpoint.x0));
    end
  end
  for k=1:nr
    fk = feval(s,'lhs', model.syme{modelPartition.grEq(k)})-feval(s,'rhs', model.syme{modelPartition.grEq(k)});
    fk = subs(fk,[symF{:} symParams{:}], [zeros(1,nf), paramVals]);
    for l=1:n1+n2
      C(k,l) = double(subs(diff( fk, symV{l} ),symV, opts.linpoint.x0));
    end
  end
  A11 = A(1:n1,1:n1);
  A12 = A(1:n1, n1+1:n1+n2);
  A21 = A(n1+1:n1+n2,1:n1);
  A22 = A(n1+1:n1+n2, n1+1:n1+n2);
  C1  = C(:,1:n1);
  C2  = C(:,1+n1:n1+n2);

  A0 = (A11-A12/A22*A21);
  C0 = -(C1-C2/A22*A21);
end


function r=EqToMatlab( s, e, o, res )
  if nargin==2 && isa(e,'sym')% e: y == x to Matlab: y = x;
    r = SymToMatlab( s, e );
  elseif nargin==3 && IsIfStatement( e ) % If-statement
    r = cell(1,4);
    r{1} = SymToMatlab( s, e{1} );
    r{1} = r{1}(5:end-1); % UGLY!
    expr = (sym(o)==feval(s,'lhs', e{2})-feval(s,'rhs', e{2}));
    r{2} = SymToMatlab( s, expr );
    expr = (sym(o)==feval(s,'lhs', e{3})-feval(s,'rhs', e{3}));
    r{3} = SymToMatlab( s, expr );
    r{4} = 'if';
  elseif nargin==3 % e: a==b to Matlab: o = a-b;
    expr = (sym(o)==feval(s,'lhs', e)-feval(s,'rhs', e));
    r = SymToMatlab( s, expr );
  else % e: a==b to Matlab: o = res-(a-b);
    expr = (o==res - (feval(s,'lhs', e)-feval(s,'rhs', e)));
    r = SymToMatlab( s, expr );
  end
end

function r=SymToMatlab( s, e )
  r = char(feval(s,'generate::MATLAB',e));
  r = strrep(r(3:end),'\n','');    
end

function r=IsIfStatement( s )
  r = isa(s,'cell') && length(s)==4 && strcmp(s{4},'if');
end

function c = GenMatlabCode( model, sol, hod, modelPartition )
  
  s = symengine; % Retrieve the symbolic computing engine
  n1 = length(hod.cdX1);
  n2 = length(hod.cX2);
  nf = length( model.f );
  nr = length( modelPartition.grEq );
  
  symF = cellfun( @(x) sym(x), model.f,'UniformOutput', false);

  % Generate matlab code for g1
  symdX1 = cellfun( @(x) sym(x),model.x(hod.cdX1),'UniformOutput', false);  
  g1Matlab = cell(1,n1);
  for l=1:n1
    g1Matlab{l} = EqToMatlab( s, symdX1{l}==sol.(char(symdX1{l})) );
  end

  % Generate matlab code for g2
  g2Matlab = cell(1,n2);
  for l=1:n2
    g2Var = sprintf('g2%d',l);
    if ~IsIfStatement( model.syme{modelPartition.g2Eq(l)} )
      e = subs(model.syme{modelPartition.g2Eq(l)},symF,zeros(1,nf));
      g2Matlab{l} = EqToMatlab( s, e,sym(g2Var) );  
    else
      expr = model.syme{modelPartition.g2Eq(l)};
      e = cell(1,4);
      e{1} = expr{1};
      e{2} = subs(expr{2},symF,zeros(1,nf));
      e{3} = subs(expr{3},symF,zeros(1,nf));
      e{4} = 'if';
      g2Matlab{l} = EqToMatlab( s, e, sym(g2Var) );  
    end
  end

  % Generate matlab code for gr
  grMatlab = cell(1,nr);
  for l=1:nr
    e = subs(model.syme{modelPartition.grEq(l)},symF,zeros(1,nf));
    grVar = sprintf('gr%d',l);
    rVar = sprintf('r%d',l);
    grMatlab{l} = EqToMatlab( s, e, sym(grVar), sym(rVar) );  
  end
  c.g1 = g1Matlab;
  c.g2 = g2Matlab;
  c.gr = grMatlab;
end

function g = PartitionModel( X, eq, hod )
  % Identify functions g1, g2, and gr using structural information
  rAlg = setdiff(1:length(eq),hod.rX1); % Algebraic part of model
  chod = [hod.cdX1', hod.cX2'];         % highest order variables
  n1 = length(hod.cdX1);
  n2 = length(hod.cX2);
  
  dm = GetDMParts(X(eq(rAlg),chod));
  
  % Which equations was matched to solve for dx1/dt?
  [~,c] = ismember(1:n1,dm.colp);
  g1Eq = eq(rAlg(dm.rowp(c)));
  
  % Which equations was matched to solve for x2?
  [~,c] = ismember(n1+1:n1+n2,dm.colp);
  g2Eq = eq(rAlg(dm.rowp(c)));

  % Identify the rest as gr, remove differential constraint
  grEq = setdiff(eq,[g1Eq, g2Eq eq(hod.rX1)]);
  
  g.g1Eq = g1Eq;
  g.g2Eq = g2Eq;
  g.grEq = grEq;
end

function r=IsHighIndexDAE(X, hod)
  n1 = length( hod.cdX1 );
  n2 = length( hod.cX2 );
  X(X==2)=0;
  X(X==3)=0;
  r = (sprank(X(:,[hod.cdX1', hod.cX2'])) < n1+n2);
end

function hod=HighestOrderDerivatives( model, eq )
  [rX1,cX1] = find(model.X(eq,:)==2);
  n1 = length(cX1);
  n = size(model.X,2);

  cdX1 = zeros(n1,1);
  for k=1:n1
    cdX1(k) = find(model.X(eq(rX1(k)),:)==3);
  end
  [~,c0] = find(all(model.X(eq,:)==0,1)); c0 = c0';
  cX2 = setdiff(1:n,[cX1' cdX1' c0'])';

  hod.rX1  = rX1;
  hod.cX1  = cX1;
  hod.cdX1 = cdX1;
  hod.cX2  = cX2;
end


function WriteMatlabNumObserver( model, sol, modelPartition, hod, name )
  mfileName = sprintf('%s.m',name); 
  fid = fopen(mfileName,'w');

  if fid~=-1
    n1 = length(hod.cX1);
    n2 = length(hod.cX2);
    nr = length(modelPartition.grEq);
    
    matlabCode = GenMatlabCode( model, sol, hod, modelPartition );
    
   % Write function header
    fprintf( fid, 'function dx = %s(x,z,K,params)\n', name );
    % Print some help text
    fprintf( fid, '%% %s Observer based residual generator', upper(name));
    if ~isempty(model.name)
      fprintf( fid, 'for model ''%s''\n', model.name);
    else
      fprintf( fid, '\n');
    end
    fprintf( fid, '%%\n');
    fprintf( fid, '%% Structurally sensitive to faults: ');
    [~,fidx] = find(model.FSM({[modelPartition.g1Eq, modelPartition.g2Eq, modelPartition.grEq]})>0);
    if ~isempty(fidx)
      for k=1:length(fidx)-1
        fprintf( fid, '%s, ', model.f{fidx(k)});
      end
      fprintf( fid, '%s\n', model.f{fidx(end)});
    end
    fprintf( fid, '%%\n');
    fprintf( fid, '%% Example of basic usage:\n');
    fprintf( fid, '%%   Let z and t be the observations and corresponding timestamps. Let K be the observer gain,\n');
    fprintf( fid, '%%   then the residual generator can be simulated by:\n');
    fprintf( fid, '%%\n');
    fprintf( fid, '%%     [~,x] = ode15s(@(ts,x) %s( x, interp1(t,z,ts), K, params ), t, x0, odeset(''Mass'',M));\n',name);
    fprintf( fid, '%%\n');
    fprintf( fid, '%%   where the mass matrix M is [eye(%d) zeros(%d,%d);zeros(%d,%d)]\n', ...
      n1, n1, n2+nr, n2+nr, n1+n2+nr);
    if nr==1
      fprintf( fid, '%%   The residual after integration is then r=x(:,%d)\n', n1+n2+1);
    else
      fprintf( fid, '%%   The residual after integration is then r=x(:,%d:%d)\n', n1+n2+1,n1+n2+nr);
    end

    fprintf( fid, '\n%% File generated %s\n\n', datestr(now));


    % Extract parameter values
    if ~isempty(model.parameters)
     fprintf( fid, '\n  %% Parameters\n');
     for k=1:length(model.parameters)
       fprintf( fid, '  %s = params.%s;\n', model.parameters{k}, model.parameters{k});
     end
     fprintf( fid, '\n');
    end

    % Extract known values
    if ~isempty(model.z)
     fprintf( fid, '  %% Known variables\n');
     for k=1:length(model.z)
       fprintf( fid, '  %s = z(%d);\n', model.z{k}, k);
     end
     fprintf( fid, '\n');
    end

    % Extract model variables
    fprintf( fid, '  %% Model variables\n');
    for k=1:n1
     fprintf( fid, '  %s = x(%d);\n', model.x{hod.cX1(k)},k);
    end
    for k=1:n2
     fprintf( fid, '  %s = x(%d);\n', model.x{hod.cX2(k)},k+n1);
    end
    for k=1:nr
     fprintf( fid, '  r%d = x(%d);\n', k,k+n1+n2);
    end

    % Write function body: g2
    fprintf( fid, '\n  %% Algebraic equations\n');
    for k=1:n2
      if ~IsIfStatement( matlabCode.g2{k} )
        fprintf( fid, '  %s\n', matlabCode.g2{k} );
      else
        fprintf( fid, '  if %s>=0\n', matlabCode.g2{k}{1} );
        fprintf( fid, '    %s\n', matlabCode.g2{k}{2} );
        fprintf( fid, '  else\n');
        fprintf( fid, '    %s\n', matlabCode.g2{k}{3} );
        fprintf( fid, '  end\n');
      end
    end

    % Write function body: gr
    fprintf( fid, '\n  %% Residual equations\n');
    for k=1:nr
     fprintf( fid, '  %s\n', matlabCode.gr{k} );
    end
    if nr>1
      fprintf( fid, '  r = [');
      for k=1:nr-1
        fprintf( fid, 'r%d; ', k );
      end
      fprintf( fid, 'r%d];\n', nr );
      feedbackStr = 'r';
    else
      feedbackStr = 'r1';
    end
    
    % Write function body: g1
    fprintf( fid, '\n  %% Dynamics, with feedback\n');
    for k=1:n1
     fprintf( fid, '  %s + K(%d,:)*%s;\n', matlabCode.g1{k}(1:end-1),k, feedbackStr );
    end

    % Output
    fprintf( fid, '\n');
    fprintf( fid, '  %% Return value\n');
    fprintf( fid, '  dx = [');
    for k=1:n1
     fprintf( fid, '%s; ', model.x{hod.cdX1(k)});
    end
    for k=1:n2
     fprintf( fid, 'g2%d; ', k);
    end
    for k=1:nr-1
     fprintf( fid, 'gr%d; ', k);     
    end
    fprintf( fid, 'gr%d];\n', nr);     

    fprintf( fid, 'end\n');
    fclose( fid );
  else
   warning('Error creating file %s', mfileName);
  end 
end
