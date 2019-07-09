function varargout = LipidMatch(varargin)
% LIPIDMATCH MATLAB code for LipidMatch.fig
%      LIPIDMATCH, by itself, creates a new LIPIDMATCH or raises the existing
%      singleton*.
%
%      H = LIPIDMATCH returns the handle to a new LIPIDMATCH or the handle to
%      the existing singleton*.
%
%      LIPIDMATCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LIPIDMATCH.M with the given input arguments.
%
%      LIPIDMATCH('Property','Value',...) creates a new LIPIDMATCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LipidMatch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LipidMatch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LipidMatch

% Last Modified by GUIDE v2.5 18-Jun-2019 11:26:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LipidMatch_OpeningFcn, ...
                   'gui_OutputFcn',  @LipidMatch_OutputFcn, ...
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


% --- Executes just before LipidMatch is made visible.
function LipidMatch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LipidMatch (see VARARGIN)

% Choose default command line output for LipidMatch
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LipidMatch wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LipidMatch_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in FeatureTable.
function FeatureTable_Callback(hObject, eventdata, handles)
% hObject    handle to FeatureTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[featureData, path] = uigetfile('*.csv');
featureDataPath = [path featureData];
handles.featureDataPath=featureDataPath;
setappdata(0,'featureDatapath', featureDataPath);

% --- Executes on button press in OuputFilePath.
function OuputFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to OuputFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outFolder = uigetdir();
setappdata(0,'outputdatapath', outFolder);

% --- Executes on button press in posRawFiles.
function posRawFiles_Callback(hObject, eventdata, handles)
% hObject    handle to posRawFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inFolder = uipickfiles ;

setappdata(0,'inputPosRawDatapath', inFolder);

% --- Executes on button press in rawNegFiles.
function rawNegFiles_Callback(hObject, eventdata, handles)
% hObject    handle to rawNegFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inFolder = uipickfiles ;

setappdata(0,'inputNegRawDatapath', inFolder);

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in identify.
function identify_Callback(hObject, eventdata, handles)
% hObject    handle to identify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mzNeg = 'Z:\BioappsTests\Mimosa\RawData\Batch1Neg';
mzPos = 'Z:\BioappsTests\Mimosa\RawData\Batch1Pos';

%% Identification

lipidWorkflow = bioapps.lipidmatch.model.LipidMatchWorkflow();
lipidWorkflow.getConfig()...
    .updateParamValue('WorkingDirectory',getappdata(0, 'outputdatapath') );

mzFileImporter = lipidWorkflow.getNode('NegRawFileImporter');


fileExtensionFilterEdit = get(handles.FileExtensionFilterEdit,'String');

fileNameFilterNegEdit = get(handles.FileNameFilterNegEdit,'String');
mzNeg = getappdata(0, 'inputNegRawDatapath');
for i=1:length(mzNeg)
    mzFileImporter.addInputFilePath( mzNeg{i} );
end
mzFileImporter.getConfig()...
    .updateParamValue('FileNameFilter', fileNameFilterNegEdit)...
    .updateParamValue('FileExtensionFilter', fileExtensionFilterEdit);

zFileImporter = lipidWorkflow.getNode('PosRawFileImporter');
fileNameFilterPosEdit = get(handles.FileNameFilterPosEdit,'String');

mzPos = getappdata(0, 'inputPosRawDatapath');
for i=1:length(mzPos)
    zFileImporter.addInputFilePath( mzPos{i} );
end
zFileImporter.getConfig()...
    .updateParamValue('FileNameFilter', fileNameFilterEdit)...
    .updateParamValue('FileExtensionFilter', FileNameFilterPosEdit);

featureTable = lipidWorkflow.getNode('FeatureTableImporter');
featureTable.addInputFilePath( getappdata(0, 'featureDatapath') );

lipidWorkflow.run();


function FileNameFilterPosEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FileNameFilterPosEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileNameFilterPosEdit as text
%        str2double(get(hObject,'String')) returns contents of FileNameFilterPosEdit as a double


% --- Executes during object creation, after setting all properties.
function FileNameFilterPosEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileNameFilterPosEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FileExtensionFilterEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FileExtensionFilterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileExtensionFilterEdit as text
%        str2double(get(hObject,'String')) returns contents of FileExtensionFilterEdit as a double


% --- Executes during object creation, after setting all properties.
function FileExtensionFilterEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileExtensionFilterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FileNameFilterNegEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FileNameFilterNegEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileNameFilterNegEdit as text
%        str2double(get(hObject,'String')) returns contents of FileNameFilterNegEdit as a double


% --- Executes during object creation, after setting all properties.
function FileNameFilterNegEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileNameFilterNegEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
