function varargout = PreProcessing(varargin)
%{
    
    HOW TO CREATE A NEW TAB

    1. Create or copy PANEL and TEXT objects in GUI

    2. Rename tag of PANEL to "tabNPanel" and TEXT for "tabNtext", where N
    - is a sequential number. 
    Example: tab3Panel, tab3text, tab4Panel, tab4text etc.
    
    3. Add to Tab Code - Settings in m-file of GUI a name of the tab to
    TabNames variable

    Version: 1.0
    First created: January 18, 2016
    Last modified: January 18, 2016

    Author: WFAToolbox (http://wfatoolbox.com)

%}

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PreProcessing_OpeningFcn, ...
                   'gui_OutputFcn',  @PreProcessing_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SimpleOptimizedTabs2 is made visible.
function PreProcessing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SimpleOptimizedTabs2 (see VARARGIN)

% Choose default command line output for SimpleOptimizedTabs2
handles.output = hObject;

%% Tabs Code
% Settings
TabFontSize = 10;
TabNames = {'Preprocessing','Negative mode', 'Positive mode'};
FigWidth = 0.54;

% Figure resize
set(handles.SimpleOptimizedTab,'Units','normalized')
pos = get(handles. SimpleOptimizedTab, 'Position');
set(handles. SimpleOptimizedTab, 'Position', [pos(1) pos(2) FigWidth pos(4)])

% Tabs Execution
handles = TabsFun(handles,TabFontSize,TabNames);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SimpleOptimizedTabs2 wait for user response (see UIRESUME)
% uiwait(handles.SimpleOptimizedTab);

% --- TabsFun creates axes and text objects for tabs
function handles = TabsFun(handles,TabFontSize,TabNames)

% Set the colors indicating a selected/unselected tab
handles.selectedTabColor=get(handles.tab1Panel,'BackgroundColor');
handles.unselectedTabColor=handles.selectedTabColor-0.1;

% Create Tabs
TabsNumber = length(TabNames);
handles.TabsNumber = TabsNumber;
% TabColor = handles.selectedTabColor;
TabColor = [0.89 0.68 0.67];

for i = 1:TabsNumber
    n = num2str(i);
    
    % Get text objects position
    set(handles.(['tab',n,'text']),'Units','normalized')
    pos=get(handles.(['tab',n,'text']),'Position');

    % Create axes with callback function
    handles.(['a',n]) = axes('Units','normalized',...
                    'Box','on',...
                    'XTick',[],...
                    'YTick',[],...
                    'Color',TabColor,...
                    'Position',[pos(1) pos(2) pos(3) pos(4)+0.01],...
                    'Tag',n,...
                    'ButtonDownFcn',[mfilename,'(''ClickOnTab'',gcbo,[],guidata(gcbo))']);
                    
    % Create text with callback function
    handles.(['t',n]) = text('String',TabNames{i},...
                    'Units','normalized',...
                    'Position',[pos(3),pos(2)/2+pos(4)],...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','middle',...
                    'Margin',0.001,...
                    'FontSize',TabFontSize,...
                    'Backgroundcolor',TabColor,...
                    'Tag',n,...
                    'ButtonDownFcn',[mfilename,'(''ClickOnTab'',gcbo,[],guidata(gcbo))']);

%     TabColor = handles.unselectedTabColor;
    TabColor =  [0.89 0.68 0.67];
end
            
% Manage panels (place them in the correct position and manage visibilities)
set(handles.tab1Panel,'Units','normalized')
pan1pos=get(handles.tab1Panel,'Position');
set(handles.tab1text,'Visible','off')
for i = 2:TabsNumber
    n = num2str(i);
    set(handles.(['tab',n,'Panel']),'Units','normalized')
    set(handles.(['tab',n,'Panel']),'Position',pan1pos)
    set(handles.(['tab',n,'Panel']),'Visible','off')
    set(handles.(['tab',n,'text']),'Visible','off')
end


% --- Executes on button press in OutputFilePath.
function OutputFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to OutputFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outFolder = uigetdir();
setappdata(0,'outputdatapath', outFolder);

% --- Executes on button press in MetadataFilePath.
function MetadataFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to MetadataFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[MetaData, path] = uigetfile('*.xlsx');
MetadataPath = [path MetaData];
handles.MetaDataPath=MetadataPath;
setappdata(0,'metaDatapath', MetadataPath);


% --- Executes on button press in InputPositiveFilePath.
function InputPositiveFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to InputPositiveFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inPosFolder = uigetdir();
setappdata(0,'inputPosDatapath', inPosFolder);

% --- Executes on button press in InputNegativeFilePath.
function InputNegativeFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to InputNegativeFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inNegFolder = uigetdir();
setappdata(0,'inputNegDatapath', inNegFolder);


% --- Callback function for clicking on tab
function ClickOnTab(hObject,~,handles)
m = str2double(get(hObject,'Tag'));

for i = 1:handles.TabsNumber
    n = num2str(i);
    if i == m
        set(handles.(['a',n]),'Color',handles.selectedTabColor)
        set(handles.(['t',n]),'BackgroundColor',handles.selectedTabColor)
        set(handles.(['tab',n,'Panel']),'Visible','on')
    else
         TabColor =  [0.89 0.68 0.67];
        set(handles.(['a',n]),'Color',TabColor)
        set(handles.(['t',n]),'BackgroundColor',TabColor)
        set(handles.(['tab',n,'Panel']),'Visible','off')
%         set(handles.(['a',n]),'Color',handles.unselectedTabColor)
%         set(handles.(['t',n]),'BackgroundColor',handles.unselectedTabColor)
%         set(handles.(['tab',n,'Panel']),'Visible','off')
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = PreProcessing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Process.
function Process_Callback(hObject, eventdata, handles)
% hObject    handle to Process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
workflow = bioapps.mimosa.model.PreprocessingWorkflow();
workflow.getConfig()...
    .updateParamValue( 'WorkingDirectory',  getappdata(0, 'outputdatapath') );

%% Import SampleMetaData
inputAdpter = workflow.getNode('SampleMetaDataFileImporter');
inputAdpter.addInputFilePath(  getappdata(0, 'metaDatapath'));

%% Import FeatureSet
pinputAdpter = workflow.getNode('PosConsensusFileImporter');
if ~isempty(getappdata(0, 'inputPosDatapath'))
    pinputAdpter.addInputFilePath(  getappdata(0, 'inputPosDatapath'));
    pinputAdpter.getConfig()...
        .updateParamValue( 'FileExtensionFilter', 'csv');
end
% ConsensusDataParser
w1 = workflow.getNode('PosModePreprocessingWorkflow');

psheetEdit = get(handles.pSheetEdit,'String');

pmetaTableParser = w1.getNode('MetaTableParser');
pmetaTableParser.getConfig()...
    .updateParamValue('Sheet', psheetEdit);

pconsensusDataExtractor = w1.getNode('ConsensusDataExtractor');
pconsensusDataExtractor.getConfig()...
    .updateParamValue('Polarity', 'Pos');

pHeaderToUseEdit = get(handles.pHeaderToUseEdit,'String');
pHeaderToUseEdit= regexprep(pHeaderToUseEdit, '\s+', '');

pUserIDHeaderEdit = get(handles.pUserIDHeaderEdit,'String');

% Annotate
pconsensusDataAnnotator = w1.getNode('ConsensusDataAnnotator');
pconsensusDataAnnotator.getConfig()...
    .updateParamValue('HeadersToUse', strsplit(pHeaderToUseEdit, ','))...
    .updateParamValue('UserIdHeader', pUserIDHeaderEdit);



pparamValue = get(handles.pCDALabelViewEdit,'String');
pparamValueLabelFormat = regexprep(pparamValue, '\s+', '');
pviewConsensusDataAnnotator = w1.getNode('ViewConsensusDataAnnotator');
pviewConsensusDataAnnotator.getConfig()...
    .updateParamValue('ViewParameters', {{'LabelFormat', {strcat(pparamValueLabelFormat, ':([^_]*)')}}});
pparamValue = get(handles.pCDALabelsViewPCAEdit,'String');
pparamValue = strsplit(pparamValue, ',');
pparamValueGroupList = regexprep(pparamValue{1}, '\s+', '');
pparamValueLabelFormat = regexprep(pparamValue{2}, '\s+', '');
pPCAconsensusDataAnnotator = w1.getNode('ViewPcaConsensusDataAnnotator');
pPCAconsensusDataAnnotator.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{pparamValueGroupList}, 'LabelFormat', {strcat(pparamValueLabelFormat, ':([^_]*)')}}});


% DataRemove
pListOfNames = get(handles.pListOfNames,'String');
pListOfNames = regexprep(pListOfNames, '\s+', '');
pdataSelector = w1.getNode('DataSelector');
pdataSelector.getConfig().updateParamValue(...
    'ListOfNames', strsplit(pListOfNames, ','));

% Blank Filter
pThresholdBlankEdit = get(handles.pThresholdBlankEdit,'String');
pThresholdBlankEdit = str2num(pThresholdBlankEdit);

pblankFilter = w1.getNode('BlankFilter');
pblankFilter.getConfig()...
    .updateParamValue('BlankIntensityRatio', pThresholdBlankEdit);

pparamValue = get(handles.pBFLabelViewEdit,'String');
pparamValueLabelFormat = regexprep(pparamValue, '\s+', '');
pviewBlankFilter = w1.getNode('ViewBlankFilter');
pviewBlankFilter.getConfig()...
    .updateParamValue('ViewParameters', {{'LabelFormat', {strcat(pparamValueLabelFormat, ':([^_]*)')}}});
pparamValue = get(handles.pBFLablesViewPCAEdit,'String');
pparamValue = strsplit(pparamValue, ',');
pparamValueGroupList = regexprep(pparamValue{1}, '\s+', '');
pparamValueLabelFormat = regexprep(pparamValue{2}, '\s+', '');
pPCABlankFilter = w1.getNode('ViewPcaBlankFilter');
pPCABlankFilter.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{pparamValueGroupList}, 'LabelFormat', {strcat(pparamValueLabelFormat, ':([^_]*)')}}});


% Filter by 80 %
pThresholdPercRuleFilterEdit = get(handles.pThresholdPercRuleFilterEdit,'String');
pThresholdPercRuleFilterEdit = str2num(pThresholdPercRuleFilterEdit);
pGroupListEdit = get(handles.pGroupListEdit,'String');
pGroupListEdit =regexprep(pGroupListEdit, '\s+', '');
pMethodOfFilteringEdit = get(handles.pMethodOfFilteringEdit,'String');

ppercentageRuleFilter = w1.getNode('PercentageRuleFilter');
ppercentageRuleFilter.getConfig()...
    .updateParamValue('PercentageRuleThreshold', pThresholdPercRuleFilterEdit)...
    .updateParamValue('GroupList',strsplit(pGroupListEdit, ',') ) ...
    .updateParamValue('MethodOfFiltering', pMethodOfFilteringEdit);


pparamValue = get(handles.pPRFLAbelsViewPlotsEdit,'String');
pparamValueLabelFormat = regexprep(pparamValue, '\s+', '');
pviewThresholdPercRuleFilter = w1.getNode('ViewPercentageRuleFilter');
pviewThresholdPercRuleFilter.getConfig()...
    .updateParamValue('ViewParameters', {{'LabelFormat', {strcat(pparamValueLabelFormat, ':([^_]*)')}}});
pparamValue = get(handles.pPRFLAbelsViewPCAEdit,'String');
pparamValue = strsplit(pparamValue, ',');
pparamValueGroupList = regexprep(pparamValue{1}, '\s+', '');
pparamValueLabelFormat = regexprep(pparamValue{2}, '\s+', '');
pPCAThresholdPercRuleFilter = w1.getNode('ViewPcaPercentageRuleFilter');
pPCAThresholdPercRuleFilter.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{pparamValueGroupList}, 'LabelFormat', {strcat(pparamValueLabelFormat, ':([^_]*)')}}});


% FilterCv 20%
pQcCVThresholdEdit = get(handles.pQcCVThresholdEdit,'String');
pQcCVThresholdEdit = str2num(pQcCVThresholdEdit);
pQcCVLoqEdit = get(handles.pQcCVLoqEdit,'String');
pQcCVLoqEdit = str2num(pQcCVLoqEdit);

pqcCvFilter = w1.getNode('QcCvFilter');
pqcCvFilter.getConfig()...
    .updateParamValue('QcCvThreshold', pQcCVThresholdEdit)...
    .updateParamValue('PercentageRuleThreshold', 0)...
    .updateParamValue('LoQ', pQcCVLoqEdit);


pparamValue = get(handles.pQcCVLabelsViewPlotsEdit,'String');
pparamValueLabelFormat = regexprep(pparamValue, '\s+', '');
pviewQcCV = w1.getNode('ViewQcCvFilter');
pviewQcCV.getConfig()...
    .updateParamValue('ViewParameters', {{'LabelFormat', {strcat(pparamValueLabelFormat, ':([^_]*)')}}});
pparamValue = get(handles.pQcCVLabelsViewPCAEdit,'String');
pparamValue = strsplit(pparamValue, ',');
pparamValueGroupList = regexprep(pparamValue{1}, '\s+', '');
pparamValueLabelFormat = regexprep(pparamValue{2}, '\s+', '');
pPCAQcCV = w1.getNode('ViewPcaQcCvFilter');
pPCAQcCV.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{pparamValueGroupList}, 'LabelFormat', {strcat(pparamValueLabelFormat, ':([^_]*)')}}});

pparamValue = get(handles.pIaDFLAbelsViewPCAEdit,'String');
pparamValue = strsplit(pparamValue, ',');
pparamValueGroupList = regexprep(pparamValue{1}, '\s+', '');
pparamValueLabelFormat = regexprep(pparamValue{2}, '\s+', '');
pPcaIntraBatchDriftCorrector = w1.getNode('ViewPcaIntraBatchDriftCorrector');
pPcaIntraBatchDriftCorrector.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{pparamValueGroupList}, 'LabelFormat', {strcat(pparamValueLabelFormat, ':([^_]*)')}}});


pparamValue = get(handles.pIDFLAbelsViewPCAEdit,'String');
pparamValue = strsplit(pparamValue, ',');
pparamValueGroupList = regexprep(pparamValue{1}, '\s+', '');
pparamValueLabelFormat = regexprep(pparamValue{2}, '\s+', '');
pPcaInterBatchDriftCorrector = w1.getNode('ViewPcaInterBatchDriftCorrector');
pPcaInterBatchDriftCorrector.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{pparamValueGroupList}, 'LabelFormat', {strcat(pparamValueLabelFormat, ':([^_]*)')}}});


%% Negative Workflow

% Import FeatureSet
ninputAdpter = workflow.getNode('NegConsensusFileImporter');
if ~isempty(getappdata(0, 'inputNegDatapath'))
    
    ninputAdpter.addInputFilePath( getappdata(0, 'inputNegDatapath'));
    ninputAdpter.getConfig()...
        .updateParamValue( 'FileExtensionFilter', 'csv');
end
% ConsensusDataParser
w2 = workflow.getNode('NegModePreprocessingWorkflow');

nsheetEdit = get(handles.nSheetEdit,'String');

nmetaTableParser = w2.getNode('MetaTableParser');
nmetaTableParser.getConfig()...
    .updateParamValue('Sheet', nsheetEdit);

nconsensusDataExtractor = w2.getNode('ConsensusDataExtractor');
nconsensusDataExtractor.getConfig()...
    .updateParamValue('Polarity', 'Neg');

nHeaderToUseEdit = get(handles.nHeaderToUseEdit,'String');
nHeaderToUseEdit= regexprep(nHeaderToUseEdit, '\s+', '');
nUserIDHeaderEdit = get(handles.nUserIDHeaderEdit,'String');


% Annotate
nconsensusDataAnnotator = w2.getNode('ConsensusDataAnnotator');
nconsensusDataAnnotator.getConfig()...
    .updateParamValue('HeadersToUse', strsplit(nHeaderToUseEdit, ','))...
    .updateParamValue('UserIdHeader',nUserIDHeaderEdit);


nparamValue = get(handles.nCDALabelViewEdit,'String');
nparamValueLabelFormat = regexprep(nparamValue, '\s+', '');
nviewConsensusDataAnnotator = w2.getNode('ViewConsensusDataAnnotator');
nviewConsensusDataAnnotator.getConfig()...
    .updateParamValue('ViewParameters', {{'LabelFormat', {strcat(nparamValueLabelFormat, ':([^_]*)')}}});
nparamValue = get(handles.nCDALabelsViewPCAEdit,'String');
nparamValue = strsplit(nparamValue, ',');
nparamValueGroupList = regexprep(nparamValue{1}, '\s+', '');
nparamValueLabelFormat = regexprep(nparamValue{2}, '\s+', '');
nPCAconsensusDataAnnotator = w2.getNode('ViewPcaConsensusDataAnnotator');
nPCAconsensusDataAnnotator.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{nparamValueGroupList}, 'LabelFormat', {strcat(nparamValueLabelFormat, ':([^_]*)')}}});


% DataRemove
nListOfNames = get(handles.nListOfNames,'String');
nListOfNames = regexprep(nListOfNames, '\s+', '');
ndataSelector = w2.getNode('DataSelector');
ndataSelector.getConfig().updateParamValue(...
    'ListOfNames', strsplit(nListOfNames, ','));

% Blank Filter
nThresholdBlankEdit = get(handles.nThresholdBlankEdit,'String');
nThresholdBlankEdit = str2num(nThresholdBlankEdit);

nblankFilter = w2.getNode('BlankFilter');
nblankFilter.getConfig()...
    .updateParamValue('BlankIntensityRatio', nThresholdBlankEdit);

nparamValue = get(handles.nBFLabelViewEdit,'String');
nparamValueLabelFormat = regexprep(nparamValue, '\s+', '');
nviewBlankFilter = w2.getNode('ViewBlankFilter');
nviewBlankFilter.getConfig()...
    .updateParamValue('ViewParameters', {{'LabelFormat', {strcat(nparamValueLabelFormat, ':([^_]*)')}}});
nparamValue = get(handles.nBFLablesViewPCAEdit,'String');
nparamValue = strsplit(nparamValue, ',');
nparamValueGroupList = regexprep(nparamValue{1}, '\s+', '');
nparamValueLabelFormat = regexprep(nparamValue{2}, '\s+', '');
nPcaBlankFilter = w2.getNode('ViewPcaBlankFilter');
nPcaBlankFilter.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{nparamValueGroupList}, 'LabelFormat', {strcat(nparamValueLabelFormat, ':([^_]*)')}}});


% Filter by 80 %
nThresholdPercRuleFilterEdit = get(handles.nThresholdPercRuleFilterEdit,'String');
nThresholdPercRuleFilterEdit = str2num(nThresholdPercRuleFilterEdit);
nGroupListEdit = get(handles.nGroupListEdit,'String');
nGroupListEdit = regexprep(nGroupListEdit, '\s+', '');
nMethodOfFilteringEdit = get(handles.nMethodOfFilteringEdit,'String');

npercentageRuleFilter = w2.getNode('PercentageRuleFilter');
npercentageRuleFilter.getConfig()...
    .updateParamValue('PercentageRuleThreshold', nThresholdPercRuleFilterEdit)...
    .updateParamValue('GroupList', strsplit(nGroupListEdit, ',')) ...
    .updateParamValue('MethodOfFiltering', nMethodOfFilteringEdit);


nparamValue = get(handles.nPRFLAbelsViewPlotsEdit,'String');
nparamValueLabelFormat = regexprep(nparamValue, '\s+', '');
nviewPercentageRuleFilter = w2.getNode('ViewPercentageRuleFilter');
nviewPercentageRuleFilter.getConfig()...
    .updateParamValue('ViewParameters', {{'LabelFormat', {strcat(nparamValueLabelFormat, ':([^_]*)')}}});
nparamValue = get(handles.nPRFLAbelsViewPCAEdit,'String');
nparamValue = strsplit(nparamValue, ',');
nparamValueGroupList = regexprep(nparamValue{1}, '\s+', '');
nparamValueLabelFormat = regexprep(nparamValue{2}, '\s+', '');
nPcaPercentageRuleFilter = w2.getNode('ViewPcaPercentageRuleFilter');
nPcaPercentageRuleFilter.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{nparamValueGroupList}, 'LabelFormat', {strcat(nparamValueLabelFormat, ':([^_]*)')}}});


% FilterCv 20%
nQcCVThresholdEdit = get(handles.nQcCVThresholdEdit,'String');
nQcCVThresholdEdit = str2num(nQcCVThresholdEdit);
nQcCVLoqEdit = get(handles.nQcCVLoqEdit,'String');
nQcCVLoqEdit = str2num(nQcCVLoqEdit);

nqcCvFilter = w2.getNode('QcCvFilter');
nqcCvFilter.getConfig()...
    .updateParamValue('QcCvThreshold', nQcCVThresholdEdit)...
    .updateParamValue('PercentageRuleThreshold', 0)...
    .updateParamValue('LoQ', nQcCVLoqEdit);


nparamValue = get(handles.nQcCVLabelsViewPlotsEdit,'String');
nparamValueLabelFormat = regexprep(nparamValue, '\s+', '');
nviewQcCvFilter = w2.getNode('ViewQcCvFilter');
nviewQcCvFilter.getConfig()...
    .updateParamValue('ViewParameters', {{'LabelFormat', {strcat(nparamValueLabelFormat, ':([^_]*)')}}});
nparamValue = get(handles.nQcCVLabelsViewPCAEdit,'String');
nparamValue = strsplit(nparamValue, ',');
nparamValueGroupList = regexprep(nparamValue{1}, '\s+', '');
nparamValueLabelFormat = regexprep(nparamValue{2}, '\s+', '');
nPcaQcCvFilter = w2.getNode('ViewPcaQcCvFilter');
nPcaQcCvFilter.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{nparamValueGroupList}, 'LabelFormat', {strcat(nparamValueLabelFormat, ':([^_]*)')}}});

nparamValue = get(handles.nIaDFLAbelsViewPCAEdit,'String');
nparamValue = strsplit(nparamValue, ',');
nparamValueGroupList = regexprep(nparamValue{1}, '\s+', '');
nparamValueLabelFormat = regexprep(nparamValue{2}, '\s+', '');
nPcaIntraBatchDriftCorrector = w2.getNode('ViewPcaIntraBatchDriftCorrector');
nPcaIntraBatchDriftCorrector.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{nparamValueGroupList}, 'LabelFormat', {strcat(nparamValueLabelFormat, ':([^_]*)')}}});


nparamValue = get(handles.nIDFLAbelsViewPCAEdit,'String');
nparamValue = strsplit(nparamValue, ',');
nparamValueGroupList = regexprep(nparamValue{1}, '\s+', '');
nparamValueLabelFormat = regexprep(nparamValue{2}, '\s+', '');
nPcaInterBatchDriftCorrector = w2.getNode('ViewPcaInterBatchDriftCorrector');
nPcaInterBatchDriftCorrector.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{nparamValueGroupList}, 'LabelFormat', {strcat(nparamValueLabelFormat, ':([^_]*)')}}});

annotationNamesEdit = get(handles.AnnotationNamesEdit,'String');
annotationNamesEdit=regexprep(annotationNamesEdit, '\s+', '');
merge = workflow.getNode('FeatureSetMerger');
merge.getConfig()...
    .updateParamValue('AnnotationNamesForMerging', strsplit(annotationNamesEdit, ','));

paramValue = get(handles.PCANPMLabelViewEdit,'String');
paramValue = strsplit(paramValue, ',');
paramValueGroupList = regexprep(paramValue{1}, '\s+', '');
paramValueLabelFormat = regexprep(paramValue{2}, '\s+', '');
PcaFeatureMerger = workflow.getNode('ViewPcaFeatureMerger');
PcaFeatureMerger.getConfig()...
    .updateParamValue('ViewParameters', {{'GroupList',{paramValueGroupList}, 'LabelFormat', {strcat(paramValueLabelFormat, ':([^_]*)')}}});


%% Run 
workflow.run();

% --- Executes on button press in Reset.
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2



function AnnotationNamesEdit_Callback(hObject, eventdata, handles)
% hObject    handle to AnnotationNamesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AnnotationNamesEdit as text
%        str2double(get(hObject,'String')) returns contents of AnnotationNamesEdit as a double


% --- Executes during object creation, after setting all properties.
function AnnotationNamesEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AnnotationNamesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PCANPMLabelViewEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PCANPMLabelViewEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PCANPMLabelViewEdit as text
%        str2double(get(hObject,'String')) returns contents of PCANPMLabelViewEdit as a double


% --- Executes during object creation, after setting all properties.
function PCANPMLabelViewEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PCANPMLabelViewEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nHeaderToUseEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nHeaderToUseEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nHeaderToUseEdit as text
%        str2double(get(hObject,'String')) returns contents of nHeaderToUseEdit as a double


% --- Executes during object creation, after setting all properties.
function nHeaderToUseEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nHeaderToUseEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nUserIDHeaderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nUserIDHeaderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nUserIDHeaderEdit as text
%        str2double(get(hObject,'String')) returns contents of nUserIDHeaderEdit as a double


% --- Executes during object creation, after setting all properties.
function nUserIDHeaderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nUserIDHeaderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nCDALabelViewEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nCDALabelViewEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nCDALabelViewEdit as text
%        str2double(get(hObject,'String')) returns contents of nCDALabelViewEdit as a double


% --- Executes during object creation, after setting all properties.
function nCDALabelViewEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nCDALabelViewEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nCDALabelsViewPCAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nCDALabelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nCDALabelsViewPCAEdit as text
%        str2double(get(hObject,'String')) returns contents of nCDALabelsViewPCAEdit as a double


% --- Executes during object creation, after setting all properties.
function nCDALabelsViewPCAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nCDALabelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nIaDFLAbelsViewPCAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nIaDFLAbelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nIaDFLAbelsViewPCAEdit as text
%        str2double(get(hObject,'String')) returns contents of nIaDFLAbelsViewPCAEdit as a double


% --- Executes during object creation, after setting all properties.
function nIaDFLAbelsViewPCAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nIaDFLAbelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nIDFLAbelsViewPCAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nIDFLAbelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nIDFLAbelsViewPCAEdit as text
%        str2double(get(hObject,'String')) returns contents of nIDFLAbelsViewPCAEdit as a double


% --- Executes during object creation, after setting all properties.
function nIDFLAbelsViewPCAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nIDFLAbelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nQcCVLabelsViewPCAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nQcCVLabelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nQcCVLabelsViewPCAEdit as text
%        str2double(get(hObject,'String')) returns contents of nQcCVLabelsViewPCAEdit as a double


% --- Executes during object creation, after setting all properties.
function nQcCVLabelsViewPCAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nQcCVLabelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nQcCVLabelsViewPlotsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nQcCVLabelsViewPlotsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nQcCVLabelsViewPlotsEdit as text
%        str2double(get(hObject,'String')) returns contents of nQcCVLabelsViewPlotsEdit as a double


% --- Executes during object creation, after setting all properties.
function nQcCVLabelsViewPlotsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nQcCVLabelsViewPlotsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function nQcCVLoqEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pQcCVLoqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pQcCVLoqEdit as text
%        str2double(get(hObject,'String')) returns contents of pQcCVLoqEdit as a double


% --- Executes during object creation, after setting all properties.
function nQcCVLoqEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pQcCVLoqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pQcCVLoqEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pQcCVLoqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pQcCVLoqEdit as text
%        str2double(get(hObject,'String')) returns contents of pQcCVLoqEdit as a double


% --- Executes during object creation, after setting all properties.
function pQcCVLoqEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pQcCVLoqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nQcCVThresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nQcCVThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nQcCVThresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of nQcCVThresholdEdit as a double


% --- Executes during object creation, after setting all properties.
function nQcCVThresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nQcCVThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPRFLAbelsViewPCAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nPRFLAbelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPRFLAbelsViewPCAEdit as text
%        str2double(get(hObject,'String')) returns contents of nPRFLAbelsViewPCAEdit as a double


% --- Executes during object creation, after setting all properties.
function nPRFLAbelsViewPCAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPRFLAbelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPRFLAbelsViewPlotsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nPRFLAbelsViewPlotsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPRFLAbelsViewPlotsEdit as text
%        str2double(get(hObject,'String')) returns contents of nPRFLAbelsViewPlotsEdit as a double


% --- Executes during object creation, after setting all properties.
function nPRFLAbelsViewPlotsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPRFLAbelsViewPlotsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nGroupListEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nGroupListEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nGroupListEdit as text
%        str2double(get(hObject,'String')) returns contents of nGroupListEdit as a double


% --- Executes during object creation, after setting all properties.
function nGroupListEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nGroupListEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nThresholdPercRuleFilterEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nThresholdPercRuleFilterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nThresholdPercRuleFilterEdit as text
%        str2double(get(hObject,'String')) returns contents of nThresholdPercRuleFilterEdit as a double


% --- Executes during object creation, after setting all properties.
function nThresholdPercRuleFilterEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nThresholdPercRuleFilterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nMethodOfFilteringEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nMethodOfFilteringEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nMethodOfFilteringEdit as text
%        str2double(get(hObject,'String')) returns contents of nMethodOfFilteringEdit as a double


% --- Executes during object creation, after setting all properties.
function nMethodOfFilteringEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nMethodOfFilteringEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nBFLablesViewPCAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nBFLablesViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nBFLablesViewPCAEdit as text
%        str2double(get(hObject,'String')) returns contents of nBFLablesViewPCAEdit as a double


% --- Executes during object creation, after setting all properties.
function nBFLablesViewPCAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nBFLablesViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nBFLabelViewEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nBFLabelViewEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nBFLabelViewEdit as text
%        str2double(get(hObject,'String')) returns contents of nBFLabelViewEdit as a double


% --- Executes during object creation, after setting all properties.
function nBFLabelViewEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nBFLabelViewEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nThresholdBlankEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nThresholdBlankEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nThresholdBlankEdit as text
%        str2double(get(hObject,'String')) returns contents of nThresholdBlankEdit as a double


% --- Executes during object creation, after setting all properties.
function nThresholdBlankEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nThresholdBlankEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nSheetEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nSheetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nSheetEdit as text
%        str2double(get(hObject,'String')) returns contents of nSheetEdit as a double


% --- Executes during object creation, after setting all properties.
function nSheetEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nSheetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nListOfNames_Callback(hObject, eventdata, handles)
% hObject    handle to nListOfNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nListOfNames as text
%        str2double(get(hObject,'String')) returns contents of nListOfNames as a double


% --- Executes during object creation, after setting all properties.
function nListOfNames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nListOfNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pIaDFLAbelsViewPCAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pIaDFLAbelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pIaDFLAbelsViewPCAEdit as text
%        str2double(get(hObject,'String')) returns contents of pIaDFLAbelsViewPCAEdit as a double


% --- Executes during object creation, after setting all properties.
function pIaDFLAbelsViewPCAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pIaDFLAbelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pIDFLAbelsViewPCAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pIDFLAbelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pIDFLAbelsViewPCAEdit as text
%        str2double(get(hObject,'String')) returns contents of pIDFLAbelsViewPCAEdit as a double


% --- Executes during object creation, after setting all properties.
function pIDFLAbelsViewPCAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pIDFLAbelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pQcCVLabelsViewPCAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pQcCVLabelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pQcCVLabelsViewPCAEdit as text
%        str2double(get(hObject,'String')) returns contents of pQcCVLabelsViewPCAEdit as a double


% --- Executes during object creation, after setting all properties.
function pQcCVLabelsViewPCAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pQcCVLabelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pQcCVLabelsViewPlotsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pQcCVLabelsViewPlotsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pQcCVLabelsViewPlotsEdit as text
%        str2double(get(hObject,'String')) returns contents of pQcCVLabelsViewPlotsEdit as a double


% --- Executes during object creation, after setting all properties.
function pQcCVLabelsViewPlotsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pQcCVLabelsViewPlotsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit103_Callback(hObject, eventdata, handles)
% hObject    handle to pQcCVLoqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pQcCVLoqEdit as text
%        str2double(get(hObject,'String')) returns contents of pQcCVLoqEdit as a double


% --- Executes during object creation, after setting all properties.
function edit103_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pQcCVLoqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pQcCVThresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pQcCVThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pQcCVThresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of pQcCVThresholdEdit as a double


% --- Executes during object creation, after setting all properties.
function pQcCVThresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pQcCVThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pPRFLAbelsViewPCAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pPRFLAbelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pPRFLAbelsViewPCAEdit as text
%        str2double(get(hObject,'String')) returns contents of pPRFLAbelsViewPCAEdit as a double


% --- Executes during object creation, after setting all properties.
function pPRFLAbelsViewPCAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pPRFLAbelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pPRFLAbelsViewPlotsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pPRFLAbelsViewPlotsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pPRFLAbelsViewPlotsEdit as text
%        str2double(get(hObject,'String')) returns contents of pPRFLAbelsViewPlotsEdit as a double


% --- Executes during object creation, after setting all properties.
function pPRFLAbelsViewPlotsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pPRFLAbelsViewPlotsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pGroupListEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pGroupListEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pGroupListEdit as text
%        str2double(get(hObject,'String')) returns contents of pGroupListEdit as a double


% --- Executes during object creation, after setting all properties.
function pGroupListEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pGroupListEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pThresholdPercRuleFilterEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pThresholdPercRuleFilterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pThresholdPercRuleFilterEdit as text
%        str2double(get(hObject,'String')) returns contents of pThresholdPercRuleFilterEdit as a double


% --- Executes during object creation, after setting all properties.
function pThresholdPercRuleFilterEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pThresholdPercRuleFilterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pMethodOfFilteringEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pMethodOfFilteringEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pMethodOfFilteringEdit as text
%        str2double(get(hObject,'String')) returns contents of pMethodOfFilteringEdit as a double


% --- Executes during object creation, after setting all properties.
function pMethodOfFilteringEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pMethodOfFilteringEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pBFLablesViewPCAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pBFLablesViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pBFLablesViewPCAEdit as text
%        str2double(get(hObject,'String')) returns contents of pBFLablesViewPCAEdit as a double


% --- Executes during object creation, after setting all properties.
function pBFLablesViewPCAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pBFLablesViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pBFLabelViewEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pBFLabelViewEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pBFLabelViewEdit as text
%        str2double(get(hObject,'String')) returns contents of pBFLabelViewEdit as a double


% --- Executes during object creation, after setting all properties.
function pBFLabelViewEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pBFLabelViewEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pThresholdBlankEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pThresholdBlankEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pThresholdBlankEdit as text
%        str2double(get(hObject,'String')) returns contents of pThresholdBlankEdit as a double


% --- Executes during object creation, after setting all properties.
function pThresholdBlankEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pThresholdBlankEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pSheetEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pSheetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pSheetEdit as text
%        str2double(get(hObject,'String')) returns contents of pSheetEdit as a double


% --- Executes during object creation, after setting all properties.
function pSheetEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pSheetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pHeaderToUseEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pHeaderToUseEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pHeaderToUseEdit as text
%        str2double(get(hObject,'String')) returns contents of pHeaderToUseEdit as a double


% --- Executes during object creation, after setting all properties.
function pHeaderToUseEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pHeaderToUseEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pUserIDHeaderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pUserIDHeaderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pUserIDHeaderEdit as text
%        str2double(get(hObject,'String')) returns contents of pUserIDHeaderEdit as a double


% --- Executes during object creation, after setting all properties.
function pUserIDHeaderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pUserIDHeaderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pCDALabelViewEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pCDALabelViewEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pCDALabelViewEdit as text
%        str2double(get(hObject,'String')) returns contents of pCDALabelViewEdit as a double


% --- Executes during object creation, after setting all properties.
function pCDALabelViewEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pCDALabelViewEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pCDALabelsViewPCAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pCDALabelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pCDALabelsViewPCAEdit as text
%        str2double(get(hObject,'String')) returns contents of pCDALabelsViewPCAEdit as a double


% --- Executes during object creation, after setting all properties.
function pCDALabelsViewPCAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pCDALabelsViewPCAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pListOfNames_Callback(hObject, eventdata, handles)
% hObject    handle to pListOfNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pListOfNames as text
%        str2double(get(hObject,'String')) returns contents of pListOfNames as a double


% --- Executes during object creation, after setting all properties.
function pListOfNames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pListOfNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
