function BipartiteToLaTeX( model, name, varargin )
% BipartiteToLaTeX  Generate a LaTeX document with the bipartite graph
%                   correponding to the structural model
%
%    model.BipartiteToLaTeX( fileName, options )
%
%
%  Options can be given as a number of key/value pairs
%
%  Key          Value
%    shortname  If true, only short node names are used (x1, f1, e1 etc).
%               Default value is false, if true latex versions are used. 
%
%    dmperm     Reorganize equations and unknown variables according to
%               Dulmage-Mendelsohn decomposition. Default value true.
%
%    faults     If true, plot nodes for fault variables. Defaults to false.
%
%    TeXNamesX  TeX representation of node names for unknown variables.
%               Only used if shortnames is false, overrides latex-names in
%               model object.
%
%    TeXNamesF  TeX representation of node names for fault variables.
%               Only used if shortnames is false, overrides latex-names in
%               model object.
%
%    TeXNamesE  TeX representation of node names for equations.
%               Only used if shortnames is false, overrides latex-names in
%               model object.
%             
%
%  Example:
%    model.BipartiteToLaTeX('EMbipartite', ...
%      'shortname', false, ...
%      'faults', true,...
%      'TeXNamesX', {'$I$'  '$\omega$'  '$\theta$'  '$\alpha$'  '$\Delta T$'  '$T_m$'  '$T_l$'},...
%      'TeXNamesF', {'$f_R$'  '$f_i$'  '$f_\omega$'  '$f_D$'},...
%      'TeXNamesE', arrayfun(@(d) sprintf('$e_{%d}$', d),1:sm.ne, 'UniformOutput', false));
%

% Copyright Erik Frisk, Mattias Krysander, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  pa = inputParser;
  pa.addOptional( 'shortnames', false );
  pa.addOptional( 'dmperm', true );
  pa.addOptional( 'faults', false );
  pa.addOptional( 'TeXNamesX', {} );
  pa.addOptional( 'TeXNamesF', {} );
  pa.addOptional( 'TeXNamesE', {} );
  pa.addOptional( 'stripped', false );
    
  pa.parse(varargin{:});
  opts = pa.Results;

  if strcmp(name(end-3:end),'.tex')
    fName = name;
  else
    fName = sprintf('%s.tex', name );
  end
  
  fid = fopen( fName, 'w');
  if fid==-1
    error('Could not create file %s.tex', name);
  end
  
  if opts.dmperm
    dm = GetDMParts(model.X);
    p = dm.rowp;
    q = dm.colp;
  else
    p = 1:size(model.X,1);
    q = 1:size(model.X,2);
  end
  
  if isempty(opts.TeXNamesE) && isempty(model.e_latex)
    eNames = model.e;
  elseif ~isempty(opts.TeXNamesE)
    eNames = cellfun(@(x) ['$' x '$'], opts.TeXNamesE, 'UniformOutput', false);
  else
    eNames = cellfun(@(x) ['$' x '$'], model.e_latex, 'UniformOutput', false);
  end
  if isempty(opts.TeXNamesX) && isempty(model.x_latex)
    xNames = model.x;
  elseif ~isempty(opts.TeXNamesX)
    xNames = cellfun(@(x) ['$' x '$'], opts.TeXNamesX, 'UniformOutput', false);
  else
    xNames = cellfun(@(x) ['$' x '$'], model.x_latex, 'UniformOutput', false);
  end
  if isempty(opts.TeXNamesF) && isempty(model.f_latex)
    fNames = model.f;
  elseif ~isempty(opts.TeXNamesF)
    fNames = cellfun(@(x) ['$' x '$'], opts.TeXNamesF, 'UniformOutput', false);
  else
    fNames = cellfun(@(x) ['$' x '$'], model.f_latex, 'UniformOutput', false);
  end
  
  if ~opts.stripped
    fprintf( fid, '\\documentclass[border=1mm]{standalone}\n');
    fprintf( fid, '\\usepackage{tikz}\n');
    fprintf( fid, '\\usetikzlibrary[positioning]\n');
    fprintf( fid, '\n');
    fprintf( fid, '%% File generated %s\n\n', datestr(now));

    fprintf( fid, '\\begin{document}\n');
    fprintf( fid, '\n');
  else
    fprintf( fid, '%% \\usepackage{tikz}\n');
    fprintf( fid, '%% \\usetikzlibrary[positioning]\n');    
  end
  
  fprintf( fid, '\\begin{tikzpicture}[>=stealth,%%\n');
  if opts.shortnames
    fprintf( fid, '  eqnode/.style={shape=circle,draw},%%\n');
    fprintf( fid, '  fnode/.style={shape=circle,color=red,draw},%%\n');
  else
    fprintf( fid, '  eqnode/.style={},%%\n');    
    fprintf( fid, '  fnode/.style={color=red},%%\n');    
  end
  fprintf( fid, '  gedge/.style={line width=1.5pt}]\n');

  if opts.shortnames
    fprintf( fid, '  \\draw node (e%d) [label={\\textbf{Equations}},eqnode]{$e_{%d}$};\n',p(1),p(1));    
  else
    fprintf( fid, '  \\draw node (e%d) [label={\\textbf{Equations}},eqnode]{%s};\n',p(1),eNames{p(1)});    
  end
  for k=2:size(model.X,1)
    if opts.shortnames
      fprintf( fid, '  \\draw node (e%d) [eqnode,below=of e%d]{$e_{%d}$};\n', p(k), p(k-1), p(k));    
    else
      fprintf( fid, '  \\draw node (e%d) [eqnode,below=of e%d]{%s};\n', p(k), p(k-1), eNames{p(k)});    
    end
  end
  fprintf( fid, '\n');
  
  if opts.shortnames
    fprintf( fid, '  \\draw node (x%d) [label={\\textbf{Variables}},eqnode,right=4cm of e%d] {$x_{%d}$};\n',q(1),p(1),q(1));    
  else
    fprintf( fid, '  \\draw node (x%d) [label={\\textbf{Variables}},eqnode,right=4cm of e%d] {%s};\n',q(1),p(1),xNames{q(1)});    
  end    
  for k=2:size(model.X,2)
    if opts.shortnames
      fprintf( fid, '  \\draw node (x%d) [eqnode,below=of x%d]{$x_{%d}$};\n', q(k), q(k-1),q(k));    
    else
      fprintf( fid, '  \\draw node (x%d) [eqnode,below=of x%d]{%s};\n', q(k), q(k-1),xNames{q(k)});    
    end    
  end 
  fprintf( fid, '\n');

  if opts.faults
    fIdx = zeros(1,model.nf);
    for k=1:model.nf
      fIdx(k) = find(model.F(:,k));
    end
    [~,l] = ismember(fIdx,p); 
    [~,fp] = sort(l);
    
    if opts.shortnames
      fprintf( fid, '  \\draw node (f%d) [label={\\textbf{Faults}},fnode,left=4cm of e%d] {$f_{%d}$};\n',fp(1),p(1),fp(1));    
    else
      fprintf( fid, '  \\draw node (f%d) [label={\\textbf{Faults}},fnode,left=4cm of e%d] {%s};\n',fp(1),p(1),fNames{fp(1)});    
    end    
    for k=2:size(model.F,2)
      if opts.shortnames
        fprintf( fid, '  \\draw node (f%d) [fnode,below=of f%d]{$f_{%d}$};\n', fp(k), fp(k-1),fp(k));    
      else
        fprintf( fid, '  \\draw node (f%d) [fnode,below=of f%d]{%s};\n', fp(k), fp(k-1),fNames{fp(k)});    
      end    
    end 
    fprintf( fid, '\n');
  end

  [r,c] = find(model.X>0);
  for ii=1:length(r)
    fprintf( fid, '  \\draw [gedge] (e%d) -- (x%d);\n', r(ii), c(ii));        
  end

  if opts.faults
    fprintf( fid, '\n');
    [r,c] = find(model.F>0);
    for ii=1:length(r)
      fprintf( fid, '  \\draw [gedge,color=red] (e%d) -- (f%d);\n', r(ii), c(ii));        
    end
  end

  fprintf( fid, '\\end{tikzpicture}\n');
  if ~opts.stripped
    fprintf( fid, '\\end{document}\n');
  end
  fclose( fid );

end
