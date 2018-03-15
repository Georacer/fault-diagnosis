function results=pantelides_raw(X,Graph,E)

% Copyright Mattias Krysander, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

% PANTELIDES  Pantelides algorithm
%
%   PANTELIDES(X,G,E) runs pantelides algorithm on the structural model
%   described by variables X and biadjacency matrix G corresponding to
%   equations E.
%
%   Inputs:
%     X  - Cell array describing the variables in the model.
%          For example:
%            X = {{'x',0},{'x',1},{y,0}}
%          corresponds to the variables {x, x', y}. Note that
%          the model must be written in a form where no derivative 
%          is higher than 1. Also, for all variables x, {'x',0} has
%          to be included.
%
%    G  - Biadjacency matrix for the graph representing the 
%         structural model
%    
%    E  - Names of equations (optional). For example E={'e1','e2','e3'}
%
%  Outputs:
%    Structure with the following members
%
%      E       = equation names
%      X       = unknown variable names
%      graph   = matrix representing the edges of the bipartite graph with
%                equations E and variables X as node sets.
%      str_idx = structural index of the underlying DAE
%      assign  = partial assignment. This is a perfect matching between
%                the most differentiated equations in E and the highest
%                derivatives in X.
%      nu      = minimal times each equation has to be differentiated
%                to determine consistent initial conditions

% Author: Mattias Krysander
% Updated by Erik Frisk

  if nargin < 2 | nargin > 3
      error('Wrong number of input arguments.')
  end

  neq = size(Graph,1);

  if nargin == 2
      for i=1:neq
          E{i} = strcat('e',num2str(i));
      end
  end

  %initializing
  A=zeros(1,length(X));
  remaining = 1:length(X);

  %Creating variable assosiation vector A
  while ~isempty(remaining)

      Xtype = remaining(1);
      remaining = remaining(2:end);

      for j=remaining
          if strcmp(X{Xtype(1)}{1},X{j}{1})
              Xtype = [Xtype j];
              remaining = setdiff(remaining,j);
          end
      end

      if length(Xtype)>2
          error('Only two enteries per variable type is allowed.')
      elseif length(Xtype)==2
          tmp = [X{Xtype(1)}{2} X{Xtype(2)}{2}];

          idx2zero = find(tmp == 0);
          if isempty(idx2zero)
              error('The non-derivative must be included in the model.')
          else
              idx2one = find(tmp == 1);
              if isempty(idx2one)
                  error('Higher derivaties than 1 are not allowed.')
              else
                  A(Xtype(idx2zero)) = Xtype(idx2one);
              end
          end
      else
          if X{Xtype}{2} ~= 0
              error('The non-derivative must be included in the model.')
          end
      end
  end
  [A,B,Graph,assign]=findMSS(Graph,A);

  %Computing structural index and equation derivatives.

  derivatives = zeros(size(B));
  for i=1:length(B)
      if B(i) ~= 0
          derivatives(B(i)) = derivatives(i) + 1;
          E{B(i)} = strcat(E{i},char(39));
      end
  end
  results.E = E;

  nu = zeros(neq,1);
  for k=1:length(nu)
      nu(k)=dnum(B,k);
  end
  results.nu=nu;

  for i=1:length(A)
      if A(i) ~= 0
          X{A(i)} = {X{i}{1}, X{i}{2} + 1};
      end
  end
  idx1problem = 0;
  for i=find(A==0)
      if X{i}{2} == 0
          idx1problem = 1;
      end
  end

  results.str_idx = max(derivatives) + idx1problem;
  results.X = X;
  results.graph = Graph;
  results.assign = assign;

  %printPantelides(results,'results.txt');
end

function n=dnum(B,i)
  % Converts the B-vector into the maximum number of times a particular
  % equations is differentiated
  if B(i)==0
    n=0;
  else
    n=1+dnum(B,B(i));
  end
end

function [A,B,Graph,assign]=findMSS(Graph,A)
  %Step 1: Initialization
  [N,M] = size(Graph);
  false = 0;

  assign = zeros(1,M);
  B = zeros(1,N);

  %Step 2
  Nprim = N;

  %Step 3
  for k=[1:Nprim]
    %Step 3a
    i=k;

    %Step 3b
    pathfound = false;
    while ~pathfound 
      %Step 3b-1
      G = Graph;
      G(:,find(A)) = zeros(N,length(find(A)));

      %Step 3b-2
      coloured_Vnodes = [];
      coloured_Enodes = [];

      %Step 3b-3
      %pathfound = false;

      %Step 3b-4
      [pathfound,coloured_Vnodes,coloured_Enodes,assign]=augmentpath(i,pathfound,coloured_Vnodes,coloured_Enodes,assign,G);

      %Step 3b-5
      if pathfound == false
        % (i)
        for j=coloured_Vnodes
          M=M+1;
          A=[A 0];
          Graph=[Graph zeros(N,1)];
          A(j)=M;
        end

        %(ii)
        for l=sort(coloured_Enodes)
          N=N+1;
          edges2Vnodes = [find(Graph(l,:)) A(find(Graph(l,:)))];
          newedges = sparse(ones(1,length(edges2Vnodes)),...
              edges2Vnodes,ones(1,length(edges2Vnodes)),1,M);
          Graph=full([Graph;newedges]);
          B=[B 0];
          B(l)=N;
        end

        %(iii)
        for j=coloured_Vnodes
          assign(A(j))=B(assign(j));
        end

        %(iv)
        i=B(i);
      end
    %Step 3c
    end
  % Step 4
  end
end

function [pathfound,coloured_Vnodes,coloured_Enodes,assign]=augmentpath(i,pathfound,coloured_Vnodes,coloured_Enodes,assign,G)
  true = 1;
  % Step 1
  coloured_Enodes = [coloured_Enodes i];
  % Step 2
  if(any(G(i,assign==0)))
    %Step 2a
    pathfound = true;
    %Step 2b
    nonassigned=find(assign==0);
    tmp = find(G(i,nonassigned));
    assign(nonassigned(tmp(1)))=i;

  % Step 3
  else
    for j=find(G(i,:))
      if isempty(find(j==coloured_Vnodes, 1))&& ~pathfound
        %Step 3a
        coloured_Vnodes = [coloured_Vnodes j];

        %Step 3b
        k=assign(j);

        %Step 3c
        [pathfound,coloured_Vnodes,coloured_Enodes,assign]=...
            augmentpath(k,pathfound,coloured_Vnodes,coloured_Enodes,assign,G);

        %Step 3d
        if pathfound
            %Step 3d-1
            assign(j)=i;
        %Step 3d-2
        end
      end
    end
  end
end


