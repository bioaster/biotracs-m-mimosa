function varargout = FeatureExtraction(varargin)
% FEATUREEXTRACTION MATLAB code for FeatureExtraction.fig
%      FEATUREEXTRACTION, by itself, creates a new FEATUREEXTRACTION or raises the existing
%      singleton*.
%
%      H = FEATUREEXTRACTION returns the handle to a new FEATUREEXTRACTION or the handle to
%      the existing singleton*.
%
%      FEATUREEXTRACTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEATUREEXTRACTION.M with the given input arguments.
%
%      FEATUREEXTRACTION('Property','Value',...) creates a new FEATUREEXTRACTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FeatureExtraction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FeatureExtraction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FeatureExtraction

% Last Modified by GUIDE v2.5 03-Jun-2019 15:15:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FeatureExtraction_OpeningFcn, ...
                   'gui_OutputFcn',  @FeatureExtraction_OutputFcn, ...
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


% --- Executes just before FeatureExtraction is made visible.
function FeatureExtraction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FeatureExtraction (see VARARGIN)

% Choose default command line output for FeatureExtraction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FeatureExtraction wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FeatureExtraction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in BrowseInputFile.
function BrowseInputFile_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseInputFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% inFolder = uigetdir();
inFolder = uipickfiles ;

setappdata(0,'inputdatapath', inFolder);

% --- Executes on button press in BrowseOutputPath.
function BrowseOutputPath_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseOutputPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outFolder = uigetdir();
setappdata(0,'outputdatapath', outFolder);


function SignalToNoiseEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SignalToNoiseEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SignalToNoiseEdit as text
%        str2double(get(hObject,'String')) returns contents of SignalToNoiseEdit as a double


% --- Executes during object creation, after setting all properties.
function SignalToNoiseEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SignalToNoiseEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ChargeFilterEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ChargeFilterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ChargeFilterEdit as text
%        str2double(get(hObject,'String')) returns contents of ChargeFilterEdit as a double


% --- Executes during object creation, after setting all properties.
function ChargeFilterEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChargeFilterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NoiseThreholdIntEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NoiseThreholdIntEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NoiseThreholdIntEdit as text
%        str2double(get(hObject,'String')) returns contents of NoiseThreholdIntEdit as a double


% --- Executes during object creation, after setting all properties.
function NoiseThreholdIntEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoiseThreholdIntEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MassErrorPpmEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MassErrorPpmEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MassErrorPpmEdit as text
%        str2double(get(hObject,'String')) returns contents of MassErrorPpmEdit as a double


% --- Executes during object creation, after setting all properties.
function MassErrorPpmEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MassErrorPpmEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Extract.
function Extract_Callback(hObject, eventdata, handles)
% hObject    handle to Extract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
extractWorkflow = bioapps.openms.model.MetaboExtractionWorkflow();
extractWorkflow.getConfig()...
    .updateParamValue('WorkingDirectory',  getappdata(0, 'outputdatapath') );

inputAdpter = extractWorkflow.getNode('MzFileImporter');

files = getappdata(0, 'inputdatapath');
for i=1:length(files)
    inputAdpter.addInputFilePath(  files{i} );
end
inputAdpter.getConfig()...
    .updateParamValue( 'FileExtensionFilter', 'mzXML');

massErrorPpmEdit = get(handles.MassErrorPpmEdit,'String');
massErrorPpmEdit= str2num(massErrorPpmEdit);

noiseThreholdIntEdit= get(handles.NoiseThreholdIntEdit,'String');
noiseThreholdIntEdit= str2num(noiseThreholdIntEdit);

signalToNoiseEdit= get(handles.SignalToNoiseEdit,'String');
signalToNoiseEdit= str2num(signalToNoiseEdit);


charge= get(handles.ChargeFilterEdit,'String');
charge= str2num(charge);

featureFinder = extractWorkflow.getNode('FeatureFinderMetabo');
featureFinder.getConfig()...
    .updateParamValue('NoiseThresholdInt', noiseThreholdIntEdit)...
    .updateParamValue('MassErrorPpm',massErrorPpmEdit)...
    .updateParamValue('SignalToNoise',signalToNoiseEdit);

fileFilter = extractWorkflow.getNode('FileFilter');
fileFilter.getConfig()...
    .updateParamValue('Charge', charge);


extractWorkflow.run();


% --- Executes on button press in Reset.
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
