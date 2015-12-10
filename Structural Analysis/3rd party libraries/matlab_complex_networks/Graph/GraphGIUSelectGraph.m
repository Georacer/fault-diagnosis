function [varargout] = GraphGIUSelectGraph(varargin)
% Loads GIU dialog which allows selection of Graph from the current scope.
%   
% Receives:
%
% Returns:
%       Selected    -   string  -   The name of the selected variable. Empty ('') if cancel is clicked,
%                   
% See Also:
%   GraphGetGraphVariables
%
% Example:
%   Selected = GraphGIUSelectGraph();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%


%% Dispatcher
if nargin>0 & ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        % [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
        disp([lasterr ' ( '  varargin{1} ' )' ]);
    end
else % Just load:
    fig = GraphGIUSelectGraph('InitGUI');
    uiwait(fig);
    if nargout > 0 & ishandle(fig)        
        varargout{1} = GetSelectedValue(fig);
        delete(fig);
    elseif nargout > 0
        varargout{1} = '';
    elseif ishandle(fig)        
        delete (fig);
    end    

end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fig = InitGUI()
%% Initialize parameters

ButtonPanelHeight = 30;
ButtonSize = [60 17];
InterbuttonGap = 10;

ScreenSize  =   get(0,'ScreenSize');
FigureSize  =   [ScreenSize(3)/4  ScreenSize(4)/3];
FigureSize  =   round([(ScreenSize(3)-FigureSize(1))/2  (ScreenSize(4)-FigureSize(2))/2 FigureSize(1)  FigureSize(2) ]);
set(0,'Units','points');

fig = figure('Units','Points','Position',FigureSize,...
    'Tag',['Figure_' mfilename],'DoubleBuffer','on',...
    'MenuBar','none','NumberTitle','off','WindowStyle','normal','Resize','off',...        
    'Color',get(0,'defaultUicontrolBackgroundColor'),'Visible','on',...
    'Name','Graph Select Dialog'...
    );
    % 'ResizeFcn','BAS_MainFigure(''Figure_BrukerAnalysis_ResizeFcn'',gcbo,[],guidata(gcbo));',...
    % 'CreateFcn','BAS_MainFigure(''Figure_BrukerAnalysis_CreateFcn'',gcbo,[],guidata(gcbo));',...
    % 'DeleteFcn','BAS_MainFigure(''Figure_BrukerAnalysis_DeleteFcn'',gcbo,[],guidata(gcbo));',...

    
FigureSize      =   get(fig,'Position');


Sz = [1 1 FigureSize(3)-2 ButtonPanelHeight];
ButtonPanel   =   uicontrol(fig,'Style','frame','Units','Points','Position',Sz,...
        'Visible','on','Tag','ButtonPanel_Frame');    
Sz = [Sz(3)-ButtonSize(1)-InterbuttonGap (ButtonPanelHeight-ButtonSize(2))/2 ButtonSize(1) ButtonSize(2)];
CancelButton   =   uicontrol(fig,'Style','pushbutton','Units','Points','Position',round(Sz),...
        'Visible','on','Tag','CancelButton_PushButton','String','Cancel',...
         'Callback','GraphGIUSelectGraph(''GraphGIUSelectGraph_CancelButton_Click'',gcbo,[],guidata(gcbo));'...
    );
Sz = get(ButtonPanel,'Position');
Sz = [Sz(3)-2*ButtonSize(1)-2*InterbuttonGap (ButtonPanelHeight-ButtonSize(2))/2 ButtonSize(1) ButtonSize(2)];
OKButton   =   uicontrol(fig,'Style','pushbutton','Units','Points','Position',round(Sz),...
        'Visible','on','Tag','OKButton_PushButton','String','OK',...
         'Callback','GraphGIUSelectGraph(''GraphGIUSelectGraph_OKButton_Click'',gcbo,[],guidata(gcbo));'...
    );
Sz = [InterbuttonGap (ButtonPanelHeight-ButtonSize(2))/2 ButtonSize(1) ButtonSize(2)];
RefreshButton   =   uicontrol(fig,'Style','pushbutton','Units','Points','Position',round(Sz),...
        'Visible','on','Tag','RefreshButton_PushButton','String','Refresh',...
         'Callback','GraphGIUSelectGraph(''GraphGIUSelectGraph_RefreshButton_Click'',gcbo,[],guidata(gcbo));'...
    );

Sz = get(ButtonPanel,'Position');
Sz = [1 Sz(4)+1 FigureSize(3)-2 FigureSize(4)-Sz(4)-2];
VariablesListbox   =   uicontrol(fig,'Style','listbox','Units','Points','Position',round(Sz),...
        'Visible','on','Tag','Variables_Listbox','String','',...
         'Callback','GraphGIUSelectGraph(''GraphGIUSelectGraph_VariablesListbox_Select'',gcbo,[],guidata(gcbo));'...
    );


%% store handles in GIUDATA
handles = guihandles(fig);
handles.ButtonPanel    =   ButtonPanel;
handles.CancelButton     =   CancelButton;
handles.OKButton =   OKButton;
handles.RefreshButton =   RefreshButton;
handles.VariablesListbox   =   VariablesListbox;

guidata(fig, handles);

%% Refresh the GIU
GraphGIUSelectGraph('GraphGIUSelectGraph_RefreshButton_Click',fig,[],guidata(fig));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Result  = GraphGIUSelectGraph_CancelButton_Click(h, eventdata, handles, varargin)
Result= [];
fig = FigureHandle(h);
if ~isempty(fig)
   close(fig); 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Result  = GraphGIUSelectGraph_OKButton_Click(h, eventdata, handles, varargin)
fig = FigureHandle(h);
if ~isempty(fig)
   Result= GetSelectedValue(fig);
   uiresume(fig);    
else
    Result = '';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Result  = GraphGIUSelectGraph_RefreshButton_Click(h, eventdata, handles, varargin)
Result= [];
fig = FigureHandle(h);
GraphVariables = GraphGetGraphVariables();
Selected = GetSelectedValue(fig);
Data        =   guidata(h);
if ~isempty(Data)
    set(Data.VariablesListbox,'String',GraphVariables);
    SetSelectedValue(fig,Selected);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Result  = GraphGIUSelectGraph_VariablesListbox_Select(h, eventdata, handles, varargin)
Result  = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Selected = GetSelectedValue(h)
Selected   = '';
try
    Data        =   guidata(h);
    if ~isempty(Data)
        Variables = get(Data.VariablesListbox,'String');
        if ~isempty(Variables)
            Selected = get(Data.VariablesListbox,'Value');
            if isempty(Selected)
                Selected = '';
            else
                Selected = Variables{Selected(1)};
            end
        end
    end
catch
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetSelectedValue(h,Value)
Data        =   guidata(h);
if ~isempty(Data)
    Variables = get(Data.VariablesListbox,'String');
    if ~isempty(Variables)
        index = strmatch(Value,Variables,'exact');
        if isempty(index)
            index = 1;
        end
        set(Data.VariablesListbox,'Value',index(1));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%