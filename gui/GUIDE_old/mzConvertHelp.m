function varargout = mzConvertHelp(varargin)
% MZCONVERTHELP MATLAB code for mzConvertHelp.fig
%      MZCONVERTHELP, by itself, creates a new MZCONVERTHELP or raises the existing
%      singleton*.
%
%      H = MZCONVERTHELP returns the handle to a new MZCONVERTHELP or the handle to
%      the existing singleton*.
%
%      MZCONVERTHELP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MZCONVERTHELP.M with the given input arguments.
%
%      MZCONVERTHELP('Property','Value',...) creates a new MZCONVERTHELP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mzConvertHelp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mzConvertHelp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mzConvertHelp

% Last Modified by GUIDE v2.5 04-Jun-2019 15:16:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mzConvertHelp_OpeningFcn, ...
                   'gui_OutputFcn',  @mzConvertHelp_OutputFcn, ...
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


% --- Executes just before mzConvertHelp is made visible.
function mzConvertHelp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mzConvertHelp (see VARARGIN)

% Choose default command line output for mzConvertHelp
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mzConvertHelp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mzConvertHelp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
