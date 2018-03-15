function sm = LumpDynamics( model )
% LumpDynamics  Lump dynamic variables for structural model
%               Lumping can only be performed on structural models, no
%               lumping can be done for symbolic models.
%
%  model2 = model.LumpDynamics()
%
%  Important: If no output argument is given, the current
%             object will be modified, i.e., it is allowed to write
%                model.LumpDynamics();
%             To create a new object without modifying the original 
%             model, instead write
%                model2 = model.LumpDynamics();

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  if nargout==0
    sm = model;
  else 
    sm = model.copy();
  end

  if ~strcmp(model.type,'Structural')
    error('Lumping dynamic models is only applicable for structural models, not symbolic');
  end
  
  % Find dynamic variables, differential consatrints, and differentiated
  % variables
  dynX = find(any(model.X==2,1));
  diffEq = zeros(1,length(dynX));
  derX   = zeros(1,length(dynX));
  for ii=1:length(dynX);
    diffEq(ii) = find(model.X(:,dynX(ii))==2);
    derX(ii)   = find(model.X(diffEq(ii),:)==3);
  end

  % Columns and equations to keep
  keepX  = setdiff(1:size(model.X,2),derX);
  keepEq = setdiff(1:size(model.X,1),diffEq);
  
  % Lump columns dynX and derX into dynX
  for ii=1:length(dynX)
    sm.X(:,dynX(ii)) = any(sm.X(:,[dynX(ii),derX(ii)]),2);
  end
  
  % Strip dynamic information
  sm.x = sm.x(keepX);

  sm.X = sm.X(keepEq,keepX);
  sm.F = sm.F(keepEq,:);
  sm.Z = sm.Z(keepEq,:);
  
  sm.e = sm.e(keepEq);
  
  sm.P = 1:size(sm.X,2);
end
