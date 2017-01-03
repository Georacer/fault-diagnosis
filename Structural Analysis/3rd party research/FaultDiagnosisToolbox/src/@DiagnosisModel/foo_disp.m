function disp(model)
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
  fprintf('    %d equations, including %d differential constraints\n', model.ne, nd);
  fprintf('\n  Degree of redundancy: %d\n', model.Redundancy());
  fprintf('\n');
  
  fprintf('  Available model properties:\n');
  fprintf('    name - Name of the model\n');
  fprintf('    X - Incidence matrix for unknown variables (%d x %d)\n', size(model.X,1), size(model.X,2));
  fprintf('    Z - Incidence matrix for known variables (%d x %d)\n', size(model.Z,1), size(model.Z,2));
  fprintf('    F - Incidence matrix for faults (%d x %d)\n', size(model.F,1), size(model.F,2));
  fprintf('    x - Unknown variable''s names (%d)\n', numel(model.x));
  fprintf('    z - Known variable''s names (%d)\n', numel(model.z));
  fprintf('    f - Fault variable''s names (%d)\n', numel(model.f));
  if ~isempty(model.syme)
    fprintf('    syme - Symbolic equations (%d)\n', numel(model.syme));
  end
  if ~isempty(model.parameters)
    fprintf('    parameters - Parameters''s names (%d)\n', numel(model.parameters));
  end  

  err = 0;
  war = 0;
  if model.ne~=size(model.F,1) || model.ne~=size(model.Z,1)
    err = err+1;
  end
  
  if model.nx~=length(model.x)
    err = err+1;
  end
 
  if model.nz~=length(model.z)
    err = err+1;
  end
  
  if model.nf~=length(model.f)
    err = err+1;
  end
  
  if model.ne~=length(model.e)
    err = err+1;
  end
  
  if ~all(ismember(model.P,1:model.nx))
    err = err+1;
  end  
  
  if ~all(ismember(model.Pfault,1:model.nx))
    err = err+1;
  end  
  
  if any(sum(model.F,1)>1)
    err = err+1;
  end
  
  xIdx = find(all(model.X==0,1));
  for ii=1:length(xIdx)
    war = war + 1;
  end
  zIdx = find(all(model.Z==0,1));
  for ii=1:length(zIdx)
    war = war + 1;
  end
  fIdx = find(all(model.F==0,1));
  for ii=1:length(fIdx)
    war = war + 1;
  end

  if ~isempty(dm.Mm.row)||~isempty(dm.Mm.col)
    war = war + 1;
  end
  
  if (err>0) || (war > 0)
    fprintf('\n');
    fprintf('There might be issues with your model definition, run the \nclass method Lint() for some basic model checking.\n');
  end
  fprintf('\n');
end