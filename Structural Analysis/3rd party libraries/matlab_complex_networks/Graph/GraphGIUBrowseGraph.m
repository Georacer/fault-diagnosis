function [varargout] = GraphGIUBrowseGraph(varargin)
% Loads GIU dialog which allows browsing a graph
%
% Receives:
%   Graph       -   structure   -   (optional) The graph loaded with GraphLoad or WikiGraphLoad
% Returns:
%   Path        -   vector      -   Path; list of nodes selected by the user.
%
% See Also:
%    GraphLoad, GraphGetGraphVariables, WikiGraphLoad, GraphGIUBrowseGraph
%
% Example:
%   Path = GraphGIUBrowseGraph(WikiGraph);
% Created:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%


%% Dispatcher
if nargin>0 && ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        % [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch ER
        disp(sprintf('%s  - "%s" , (%s)',ER.identifier, ER.message, varargin{1}));
    end
else % Just load:
    fig = GraphGIUBrowseGraph('InitGUI');
    %   uiwait(fig);
    if nargout > 0 && ishandle(fig)
        varargout{1} = [];
        %         delete(fig);
    elseif nargout > 0
        varargout{1} = [];
        %     elseif ishandle(fig)
        %         delete (fig);
    end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Properties = GetProperties()
Properties                                 =   [];
Properties.ControlPanelHeight              =   30;
Properties.ButtonPanelHeight               =   30;
Properties.PathPanelHeight                 =   20;
Properties.ButtonSize                      =   [60 17];
Properties.PopupMenuSize                   =   [120 17];
Properties.InterbuttonGap                  =   10;
Properties.DetailsPanelWidth               =   175;
Properties.ScrollBarWidth                  =   14;
Properties.NodeDetailsListBoxWidth         =   200;
Properties.NodeDetailsListBoxGap           =   20;
Properties.MaxNumberOfListElements         =   500;

Properties.Font = [];

[FilePath FileName] = fileparts(mfilename('fullpath'));
FileName =    [FilePath '\' FileName '.mat'];
if exist(FileName,'file')==2
    try
        Loaded = load(FileName,'-mat');
        Fields = fieldnames(Loaded.Properties);
        for i = 1 : numel(Fields)
            Properties = setfield(Properties,Fields{i},getfield(Loaded.Properties,Fields{i}));
        end
    catch
    end
end

%% Initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fig = InitGUI
%% Initialize parameters
Properties = GetProperties();

ScreenSize  =   get(0,'ScreenSize');
FigureSize  =   [ScreenSize(3)*3/4  ScreenSize(4)*3/4];
FigureSize  =   round([(ScreenSize(3)-FigureSize(1))/2  (ScreenSize(4)-FigureSize(2))/2 FigureSize(1)  FigureSize(2) ]);
set(0,'Units','points');
%% Create Figure;
fig = figure('Units','Points','Position',FigureSize,...
    'Tag',['Figure_' mfilename],'DoubleBuffer','on',...
    'MenuBar','none','NumberTitle','off','WindowStyle','normal','Resize','on',...
    'Color',get(0,'defaultUicontrolBackgroundColor'),'Visible','on',...
    'ResizeFcn','GraphGIUBrowseGraph(''Figure_GraphGIUBrowseGraph_ResizeFcn'',gcbo,[],guidata(gcbo));',...
    'DeleteFcn','GraphGIUBrowseGraph(''Figure_GraphGIUBrowseGraph_DeleteFcn'',gcbo,[],guidata(gcbo));',...
    'Name','Graph Select Dialog'...
    );
%
% 'CreateFcn','BAS_MainFigure(''Figure_BrukerAnalysis_CreateFcn'',gcbo,[],guidata(gcbo));',...
%
FigureSize      =   get(fig,'Position');

Sz = [1 FigureSize(4)-Properties.ControlPanelHeight-1 FigureSize(3)-2 Properties.ControlPanelHeight];
ControlsPanel   =   uicontrol(fig,'Style','frame','Units','Points','Position',round(Sz),...
    'Visible','on','Tag','ControlsPanel_Frame');

Sz = [1 FigureSize(4)-Properties.PathPanelHeight-Properties.ControlPanelHeight-2 FigureSize(3)-2 Properties.PathPanelHeight];
PathPanel   =   uicontrol(fig,'Style','frame','Units','Points','Position',round(Sz),...
    'Visible','on','Tag','PathPanel_Frame');

Sz = get(ControlsPanel,'Position');
Sz = [Sz(3)-Properties.ButtonSize(1)-Properties.InterbuttonGap Sz(2) + (Properties.ControlPanelHeight-Properties.ButtonSize(2))/2 Properties.ButtonSize(1) Properties.ButtonSize(2)];
CloseButton   =   uicontrol(fig,'Style','pushbutton','Units','Points','Position',round(Sz),...
    'Visible','on','Tag','CloseButton_PushButton','String','Close',...
    'Callback','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_CloseButton_Click'',gcbo,[],guidata(gcbo));'...
    );

Sz = get(ControlsPanel,'Position');
Sz = [Properties.InterbuttonGap Sz(2) + (Properties.ControlPanelHeight-Properties.PopupMenuSize(2))/2 Properties.PopupMenuSize(1) Properties.PopupMenuSize(2)];
SelectedGraphPopup   =   uicontrol(fig,'Style','popupmenu','Units','Points','Position',round(Sz),...
    'Callback','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_VariablesListbox_ButtonDown'',gcbo,[],guidata(gcbo));',...
    'Visible','on','Tag','SelectedGraphButton_PushButton','String',GraphGetGraphVariables()...
    );
Sz = get(SelectedGraphPopup,'Position');
Sz = [Sz(1)+Sz(3)+1 Sz(2) Properties.ButtonSize(1) Properties.ButtonSize(2)];
VariablesListRefreshPushButton   =   uicontrol(fig,'Style','pushbutton','Units','Points','Position',round(Sz),...
    'Callback','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_VariablesListbox_ButtonDown'',gcbo,[],guidata(gcbo));',...
    'Visible','on','Tag','VariablesListRefresh_PushButton','String','Refresh'...
    );

Sz = get(ControlsPanel,'Position');
Sz2 = Sz(2) + (Properties.ControlPanelHeight-Properties.PopupMenuSize(2))/2;
Sz = get(VariablesListRefreshPushButton,'Position');
Sz = [Sz(1)+Sz(3)+Properties.InterbuttonGap Sz2 Properties.PopupMenuSize(1) Properties.PopupMenuSize(2)];
SortOrderPopup   =   uicontrol(fig,'Style','popupmenu','Units','Points','Position',round(Sz),...
    'Callback','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_SortOrderSelect_ButtonDown'',gcbo,[],guidata(gcbo));',...
    'Visible','on','Tag','SortOrder_Popup','String',{ 'ID', 'Name' }...
    );

Sz = get(ControlsPanel,'Position');
Sz2 = Sz(2) + (Properties.ControlPanelHeight-Properties.ButtonSize(2))/2;
Sz = get(SortOrderPopup,'Position');
Sz = [Sz(1)+Sz(3)+Properties.InterbuttonGap Sz2 Properties.ButtonSize(1)*1.5 Properties.ButtonSize(2)];
SortDirectionToggleButton  =   uicontrol(fig,'Style','togglebutton','Units','Points','Position',round(Sz),...
    'Callback','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_SortDirection_ToggleButton'',gcbo,[],guidata(gcbo));',...
    'Visible','on','Tag','SortDirection_ToggleButton','String','Now: Ascending' , 'Value',1 ...
    );

Sz = get(ControlsPanel,'Position');
Sz2 = Sz(2) + (Properties.ControlPanelHeight-Properties.ButtonSize(2))/2;
Sz = get(SortDirectionToggleButton  ,'Position');
Sz = [Sz(1)+Sz(3)+Properties.InterbuttonGap Sz2 Properties.ButtonSize(1) Properties.ButtonSize(2)];
FontSelectPushbutton   =   uicontrol(fig,'Style','pushbutton','Units','Points','Position',round(Sz),...
    'Callback','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_FontSelectSelect_ButtonDown'',gcbo,[],guidata(gcbo));',...
    'Visible','on','Tag','FontSelect_Pushbutton','String','Select Font'...
    );

Sz   = get(FontSelectPushbutton,'Position');
Sz1  = Sz(1)+Sz(3) + Properties.InterbuttonGap;
Sz = get(ControlsPanel,'Position');
Sz = [Sz1 Sz(2) + (Properties.ControlPanelHeight-Properties.PopupMenuSize(2))/2 0.5*Properties.PopupMenuSize(1) Properties.PopupMenuSize(2)];
BrowseDirectionPopup   =   uicontrol(fig,'Style','popupmenu','Units','Points','Position',round(Sz),...
    'Callback','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_BrowseDirectionbox_ButtonDown'',gcbo,[],guidata(gcbo));',...
    'Visible','on','Tag','BrowseDirection_Popup ','String',{'direct','inverse','both'}...
    );

Sz   = get(BrowseDirectionPopup ,'Position');
Sz1  = Sz(1)+Sz(3) + Properties.InterbuttonGap;
Sz = get(ControlsPanel,'Position');
Sz = [Sz1 Sz(2) + (Properties.ControlPanelHeight-Properties.ButtonSize(2))/2 Properties.ButtonSize(1) Properties.ButtonSize(2)];
SearchNodeEdit  =   uicontrol(fig,'Style','edit','Units','Points','Position',round(Sz),...
    'Visible','on','Tag','SearchNode_Edit','String',''...
    );
    % 'KeyPressFcn','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_SearchNodeEdit_KeyPress'',gcbo,[],guidata(gcbo));',...

Sz   = get(SearchNodeEdit,'Position');
Sz1  = Sz(1)+Sz(3) ;
Sz = get(ControlsPanel,'Position');
Sz = [Sz1 Sz(2) + (Properties.ControlPanelHeight-Properties.ButtonSize(2))/2 Properties.ButtonSize(1) Properties.ButtonSize(2)];
SearchNodeButton  =   uicontrol(fig,'Style','pushbutton','Units','Points','Position',round(Sz),...
    'Callback','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_SearchNodePushbutton_ButtonDown'',gcbo,[],guidata(gcbo));',...
    'Visible','on','Tag','SearchNode_Button','String','Search'...
    );

Sz = get(PathPanel,'Position');
Sz = [FigureSize(3)-Properties.DetailsPanelWidth-1 1 Properties.DetailsPanelWidth FigureSize(4)-Properties.PathPanelHeight-Properties.ControlPanelHeight-4];
DetailsPanel   =   uicontrol(fig,'Style','frame','Units','Points','Position',round(Sz),...
    'Visible','on','Tag','DetailsPanel_Frame');

Sz = get(DetailsPanel,'Position');
Sz = [Sz(1)+1 Sz(2)+Sz(4)/2+1 Sz(3)-3 (Sz(4)-4)/2];
GraphDetailsEdit   =   uicontrol(fig,'Style','edit','Units','Points','Position',round(Sz),...
    'Enable','inactive','HorizontalAlignment','left','Max',2,'Min',0,'String','',...
    'Visible','on','Tag','GraphDetails_Edit');

Sz = get(DetailsPanel,'Position');
Sz = [Sz(1)+1 2 Sz(3)-3 (Sz(4)-4)/2];
NodeDetailsEdit   =   uicontrol(fig,'Style','edit','Units','Points','Position',round(Sz),...
    'Enable','inactive','HorizontalAlignment','left','Max',2,'Min',0,'String','',...
    'Visible','on','Tag','NodeDetails_Edit');
if isempty(Properties.Font)
    Properties.Font = GetFont(NodeDetailsEdit);
end
Sz = get(DetailsPanel,'Position');
Sz = [1 1 FigureSize(3)-3-Sz(3) Properties.ScrollBarWidth];
PathDetailsSlider =  uicontrol(fig,'Style','slider','Units','Points','Position',round(Sz),...
    'Callback','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_PathDetailsSlider_ButtonDown'',gcbo,[],guidata(gcbo));',...
    'SliderStep',[1 1],...
    'Visible','on','Tag','PathDetails_Slider');

Sz = get(DetailsPanel,'Position');
Sz = [1 Properties.ScrollBarWidth+1 FigureSize(3)-3-Sz(3) Sz(4)-Properties.ScrollBarWidth-2];
PathBrowserPanel =  uicontrol(fig,'Style','frame','Units','Points','Position',round(Sz),...
    'Visible','on','Tag','PathBrowserPanel_Frame');




%% Path Details Structure:
PathDetails             =   [];
PathDetails.Path        =   {};
PathDetails.OldPath     =   {};
PathDetails.NodeIDs     =   [];
PathDetails.SortOrder    =   [];
PathDetails.NodeNames   =   [];
PathDetails.Elements    =   {};
PathDetails.Text = {};
PathDetails.ScrollPosition = [];
PathDetails.ScrollButtons = cell(2,0);

%% store handles in the Global Variable

global GraphGUIBrowseGraphData;
GraphGUIBrowseGraphData = [];
GraphGUIBrowseGraphData.Properties                                                      =   Properties;

GraphGUIBrowseGraphData.ControlsPanel                                                =   ControlsPanel;
GraphGUIBrowseGraphData.PathPanel                                                           =   PathPanel;
GraphGUIBrowseGraphData.CloseButton                                                     =   CloseButton;
GraphGUIBrowseGraphData.SelectedGraphPopup                                  =   SelectedGraphPopup;
GraphGUIBrowseGraphData.VariablesListRefreshPushButton   =   VariablesListRefreshPushButton;
GraphGUIBrowseGraphData.SortOrderPopup                                              =   SortOrderPopup;
GraphGUIBrowseGraphData.FontSelectPushbutton                              =   FontSelectPushbutton;
GraphGUIBrowseGraphData.DetailsPanel                                                    =   DetailsPanel;
GraphGUIBrowseGraphData.GraphDetailsEdit                                         =   GraphDetailsEdit;
GraphGUIBrowseGraphData.NodeDetailsEdit                                            =   NodeDetailsEdit;
GraphGUIBrowseGraphData.PathDetailsSlider                                       =   PathDetailsSlider;
GraphGUIBrowseGraphData.PathBrowserPanel                                          =   PathBrowserPanel;
GraphGUIBrowseGraphData.PathDetails                                                        =   PathDetails;
GraphGUIBrowseGraphData.BrowseDirectionPopup                                =    BrowseDirectionPopup ;
GraphGUIBrowseGraphData.SortDirectionToggleButton                   =   SortDirectionToggleButton;
GraphGUIBrowseGraphData.SearchNodeEdit                                                 =   SearchNodeEdit  ;
GraphGUIBrowseGraphData.SearchNodeButton                                            = SearchNodeButton ;

SetFont(fig);
%% Refresh controls:
GraphGIUBrowseGraph('GraphGIUBrowseGraph_VariablesListbox_ButtonDown',SelectedGraphPopup,[],guidata(SelectedGraphPopup));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Figure_GraphGIUBrowseGraph_DeleteFcn(h, eventdata, handles, varargin)
global GraphGUIBrowseGraphData;
if ~isempty(GraphGUIBrowseGraphData)
    Properties  =   GraphGUIBrowseGraphData.Properties;
    [FilePath FileName] = fileparts(mfilename('fullpath'));
    save([FilePath '\' FileName '.mat'],'Properties');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GraphGIUBrowseGraph_FontSelectSelect_ButtonDown(h, eventdata, handles, varargin)
global GraphGUIBrowseGraphData;
if ~isempty(GraphGUIBrowseGraphData)
    NewFont = uisetfont(GraphGUIBrowseGraphData.Properties.Font);
    if isstruct(NewFont)
        GraphGUIBrowseGraphData.Properties.Font = NewFont;
        SetFont(h);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Font = GetFont(h)
Font = [];
try
    Font.FontName   = get(h,'FontName');
    Font.FontUnits  = get(h,'FontUnits');
    Font.FontSize   = get(h,'FontSize');
    Font.FontWeight = get(h,'FontWeight');
    Font.FontAngle  = get(h,'FontAngle');
catch
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetFont(h)
fig         =   FigureHandle(h);
global GraphGUIBrowseGraphData;
if ~isempty(GraphGUIBrowseGraphData)
    % Data.Properties.FontName = 'FixedWidth';
    set(GraphGUIBrowseGraphData.NodeDetailsEdit,GraphGUIBrowseGraphData.Properties.Font);
    set(GraphGUIBrowseGraphData.SearchNodeEdit,GraphGUIBrowseGraphData.Properties.Font);
    for i = 1 : numel(GraphGUIBrowseGraphData.PathDetails.Elements)
        set(GraphGUIBrowseGraphData.PathDetails.Elements{i},GraphGUIBrowseGraphData.Properties.Font);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Figure_GraphGIUBrowseGraph_ResizeFcn(h, eventdata, handles, varargin)
fig = FigureHandle(h);
global GraphGUIBrowseGraphData;
if ~isempty(GraphGUIBrowseGraphData)
    ScreenSize      =   get(0,'ScreenSize');
    FigureSize      =   get(fig,'Position');

    Sz = [1 FigureSize(4)-GraphGUIBrowseGraphData.Properties.ControlPanelHeight-1 FigureSize(3)-2 GraphGUIBrowseGraphData.Properties.ControlPanelHeight];
    set(GraphGUIBrowseGraphData.ControlsPanel,'Position',round(Sz));

    Sz = [1 FigureSize(4)-GraphGUIBrowseGraphData.Properties.PathPanelHeight-GraphGUIBrowseGraphData.Properties.ControlPanelHeight-2 FigureSize(3)-2 GraphGUIBrowseGraphData.Properties.PathPanelHeight];
    set(GraphGUIBrowseGraphData.PathPanel,'Position',round(Sz));

    Sz = get(GraphGUIBrowseGraphData.ControlsPanel,'Position');
    Sz = [Sz(3)-GraphGUIBrowseGraphData.Properties.ButtonSize(1)-GraphGUIBrowseGraphData.Properties.InterbuttonGap Sz(2) + (GraphGUIBrowseGraphData.Properties.ControlPanelHeight-GraphGUIBrowseGraphData.Properties.ButtonSize(2))/2 GraphGUIBrowseGraphData.Properties.ButtonSize(1) GraphGUIBrowseGraphData.Properties.ButtonSize(2)];
    set(GraphGUIBrowseGraphData.CloseButton,'Position',round(Sz));

    Sz = get(GraphGUIBrowseGraphData.ControlsPanel,'Position');
    Sz = [GraphGUIBrowseGraphData.Properties.InterbuttonGap Sz(2) + (GraphGUIBrowseGraphData.Properties.ControlPanelHeight-GraphGUIBrowseGraphData.Properties.PopupMenuSize(2))/2 GraphGUIBrowseGraphData.Properties.PopupMenuSize(1) GraphGUIBrowseGraphData.Properties.PopupMenuSize(2)];
    set(GraphGUIBrowseGraphData.SelectedGraphPopup   ,'Position',round(Sz));

    Sz = get(GraphGUIBrowseGraphData.SelectedGraphPopup,'Position');
    Sz = [Sz(1)+Sz(3)+1 Sz(2) GraphGUIBrowseGraphData.Properties.ButtonSize(1) GraphGUIBrowseGraphData.Properties.ButtonSize(2)];
    set(GraphGUIBrowseGraphData.VariablesListRefreshPushButton,'Position',round(Sz));

    Sz = get(GraphGUIBrowseGraphData.ControlsPanel,'Position');
    Sz2 = Sz(2) + (GraphGUIBrowseGraphData.Properties.ControlPanelHeight-GraphGUIBrowseGraphData.Properties.PopupMenuSize(2))/2;
    Sz = get(GraphGUIBrowseGraphData.VariablesListRefreshPushButton,'Position');
    Sz = [Sz(1)+Sz(3)+GraphGUIBrowseGraphData.Properties.InterbuttonGap Sz2 GraphGUIBrowseGraphData.Properties.PopupMenuSize(1) GraphGUIBrowseGraphData.Properties.PopupMenuSize(2)];
    set(GraphGUIBrowseGraphData.SortOrderPopup,'Position',round(Sz));

    Sz = get(GraphGUIBrowseGraphData.PathPanel,'Position');
    Sz = [FigureSize(3)-GraphGUIBrowseGraphData.Properties.DetailsPanelWidth-1 1 GraphGUIBrowseGraphData.Properties.DetailsPanelWidth FigureSize(4)-GraphGUIBrowseGraphData.Properties.PathPanelHeight-GraphGUIBrowseGraphData.Properties.ControlPanelHeight-4];
    set(GraphGUIBrowseGraphData.DetailsPanel,'Position',round(Sz));

    Sz = get(GraphGUIBrowseGraphData.DetailsPanel,'Position');
    Sz = [Sz(1)+1 Sz(2)+Sz(4)/2+1 Sz(3)-3 (Sz(4)-4)/2];
    set(GraphGUIBrowseGraphData.GraphDetailsEdit,'Position',round(Sz));

    Sz = get(GraphGUIBrowseGraphData.DetailsPanel,'Position');
    Sz = [Sz(1)+1 2 Sz(3)-3 (Sz(4)-4)/2];
    set(GraphGUIBrowseGraphData.NodeDetailsEdit,'Position',round(Sz));

    Sz = get(GraphGUIBrowseGraphData.DetailsPanel,'Position');
    Sz = [1 1 FigureSize(3)-3-Sz(3) GraphGUIBrowseGraphData.Properties.ScrollBarWidth];
    set(GraphGUIBrowseGraphData.PathDetailsSlider,'Position',round(Sz));

    Sz = get(GraphGUIBrowseGraphData.DetailsPanel,'Position');
    Sz = [1 GraphGUIBrowseGraphData.Properties.ScrollBarWidth+1 FigureSize(3)-3-Sz(3) Sz(4)-GraphGUIBrowseGraphData.Properties.ScrollBarWidth-2];
    set(GraphGUIBrowseGraphData.PathBrowserPanel,'Position',round(Sz));

    Sz = get(GraphGUIBrowseGraphData.ControlsPanel,'Position');
    Sz2 = Sz(2) + (GraphGUIBrowseGraphData.Properties.ControlPanelHeight-GraphGUIBrowseGraphData.Properties.ButtonSize(2))/2;
    Sz = get(GraphGUIBrowseGraphData.SortOrderPopup,'Position');
    Sz = [Sz(1)+Sz(3)+GraphGUIBrowseGraphData.Properties.InterbuttonGap Sz2 GraphGUIBrowseGraphData.Properties.ButtonSize(1)*1.5 GraphGUIBrowseGraphData.Properties.ButtonSize(2)];
    set(GraphGUIBrowseGraphData.SortDirectionToggleButton,'Position',round(Sz));
    
    Sz = get(GraphGUIBrowseGraphData.ControlsPanel,'Position');
    Sz2 = Sz(2) + (GraphGUIBrowseGraphData.Properties.ControlPanelHeight-GraphGUIBrowseGraphData.Properties.ButtonSize(2))/2;
    Sz = get(GraphGUIBrowseGraphData.SortDirectionToggleButton,'Position');
    Sz = [Sz(1)+Sz(3)+GraphGUIBrowseGraphData.Properties.InterbuttonGap Sz2 GraphGUIBrowseGraphData.Properties.ButtonSize(1) GraphGUIBrowseGraphData.Properties.ButtonSize(2)];
    set(GraphGUIBrowseGraphData.FontSelectPushbutton ,'Position',round(Sz));

    Sz   = get(GraphGUIBrowseGraphData.FontSelectPushbutton,'Position');
    Sz1  = Sz(1)+Sz(3) + GraphGUIBrowseGraphData.Properties.InterbuttonGap;
    Sz = get(GraphGUIBrowseGraphData.ControlsPanel,'Position');
    Sz = [Sz1 Sz(2) + (GraphGUIBrowseGraphData.Properties.ControlPanelHeight-GraphGUIBrowseGraphData.Properties.PopupMenuSize(2))/2 0.5*GraphGUIBrowseGraphData.Properties.PopupMenuSize(1) GraphGUIBrowseGraphData.Properties.PopupMenuSize(2)];
    set(GraphGUIBrowseGraphData.BrowseDirectionPopup,'Position',round(Sz)  );

    Sz   = get(GraphGUIBrowseGraphData.BrowseDirectionPopup ,'Position');
    Sz1  = Sz(1)+Sz(3) + GraphGUIBrowseGraphData.Properties.InterbuttonGap;
    Sz = get(GraphGUIBrowseGraphData.ControlsPanel,'Position');
    Sz = [Sz1 Sz(2) + (GraphGUIBrowseGraphData.Properties.ControlPanelHeight-GraphGUIBrowseGraphData.Properties.ButtonSize(2))/2 GraphGUIBrowseGraphData.Properties.ButtonSize(1) GraphGUIBrowseGraphData.Properties.ButtonSize(2)];
    set(GraphGUIBrowseGraphData.SearchNodeEdit,'Position',round(Sz));

    Sz   = get(GraphGUIBrowseGraphData.SearchNodeEdit,'Position');
    Sz1  = Sz(1)+Sz(3) ;
    Sz = get(GraphGUIBrowseGraphData.ControlsPanel,'Position');
    Sz = [Sz1 Sz(2) + (GraphGUIBrowseGraphData.Properties.ControlPanelHeight-GraphGUIBrowseGraphData.Properties.ButtonSize(2))/2 GraphGUIBrowseGraphData.Properties.ButtonSize(1) GraphGUIBrowseGraphData.Properties.ButtonSize(2)];
    set(GraphGUIBrowseGraphData.SearchNodeButton ,'Position',round(Sz));

    Sz = get(GraphGUIBrowseGraphData.PathBrowserPanel,'Position');
    for i = 1 : numel(    GraphGUIBrowseGraphData.PathDetails.Elements  )
        CurrentSz  = get(GraphGUIBrowseGraphData.PathDetails.Elements{i},'Position');
        CurrentSz(4) = Sz(4)-3-GraphGUIBrowseGraphData.Properties.ButtonSize(2);
        set(GraphGUIBrowseGraphData.PathDetails.Elements{i},'Position',round(CurrentSz));
        Visibility = SetChildVisibility(GraphGUIBrowseGraphData.PathBrowserPanel,GraphGUIBrowseGraphData.PathDetails.Elements{i});
        set(GraphGUIBrowseGraphData.PathDetails.ScrollButtons{1,i},'Visible',Visibility);
        set(GraphGUIBrowseGraphData.PathDetails.ScrollButtons{2,i},'Visible',Visibility);
        set(GraphGUIBrowseGraphData.PathDetails.Text{i},'Visible',Visibility);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Visibility = SetChildVisibility(Parent,Child)
try
    ParentSz = get(Parent,'Position');
    ChildSz = get(Child,'Position');
    if ChildSz(1)+ChildSz(3) > ParentSz(1) & ChildSz(1)+ChildSz(3) <= ParentSz(1) +ParentSz(3)
        Visibility = 'on';
    else
        Visibility  = 'off';
    end
catch
    Visibility = 'off';
end
set(Child,'Visible',Visibility);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GraphGIUBrowseGraph_CloseButton_Click(h, eventdata, handles, varargin)
fig = FigureHandle(h);
if ~isempty(fig)
    % uiresume(fig);
    delete(fig);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GraphGIUBrowseGraph_VariablesListbox_ButtonDown(h, eventdata, handles, varargin)
fig = FigureHandle(h);
global GraphGUIBrowseGraphData;
if ~isempty(fig)
    if ~isempty(GraphGUIBrowseGraphData)
        CurrentSelection = GetVariable(fig);
    end
    GraphVariables = GraphGetGraphVariables();
    set(GraphGUIBrowseGraphData.SelectedGraphPopup,'String',GraphVariables);
    SetVariable(fig,CurrentSelection );

    %% Set sort order:
    SelectedSortOrderList = get(GraphGUIBrowseGraphData.SortOrderPopup,'String');
    SelectedSortOrder = SelectedSortOrderList{get(GraphGUIBrowseGraphData.SortOrderPopup,'Value')};
    SelectedSortOrderList = { 'ID', 'Name' };
    for i = 1 : evalin('base',['numel(' GetVariable(fig) '.Index.Properties)'])
        SelectedSortOrderList{end+1} = evalin('base',[ GetVariable(fig) '.Index.Properties(' num2str(i) ').PropertyName']);
    end
    set(GraphGUIBrowseGraphData.SortOrderPopup,'String',SelectedSortOrderList);
    Index = strmatch(SelectedSortOrder,SelectedSortOrderList,'exact');
    if isempty(Index)
        Index = 1;
    end
    set(GraphGUIBrowseGraphData.SortOrderPopup,'Value',Index);

    %% Set Graph Details:
    set(GraphGUIBrowseGraphData.GraphDetailsEdit,'String',GetGraphDetails(fig));
    %% Set node details:
    Selected = GetVariable(h);
    ClearPath(fig);

    GraphGUIBrowseGraphData.PathDetails.NodeIDs = evalin('base',['GraphNodeIDs(' Selected ')']);
    GraphGUIBrowseGraphData.PathDetails.NodeNames = evalin('base',['GraphGetNodeNames(' Selected ',GraphNodeIDs(' Selected '))']);
    % evalin('base',[ 'strcat(GraphGetNodeNames(' Selected ',GraphNodeIDs(' Selected ')), ''   ('', num2str( GraphNodeIDs(' Selected ')),'')'')' ]);

    % Sort nodes... - not implemented yet
    SortOrder = GetSortOrder(h);
    if ~isempty(SortOrder)
        GraphGUIBrowseGraphData.PathDetails.NodeIDs = GraphGUIBrowseGraphData.PathDetails.NodeIDs (SortOrder);
        if ~isempty(GraphGUIBrowseGraphData.PathDetails.NodeNames)
            GraphGUIBrowseGraphData.PathDetails.NodeNames = GraphGUIBrowseGraphData.PathDetails.NodeNames (SortOrder);
        else
            GraphGUIBrowseGraphData.PathDetails.NodeNames = num2str(GraphGUIBrowseGraphData.PathDetails.NodeIDs);
        end
    end
    if numel(GraphGUIBrowseGraphData.PathDetails.NodeIDs)
        AddNodeToPath(fig,[]);
    end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GraphGIUBrowseGraph_SortDirection_ToggleButton(h, eventdata, handles, varargin)
GraphGIUBrowseGraph_SortOrderSelect_ButtonDown(h, eventdata, handles, varargin)
try
    global GraphGUIBrowseGraphData;
    if ~isempty(GraphGUIBrowseGraphData)
        if get(GraphGUIBrowseGraphData.SortDirectionToggleButton,'Value')==0
            set(GraphGUIBrowseGraphData.SortDirectionToggleButton,'String','Now: Descending');
        else
            set(GraphGUIBrowseGraphData.SortDirectionToggleButton,'String','Now: Ascending');
        end
    end
catch
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GraphGIUBrowseGraph_BrowseDirectionbox_ButtonDown(h, eventdata, handles, varargin)
GraphGIUBrowseGraph_SortOrderSelect_ButtonDown(h, eventdata, handles, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GraphGIUBrowseGraph_SortOrderSelect_ButtonDown(h, eventdata, handles, varargin)
try
    global GraphGUIBrowseGraphData;
    if ~isempty(GraphGUIBrowseGraphData)
        %SortOrder = GetSortOrder(h);
        %if ~isempty(SortOrder )
        %GraphGUIBrowseGraphData.PathDetails.NodeIDs = GraphGUIBrowseGraphData.PathDetails.NodeIDs (SortOrder);
        %GraphGUIBrowseGraphData.PathDetails.NodeNames = GraphGUIBrowseGraphData.PathDetails.NodeNames (SortOrder);
        OldPath = GraphGUIBrowseGraphData.PathDetails.Path;
        ClearPath(h);
        AddNodeToPath(h,[]);
        if iscell(OldPath) & ~isempty(OldPath)
            for i = 1 : numel(OldPath)
                AddNodeToPath(h,OldPath{i});
            end
        end
        %end
    end
catch
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SortOrder = GetSortOrder(h,NodeIDs)
SortOrder = [];
try
    global GraphGUIBrowseGraphData;
    if ~isempty(GraphGUIBrowseGraphData)
        SortBy = get(GraphGUIBrowseGraphData.SortOrderPopup,'Value');
        if SortBy == 1
            if ~exist('NodeIDs','var') | isempty(NodeIDs)
                [Dummy SortOrder] = sort(GraphGUIBrowseGraphData.PathDetails.NodeIDs);
            else
                [Dummy SortOrder] = sort(NodeIDs);
            end
        elseif SortBy == 2
            % Sort By Name
            if ~exist('NodeIDs','var') | isempty(NodeIDs)
                [Dummy SortOrder] = sort(GraphGUIBrowseGraphData.PathDetails.NodeNames);
            else 
                GraphGUIBrowseGraphData.Temp=NodeIDs;
                Selected = GetVariable(h);
                evalin('base','global GraphGUIBrowseGraphData;');
                [NodeNames] = evalin('base',[' GraphGetNodeNames(' Selected ',GraphGUIBrowseGraphData.Temp)']);
                [Dummy SortOrder] = sort(NodeNames);
            end
        else
            % Sort by parameter:
            ParameterNames        = get(GraphGUIBrowseGraphData.SortOrderPopup,'String');
            SortParameterName = ParameterNames{SortBy};
            Selected = GetVariable(h);
            if ~exist('NodeIDs','var') | isempty(NodeIDs)
                evalin('base','global GraphGUIBrowseGraphData;');
                SortByProperty = evalin('base',['GraphGetNodeProperty(' Selected ',''' SortParameterName ''',GraphGUIBrowseGraphData.PathDetails.NodeIDs)']);
                [DummySortOrder] = sort(SortByProperty.Values);
            else
                GraphGUIBrowseGraphData.Temp=NodeIDs;
                evalin('base','global GraphGUIBrowseGraphData;');
                SortByProperty = evalin('base',['GraphGetNodeProperty(' Selected ',''' SortParameterName ''',GraphGUIBrowseGraphData.Temp)']);
                [Dummy SortOrder] = sort(SortByProperty.Values);
            end
        end
         if get( GraphGUIBrowseGraphData.SortDirectionToggleButton ,'Value')==0
             SortOrder = rot90(SortOrder,3);
         end
    end
catch
    SortOrder = [];
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Selected = GetVariable(h)
%Returns the currently selected variable
Selected   = '';
try
    global GraphGUIBrowseGraphData;
    if ~isempty(GraphGUIBrowseGraphData)
        Variables = get(GraphGUIBrowseGraphData.SelectedGraphPopup,'String');
        if ~isempty(Variables)
            Selected = get(GraphGUIBrowseGraphData.SelectedGraphPopup,'Value');
            if isempty(Selected)
                Selected = '';
            else
                Selected = Variables{Selected(1)};
            end
        end
    end
    if isempty(Selected) | ~ObjectIsType(evalin('base',Selected),'Graph')
        Selected = SetSelectedValue(h,Value);
    end
catch
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetVariable(h,Value)
try
    global GraphGUIBrowseGraphData;
    if ~isempty(GraphGUIBrowseGraphData)
        Variables = get(GraphGUIBrowseGraphData.SelectedGraphPopup,'String');
        if ~isempty(Variables)
            index = strmatch(Value,Variables,'exact');
            if isempty(index)
                index = 1;
            end
            set(GraphGUIBrowseGraphData.SelectedGraphPopup,'Value',index(1));
        end
    end
catch
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GraphDetails = GetGraphDetails(h)
GraphDetails  = {};
try
    Selected = GetVariable(h);
    GraphDetails{end+1} = ['Variable Name: ' Selected ];
    GraphDetails{end+1} = ['     Type: ' evalin('base',[Selected '.Type'])];
    GraphDetails{end+1} = ['     Signature: '];
    for i = 1 : evalin('base',['numel(' Selected '.Signature)'])
        GraphDetails{end+1} = ['              ' evalin('base',[Selected '.Signature{' num2str(i) '}'])];
    end
    GraphDetails{end+1} = ['     File Name: '];
    [FileDir FileName FileExt] = fileparts( evalin('base',[Selected '.FileName']));
    GraphDetails{end+1} = ['              ' FileName FileExt];
    GraphDetails{end+1} = ['     Properties: '];
    for i = 1 : evalin('base',['numel(' Selected '.Index.Properties)'])
        GraphDetails{end+1} = ['              ' evalin('base',[Selected '.Index.Properties(' num2str(i) ').PropertyName'])];
    end
    GraphDetails{end+1} = ['     Number of Nodes: ' num2str(evalin('base',['GraphCountNumberOfNodes(' Selected ')']))];
    GraphDetails{end+1} = ['     Number of Links: ' num2str(evalin('base',['GraphCountNumberOfLinks(' Selected ')']))];
catch
    GraphDetails{end+1}  = '';
    GraphDetails{end+1}  = 'Error:';
    GraphDetails{end+1}  = lasterr;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GraphNodeDetails = GetGraphNodeDetails(h,NodeID)
GraphNodeDetails  = {};
try
    Selected = GetVariable(h);
    GraphNodeDetails{end+1} = ['Node ID:    ' num2str(NodeID)];
    NodeName = evalin('base',['GraphGetNodeNames(' Selected ', ' num2str(NodeID) ')']);
    if isempty(NodeName)
        NodeName =' ' ;
    elseif iscell(NodeName)
        NodeName= NodeName{1};
    end
    GraphNodeDetails{end+1} = ['     Name:  ' NodeName ];
    Degree = evalin('base',['GraphCountNodeDegree(' Selected ',' num2str(NodeID) ')']);
    GraphNodeDetails{end+1} = ['     In Degree:  ' num2str(Degree(1)) ];
    GraphNodeDetails{end+1} = ['     Out Degree:  ' num2str(Degree(2)) ];
    if evalin('base', ['numel(' Selected '.Index.Properties)'])
        GraphNodeDetails{end+1} = ['     Node Properties:  '  ];
        for i = 1 : evalin('base', ['numel(' Selected '.Index.Properties)'])
            PropertyName = evalin('base', [Selected '.Index.Properties(' num2str(i) ').PropertyName']);
            PropertyValue = evalin('base', ['GraphGetNodeProperty(' Selected ',''' PropertyName ''',' num2str(NodeID) ','''')']);
            if isnumeric(PropertyValue.Values)
                GraphNodeDetails{end+1} = [ '          '   PropertyName ':   ' num2str(PropertyValue.Values) ];
            else
                GraphNodeDetails{end+1} = [ '          '   PropertyName ':   ' PropertyValue.Values ];
            end
        end
    end
catch
    GraphNodeDetails{end+1}  = '';
    GraphNodeDetails{end+1}  = 'Error:';
    GraphNodeDetails{end+1}  = lasterr;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ClearPath(h)
fig = FigureHandle(h);
if ~isempty(fig)
    try
        global GraphGUIBrowseGraphData;
        if ~isempty(GraphGUIBrowseGraphData)
            GraphGUIBrowseGraphData.PathDetails.OldPath = GraphGUIBrowseGraphData.PathDetails.Path;
            GraphGUIBrowseGraphData.PathDetails.Path = {};
            for i = numel(GraphGUIBrowseGraphData.PathDetails.Elements) : -1 : 1
                delete (GraphGUIBrowseGraphData.PathDetails.Elements{i});
                delete(GraphGUIBrowseGraphData.PathDetails.ScrollButtons{1,i});
                delete(GraphGUIBrowseGraphData.PathDetails.ScrollButtons{2,i});
                delete(GraphGUIBrowseGraphData.PathDetails.Text{i});
            end
            GraphGUIBrowseGraphData.PathDetails.ScrollButtons = cell(2,0);
            GraphGUIBrowseGraphData.PathDetails.Elements = {};
            GraphGUIBrowseGraphData.PathDetails.Nodes = {};
            GraphGUIBrowseGraphData.PathDetails.Text = {};
            PathDetails.NodeIDs     =   [];
            PathDetails.NodeNames   =   [];
            PathDetails.ScrollPosition  = [];
        end
    catch
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GraphGIUBrowseGraph_SearchNodePushbutton_ButtonDown(h, eventdata, handles, varargin)
try
    global GraphGUIBrowseGraphData;
    if ~isempty(GraphGUIBrowseGraphData)
        SearchValue = get(GraphGUIBrowseGraphData.SearchNodeEdit,'String');
        if ~isempty(SearchValue)
            % GraphGUIBrowseGraphData.SearchValue
            Tag = max([ 1 numel(GraphGUIBrowseGraphData.PathDetails.Elements)-1]);          

            [Indeces, NumberOfElements]= FindLinkedElements(h,Tag,1);
            CriteriaIndeces = [];
            SearchWhat = get(GraphGUIBrowseGraphData.SortOrderPopup,'Value');
            if SearchWhat==1 % By ID.
                SearchValue = str2num(SearchValue)
                if ~isempty(SearchValue);                          
                        CriteriaIndeces = find( GraphGUIBrowseGraphData.PathDetails.NodeIDs(Indeces) >= SearchValue );
                end
            elseif SearchWhat==2 % By Name
                if ~isempty(SearchValue);
                    CriteriaIndeces = strmatch(SearchValue,GraphGUIBrowseGraphData.PathDetails.NodeNames(Indeces));
                end
            else  % Sort by property::
                ParameterNames        = get(GraphGUIBrowseGraphData.SortOrderPopup,'String');
                SortParameterName = ParameterNames{SearchWhat};
                Selected = GetVariable(h);
                GraphGUIBrowseGraphData.Temp=GraphGUIBrowseGraphData.PathDetails.NodeIDs(Indeces);
                evalin('base','global GraphGUIBrowseGraphData;');
                SortByProperty = evalin('base',['GraphGetNodeProperty(' Selected ',''' SortParameterName ''',GraphGUIBrowseGraphData.Temp)']);
                if isnumeric(SortByProperty.Values)
                    CriteriaIndeces = find(SortByProperty.Values>=str2num(SearchValue));
                else
                    CriteriaIndeces = strmatch(SearchValue,SortByProperty.Values);
                end
            end
            if get(GraphGUIBrowseGraphData.SortDirectionToggleButton ,'Value')
                GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag)  = min(CriteriaIndeces);
            else
                GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag)  = max(CriteriaIndeces);
            end
            GraphGIUBrowseGraph_ScrollListbox_PushDown(GraphGUIBrowseGraphData.PathDetails.Elements{Tag}, eventdata, handles, varargin);
            set(GraphGUIBrowseGraphData.PathDetails.Elements{Tag},'Value',1);
            % set(h,'String',['Search - ' num2str( numel(CriteriaIndeces) );        end
        end
    end
catch
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GraphGIUBrowseGraph_PathDetailsSlider_ButtonDown(h, eventdata, handles, varargin)
fig = FigureHandle(h);
if ~isempty(fig)
    try
        global GraphGUIBrowseGraphData;
        if ~isempty(GraphGUIBrowseGraphData)
            Position = get( GraphGUIBrowseGraphData.PathDetailsSlider,'Value');
            W = (GraphGUIBrowseGraphData.Properties.NodeDetailsListBoxWidth+GraphGUIBrowseGraphData.Properties.NodeDetailsListBoxGap);
            for i = 1 : numel(GraphGUIBrowseGraphData.PathDetails.Elements)
                ListboxSz = get(GraphGUIBrowseGraphData.PathDetails.Elements{i},'Position');
                ListboxSz(1) = Position + (i-1)*W;
                set(GraphGUIBrowseGraphData.PathDetails.Elements{i},'Position',ListboxSz);
                AdjustBrowseControls(h,i);
            end
        end
    catch
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AdjustBrowseControls(h,Index)
fig = FigureHandle(h);
if ~isempty(fig)
    try
        global GraphGUIBrowseGraphData;
        if ~isempty(GraphGUIBrowseGraphData)
            ListboxSz = get(GraphGUIBrowseGraphData.PathDetails.Elements{Index},'Position');
            SzButton = get(GraphGUIBrowseGraphData.PathDetails.ScrollButtons{1,Index},'Position');
            SzButton(1) = ListboxSz(1);
            set( GraphGUIBrowseGraphData.PathDetails.ScrollButtons{1,Index},'Position',SzButton);
            SzButton(1) = SzButton(1)+SzButton(3);
            set( GraphGUIBrowseGraphData.PathDetails.ScrollButtons{2,Index},'Position',SzButton);
            SzButton(1) = SzButton(1)+SzButton(3);
            set( GraphGUIBrowseGraphData.PathDetails.Text{Index},'Position',SzButton);
            % GraphGUIBrowseGraphData.PathDetails.Text{Index};
            Visibility = SetChildVisibility(GraphGUIBrowseGraphData.PathBrowserPanel,GraphGUIBrowseGraphData.PathDetails.Elements{Index});
            set(GraphGUIBrowseGraphData.PathDetails.ScrollButtons{1,Index},'Visible',Visibility);
            set(GraphGUIBrowseGraphData.PathDetails.ScrollButtons{2,Index},'Visible',Visibility);
            set(GraphGUIBrowseGraphData.PathDetails.Text{Index},'Visible',Visibility);
        end
    catch
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Indeces, NumberOfElements]= FindLinkedElements(h,Tag,FindAll)
try
    global GraphGUIBrowseGraphData;
    if ~isempty(GraphGUIBrowseGraphData)
        if Tag == 1
            NumberOfElements  = numel(GraphGUIBrowseGraphData.PathDetails.NodeIDs);
            SortOrder = GetSortOrder(h,GraphGUIBrowseGraphData.PathDetails.NodeIDs);
        else
            Selected = GetVariable(h);
            NodeID = GraphGUIBrowseGraphData.PathDetails.Path{Tag-1};
            Direction = get(GraphGUIBrowseGraphData.BrowseDirectionPopup,'String');
            Direction = Direction{ get(GraphGUIBrowseGraphData.BrowseDirectionPopup,'Value') };
            Neighbours = evalin('base',['GraphNodeFirstNeighbours(' Selected  ',' num2str(NodeID)  ',''' Direction ''')']);
            NumberOfElements  = numel(Neighbours );
            if NumberOfElements>0
                SortOrder = GetSortOrder(h,Neighbours );
                Neighbours = Neighbours (SortOrder);
            end
        end
        if ~exist('FindAll','var') | FindAll==0
            Indeces = GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag) :  GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag)+GraphGUIBrowseGraphData.Properties.MaxNumberOfListElements-1;
            Indeces (Indeces >NumberOfElements) = [];
        else
            Indeces = 1 : NumberOfElements;
        end                
        if Tag == 1
            Indeces = SortOrder(Indeces);
         %   GraphGUIBrowseGraphData.PathDetails.NodeNames = GraphGUIBrowseGraphData.PathDetails.NodeNames(SortOrder);
         %   GraphGUIBrowseGraphData.PathDetails.NodeIDs    =   GraphGUIBrowseGraphData.PathDetails.NodeIDs(SortOrder);
        else
            GraphGUIBrowseGraphData.Neighbours = Neighbours(Indeces);
            evalin('base',['global GraphGUIBrowseGraphData;']);
            [Neighbours Indeces  ib] = evalin('base',['intersect(GraphGUIBrowseGraphData.PathDetails.NodeIDs, GraphGUIBrowseGraphData.Neighbours)']);
        end
    end
catch
    Indeces = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  GraphGIUBrowseGraph_ScrollListbox_PushDown(h, eventdata, handles, varargin)
fig = FigureHandle(h);
if ~isempty(fig)
    try
        global GraphGUIBrowseGraphData;
        if ~isempty(GraphGUIBrowseGraphData)
            Tag = str2num(get(h,'Tag'));            
            if  strcmp(get(h,'Style'),'pushbutton')  &  ~isempty(strfind(get(h,'String'),'>>'))
                GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag)  = GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag) +GraphGUIBrowseGraphData.Properties.MaxNumberOfListElements;
%                 if GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag) > NumberOfElements - GraphGUIBrowseGraphData.Properties.MaxNumberOfListElements
%                     GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag) = NumberOfElements - GraphGUIBrowseGraphData.Properties.MaxNumberOfListElements;
%                 end
            elseif strcmp(get(h,'Style'),'pushbutton')   & ~isempty(strfind(get(h,'String'),'<<'))
                GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag) = GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag)-GraphGUIBrowseGraphData.Properties.MaxNumberOfListElements;
                if GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag)<=0
                    GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag) = 1;
                end
            end           
            [Indeces, NumberOfElements]= FindLinkedElements(h,Tag);
            if isempty(Indeces) & NumberOfElements>0
                GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag) = 1;
                [Indeces, NumberOfElements]= FindLinkedElements(h,Tag);
            end
            ListBoxString = strcat( GraphGUIBrowseGraphData.PathDetails.NodeNames(Indeces), '    (', num2str(GraphGUIBrowseGraphData.PathDetails.NodeIDs(Indeces)), ')');
            
            set ( GraphGUIBrowseGraphData.PathDetails.Elements{Tag},'String',ListBoxString);
            set(GraphGUIBrowseGraphData.PathDetails.Text{Tag},'String',num2str(NumberOfElements));

            %  eval(get ( GraphGUIBrowseGraphData.PathDetails.Elements{Tag},'Callback'));
        end
    catch
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  GraphGIUBrowseGraph_NodeListBox_Select(h, eventdata, handles, varargin)
fig = FigureHandle(h);
if ~isempty(fig)
    try
        global GraphGUIBrowseGraphData;
        % Properties  =   Data.Properties;
        if ~isempty(GraphGUIBrowseGraphData)
            Tag = str2num(get(h,'Tag'));
            [Indeces, NumberOfElements]= FindLinkedElements(h,Tag);
            Value = get(h,'Value');%  + GraphGUIBrowseGraphData.PathDetails.ScrollPosition(Tag)-1;
            NodeID = Indeces(Value);
            % NodeID = GraphGUIBrowseGraphData.PathDetails.NodeIDs(Value);
            set(GraphGUIBrowseGraphData.NodeDetailsEdit,'String',GetGraphNodeDetails(fig,NodeID));
            for i = Tag + 1 : numel(GraphGUIBrowseGraphData.PathDetails.Elements)
                delete (GraphGUIBrowseGraphData.PathDetails.Elements{i});
                delete (GraphGUIBrowseGraphData.PathDetails.ScrollButtons{1,i});
                delete (GraphGUIBrowseGraphData.PathDetails.ScrollButtons{2,i});
                delete (GraphGUIBrowseGraphData.PathDetails.Text{i});
            end
            GraphGUIBrowseGraphData.PathDetails.Elements(Tag+1:end) = [];
            GraphGUIBrowseGraphData.PathDetails.ScrollButtons(:,Tag+1:end) = [];
            GraphGUIBrowseGraphData.PathDetails.ScrollPosition(:,Tag+1:end) = [];
            GraphGUIBrowseGraphData.PathDetails.Text(Tag+1:end)  = [];
            GraphGUIBrowseGraphData.PathDetails.Path(Tag:end) = [];
            GraphGUIBrowseGraphData.PathDetails.Path(Tag+1:end) = [];
            AddNodeToPath(h,NodeID);
        end
    catch
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AddNodeToPath(h,NodeID)
fig = FigureHandle(h);
if ~isempty(fig)
    try
        global GraphGUIBrowseGraphData;
        % Properties  =   Data.Properties;
        % Add box:

        Sz = get(GraphGUIBrowseGraphData.PathBrowserPanel,'Position');        
        
%        W = (GraphGUIBrowseGraphData.Properties.NodeDetailsListBoxWidth+GraphGUIBrowseGraphData.Properties.NodeDetailsListBoxGap);
        if numel(GraphGUIBrowseGraphData.PathDetails.Elements)>0
            PrevSz = get(GraphGUIBrowseGraphData.PathDetails.Elements{end},'Position');
            PrevWs  = PrevSz(1)+PrevSz(3)+GraphGUIBrowseGraphData.Properties.NodeDetailsListBoxGap;
        else
            PrevWs = 2;
        end
        Sz = [ PrevWs  GraphGUIBrowseGraphData.Properties.ScrollBarWidth+2+GraphGUIBrowseGraphData.Properties.ButtonSize(2) GraphGUIBrowseGraphData.Properties.NodeDetailsListBoxWidth Sz(4)-3-GraphGUIBrowseGraphData.Properties.ButtonSize(2)];
        NewListBox =   uicontrol(fig,'Style','listbox','Units','Points','Position',round(Sz),...
            'Visible','on','Tag',num2str(numel(GraphGUIBrowseGraphData.PathDetails.Elements)+1),'String','', ...
            'Callback','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_NodeListBox_Select'',gcbo,[],guidata(gcbo));'...
            );
        set(NewListBox ,GraphGUIBrowseGraphData.Properties.Font);
        if exist('NodeID','var')  && ~isempty(NodeID)
            if ~isempty(GraphGUIBrowseGraphData)
                if isnumeric(NodeID)
                    if iscell(GraphGUIBrowseGraphData.PathDetails.NodeNames)
                       NodeName = GraphGUIBrowseGraphData.PathDetails.NodeNames{find(GraphGUIBrowseGraphData.PathDetails.NodeIDs==NodeID)};
                    else
                        NodeName = GraphGUIBrowseGraphData.PathDetails.NodeNames(find(GraphGUIBrowseGraphData.PathDetails.NodeIDs==NodeID),:);
                    end
                else
                    NodeName = NodeID;
                    NodeID = GraphGUIBrowseGraphData.PathDetails.NodeIDs(strmatch(NodeID,GraphGUIBrowseGraphData.PathDetails.NodeNames,'exact'));
                end
            end
            GraphGUIBrowseGraphData.PathDetails.Path{end+1} = NodeID;
        end
        Sz = get(NewListBox ,'Position');
        Sz = [Sz(1) Sz(2)-GraphGUIBrowseGraphData.Properties.ButtonSize(2) GraphGUIBrowseGraphData.Properties.ButtonSize(1) GraphGUIBrowseGraphData.Properties.ButtonSize(2)];
        GraphGUIBrowseGraphData.PathDetails.ScrollButtons{end+1} =  uicontrol(fig,'Style','pushbutton','Units','Points','Position',round(Sz),...
            'Callback','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_ScrollListbox_PushDown'',gcbo,[],guidata(gcbo));',...
            'Visible','on','Tag',num2str(numel(GraphGUIBrowseGraphData.PathDetails.Elements)+1),'String','<< Back'...
            );
        Sz = [Sz(1)+GraphGUIBrowseGraphData.Properties.ButtonSize(1) Sz(2) GraphGUIBrowseGraphData.Properties.ButtonSize(1) GraphGUIBrowseGraphData.Properties.ButtonSize(2)];
        GraphGUIBrowseGraphData.PathDetails.ScrollButtons{end+1}=  uicontrol(fig,'Style','pushbutton','Units','Points','Position',round(Sz),...
            'Callback','GraphGIUBrowseGraph(''GraphGIUBrowseGraph_ScrollListbox_PushDown'',gcbo,[],guidata(gcbo));',...
            'Visible','on','Tag',num2str(numel(GraphGUIBrowseGraphData.PathDetails.Elements)+1),'String','Forward >>'...
            );
        Sz(1)  = Sz(1) + Sz(3);
        GraphGUIBrowseGraphData.PathDetails.Text{end+1} = uicontrol(fig,'Style','text','Units','Points','Position',round(Sz),...
            'Visible','on','Tag',num2str(numel(GraphGUIBrowseGraphData.PathDetails.Elements)+1),'String',''...
            );
        GraphGUIBrowseGraphData.PathDetails.ScrollButtons = reshape(GraphGUIBrowseGraphData.PathDetails.ScrollButtons,[2 numel(GraphGUIBrowseGraphData.PathDetails.ScrollButtons)/2]);
        GraphGUIBrowseGraphData.PathDetails.ScrollPosition(end+1) = 1;
        GraphGUIBrowseGraphData.PathDetails.Elements{end+1} = NewListBox;
        GraphGIUBrowseGraph_ScrollListbox_PushDown( GraphGUIBrowseGraphData.PathDetails.ScrollButtons{end-1} );
        if  numel(GraphGUIBrowseGraphData.PathDetails.Elements) < 2
            set(GraphGUIBrowseGraphData.PathDetailsSlider,'Enable','off');
        else
            ListboxSz = get(NewListBox,'Position');
            ClientSz = get(GraphGUIBrowseGraphData.PathBrowserPanel,'Position');
            Shift = (ListboxSz (1)+ListboxSz (3) ) - (ClientSz  (1)+ClientSz (3));
            if Shift>0
                for i = 1 : numel(GraphGUIBrowseGraphData.PathDetails.Elements)
                    Sz = get( GraphGUIBrowseGraphData.PathDetails.Elements{i},'Position');
                    Sz(1) = Sz(1)-Shift;
                    set( GraphGUIBrowseGraphData.PathDetails.Elements{i},'Position',Sz);
                    SzButton = get(GraphGUIBrowseGraphData.PathDetails.ScrollButtons{1,i},'Position');
                    SzButton(1) = Sz(1);
                    set( GraphGUIBrowseGraphData.PathDetails.ScrollButtons{1,i},'Position',SzButton);
                    SzButton(1) = SzButton(1)+SzButton(3);
                    set( GraphGUIBrowseGraphData.PathDetails.ScrollButtons{2,i},'Position',SzButton);
                    SzButton(1) = SzButton(1)+SzButton(3);
                    set(GraphGUIBrowseGraphData.PathDetails.Text{i},'Position',SzButton);

                    Visibility = SetChildVisibility(GraphGUIBrowseGraphData.PathBrowserPanel,GraphGUIBrowseGraphData.PathDetails.Elements{i});
                    set(GraphGUIBrowseGraphData.PathDetails.ScrollButtons{1,i},'Visible',Visibility);
                    set(GraphGUIBrowseGraphData.PathDetails.ScrollButtons{2,i},'Visible',Visibility);
                    set(GraphGUIBrowseGraphData.PathDetails.Text{i},'Visible',Visibility);
                end
            end
            TotalWidth = 0;
            SzFirst = get(GraphGUIBrowseGraphData.PathDetails.Elements{1},'Position');
            SzLast = get(GraphGUIBrowseGraphData.PathDetails.Elements{end},'Position');
            TotalWidth = SzLast(1)+SzLast(3)-SzFirst(1);
            set(GraphGUIBrowseGraphData.PathDetailsSlider,'Enable','on');
            % TO DO: SET THE SLIDER VALUE.
            set(GraphGUIBrowseGraphData.PathDetailsSlider,'Max',2,'Min',-TotalWidth,'Value', SzFirst(1));
        end
    catch
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
