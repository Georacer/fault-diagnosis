function Lint( model )
% LINT Print model information and check for inconsistencies
% 
%   model.Lint()
% 
% Prints model information and checks for inconsistencies in model
% definition.

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)
   
  war = 0;
  err = 0;
  
  dm = GetDMParts(model.X);

  if ~isempty(model.name)
    fprintf('Model: %s\n', model.name );
  else
    fprintf('Model information\n');
  end

  fprintf('\n  Type: %s', model.type );

  nd = sum(any(model.X==3,2));
  
  if nd>0
    fprintf(', dynamic\n' );
  else
    fprintf(', static\n' );
  end
  
  fprintf('\n  Variables and equations\n');
  fprintf('    %d unknown variables\n', model.nx);
  fprintf('    %d known variables\n', model.nz);
  fprintf('    %d fault variables\n', model.nf);
  fprintf('    %d equations, including %d differentical constraints\n', model.ne, nd);
  
  fprintf('\n  Degree of redundancy: %d\n', model.Redundancy());
  fprintf('\n');
  
  if model.ne~=size(model.F,1) || model.ne~=size(model.Z,1)
    fprintf('Error! Inconsistent numnber of rows in incidence matrices\n');
    err = err+1;
  end
  
  if model.nx~=length(model.x)
    fprintf('Error! Inconsistent number of unknown variables\n');
    err = err+1;
  end
 
  if model.nz~=length(model.z)
    fprintf('Error! Inconsistent number of known variables\n');
    err = err+1;
  end
  
  if model.nf~=length(model.f)
    fprintf('Error! Inconsistent number of fault variables\n');
    err = err+1;
  end
  
  if model.ne~=length(model.e)
    fprintf('Error! Inconsistent number of equations\n');
    err = err+1;
  end
  
  if ~all(ismember(model.P,1:model.nx))
    fprintf('Error! Possible sensor locations outside set of unknown variables\n');
    err = err+1;
  end  
  
  if ~all(ismember(model.Pfault,1:model.nx))
    fprintf('Error! Possible sensor locations with faults outside set of unknown variables\n');
    err = err+1;
  end  
  
  if any(sum(model.F,1)>1)
    fprintf('Error! Fault variables can only appear in 1 equation, rewrite model with intermediate variables\n');
    err = err+1;
  end
  
  xIdx = find(all(model.X==0,1));
  for ii=1:length(xIdx)
    fprintf('Warning! Variable %s not included in model\n', model.x{xIdx(ii)});
    war = war + 1;
  end
  zIdx = find(all(model.Z==0,1));
  for ii=1:length(zIdx)
    fprintf('Warning! Variable %s not included in model\n', model.z{zIdx(ii)});
    war = war + 1;
  end
  fIdx = find(all(model.F==0,1));
  for ii=1:length(fIdx)
    fprintf('Warning! Variable %s not included in model\n', model.f{fIdx(ii)});
    war = war + 1;
  end

  if ~isempty(dm.Mm.row)||~isempty(dm.Mm.col)
    fprintf('Warning! Model is underdetermined\n');
    war = war + 1;
  end
  
  fprintf('  Model validation finished with %d errors and %d warnings.\n', err, war);
  
end
