function GraphPlotNodesDegreeDistributionNature(Graph,varargin)
% Computes and plots distribution of node degrees in th eprovided graph.
% 
% Receives:
%   Graph       -   Graph Struct                                -   the graph loaded with GraphLoad
%                      -    string                                            -    Name of file containing the graph
%   varargin        -   FLEX IO -   The input is in FlexIO format.  The following parameters are allowed:
%                                       Parameter Name          |  Type         |  Optional |   Default Value |   Description
%                                           NumberOfBins         |  integer  |    yes           |       -                         | Sets the number of bins in both in & out links distribution. Overrides both NumberOfInBins and NumberOfOutBins
%                                           NumberOfInBins    |  integer  |    yes           |       15                      | Sets the number of bins in Incoming links distribution.  Will be overriden by NumberOfBins if specified
%                                           NumberOfOutBins  |  integer  |    yes           |       15                      | Sets the number of bins in Outgoing links distribution.  Will be overriden by NumberOfBins if specified
%                                          XAxisType                 |    string  |    yes            |       'log10'             | The type of X axis . May be: 'log' (log10), 'ln' (natural log) or 'normal', case incensitive. Other value produces error.
%                                          YAxisType                 |    string  |    yes            |       'log10'             | The type of Y axis . May be: 'log' (log10), 'ln' (natural log) or 'normal', case incensitive Other value produces error.
%                                          DataType                   |   string   |    yes            |       'both'               | The type of data to plot. May be: 'in','out','both'. case incensitive Other values ignored
%                                          InFitRange              |    string  |   yes             |           []                    | If not empty, specifies the range for the liniar fit for the incoming links distrinution. May be ignored if DataType is not proper.
%                                          OutFitRange            |    string  |   yes             |           []                    | If not empty, specifies the range for the liniar fit for the outgoing links distrinution. May be ignored if DataType is not proper. 
%
% Returns:
%   Nothing
%
% See Also:
%       GraphLoad, GraphCountNodesDegree, FlexIO toolbox
%
% Example:
%   GraphPlotNodesDegreeDistribution('E:\Documents\Articles\Data\ColiNet\CoilInterNoAutoRegVec.Graph','NumberOfInBins',12,'DataType','both','InFitRange',[0.2 1.4]);
%

error(nargchk(1,inf,nargin));
error(nargoutchk(0,0,nargout));

if ~FIOProcessInputParameters(GetDefaultInput)
    error('The default input is not FlexIO compatible');
end
if ~FIOProcessInputParameters(varargin)
    error('The input is not FlexIO compatible');
end
try 
    if exist('NumberOfBins','var')
        NumberOfInBins = NumberOfBins;
        NumberOfOutBins = NumberOfBins;
    end
    Degree = GraphCountNodesDegree(Graph);
    
    hold on;
    
    DynamicLegend = {};
    if ~isempty(strmatch(lower(DataType),{'in','both'},'exact'))
        [X_in, XScale_in] = GetXAxis(Degree(:,2),XAxisType,NumberOfInBins) ;
        Y_in = ComputeDistribution(Degree(:,2),YAxisType,X_in);
        plot(XScale_in(~isnan(Y_in)),Y_in(~isnan(Y_in)),'+-b','MarkerSize',6,'LineWidth',2);
        DynamicLegend{end+1}='Incoming links';
        if ~isempty(InFitRange)
            Cond = XScale_in>=InFitRange(1) & XScale_in<=InFitRange(2)  & ~isnan(Y_in);
            [p s] = polyfit(XScale_in(Cond),Y_in(Cond),1);
            [Y_in_fit,Err_in_fit] = polyval(p,XScale_in(Cond),s);
         %   hErrorBar_in=errorbar(XScale_in(Cond),Y_in_fit,Err_in_fit);
               hErrorBar_in=plot(XScale_in(Cond),Y_in_fit);
            set(hErrorBar_in,'LineWidth',2,'Color','r');
            DynamicLegend{end+1}=['Incoming links fit, slope='  num2str(round(p(1)*10)/10);];
        end
    end
    if ~isempty(strmatch(lower(DataType),{'out','both'},'exact'))
        [X_out, XScale_out] = GetXAxis(Degree(:,3),XAxisType,NumberOfInBins) ;
        Y_out = ComputeDistribution(Degree(:,3),YAxisType,X_out);
        plot(XScale_out(~isnan(Y_out)),Y_out(~isnan(Y_out)),'+-','Color',0.7*[1 1 1],'MarkerSize',6,'LineWidth',2);
        DynamicLegend{end+1}='Outgoing links';
        if ~isempty(OutFitRange)
            Cond = XScale_out>=OutFitRange(1) & XScale_out<=OutFitRange(2)  & ~isnan(Y_out);
            [p s] = polyfit(XScale_out(Cond),Y_out(Cond),1);
            [Y_out_fit,Err_out_fit] = polyval(p,XScale_out(Cond),s);
            hErrorBar_out=errorbar(XScale_out(Cond),Y_out_fit,Err_out_fit);
            set(hErrorBar_out,'LineWidth',2);
            DynamicLegend{end+1}=['Outgoing links fit: Slope='  num2str(p(1))];
        end        
    end
    legend(DynamicLegend);
    grid on;
    title('Nodes degree distribution histogram');
    xlabel('Degree');
    ylabel('Number of nodes');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Y] = ComputeDistribution(Degree,YAxisType,X)
% Computes the histogramm
%
[Y X] = hist(Degree,X);
Y(Y==0 ) = NaN;
switch lower(YAxisType)
    case 'log'
        Y               = log10(Y);
    case 'ln'
        Y               = log(Y);         
    case 'normal'
        ;    
    otherwise   
        error('Unsupported X axis type');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X, XScale] = GetXAxis(Degree,XAxisType,NumberOfBins)
% Generates X axis and labels for the plot.
switch lower(XAxisType)
    case 'log'
        X               = logspace(0,log10(max(Degree)),NumberOfBins);
        XScale   = log10(X);
    case 'ln'
        X               =  exp([0+(0:NumberOfBins-2)*(log(max(Degree))-0)/(floor(NumberOfBins)-1), log(max(Degree))]);
        XScale   = log(X);            
    case 'normal'
        X               = linspace(0,max(Degree),NumberOfBins);
        XScale   = X;            
    otherwise   
        error('Unsupported X axis type');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DefaultInput  = GetDefaultInput()
DefaultInput = {};

% DefaultInput    =   FIOAddParameter(DefaultInput,'NumberOfBins',15);
DefaultInput    =   FIOAddParameter(DefaultInput,'NumberOfInBins',15);
DefaultInput    =   FIOAddParameter(DefaultInput,'NumberOfOutBins',15);
DefaultInput    =   FIOAddParameter(DefaultInput,'XAxisType','log');
DefaultInput    =   FIOAddParameter(DefaultInput,'YAxisType','log');
DefaultInput    =   FIOAddParameter(DefaultInput,'DataType','both');
DefaultInput    =   FIOAddParameter(DefaultInput,'InFitRange',[]);
DefaultInput    =   FIOAddParameter(DefaultInput,'OutFitRange',[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
