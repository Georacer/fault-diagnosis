function [sidx,nu]=Pantelides(model, eq)  
% Pantelides  Runs Pantelides algorithm for determining structural index and differentiation vector
%
%    [sidx,nu] = model.Pantelides( eq )  
%  
%  Inputs:
%    eq  - Set of exactly determined equations (indices), defaults to complete model.
%
%  Outputs:
%    sidx          - Structural index
%    nu            - Differentiation vector, if eq is supplied, the
%                    differentiation vectors is with respect to the 
%                    subset of equations
%
% Example: 
%   modeldef.type = 'VarStruc';
%   modeldef.x = {'x1','x2','x3','dx1','dx2'};
%   modeldef.z = {};
%   modeldef.f = {};
%   modeldef.rels = {...
%     {'dx1','x1','x2','x3'},...
%     {'dx2','x1','x2'},...
%     {'x2'},...
%     DiffConstraint('dx1','x1'),...
%     DiffConstraint('dx2','x2')};
%   sm = DiagnosisModel( modeldef );
%   sm.name = 'Hessenberg index 3 model';
%
%   [sidx,nu] = sm.Pantelides(1:sm.ne);
%
% For more details, see 
%   Pantelides, Constantinos C. "The consistent initialization of 
%   differential-algebraic systems." SIAM Journal on Scientific and 
%   Statistical Computing 9.2 (1988): 213-231.

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)
  
  if nargin < 2
    eq = 1:model.ne;
    sm = model;
  else
    sm = model.SubModel( eq, 1:model.nx, 'clear', true );
    eq = 1:sm.ne;
  end
  
  X = sm.X(eq,:);

  if sprank(X)~=size(X,1)||size(X,1)~=size(X,2)
    error('Pantelides algortihm can only be run on square, just-determined systems\n');
  end
  
  varIdx = find(any(X~=0,1));
  p.x = arrayfun(@(v) {sm.x{v},0},varIdx,'UniformOutput',false);
  diffC = find(any(X==3,2));
  algC = find(all(X~=3,2));

  Xdiff = (zeros(length(diffC),sm.nx+length(diffC)));
  for k=1:length(diffC)
    iVar = X(diffC(k),:)==2;
    dVar = find(X(diffC(k),:)==3);
    Xdiff(k,[dVar sm.nx+k])=1;
    p.x{end+1} = {sm.x{iVar},1};
  end
  p.X = [X(algC,:) zeros(length(algC),length(diffC));Xdiff];

  r = pantelides_raw( p.x, p.X );
  
  nu = r.nu;
  sidx = r.str_idx;  
end
  
