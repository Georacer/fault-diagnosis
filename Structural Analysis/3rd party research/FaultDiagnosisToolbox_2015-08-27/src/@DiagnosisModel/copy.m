function m2 = copy( model )
% copy  Make a new copy of the model object
%
%  model2 = model.copy()
%

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  m2 = DiagnosisModel();

  m2.x = model.x;
  m2.f = model.f;
  m2.z = model.z;
  m2.X = model.X;
  m2.F = model.F;
  m2.Z = model.Z;
  m2.type = model.type;
  m2.e = model.e;
  m2.P = model.P;
  m2.Pfault = model.Pfault;
  m2.name = model.name;  
  m2.idGen.setState( model.idGen.state() );
  m2.syme = model.syme;
  m2.parameters = model.parameters;
end
