function r = SimScenario(fi,fault, controller, params, t, x0)
  Fi = zeros(1,6); if fi>0, Fi(fi)=1; end
  
  [t,x] = ode45(@(t,x) fThreeTank(x,controller(t,x),fault(t).*Fi,params),t,x0);
  
  r.t = t';
  if fi==0
    r.f = 0*t;
  else
    r.f = fault(t);
  end
  r.Fi = fi;

  f = fault(t)*Fi;
  q0 = controller(t',x')';
  q1 = 1/params.Rv1*(x(:,1)-x(:,2)) + f(:,1);
  q2 = 1/params.Rv2*(x(:,2)-x(:,3)) + f(:,2);
  q3 = 1/params.Rv3*x(:,3) + f(:,3);

  r.z0 = [x q0 q1 q2 q3]';
end