function [p,q,P]=PlotDM( X, varargin )
% PlotDM  Plots Dulmage-Mendelsohn decomposition of incidence matrix
%
%    [row,col,psodecomp] = PlotDM(X, [eq])
%
%  Inputs:
%    X      - Incidence matrix
%    eq (optional)
%           - If non-zero, perform canonical decomposition of M+ and
%             plot equivalence classes
%
%             For further details on the canonical decomposition
%             of the M+ part of the structure, see Chapter 4 in 
%             "Design and Analysis of Diagnosis Systems Using Structural 
%              Methods", PhD thesis, Mattias Krysander, 2006. 
%
%  Outputs:
%    row       - row permutation used in the plot
%    col       - column permutation used in the plot
%    psodecomp - result of psodecomposition of the M+ part
%
%  See also: 
%

  pa = inputParser;
  pa.addOptional( 'eqclass', false );
  pa.parse(varargin{:});
  opts = pa.Results;
  
  dm = GetDMParts(X);
  Mm0Eqs  = [dm.Mm.row dm.M0eqs];
  Mm0Vars = [dm.Mm.col dm.M0vars];
  P = [];
  
  nx = size(X,2);
  if nx<50
    fontSize = 12;
  elseif nx > 50 && nx < 75
    fontSize = 10;
  else
    fontSize = 8;
  end
  
  if opts.eqclass && ~isempty(dm.Mp.row)
    % Perform PSO decomposition of M+
    Xp = X(dm.Mp.row,dm.Mp.col);
    P = PSODecomposition(Xp);
     
    % Update PSO decomposition description to correspond to global equation
    % indices
    rowp = dm.Mp.row(P.p);
    colp = dm.Mp.col(P.q);

    for ii=1:length(P.eqclass)
      P.eqclass{ii}.row = dm.Mp.row(P.eqclass{ii}.row);
      P.eqclass{ii}.col = dm.Mp.col(P.eqclass{ii}.col);
    end
    P.trivclass = dm.Mp.row( P.trivclass );
    P.X0        = dm.Mp.col( P.X0 );
    P.p         = dm.Mp.row( P.p );
    P.q         = dm.Mp.col( P.q );
    
    % Update dm.rowp and dm.colp according to PSO decomposition
    prowstart = length(dm.rowp)-length(P.p)+1;
    dm.rowp(prowstart:end) = rowp;
    
    pcolstart = length(dm.colp)-length(P.q)+1;    
    dm.colp(pcolstart:end) = colp;    
  end
%  spy(X(dm.rowp,dm.colp))
  Xalg = X; Xalg(Xalg==2|Xalg==3)=0;
  [rd,cd] = find(X(dm.rowp,dm.colp)==3);
  [ri,ci] = find(X(dm.rowp,dm.colp)==2);
  
  spy(Xalg(dm.rowp,dm.colp))
  hold on
  for k=1:length(rd)
    text(cd(k),rd(k),'D', 'Color', 'blue', 'FontSize', fontSize,...
      'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
    text(ci(k),ri(k),'I', 'Color', 'blue', 'FontSize', fontSize,...
      'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
  end
  
  % Plot under determined part
  if ~isempty(dm.Mm.row)
    r = length(dm.Mm.row);
    c = length(dm.Mm.col);
    x1 = 0.5;
    x2 = x1+c;
    y1 = 0.5;
    y2 = y1+r;
    plot( [x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],'b')    
  end
  
  % Plot exactly determined part
  r = 1+length(dm.Mm.row);
  c = 1+length(dm.Mm.col);
  for k=1:length(dm.M0)
    n = length(dm.M0{k}.row);
    x1 = c-0.5;
    x2 = x1+n;
    y1 = r-0.5;
    y2 = y1+n;
    plot( [x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],'b')
    r = r+n;
    c = c+n;
  end
  
  % Plot over determined part  
  if ~isempty(dm.Mp.row)
    nr = length(dm.Mp.row);
    nc = length(dm.Mp.col);
    x1 = c-0.5;
    x2 = x1+nc;
    y1 = r-0.5;
    y2 = y1+nr;
    plot( [x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],'b')    
  end

  if opts.eqclass && ~isempty(dm.Mp.row)
    % Plot equivalence classes in over determined part  
    r1 = r;
    c1 = c;
    for k=1:length(P.eqclass)
      nr = length(P.eqclass{k}.row);
      nc = length(P.eqclass{k}.col);
      x1 = c-0.5;
      x2 = x1+nc;
      y1 = r-0.5;
      y2 = y1+nr;
      %plot( [x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],'g')
      fill( [x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],0.7*[1 1 1])
      r = r+nr;
      c = c+nc;
    end  
    plot([c1-0.5 length(dm.colp)+0.5], [r-0.5 r-0.5], 'k--')
    plot([c-0.5 c-0.5], [r1-0.5 length(dm.rowp)+0.5], 'k--')   
%    spy(X(dm.rowp,dm.colp))
    Xalg = X; Xalg(Xalg==2|Xalg==3)=0;
    [rd,cd] = find(X(dm.rowp,dm.colp)==3);
    [ri,ci] = find(X(dm.rowp,dm.colp)==2);

    spy(Xalg(dm.rowp,dm.colp))
    hold on
    for k=1:length(rd)
      text(cd(k),rd(k),'D', 'Color', 'blue', 'FontSize', fontSize,...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
      text(ci(k),ri(k),'I', 'Color', 'blue', 'FontSize', fontSize,...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
    end
  end
    
  hold off
  xlabel('Variables');
  ylabel('Equations');
  
  set( gca, 'YTick', 1:length(dm.rowp));
  set( gca, 'XTick', 1:length(dm.colp));
  set( gca, 'YTickLabel', dm.rowp, 'TickLabelInterpreter','none');
  set( gca, 'XTickLabel', dm.colp, 'TickLabelInterpreter','none');

  if nargout > 0
    p = dm.rowp;
    q = dm.colp;
  end
end
