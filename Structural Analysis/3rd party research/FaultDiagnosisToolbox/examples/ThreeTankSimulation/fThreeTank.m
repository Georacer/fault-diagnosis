function xd = fThreeTank(x,u,f,params)

  % Define parameter variables
  Rv1 = params.Rv1;
  Rv2 = params.Rv2;
  Rv3 = params.Rv3;  
  CT1 = params.CT1;
  CT2 = params.CT2;
  CT3 = params.CT3;

  % Define state variables
  p1 = x(1,:);
  p2 = x(2,:);
  p3 = x(3,:);
  
  % Define control inputs
  q0 = u;
  
  % Define fault variables
  fRv1 = f(:,1);
  fRv2 = f(:,2);
  fRv3 = f(:,3);
  fCT1 = f(:,4);
  fCT2 = f(:,5);
  fCT3 = f(:,6);
  
  % Model equations
  
  q1 = 1/Rv1*(p1-p2)  + fRv1;
  q2 = 1/Rv2*(p2-p3)  + fRv2;
  q3 = 1/Rv3*p3       + fRv3;
  
  p1d = 1/CT1*(q0-q1) + fCT1;
  p2d = 1/CT2*(q1-q2) + fCT2;
  p3d = 1/CT3*(q2-q3) + fCT3;
  
  xd = [p1d;p2d;p3d];
end