%%See also paper: A method for quantitative fault diagnosability analysis of stochastic linear descriptor models

classdef DistinguishabilityAnalysisClass
  properties
    ss = [];
    model_type = [];
  end
  methods
    %% Constructor
    function obj = DistinguishabilityAnalysisClass(E, A, Bu, Bf, Be, C, Du, Df, Dv, Lambdae, Lambdav, model_type)
      
      
      if nargin > 11
        obj.model_type = model_type;
      elseif nargin == 11
        obj.model_type = 'dynamic';
      elseif nargin < 11
          error('Not enough inputs.');
      end
      
      % Add model matrices
      obj.ss.E  = E;
      
      obj.ss.A  = A;
      obj.ss.Bu = Bu;
      obj.ss.Bf = Bf;
      obj.ss.Be = Be;

      obj.ss.Lambdae = Lambdae;     
      
      obj.ss.C  = C;
      obj.ss.Du = Du;
      obj.ss.Df = Df;
      obj.ss.Dv = Dv;
      
      obj.ss.Lambdav = Lambdav; 
      
    end
    %% Change Model Type
    function obj = ChangeType(obj, model_type)
      obj.model_type = model_type;
    end
    %% Compute Distinguishability
    function [Dij] = ComputeDistinguishability(obj, fi, fj, theta, n)

      if n <= 0
        error('Window length must be positive.');
      end
      
      nf = numel(obj.ss.Bf(1,:));
      fv = theta;
      
      % Create window model 
      [L H F N Lambda] = CBV(obj, n);
      if rank([H N]) < min(size(H,1))
        disp('[H N] not full row rank. Dij = NaN');
        Dij = NaN;
        return;     
      end
      % Normalize model
      [L H F N] = TMV(obj, L, H, F, N, Lambda);
        
      if numel(theta) == 1
        fv = ones(n,1)*fv;
      elseif numel(fv) > 1 && numel(fv) == n
        [r c] = size(fv);
        if c > r
          fv = fv';
        end
      else
        error('Wrong dimensioned fault vector');
      end
      
      if fj == 0
        Hbar = H;
      else
        Hbar = [H F(:,fj:nf:end)];
      end
      N_Hbar = null(Hbar.').';
      % Ber�kna D
      Dij = 1/2*norm(N_Hbar*F(:,fi:nf:end)*fv)^2;
    end
    %% Compute Distinguishability Matrix
    function [Dij] = ComputeDistinguishabilityMatrix(obj, theta, n)
      nf = size(obj.ss.Bf(1,:),2); % Number of faults
      thetamatrix = cell(nf,nf+1);
      % If all faults have unique fault time profiles stored in a cell
      if iscell(theta) && all(size(theta) == [nf nf+1])
        thetamatrix = theta;
      % If entered fault time profile constant (and length 1)        
      elseif numel(theta) == 1
        for row = 1:nf
          for col = 1:nf+1
            thetamatrix{row, col} = theta*ones(n,1);
          end
        end
      % If fault time profile a vector
      elseif all(size(theta) == [n 1])
        for row = 1:nf
          for col = 1:nf+1
            thetamatrix{row, col} = theta;
          end
        end
      % if fault time profile a matrix
      elseif all(size(theta) == [nf nf+1])
        for row = 1:nf
          for col = 1:nf+1
            thetamatrix{row, col} = theta(row, col)*ones(n,1);
          end
        end      
      elseif size(theta) ~= [nf nf+1]
        error('Wrong dimension of theta');
      end
      
      Dij = zeros(nf, 1+nf);
      for fi = 1:nf
        for fj = 0:nf
          Dij(fi,fj+1) = ComputeDistinguishability(obj, fi, fj, thetamatrix{fi,fj+1}, n);
        end
      end
    end
    %% Return number of unknown variables x
    function [nx] = ReturnX(obj)
      nx = size(obj.ss.A,2);
    end
    %% Create Window model
    function [L H F N Lambda] = CBV(obj, n)
      % Rewrite model as a window model of length n
      A       = obj.ss.A;
      Bu      = obj.ss.Bu;
      Bf      = obj.ss.Bf;
      Be      = obj.ss.Be;
      Lambdae = obj.ss.Lambdae;

      C       = obj.ss.C;
      Du      = obj.ss.Du;
      Df      = obj.ss.Df;
      Dv      = obj.ss.Dv;
      Lambdav = obj.ss.Lambdav;

      %% If same noise components in both Be and Dv
      onlyLambda = 0;
      
      %% Not optimal!!
      %% If noise e = v then Lambda = Lambdae and Lambdav = []
      if isempty(Lambdav) && size(Dv,2) == size(Be,2)
        onlyLambda = 1;
      end
      
      %% Compute sizes of the matrices
      
      % # model equations
      np = max([size(A,1), size(Bu,1), size(Bf,1), size(Be,1)]);
      nq = max([size(C,1), size(Du,1), size(Df,1), size(Dv,1)]);
      
      if size(A,2) ~= size(C,2)
        error('Number of states not consistent in A and C.');
      end
      nx = size(A,2);
      if nx > 0 && size(A,1) ~= np
        error('Number of rows in A not consistent.');
      end
      if nx > 0 && size(C,1) ~= nq
        error('Number of rows in C not consistent.');
      end      
      
      if size(Bu,2) ~= size(Du,2)
        error('Number of inputs not consistent in Bu and Du');
      end
      nu = size(Bu,2);
      if nu > 0 && size(Bu,1) ~= np
        error('Number of rows in Bu not consistent.');
      end
      if nu > 0 && size(Du,1) ~= nq
        error('Number of rows in Du not consistent.');
      end
      
      if size(Bf,2) ~= size(Df,2)
        error('Number of faults not consistent in Bf and Df');
      end
      nf = size(Bf,2);
      if nf > 0 && size(Bf,1) ~= np
        error('Number of rows in Bf not consistent.');
      end
      if nf > 0 && size(Df,1) ~= nq
        error('Number of rows in Df not consistent.');
      end
      
      if size(Be,2) ~= size(Lambdae,2)
        error('Number of stochastic variables not consistent in Be and Lambdae');
      end
      ne = size(Lambdae,2);
      if ne > 0 && size(Be,1) ~= np
        error('Number of rows in Be not consistent.');
      end

      if ~onlyLambda
        if size(Dv,2) ~= size(Lambdav,2)
          error('Number of stochastic variables not consistent in Dv and Lambdav');
        end      
        nv = size(Lambdav,2);
        if nv > 0 && size(Dv,1) ~= nq
          error('Number of rows in Dv not consistent.');
        end
      else
        if size(Dv,2) ~= size(Be,2)
          error('Number of stochastic variables not consistent in Dv and Be');
        end    
        nv = ne;
      end
      % Select E depending if model is static or dynamic
      E = obj.ss.E;
      if strcmpi(obj.model_type, 'dynamic')
        if ~all([np nx] == size(E))
          error('Size of E not consistent.')
        end
      elseif strcmpi(obj.model_type, 'static')
        if isempty(E) 
          E = zeros(np, nx);
        end
        if ~all([np nx] == size(E))
          error('Size of E not consistent.')
        end
        A = A-E;
        E = zeros(np, nx);
      else
        error('Unknown model type.');
      end

      %% Middle step 
      A_n = zeros(n*np, (n+1)*nx);
      for i = 1:n
        A_n((i-1)*np+1:i*np, (i-1)*nx+1:(i+1)*nx) = [A, -E];
      end

      Bu_n = zeros(n*np, n*nu);
      for i = 1:n
        Bu_n((i-1)*np+1:i*np, (i-1)*nu+1:i*nu) = Bu;
      end

      Bf_n = zeros(n*np, n*nf);
      for i = 1:n
        Bf_n((i-1)*np+1:i*np, (i-1)*nf+1:i*nf) = Bf;
      end

      Be_n = zeros(n*np, n*ne);
      for i = 1:n
        Be_n((i-1)*np+1:i*np, (i-1)*ne+1:i*ne) = Be;
      end

      Lambdae_n = zeros(n*ne, n*ne);
      for i = 1:n
        Lambdae_n((i-1)*ne+1:i*ne, (i-1)*ne+1:i*ne) = Lambdae;
      end

      C_n = zeros(n*nq, n*nx);
      for i = 1:n
        C_n((i-1)*nq+1:i*nq, (i-1)*nx+1:i*nx) = C;
      end

      Du_n = zeros(n*nq, n*nu);
      for i = 1:n
        Du_n((i-1)*nq+1:i*nq, (i-1)*nu+1:i*nu) = Du;
      end

      Df_n = zeros(n*nq, n*nf);
      for i = 1:n
        Df_n((i-1)*nq+1:i*nq, (i-1)*nf+1:i*nf) = Df;
      end

      Dv_n = zeros(n*nq, n*nv);
      for i = 1:n
        Dv_n((i-1)*nq+1:i*nq, (i-1)*nv+1:i*nv) = Dv;
      end

      if ~onlyLambda
        Lambdav_n = zeros(n*nv, n*nv);
        for i = 1:n
          Lambdav_n((i-1)*nv+1:i*nv, (i-1)*nv+1:i*nv) = Lambdav;
        end
      end

      %% Compute sizes of new matrices
      
      np_n = max([size(A_n,1), size(Bu_n,1), size(Bf_n,1), size(Be_n,1)]);
      nq_n = max([size(C_n,1), size(Du_n,1), size(Df_n,1), size(Dv_n,1)]);
      
      nx_n = size(A_n,2);     
      nu_n = size(Bu_n,2);
      nf_n = size(Bf_n,2);
      ne_n = size(Lambdae_n,2);
      if ~onlyLambda
        nv_n = size(Lambdav_n,2);    
      end
      %% Return the model in the form Lz = Hz + Ff + Ne
      %
      H = [C_n zeros(nq_n, nx);A_n];
      L = [eye(nq_n), -Du_n; zeros(np_n, nq_n), -Bu_n];
      F = [Df_n; Bf_n];
      if ~onlyLambda
        N = blkdiag(Dv_n,Be_n);
        Lambda = blkdiag(Lambdav_n, Lambdae_n);
      else
        N = [Dv_n;Be_n];
        Lambda = Lambdae_n;
      end
      
    end
    %% Transform window model
    function [L H F N] = TMV(obj, L, H, F, N, Lambda)

      N_H = null(H.').';
      
      Gammainv = inv(chol(N_H*N*Lambda*N'*N_H').');
      
      % Create T
      T = Gammainv*N_H;
      
      if rank(T) < size(T,1)
        error('T low rank.');
      end

      I = eye(numel(T(1,:)));

      % Add rows if rows < cols
      for i = 1:numel(T(1,:))
        if numel(T(:,1)) > numel(T(1,:))
          error('Felaktig T');
        end
        if rank(T) == numel(T(1,:))
          break;
        end
        if rank([T;I(i,:)]) > rank(T)
          T = [T;I(i,:)];
        end
      end

      L = T*L;
      H = T*H;
      F = T*F;
      N = T*N;

    end
    %% Return optimal residual isolating f_i = theta from f_j
    function r = GenerateResidual(obj, fi, fj, theta, n)
      if n <= 0
        error('Window length must be positive.');
      end
      
      nf = numel(obj.ss.Bf(1,:));
      fv = theta;
      
      % Create window model 
      [L H F N Lambda] = CBV(obj, n);
      % Normalize model
      try
        [L H F N] = TMV(obj, L, H, F, N, Lambda);
      catch
        warning('Transformation matrix error');
        Dij = 0;
        return;
      end
        
      if numel(theta) == 1
        fv = ones(n,1)*fv;
      elseif numel(fv) > 1 && numel(fv) == n
        [r c] = size(fv);
        if c > r
          fv = fv';
        end
      else
        error('Wrong dimensioned fault vector');
      end
      
      if fj == 0
        Hbar = H;
      else
        Hbar = [H F(:,fj:nf:end)];
      end
      N_Hbar = null(Hbar.').';
      gamma = (N_Hbar*F(:,fi:nf:end)*fv).';
      % Return vector 
      r = gamma*(N_Hbar*L);
    end
  end
end