function varargout = mzConvert(varargin)
% MZCONVERT MATLAB code for mzConvert.fig
%      MZCONVERT, by itself, creates a new MZCONVERT or raises the existing
%      singleton*.
%
%      H = MZCONVERT returns the handle to a new MZCONVERT or the handle to
%      the existing singleton*.
%
%      MZCONVERT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MZCONVERT.M with the given input arguments.
%
%      MZCONVERT('Property','Value',...) creates a new MZCONVERT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mzConvert_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mzConvert_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mzConvert

% Last Modified by GUIDE v2.5 04-Jun-2019 17:15:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mzConvert_OpeningFcn, ...
                   'gui_OutputFcn',  @mzConvert_OutputFcn, ...
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


% --- Executes just before mzConvert is made visible.
function mzConvert_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mzConvert (see VARARGIN)

% Choose default command line output for mzConvert
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mzConvert wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mzConvert_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in BrowseInput.
function BrowseInput_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% inFolder = uigetdir();
inFolder = uipickfiles ;

setappdata(0,'inputdatapath', inFolder);

% --- Executes on button press in BrowseOutput.
function BrowseOutput_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outFolder = uigetdir();
setappdata(0,'outputdatapath', outFolder);


% --- Executes on button press in Convert.
function Convert_Callback(hObject, eventdata, handles)
% hObject    handle to Convert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datetime.setDefaultFormats('default','yyyyMMdd_hhmm')

%% MzConvert Controller
ctrl = bioapps.mzconvert.controller.Controller();
workflow = ctrl.get('MzConvertWorkflow');
workflow.getConfig()...
        .updateParamValue( 'WorkingDirectory', getappdata(0, 'outputdatapath'));
           
fileExtensionFilterEdit = get(handles.FileExtensionFilterEdit,'String');

fileNameFilterEdit = get(handles.FileNameFilterEdit,'String');

inputAdpter = workflow.getNode('MzFileImporter');
files = getappdata(0, 'inputdatapath');
for i= 1:length(files)
    inputAdpter.addInputFilePath(files{i});
end
inputAdpter.getConfig()...
    .updateParamValue( 'FileExtensionFilter', fileExtensionFilterEdit)...
    .updateParamValue('FileNameFilter', fileNameFilterEdit);

intensityThreshold = get(handles.IntenistyThresholdEdit,'String');
intensityThreshold = str2num(intensityThreshold);

mzRangeEdit= get(handles.MzRangeEdit,'String');
mzRangeEdit = str2num(mzRangeEdit);

timeRangeEdit= get(handles.TimeRangeEdit,'String');
timeRangeEdit= str2num(timeRangeEdit);

scanRangeEdit = get(handles.ScanRangeEdit,'String');
scanRangeEdit = str2num(scanRangeEdit);

mzConvert = workflow.getNode('MzConverter'); 
mzConvert.getConfig()...
        .updateParamValue('IntensityThreshold', intensityThreshold)...
        .updateParamValue('MzRange', mzRangeEdit )...
        .updateParamValue('TimeRange', timeRangeEdit)...
        .updateParamValue('ScanRange', scanRangeEdit);
            
 workflow.run(); 

function IntenistyThresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to IntenistyThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IntenistyThresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of IntenistyThresholdEdit as a double


% --- Executes during object creation, after setting all properties.
function IntenistyThresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IntenistyThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ScanRangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ScanRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScanRangeEdit as text
%        str2double(get(hObject,'String')) returns contents of ScanRangeEdit as a double


% --- Executes during object creation, after setting all properties.
function ScanRangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeRangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TimeRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeRangeEdit as text
%        str2double(get(hObject,'String')) returns contents of TimeRangeEdit as a double


% --- Executes during object creation, after setting all properties.
function TimeRangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MzRangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MzRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MzRangeEdit as text
%        str2double(get(hObject,'String')) returns contents of MzRangeEdit as a double


% --- Executes during object creation, after setting all properties.
function MzRangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MzRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in Reset.
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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



function FileNameFilterEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FileNameFilterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileNameFilterEdit as text
%        str2double(get(hObject,'String')) returns contents of FileNameFilterEdit as a double


% --- Executes during object creation, after setting all properties.
function FileNameFilterEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileNameFilterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mzConvertHelp
