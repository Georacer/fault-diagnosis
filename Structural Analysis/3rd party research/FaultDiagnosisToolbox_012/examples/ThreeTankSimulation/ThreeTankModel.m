function G=ThreeTankModel( params )
  Rv1 = params.Rv1;
  Rv2 = params.Rv2;
  Rv3 = params.Rv3;
  
  CT1 = params.CT1;
  CT2 = params.CT2;
  CT3 = params.CT3;

  A = [-1/CT1/Rv1 1/CT1/Rv1 0;...
    1/CT2/Rv1 -1/CT2*(1/Rv1+1/Rv2) 1/CT2/Rv2;...
    0 1/CT3/Rv2 -1/CT3*(1/Rv2+1/Rv3)];
  B = [1/CT1;0;0];
  C = eye(3);
  D = zeros(3,1);
  G = ss(A,B,C,D);
end