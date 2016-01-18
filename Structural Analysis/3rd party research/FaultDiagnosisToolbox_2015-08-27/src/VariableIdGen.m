classdef VariableIdGen < handle
  properties (Hidden) 
    xlabel='x';
    zlabel='z';
    flabel='f';
    elabel='e';
    x = 1;
    z = 1;
    f = 1;
    e = 1;
  end
  
  methods
    function setXLabel(m,l)
      m.xlabel = l;
    end
    function setZLabel(m,l)
      m.zlabel = l;
    end
    function setFLabel(m,l)
      m.flabel = l;
    end
    function setELabel(m,l)
      m.elabel = l;
    end
    function reset(m)
      resetX(m);
      resetZ(m);
      resetF(m);
      resetE(m);
    end

    function s = state(m)
      s = [m.x m.z m.f m.e];
    end
    
    function setState( m, s )
      m.x = s(1);
      m.z = s(2);
      m.f = s(3);
      m.e = s(4);
    end
    function resetX(m)
      m.x = 1;
    end
    function resetZ(m)
      m.z = 1;
    end
    function resetF(m)
      m.f = 1;
    end
    function resetE(m)
      m.e = 1;
    end
    function r=NewX(m)
      r = sprintf('%s%d',m.xlabel, m.x);
      m.x = m.x + 1;
    end
    function r=NewZ(m)
      r = sprintf('%s%d',m.zlabel, m.z);
      m.z = m.z + 1;
    end
    function r=NewF(m)
      r = sprintf('%s%d',m.flabel, m.f);
      m.f = m.f + 1;
    end
    function r=NewE(m)
      r = sprintf('%s%d',m.elabel, m.e);
      m.e = m.e + 1;
    end
  end
end