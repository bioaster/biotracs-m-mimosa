function varargout = FeatureLinking(varargin)
% FEATURELINKING MATLAB code for FeatureLinking.fig
%      FEATURELINKING, by itself, creates a new FEATURELINKING or raises the existing
%      singleton*.
%
%      H = FEATURELINKING returns the handle to a new FEATURELINKING or the handle to
%      the existing singleton*.
%
%      FEATURELINKING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEATURELINKING.M with the given input arguments.
%
%      FEATURELINKING('Property','Value',...) creates a new FEATURELINKING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FeatureLinking_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FeatureLinking_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FeatureLinking

% Last Modified by GUIDE v2.5 04-Jun-2019 10:27:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FeatureLinking_OpeningFcn, ...
                   'gui_OutputFcn',  @FeatureLinking_OutputFcn, ...
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


% --- Executes just before FeatureLinking is made visible.
function FeatureLinking_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FeatureLinking (see VARARGIN)

% Choose default command line output for FeatureLinking
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FeatureLinking wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FeatureLinking_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in BrowseInputPath.
function BrowseInputPath_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseInputPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inFolder = uipickfiles ;
% inFolder = uigetdir();
setappdata(0,'inputdatapath', inFolder);

% --- Executes on button press in BrowseOutputPath.
function BrowseOutputPath_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseOutputPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outFolder = uigetdir();
setappdata(0,'outputdatapath', outFolder);

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Link.
function Link_Callback(hObject, eventdata, handles)
% hObject    handle to Link (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
linkWorkflow = bioapps.openms.model.MetaboLinkingWorkflow();
linkWorkflow.getConfig()...
    .updateParamValue('WorkingDirectory',  getappdata(0, 'outputdatapath') );

inputAdpter = linkWorkflow.getNode('MzFileImporter');
files = getappdata(0, 'inputdatapath');
for i=1:length(files)
    inputAdpter.addInputFilePath(  files{i} );
end
inputAdpter.getConfig()...
    .updateParamValue( 'FileExtensionFilter', 'featureXML');

maxDifferenceRtDistanceMAPCEdit = get(handles.MaxDifferenceRtDistanceMAPCEdit,'String');
maxDifferenceRtDistanceMAPCEdit= str2num(maxDifferenceRtDistanceMAPCEdit);

maxDifferenceMzDistanceMAPCEdit = get(handles.MaxDifferenceMzDistanceMAPCEdit,'String');
maxDifferenceMzDistanceMAPCEdit= str2num(maxDifferenceMzDistanceMAPCEdit);

referenceEdit = get(handles.ReferenceEdit,'String');

maxDifferenceRtDistanceFLEdit = get(handles.MaxDifferenceRtDistanceFLEdit,'String');
maxDifferenceRtDistanceFLEdit= str2num(maxDifferenceRtDistanceFLEdit);

maxDifferenceMzDistanceFLEdit = get(handles.MaxDifferenceMzDistanceFLEdit,'String');
maxDifferenceMzDistanceFLEdit= str2num(maxDifferenceMzDistanceFLEdit);

minConsensusSizeEdit = get(handles.MinConsensusSizeEdit,'String');
minConsensusSizeEdit= str2num(minConsensusSizeEdit);


mapAlignerPoseClustering = linkWorkflow.getNode('MapAlignerPoseClustering');
mapAlignerPoseClustering.getConfig()...
    .updateParamValue('MaxDifferenceRtDistance', maxDifferenceRtDistanceMAPCEdit)...
    .updateParamValue('MaxDifferenceMzDistance',maxDifferenceMzDistanceMAPCEdit)...
    .updateParamValue('Reference',referenceEdit);

featureLinkerUnlabeledQT = linkWorkflow.getNode('FeatureLinkerUnlabeledQT');
featureLinkerUnlabeledQT.getConfig()...
    .updateParamValue('RtMaxDifference', maxDifferenceRtDistanceFLEdit) ...
    .updateParamValue('MzMaxDifference', maxDifferenceMzDistanceFLEdit) ;

qualityFileFilter = linkWorkflow.getNode('QualityFileFilter');
qualityFileFilter.getConfig()...
    .updateParamValue('MinConsensusSize', [minConsensusSizeEdit,Inf]);

linkWorkflow.run();


function MaxDifferenceRtDistanceMAPCEdit_Callback(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text6 as text
%        str2double(get(hObject,'String')) returns contents of text6 as a double


% --- Executes during object creation, after setting all properties.
function MaxDifferenceRtDistanceMAPCEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxDifferenceMzDistanceMAPCEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDifferenceMzDistanceMAPCEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxDifferenceMzDistanceMAPCEdit as text
%        str2double(get(hObject,'String')) returns contents of MaxDifferenceMzDistanceMAPCEdit as a double


% --- Executes during object creation, after setting all properties.
function MaxDifferenceMzDistanceMAPCEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxDifferenceMzDistanceMAPCEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ReferenceEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ReferenceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ReferenceEdit as text
%        str2double(get(hObject,'String')) returns contents of ReferenceEdit as a double


% --- Executes during object creation, after setting all properties.
function ReferenceEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReferenceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MinConsensusSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text1 as text
%        str2double(get(hObject,'String')) returns contents of text1 as a double

function MinConsensusSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReferenceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MaxDifferenceRtDistanceFLEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDifferenceRtDistanceFLEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxDifferenceRtDistanceFLEdit as text
%        str2double(get(hObject,'String')) returns contents of MaxDifferenceRtDistanceFLEdit as a double


% --- Executes during object creation, after setting all properties.
function MaxDifferenceRtDistanceFLEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxDifferenceRtDistanceFLEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxDifferenceMzDistanceFLEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDifferenceMzDistanceFLEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxDifferenceMzDistanceFLEdit as text
%        str2double(get(hObject,'String')) returns contents of MaxDifferenceMzDistanceFLEdit as a double


% --- Executes during object creation, after setting all properties.
function MaxDifferenceMzDistanceFLEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxDifferenceMzDistanceFLEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
