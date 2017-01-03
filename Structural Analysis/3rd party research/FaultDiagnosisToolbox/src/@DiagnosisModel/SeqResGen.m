function resGen = SeqResGen( model, Gamma, resEq, name, varargin )
% SeqResGen  (Experimental) Generate Matlab code for sequential residual generator
%
%    model.SeqResGen( Gamma, resEq, name, options )  
%
%  Given a matching and a residual equation, generate code implementing the
%  residual generator in Matlab. Generates Matlab/C++ file. How to call the
%  generated file is described in the generated file (or the user manual).
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
%
%    diffres          Can be 'int' or 'der' (default 'int'). Determines how
%                     to treat differential constraints when used as a
%                     residual equation.
%
%    language         Defaults to Matlab but also C code can be generated
%
%    batch            Generate a batch mode residual generator, only
%                     applicable when generating C code. Instead of
%                     computing the residual for one data samnple, 
%                     batch mode runs the residual generator for a whole
%                     data set. This can significantly decrease
%                     computational time.
%
%    external         Name of external header-file to include in generated
%                     source. In case of several header files, submit a
%                     cell-array with header file names.
%
%    parameters       Structure with parameter values. 
%                     Hard codes the parameter values in the generated C
%                     file. Note that this option only has effect if 
%                     language is set to C.
%
%                     If generating C code in non-batch mode and providing
%                     the parameter values which can result in significant
%                     performance increase if there are many parameters.
%                     In batch mode, no performance increase is expected,
%                     however it might still be of use to hard code the
%                     parameter values into the generated code.
%
%    quiet            Set to true to supress warnings from symbolic solver,
%                     use with care! (default: false)

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  if ~strcmp(model.type,'Symbolic')
    error('Generation of sequential residual generators only for symbolic models');
  end
  
  p = inputParser;
  p.addOptional('implementation', 'discrete');
  p.addOptional('diffres', 'int');
  p.addOptional('experimental', false);
  p.addOptional('language', 'Matlab');
  p.addOptional('external', false);
  p.addOptional('batch', false );
  p.addOptional('parameters', false );
  p.addOptional('quiet', false );
  p.parse(varargin{:});
  opts = p.Results;
  
  if ~strcmp(opts.implementation,'discrete') && (strcmp(Gamma.type,'der') || strcmp(Gamma.type,'mixed'))
    error('Continuous time implementation not available for derivative or mixed causality residual generators');
  end
  
  if ~strcmp(opts.implementation,'discrete') && strcmp(Gamma.type,'int')
    error('Sorry, continiuous time implementation is not yet supported');
  end
  
  if length(resEq)>1
    error('Sorry, vector valued residual equations not yet supported');
  end
  
  if nargin < 4
    name = [];
  end

  % TODO: Make feasibility test

  fprintf('Generating residual generator %s\n', name);

  % Generate code for exactly determined part of residual generator
  fprintf('  Generating code for exactly determined part: ');
  [resGenM0,iState, dState, integ] = GenerateExactlyDetermined( model, Gamma, opts.language, opts.quiet );
  fprintf('\n');
  
  % Generate code for residual equations
  fprintf('  Generating code for residual equations\n');
  [resGenRes,iStater, dStater, integr] = GenerateResidualEquations( model, resEq, opts.diffres, opts.language );
  iState = [iState{:} iStater];
  dState = [dState{:} dStater];
  integ = [integ{:} integr];
  
  % Collect all generated code
  resGen = [resGenM0 ' ' resGenRes];
  
  % Find equations used in the residual generator
  eqr = resEq;
  for k=1:length(Gamma.matching)
    eqr = [eqr Gamma.matching{k}.row];    
  end
  
  matchType = SeqResGenCausality( Gamma, model.syme{resEq}, opts.diffres );  
  
  fprintf('  Writing residual generator file\n');
  if ~isempty(name)
    if strcmp(opts.language, 'Matlab')
      state = [iState dState];
      WriteMatlabResGenFunction( model, resGen, state, integ, name, matchType, eqr );
      fprintf('  File %s.m generated.\n', name);
    elseif strcmp(opts.language, 'C')
      if ~opts.batch
        WriteCResGenFunction( model, resGen, iState, dState, integ, name, matchType, eqr, opts.external, opts.parameters );
      else
        WriteCResGenFunctionBatch( model, resGen, iState, dState, integ, name, matchType, eqr, opts.external, opts.parameters );
      end
      fprintf('  File %s.cc generated.\n', name);
    else
      error('Unsupported language %s', opts.language);
    end
  end
end

function WriteCResGenFunctionBatch( model, resGen, iState, dState, integ, name, matchType, eqr, ext, parameters )
  mfileName = sprintf('%s.cc',name); 
  fid = fopen(mfileName,'w');
  
  state = [iState dState];
  
  if fid~=-1
    fprintf( fid, '#include "mex.h"\n');
    fprintf( fid, '#include <math.h>\n');

    if ext
      fprintf( fid, '\n// External function headers\n');

      if ~iscell(ext)
        ext = {ext};
      end
      for k=1:numel(ext)
        fprintf( fid, '#include "%s"\n', ext{k});
      end    
    end
    
    fprintf( fid, '\n');
    fprintf( fid, '// %s Sequential residual generator', upper(name));
    if ~isempty(model.name)
      fprintf( fid, ' for model ''%s'' (batch version)\n', model.name);
    else
      fprintf( fid, '(batch version)\n');
    end
    fprintf( fid, '// Causality: %s\n', matchType );
    fprintf( fid, '//\n');
    fprintf( fid, '// Structurally sensitive to faults: ');
    [~,fidx] = find(model.FSM({eqr})>0);
    if ~isempty(fidx)
      for k=1:length(fidx)-1
        fprintf( fid, '%s, ', model.f{fidx(k)});
      end
      fprintf( fid, '%s\n', model.f{fidx(end)});
    end
    fprintf( fid, '//\n');
    
    fprintf( fid, '// Example of basic usage:\n');
    fprintf( fid, '//   Let z be the observations and N the number of samples, then\n');
    fprintf( fid, '//   the residual generator can be simulated by:\n');
    fprintf( fid, '//\n');
    if ~isa(parameters, 'logical')
      fprintf( fid, '//   r = %s( z, state, 1/fs );\n',name);
    else
      fprintf( fid, '//   r = %s( z, state, params, 1/fs );\n',name);
    end
    fprintf( fid, '//\n');
    fprintf( fid, '//   The observations z must be a MxN matrix where M is the number\n');
    fprintf( fid, '//   of known signals and N the number of samples.\n');
    fprintf( fid, '//\n');
    if ~isa(parameters, 'logical')
      fprintf( fid, '//   Note that this function is generated with hard coded parameter values for performance reasons.\n');
      fprintf( fid, '//   Regenerate without parameters option for configurable parameter values.\n\n');
    end

    if ~isempty(state)
      fprintf( fid, '//   State is a structure with the state of the residual generator.\n');
      fprintf( fid, '//   The state has fieldnames: ');
      for k=1:length(state)-1
        fprintf( fid, '%s, ', state{k});
      end
      fprintf( fid, '%s\n', state{end});
    end

    fprintf( fid, '\n// File generated %s\n\n', datestr(now));

    % Define state structure data type
    if ~isempty(state)
      fprintf( fid, 'typedef struct {\n');
      for k=1:length(state)
        fprintf( fid, '  double %s;\n', state{k});
      end
      fprintf( fid, '} ResState;\n\n');      
    end
    
    % Define parameters structure data type
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

    if ~isempty(model.parameters) && numel(pIdx)>0
      fprintf( fid, 'typedef struct {\n');
      for k=pIdx
        fprintf( fid, '  double %s;\n', model.parameters{k});
      end
      fprintf( fid, '} Parameters;\n\n');      
    end
      
    % Write approximate diff/int function headers
    if strcmp(matchType,'int')||strcmp(matchType,'mixed')
      WriteIntCHeader( fid );
      fprintf( fid, '\n');
    end
    if strcmp(matchType,'der')||strcmp(matchType,'mixed')
      WriteDiffCHeader( fid );
      fprintf( fid, '\n');
    end
    
    % Write residual body function header
    fprintf( fid, 'void %s( double* r, const double *z', name);
    if ~isempty(state)
      fprintf( fid, ', ResState &state');
    end
    if numel(pIdx)>0
    fprintf( fid, ', const Parameters &params');
    end
    fprintf( fid, ', double Ts );\n');
    
    % Write parameter-filling function header
    if numel(pIdx)>0
      if isa(parameters, 'logical')
        fprintf( fid, 'void GetParameters( const mxArray *mxParams, Parameters* params );\n');
      else
        fprintf( fid, 'void SetParameters( Parameters* params );\n');
      end
    end
    
    % Write state-filling function header
    if ~isempty(state)
      fprintf( fid, 'void GetState( const mxArray *mxStates, ResState* state );\n');
    end
    
    % Mex main function 
    fprintf( fid, '\n');
    fprintf( fid, 'void\n');
    fprintf( fid, 'mexFunction( int nlhs, mxArray *plhs[], \n');
    fprintf( fid, '	     int nrhs, const mxArray*prhs[] )\n');
    fprintf( fid, '{\n');
    if isa(parameters, 'logical')
      fprintf( fid, '  if( nrhs != 4 ) {\n');
    else
      fprintf( fid, '  if( nrhs != 3 ) {\n');
    end
    fprintf( fid, '    mexErrMsgIdAndTxt( "MATLAB:WrongNumberofInputArguments", \n');
    fprintf( fid, '    "Incorrect number of input arguments");\n');
    fprintf( fid, '  }\n');

    if isa(parameters, 'logical')
      fprintf( fid, '\n  if( !mxIsStruct(prhs[2]) ) {\n');
      fprintf( fid, '    mexErrMsgIdAndTxt( "MATLAB:Parameters",\n');
      fprintf( fid, '      "Parameters must be given by a struct");\n');
      fprintf( fid, '  }\n');    
    end

    nRes = 1;
    
    fprintf( fid, '  \n');
    fprintf( fid, '  mxArray *matVar;\n');
    fprintf( fid, '  double  *matVarPr;\n\n');

    fprintf( fid, '  // Determine size of dataset\n');
    fprintf( fid, '  const mxArray *zMx = prhs[0];\n');
    fprintf( fid, '  long N = mxGetN( zMx ); // Number of datapoints\n');
    fprintf( fid, '  long M = mxGetM( zMx ); // Number of measurements\n\n');

    fprintf( fid, '\n  // Allocate output variables\n');
    fprintf( fid, '  plhs[0] = mxCreateDoubleMatrix(%d, N, mxREAL); // Residual\n', nRes);
    fprintf( fid, '  double *r = mxGetPr( plhs[0] ); // Pointer to output array\n');

    % Extract parameter values
    if ~isempty(model.parameters) && numel(pIdx)>0
      fprintf( fid, '  \n');
      fprintf( fid, '  // Parameters\n');
      fprintf( fid, '  Parameters params;\n');
      if isa(parameters, 'logical')
        fprintf( fid, '  GetParameters( prhs[2], &params );\n');
      else
        fprintf( fid, '  SetParameters( &params );\n');
      end
    end

    fprintf( fid, '\n');
    fprintf( fid, '  // Known variables\n');
    fprintf( fid, '  double *z = (double *)mxGetData( prhs[0] );\n');

    fprintf( fid, '\n');
    if ~isempty(state)
      fprintf( fid, '  // Initialize state variables\n');
      fprintf( fid, '  ResState state;\n');
      fprintf( fid, '  GetState( prhs[1], &state );\n\n');
    end
    
    fprintf( fid, '  // Sampling time\n');
    if isa(parameters, 'logical')
      fprintf( fid, '  double Ts = mxGetScalar(prhs[3]);\n');
    else
      fprintf( fid, '  double Ts = mxGetScalar(prhs[2]);\n');
    end
    fprintf( fid, '\n');
    
    % Main computational loop
    fprintf( fid, '  // Main residual computation loop\n');
    fprintf( fid, '  for( int k=0; k < N; k++ ) {\n');
    fprintf( fid, '    %s(r+k, z+M*k',name);
    if ~isempty(state)
      fprintf( fid, ', state');
    end
    if numel(pIdx)>0
      fprintf( fid, ', params');
    end
    fprintf( fid, ', Ts );\n');
    
    fprintf( fid, '  }\n');

    % End of main function
    fprintf( fid, '}\n\n');

    % Write residual generator body function    
    fprintf( fid, '\n');
    fprintf( fid, 'void\n');
    fprintf( fid, '%s( double* r, const double *z', name);    
    if ~isempty(state)
      fprintf( fid, ', ResState &state');
    end
    if numel(pIdx)>0
      fprintf( fid, ', const Parameters &params');
    end
    fprintf( fid, ', double Ts )\n');
        
    fprintf( fid, '{\n');
    fprintf( fid, '  mxArray *matVar;\n');
    fprintf( fid, '  double  *matVarPr;\n\n');

    % Extract parameter values
    if ~isempty(model.parameters) && numel(pIdx)>0
      fprintf( fid, '  // Parameters\n');

      for k=pIdx
        fprintf( fid, '  double %s = params.%s;\n', model.parameters{k}, model.parameters{k});
      end
    end

    fprintf( fid, '\n  // Declare residual generator variables\n');
    resgenvars = model.x(any(model.X(eqr,:),1));
    for k=1:numel(resgenvars)
      fprintf( fid, '  double %s;\n', resgenvars{k});      
    end
    fprintf( fid, '\n');
    
    % Initialize integral state variables
    if ~isempty(iState)
    fprintf( fid, '\n');
      fprintf( fid, '  // Initialize integral state variables\n');
      for k=1:length(iState)
        fprintf( fid, '  %s = state.%s;\n', iState{k}, iState{k});
      end
      fprintf( fid, '\n');
    end

    % Extract known variables values
    if ~isempty(model.z)
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
      fprintf( fid, '  // Known variables\n');
      for k=zIdx
        fprintf( fid, '  double %s = z[%d];\n', model.z{k},k-1);
      end
      fprintf( fid, '\n');
    end

    % Write function body
    fprintf( fid, '  // Residual generator body\n');
    for k=1:length(resGen)
     fprintf( fid, '  %s\n', resGen{k} );
    end

    % Write integrator update equations
    if ~isempty(integ)
      fprintf( fid, '\n');
      fprintf( fid, '  // Update integrator variables\n');
      for k=1:length(integ)
       fprintf( fid, '  %s\n', integ{k} );
      end      
    end
    
    % Update state-variables
    if ~isempty(state)
      fprintf( fid, '\n');
      fprintf( fid, '  // Update state variables\n');
      for k=1:length(state)
        fprintf( fid, '  state.%s = %s;\n', state{k}, state{k});
      end
    end
    
    fprintf( fid, '}\n');
    
    % Write integrator and differentiator functions
    if strcmp(matchType,'der')||strcmp(matchType,'mixed')
      WriteDiffFunction( fid, 'C' );
    end
    if strcmp(matchType,'int')||strcmp(matchType,'mixed')
      WriteIntFunction( fid, 'C' );
    end

    % Write parameter getting function
    fprintf( fid, '\n');
    if numel(pIdx)>0
      if isa(parameters, 'logical')
        fprintf( fid, 'void\nGetParameters( const mxArray *mxParams, Parameters* params )\n');
        fprintf( fid, '{\n');
        fprintf( fid, '  mxArray *matVar;\n');
        fprintf( fid, '  double  *matVarPr;\n');
        fprintf( fid, '\n');
        for k=pIdx
          fprintf( fid, '  matVar = mxGetField( mxParams, 0, "%s"); ', model.parameters{k});
          fprintf( fid, 'matVarPr = mxGetPr( matVar );\n');
          fprintf( fid, '  params->%s = *matVarPr;\n', model.parameters{k});
        end
        fprintf( fid, '}\n');
      else
        fprintf( fid, 'void\nSetParameters( Parameters* params )\n');
        fprintf( fid, '{\n');
        for k=pIdx
          fprintf( fid, '  params->%s = %g;\n', model.parameters{k},parameters.(model.parameters{k}));
        end
        fprintf( fid, '}\n');
      end
    end
    % Write state getting function    
    if ~isempty(state)
      fprintf( fid, '\n');
      fprintf( fid, 'void\nGetState( const mxArray *mxState, ResState* state )\n');
      fprintf( fid, '{\n');
      fprintf( fid, '  mxArray *matVar;\n');
      fprintf( fid, '  double  *matVarPr;\n');
      fprintf( fid, '\n');
      if ~isempty(state)
        for k=1:length(state)
          fprintf( fid, '  matVar = mxGetField( mxState, 0, "%s"); ', state{k});
          fprintf( fid, 'matVarPr = mxGetPr( matVar );\n');
          fprintf( fid, '  state->%s = *matVarPr;\n', state{k});
        end
        fprintf( fid, '\n');
      end
      fprintf( fid, '}\n');
    end
    fclose( fid );
  else
   warning('Error creating file %s', mfileName);
  end 
end

function WriteCResGenFunction( model, resGen, iState, dState, integ, name, matchType, eqr, ext, parameters )
  mfileName = sprintf('%s.cc',name); 
  fid = fopen(mfileName,'w');
  
  state = [iState dState];
  
  if fid~=-1
    fprintf( fid, '#include "mex.h"\n');
    fprintf( fid, '#include <math.h>\n');

    if ext
      fprintf( fid, '\n// External function headers\n');

      if ~iscell(ext)
        ext = {ext};
      end
      for k=1:numel(ext)
        fprintf( fid, '#include "%s"\n', ext{k});
      end    
    end
    
    fprintf( fid, '\n');
    fprintf( fid, '// %s Sequential residual generator', upper(name));
    if ~isempty(model.name)
      fprintf( fid, ' for model ''%s''\n', model.name);
    else
      fprintf( fid, '\n');
    end
    fprintf( fid, '// Causality: %s\n', matchType );
    fprintf( fid, '//\n');
    fprintf( fid, '// Structurally sensitive to faults: ');
    [~,fidx] = find(model.FSM({eqr})>0);
    if ~isempty(fidx)
      for k=1:length(fidx)-1
        fprintf( fid, '%s, ', model.f{fidx(k)});
      end
      fprintf( fid, '%s\n', model.f{fidx(end)});
    end
    fprintf( fid, '//\n');
    
    fprintf( fid, '// Example of basic usage:\n');
    fprintf( fid, '//   Let z be the observations and N the number of samples, then\n');
    fprintf( fid, '//   the residual generator can be simulated by:\n');
    fprintf( fid, '//\n');
    if ~isa(parameters, 'logical')
      fprintf( fid, '//   Note that this function is generated with hard coded parameter values for performance reasons.\n');
      fprintf( fid, '//   Regenerate without parameters option for configurable parameter values.\n\n');
    end
    fprintf( fid, '//   for k=1:N\n');
    if isa(parameters, 'logical')
      fprintf( fid, '//     [r(k), state] = %s( z(k,:), state, params, 1/fs );\n',name);
    else
      fprintf( fid, '//     [r(k), state] = %s( z(k,:), state, 1/fs );\n',name);
    end
    fprintf( fid, '//   end\n');

    if ~isempty(state)
      fprintf( fid, '//   where state is a structure with the state of the residual generator.\n');
      fprintf( fid, '//   The state has fieldnames: ');
      for k=1:length(state)-1
        fprintf( fid, '%s, ', state{k});
      end
      fprintf( fid, '%s\n', state{end});
    end

    fprintf( fid, '\n// File generated %s\n\n', datestr(now));

    % Define state structure data type
    if ~isempty(state)
      fprintf( fid, 'typedef struct {\n');
      for k=1:length(state)
        fprintf( fid, '  double %s;\n', state{k});
      end
      fprintf( fid, '} ResState;\n\n');      
    end
    
    % Define parameters structure data type
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
    if isa(parameters, 'logical') && numel(pIdx)>0
      fprintf( fid, 'typedef struct {\n');
      for k=pIdx
        fprintf( fid, '  double %s;\n', model.parameters{k});
      end
      fprintf( fid, '} Parameters;\n\n');
   end

  % Write approximate diff/int function headers
    if strcmp(matchType,'int')||strcmp(matchType,'mixed')
      WriteIntCHeader( fid );
      fprintf( fid, '\n');
    end
    if strcmp(matchType,'der')||strcmp(matchType,'mixed')
      WriteDiffCHeader( fid );
      fprintf( fid, '\n');
    end
    
    % Write residual body function header
    fprintf( fid, 'void %s( double* r, const double *z', name);
    if ~isempty(state)
      fprintf( fid, ', ResState &state');
    end
    if numel(pIdx)>0
      fprintf( fid, ', const Parameters &params');
    end
    fprintf( fid, ', double Ts );\n');
    
    if isa(parameters, 'logical') && numel(pIdx)>0
      % Write parameter-filling function header
      fprintf( fid, 'void GetParameters( const mxArray *mxParams, Parameters* params );\n');
    end
    % Write state-filling function header
    if ~isempty(state)
      fprintf( fid, 'void GetState( const mxArray *mxStates, ResState* state );\n');
    end  

    % Write mex function
    fprintf( fid, '\n');
    fprintf( fid, 'void\n');
    fprintf( fid, 'mexFunction( int nlhs, mxArray *plhs[], \n');
    fprintf( fid, '	     int nrhs, const mxArray*prhs[] )\n');
    fprintf( fid, '{\n');
    if isa(parameters, 'logical')
      fprintf( fid, '  if( nrhs != 4 ) {\n');
    else
      fprintf( fid, '  if( nrhs != 3 ) {\n');
    end
    fprintf( fid, '    mexErrMsgIdAndTxt( "MATLAB:WrongNumberofInputArguments", \n');
    fprintf( fid, '    "Incorrect number of input arguments");\n');
    fprintf( fid, '  }\n');

    if isa(parameters, 'logical')
      fprintf( fid, '\n  if( !mxIsStruct(prhs[2]) ) {\n');
      fprintf( fid, '    mexErrMsgIdAndTxt( "MATLAB:Parameters",\n');
      fprintf( fid, '      "Parameters must be given by a struct");\n');
      fprintf( fid, '  }\n');    
    end
    
    nRes = 1;
    fprintf( fid, '\n  // Allocate output variables\n');
    fprintf( fid, '  plhs[0] = mxCreateDoubleMatrix(1, %d, mxREAL); // Residual\n', nRes);
    fprintf( fid, '  double *r = mxGetPr( plhs[0] ); // Pointer to output array\n');

    if ~isempty(state)
      fprintf( fid, '\n  // Create state output\n');
      fprintf( fid, '  const char *stateNames[%d] = {',length(state));
      for k=1:length(state)-1
        fprintf( fid, '"%s", ', state{k});
      end
      fprintf( fid, '"%s"};\n', state{end});
      fprintf( fid, '  plhs[1] = mxCreateStructMatrix(1, 1, %d, stateNames);\n', numel(state));
    else
      fprintf( fid, '  plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL); // dummy state\n');
    end
    fprintf( fid, '\n');

    fprintf( fid, '  mxArray *matVar;\n');
    fprintf( fid, '  double  *matVarPr;\n\n');

    % Extract known variables values
    fprintf( fid, '  // Known variables\n');
    fprintf( fid, '  double *z = (double *)mxGetData( prhs[0] );\n');

    % Extract parameter values
    if isa(parameters, 'logical') && numel(pIdx)>0
      if ~isempty(model.parameters)
        fprintf( fid, '  \n');
        fprintf( fid, '  // Parameters\n');
        fprintf( fid, '  Parameters params;\n');
        fprintf( fid, '  GetParameters( prhs[2], &params );\n');
      end
    end
    fprintf( fid, '\n');
    
    % Initialize state variables
    if ~isempty(state)
      fprintf( fid, '  // Initialize state variables\n');
      fprintf( fid, '  ResState state;\n');
      fprintf( fid, '  GetState( prhs[1], &state );\n\n');
    end
    
    fprintf( fid, '  // Sampling time\n');
    if isa(parameters, 'logical')
      fprintf( fid, '  double Ts = mxGetScalar(prhs[3]);\n');
    else
      fprintf( fid, '  double Ts = mxGetScalar(prhs[2]);\n');
    end
    fprintf( fid, '\n');
    
    % Call residual generator
    fprintf( fid, '  // Call residual generator body function\n');
    fprintf( fid, '  %s(r, z',name);
    if ~isempty(state)
      fprintf( fid, ', state');
    end
    if numel(pIdx)>0 && isa(parameters, 'logical')
      fprintf( fid, ', params');
    end
    fprintf( fid, ', Ts );\n');
    
    % Update state variables
    if ~isempty(state)
     fprintf( fid, '\n');
     fprintf( fid, '  // Update state variables\n');
     for k=1:length(state)
       fprintf( fid, '  mxSetFieldByNumber(plhs[1], 0, %d, mxCreateDoubleScalar(state.%s));\n', k-1, state{k});
     end
    end
    
    % End of main function
    fprintf( fid, '}\n\n');

    % Write residual generator body function    
    fprintf( fid, 'void\n');
    fprintf( fid, '%s( double* r, const double *z',name);
    if ~isempty(state)
      fprintf( fid, ', ResState &state');
    end
    if isa(parameters, 'logical') && numel(pIdx)>0
      fprintf( fid, ', const Parameters &params');
    end
    fprintf( fid, ', double Ts )\n');

    fprintf( fid, '{\n');

    % Extract parameter values
    if ~isempty(model.parameters) && numel(pIdx)>0
      fprintf( fid, '  // Parameters\n');

      % Extract parameters used
      for k=pIdx
        if isa(parameters, 'logical')
          fprintf( fid, '  double %s = params.%s;\n', model.parameters{k},model.parameters{k});
        else
          fprintf( fid, '  double %s = %g;\n', model.parameters{k},parameters.(model.parameters{k}));
        end
      end
      fprintf( fid, '\n');  
    end
    
    fprintf( fid, '  // Declare residual generator variables\n');
    resgenvars = model.x(any(model.X(eqr,:),1));
    for k=1:numel(resgenvars)
      fprintf( fid, '  double %s;\n', resgenvars{k});      
    end
    fprintf( fid, '\n');

    % Initialize integral state variables
    if ~isempty(iState)
      fprintf( fid, '  // Initialize integral state variables\n');
      for k=1:length(iState)
        fprintf( fid, '  %s = state.%s;\n', iState{k}, iState{k});
      end
      fprintf( fid, '\n');
    end

    % Extract known variables values
    if ~isempty(model.z)
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
      fprintf( fid, '  // Known variables\n');
      for k=zIdx
        fprintf( fid, '  double %s = z[%d];\n', model.z{k},k-1);
      end
      fprintf( fid, '\n');
    end

    % Write function body
    fprintf( fid, '  // Residual generator body\n');
    for k=1:length(resGen)
     fprintf( fid, '  %s\n', resGen{k} );
    end

    % Write integrator update equations
    if ~isempty(integ)
      fprintf( fid, '\n');
      fprintf( fid, '  // Update integrator variables\n');
      for k=1:length(integ)
       fprintf( fid, '  %s\n', integ{k} );
      end      
    end
    
    % Update state-variables
    if ~isempty(state)
      fprintf( fid, '\n');
      fprintf( fid, '  // Update state variables\n');
      for k=1:length(state)
        fprintf( fid, '  state.%s = %s;\n', state{k}, state{k});
      end
    end
    
    fprintf( fid, '}\n');
    
    % Write integrator and differentiator functions
    if strcmp(matchType,'der')||strcmp(matchType,'mixed')
      WriteDiffFunction( fid, 'C' );
    end
    if strcmp(matchType,'int')||strcmp(matchType,'mixed')
      WriteIntFunction( fid, 'C' );
    end

    % Write parameter getting function
    if isa(parameters, 'logical') && numel(pIdx)>0
      fprintf( fid, '\n');
      fprintf( fid, 'void\nGetParameters( const mxArray *mxParams, Parameters* params )\n');
      fprintf( fid, '{\n');
      fprintf( fid, '  mxArray *matVar;\n');
      fprintf( fid, '  double  *matVarPr;\n');
      fprintf( fid, '\n');
      for k=pIdx
        fprintf( fid, '  matVar = mxGetField( mxParams, 0, "%s"); ', model.parameters{k});
        fprintf( fid, 'matVarPr = mxGetPr( matVar );\n');
        fprintf( fid, '  params->%s = *matVarPr;\n', model.parameters{k});
      end
      fprintf( fid, '}\n');
    end
    
    % Write state getting function    
    if ~isempty(state)
      fprintf( fid, '\n');
      fprintf( fid, 'void\nGetState( const mxArray *mxState, ResState* state )\n');
      fprintf( fid, '{\n');
      fprintf( fid, '  mxArray *matVar;\n');
      fprintf( fid, '  double  *matVarPr;\n');
      fprintf( fid, '\n');
      if ~isempty(state)
        for k=1:length(state)
          fprintf( fid, '  matVar = mxGetField( mxState, 0, "%s"); ', state{k});
          fprintf( fid, 'matVarPr = mxGetPr( matVar );\n');
          fprintf( fid, '  state->%s = *matVarPr;\n', state{k});
        end
        fprintf( fid, '\n');
      end
      fprintf( fid, '}\n');
    end
    fclose( fid );
  else
   warning('Error creating file %s', mfileName);
  end 
end

function WriteMatlabResGenFunction( model, resGen, state, integ, name, matchType, eqr )
  mfileName = sprintf('%s.m',name); 
  fid = fopen(mfileName,'w');

  if fid~=-1
    % Write function header
    fprintf( fid, 'function [r, state] = %s(z,state,params,Ts)\n', name );

    fprintf( fid, '%% %s Sequential residual generator', upper(name));
    if ~isempty(model.name)
      fprintf( fid, ' for model ''%s''\n', model.name);
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
       fprintf( fid, '  %s = state.%s;\n', state{k}, state{k});
     end
     fprintf( fid, '\n');
    end

    % Write function body
    fprintf( fid, '  %% Residual generator body\n');
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
     fprintf( fid, '  %% Update state variables\n');
     for k=1:length(state)
%       fprintf( fid, '  if length(state.%s)==1\n', state{k});
       fprintf( fid, '  state.%s = %s;\n', state{k}, state{k});
%       fprintf( fid, '  else\n');
%       fprintf( fid, '    state.%s = [%s state.%s(1)];\n', state{k}, state{k},state{k});
%       fprintf( fid, '  end\n');
     end
    end
    fprintf( fid, 'end\n');

    if strcmp(matchType,'der')||strcmp(matchType,'mixed')
     WriteDiffFunction( fid );
    end
    if strcmp(matchType,'int')||strcmp(matchType,'mixed')
     WriteIntFunction( fid );     
    end


    fclose( fid );
  else
   warning('Error creating file %s', mfileName);
  end 
end

function [resGenRes,iState, dState, integ] = GenerateResidualEquations( model, resEq, diffres, language )
  % TODO: support multiple output residuals

  if IsMatlab(language)
    rStr = 'r';
  elseif IsC(language)
    rStr = 'r[0]';
  else
    error('Language %s not supported', language );
  end
    
  iState = {};
  dState = {};
  
  if ~IsDifferentialConstraint( model.syme{resEq} ) && ~IsIfConstraint( model.syme{resEq} )
    resExpression = feval(symengine,'lhs', model.syme{resEq})-feval(symengine,'rhs', model.syme{resEq});

    matForm = {sprintf('%s=%s; %s %s', ...
      rStr, ExprToCode( model, resExpression, 1,false, language), CommentSymbol(language), model.e{resEq})};
    
    integ = {};
  elseif IsIfConstraint( model.syme{resEq} )
    if IsC(language)
      error('Generation of if-constraint code is not yet supported for language C');
    end
%    error('Does not yet support code generation for if-constraints');
    integ = {};

    matForm = cell(1,5);
    
    % if condition >= 0
    matForm{1} = sprintf('if %s >= 0', ...
      ExprToCode( model, model.syme{resEq}{1},1,false, language)); 
    % condition true
    resExpression = sym('r')==feval(symengine,'lhs', model.syme{resEq}{2}) ...
      - feval(symengine,'rhs', model.syme{resEq}{2});
    matForm{2} = sprintf('  %s;', ExprToCode( model, resExpression,0,false,language)); 
    matForm{3} = 'else';
    % condition false
    resExpression = sym('r')==feval(symengine,'lhs', model.syme{resEq}{3}) ...
      - feval(symengine,'rhs', model.syme{resEq}{3});
    matForm{4} = sprintf('  %s;', ExprToCode( model, resExpression,0,false,language)); 
    %end    
    matForm{5} = 'end';
  elseif strcmp(diffres,'der')
    e = model.syme{resEq};
    matForm = {sprintf('%s = %s-ApproxDiff(%s, state.%s,Ts); %s %s',rStr,e{1},e{2},e{2},CommentSymbol(language), model.e{resEq})};
    dState = e(2);
    integ = {};
  else 
    diffConstraint = model.syme{resEq};
    matForm = sprintf('%s = ApproxInt(%s,state.%s,Ts); %s %s', ...
      diffConstraint{2},diffConstraint{1}, diffConstraint{2}, ...
      CommentSymbol(language), model.e{resEq});
    integ = {matForm};
    
    e = model.syme{resEq};
%    matForm = sprintf('r = %s-ApproxInt(%s, %s,Ts); %% %s',e{2},e{1},e{2},model.e{resEq});  
    matForm = {sprintf('%s = %s-state.%s; %s %s',rStr,e{2},e{2},CommentSymbol(language),model.e{resEq})};
    iState = e(2);
  end
  resGenRes = matForm;
end

function [resGen, iState, dState, integ] = GenerateExactlyDetermined( model, Gamma,language, quiet )
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
      resGen = [resGen{:} AlgebraicHallComponent(model, Gamma.matching{k}, language, quiet)];
    elseif strcmp(Gamma.matching{k}.type,'int') && length(Gamma.matching{k}.row)>1
      [aRes, aState,aInt] = IntegralHallComponent(model, Gamma.matching{k},language, quiet);
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
      [aRes, aiState,adState,aInt] = MixedHallComponent(model, Gamma.matching{k}, language, quiet);
      resGen = [resGen{:} aRes];
      iState = [iState aiState];
      dState = [dState adState];
      integ = [integ{:} aInt];
    else
      error('Unknown Hall component type');
    end
  end
end

function [resGen, iState, dState, integ] = MixedHallComponent(model, Gamma, language, quiet)
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
      if quiet
        [sol,~,~] = solve(symE{k}, symV{k}, 'Real', true, 'ReturnConditions', true);
      else
        sol = solve(symE{k}, symV{k}, 'Real', true);
      end
      
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

function [resGen, state, integ] = IntegralHallComponent(model, Gamma, language, quiet)
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
      if quiet
        [sol,~,~] = solve(symE{k}, symV{k}, 'Real', true, 'ReturnConditions', true);
      else
        sol = solve(symE{k}, symV{k}, 'Real', true);
      end

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

function resGen = AlgebraicHallComponent(model, Gamma, language, quiet)
  symF = cellfun( @(x) sym(x), model.f,'UniformOutput', false);
  nf = length(model.f);
  
  % Generate symbolic variables
  symV = cellfun( @(x) sym(x),model.x(Gamma.col),'UniformOutput', false);  
  
  % Get symbolic equations and subsititute f_i=0
  symE = cellfun(@(x) subs(x,symF,zeros(1,nf)), model.syme(Gamma.row),...
    'UniformOutput', false);
  
  % Solve algebraic loop
  if quiet
%    [sol,~,~] = solve(symE{:}, symV{:}, 'Real', true, 'ReturnConditions', true);
    sol= solve(symE{:}, symV{:}, 'Real', true, 'ReturnConditions', true);
  else
    sol = solve(symE{:}, symV{:}, 'Real', true);
  end
  if length(sol)>1
    warning('Multiple solutions, using first one');
    sol = sol(1);
  end
%  if length(Gamma.col)==1 || ~isstruct(sol) % Ensure output format is consistent
  if ~isstruct(sol) % Ensure output format is consistent
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

function WriteDiffCHeader( fid )
  fprintf( fid, '// Simple Euler-forward approximation of a derivative\n');
  fprintf( fid, 'double ApproxDiff(double dx, double x0, double Ts);\n');
end

function WriteDiffFunction( fid, language )
  if nargin < 2
    language = 'Matlab';
  end
  if IsMatlab( language )
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
  elseif IsC( language )
    fprintf( fid, '\n');
    fprintf( fid, 'double\nApproxDiff(double x, double xold, double Ts)\n');
    fprintf( fid, '{\n');
    fprintf( fid, '  return (x-xold)/Ts;\n');
    fprintf( fid, '}\n');
  else
    error('Language %s not supported', language );
  end
end

function WriteIntCHeader( fid )
  fprintf( fid, '// Simple Euler-forward integration\n');
  fprintf( fid, 'double ApproxInt(double dx, double x0, double Ts);\n');
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
    fprintf( fid, 'double\nApproxInt(double dx, double x0, double Ts)\n');
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

function s = SeqResGenCausality( Gamma, e, diffres )
  if ~IsDifferentialConstraint(e)
    s = Gamma.type;
  elseif strcmp(diffres,'int')
    % Treat differential residual constraint in integral causality
    switch Gamma.type
      case 'der'
        s = 'mixed';
      case {'int','mixed'}
        s = Gamma.type;
      case 'algebraic'
        s = 'int';
      otherwise
        error('Unknown type of matching');
    end
  else % Treat differential residual constraint in derivative causality
    switch Gamma.type
      case 'int'
        s = 'mixed';
      case {'der','mixed'}
        s = Gamma.type;
      case 'algebraic'
        s = 'der';
      otherwise
        error('Unknown type of matching');
    end
  end
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


