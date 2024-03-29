function varargout = RespGUI2(varargin)
% RESPGUI2 M-file for RespGUI2.fig
%      RESPGUI2, by itself, creates a new RESPGUI2 or raises the existing
%      singleton*.
%
%      H = RESPGUI2 returns the handle to a new RESPGUI2 or the handle to
%      the existing singleton*.
%
%      RESPGUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESPGUI2.M with the given input
%      arguments.
%
%      RESPGUI2('Property','Value',...) creates a new RESPGUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RespGUI2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RespGUI2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RespGUI2

% Last Modified by GUIDE v2.5 26-Jan-2012 23:48:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RespGUI2_OpeningFcn, ...
                   'gui_OutputFcn',  @RespGUI2_OutputFcn, ...
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


% --- Executes just before RespGUI2 is made visible.
function RespGUI2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RespGUI2 (see VARARGIN)

% Choose default command line output for RespGUI2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RespGUI2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RespGUI2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in b_loadData.
function b_loadData_Callback(hObject, eventdata, handles)
% hObject    handle to b_loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global acqData ;

[File , Path] = uigetfile({'*.acq','ACQknowledge file';'*.xls','Microsoft Excel file';'*.csv','CSV file';'*.lst','Set of files'}, 'Please select your file');
acqData.File = File ;
acqData.Path = Path ;
if File~=0
    if strcmp(File(length(File)-2:length(File)),'lst')==1
        
        try
        % Multiple file mode
            [fileType, firstName,lastName,age,size,sex,observation] = textread( [Path File] ,'%s%s%s%s%s%s%q' ) ;  

            XLSFileName = fullfile(acqData.Path,[acqData.File(1:(end-4)) '_results.xls']);
            [File,Path,FilterIndex] = uiputfile('*.xls', ...
                'Please select the file to export results or type a new name to create the file' ,...
                XLSFileName );
            fidOut = fopen( fullfile(Path,File) , 'a+' );
            % write header file
            fprintf(fidOut,['File \t' 'age \t' 'size \t' 'sex \t' 'Ccw \t' 'PTPesC \t'...
                'Ti \t' 'Ttot \t' 'Vt \t' 'SwingPes \t' 'CLdyn \t' ...
                 'PTPdiC \t' 'Wel \t' 'Wresp \t' 'Res \t' 'AutoPEEP \n' ]);

            for i=1:1:length(firstName)
                if strcmp( fileType{i} ,'###')~=1 % Line has not been commented
                    % fill the description of the file
                    set( handles.edit_firstname , 'String' , firstName{i} );
                    set( handles.edit_lastname , 'String' , lastName{i} );
                    set( handles.edit_age , 'String' , age{i} );
                    set( handles.edit_size , 'String' , size{i} );
                    if strcmp(sex{i},'M') | strcmp(sex{i},'m')
                        set( handles.popup_sex  , 'Value' , 1 );
                    else
                        set( handles.popup_sex  , 'Value' , 2 );
                    end
                    set( handles.edit_comments , 'String' , observation(i) );
                    set( handles.text_fileName , 'String' , [firstName{i} ' ' lastName{i} '.' fileType{i}] );
                    File =  [firstName{i} '' lastName{i} '.' fileType{i}] ;
                    % load file
                    acqData = load_data_file( Path , File , handles  );
                    acqData.listmode = true;
                    acqData.fidOut = fidOut ;
                    process_and_export( acqData , handles  ) ;
                end
            end
            fclose(fidOut);
            acqData.listmode = false;
     catch me1
         errmsg = ['In file: ' me1.stack(1).file ...
             '      line:' num2str(me1.stack(1).line) ...
             '                   Message:' me1.message];
         clipboard('copy', errmsg);
         errordlg(['An error has occured, this message has been copied in your clipboard: '...
             errmsg '     Please paste the content to the project website (ctrl+v)'...
              ]);
         if web('http://code.google.com/p/respmat/issues/entry?template=Defect%20report%20from%20user','-browser')
             helpdlg('Can''t open the web browser, please connect to http://code.google.com/p/respmat/issues/entry to report the message and/or send an email to louis.mayaud@gmail.com'); 
         end
%         rethrow(me1);
     end
    else
    % Single file Mode
        set( handles.text_fileName , 'String' , File );
        acqData = load_data_file( Path , File , handles  );
        clean_plots(handles)
    end
end

% function that load and process files with exceptions management
function acqData = process_and_export( acqData , handles  )
     try
        % Reset warnings
        lastwarn('');
        
        % Compute data from inputs
        acqData = process_gui_io( acqData , handles ) ;        
         
        
        % Process file
        acqData = process_data(acqData);
                
        % Export to CSV (if option checked)
        if ( acqData.listmode && isempty(lastwarn) )
            export_results( acqData );
        end
        % Update plots
        update_plots( acqData , handles );
        % Export plots (if option checked)
        PDFFileName = [ acqData.Path  get(handles.edit_firstname, 'String') '_' get(handles.edit_lastname, 'String') '.pdf'];
        if ( acqData.listmode  && isempty(lastwarn) )
            save_to_pdf( handles.figure1 , PDFFileName );    
        end
     catch me1       
         errmsg = ['In file: ' me1.stack(1).file ...
             '      line:' num2str(me1.stack(1).line) ...
             '                   Message:' me1.message];
         clipboard('copy', errmsg);
         errordlg(['An error has occured, this message has been copied in your clipboard: '...
             errmsg '     Please paste the content to the project website (ctrl+v)'...
              ]);
          if web('http://code.google.com/p/respmat/issues/entry?template=Defect%20report%20from%20user','-browser')
             helpdlg('Can''t open the web browser, please connect to http://code.google.com/p/respmat/issues/entry to report the message and/or send an email to louis.mayaud@gmail.com'); 
         end 
     end



% --- Executes on slider movement.
function slider_PEEP_Callback(hObject, eventdata, handles)
% hObject    handle to slider_PEEP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global acqData ;
    acqData.AutoPEEPIdx = floor(get(hObject,'Value'));
    acqData = process_and_export( acqData , handles  ) ;
        
% --- Executes on slider movement.
function sliderTol_Callback(hObject, eventdata, handles)
% hObject    handle to sliderTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider
global acqData ;
acqData = process_and_export( acqData , handles  ) ;




% --------------------------------------------------------------------
function Export_Callback(hObject, eventdata, handles)
% hObject    handle to Export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function export_to_pdf_Callback(hObject, eventdata, handles)
% hObject    handle to export_to_pdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global acqData ;
PDFFileName = [ acqData.Path  get(handles.edit_firstname, 'String') '_' get(handles.edit_lastname, 'String') '.pdf'];
[FileName,PathName,FilterIndex] = uiputfile('*.pdf', ...
    'Please select file to save study' , PDFFileName );
if FileName~=0
    PDFFileName = [PathName FileName];
    save_to_pdf( handles.figure1 , PDFFileName );   
end


% --------------------------------------------------------------------
function load_file_Callback(hObject, eventdata, handles)
% hObject    handle to load_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path] = uigetfile({'*.acq','ACQknowledge file';'*.xls',...
        'Microsoft Excel file';...
        '*.csv','CSV file';...
        '*.lst','Set of files'}, 'Please select your file');
load_file(File,Path,handles);

% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_Run.
function button_Run_Callback(hObject, eventdata, handles)
% hObject    handle to button_Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global acqData
    
if strcmp('Study_code',get(handles.edit_lastname,'String'))...
        ||  strcmp('Subject_code',get(handles.edit_firstname,'String'))...
        ||  strcmp('years',get(handles.edit_age,'String'))...
        ||  strcmp('cm',get(handles.edit_size,'String'))
    warndlg('Please fill all patient''s data before RUN!');
else
    acqData.listmode = false;
    acqData = process_and_export( acqData , handles  ) ;
end



function edit_comments_Callback(hObject, eventdata, handles)
% hObject    handle to edit_comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_comments as text
%        str2double(get(hObject,'String')) returns contents of edit_comments as a double


% --- Executes during object creation, after setting all properties.
function edit_comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_firstname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_firstname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_firstname as text
%        str2double(get(hObject,'String')) returns contents of edit_firstname as a double


% --- Executes during object creation, after setting all properties.
function edit_firstname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_firstname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function export_xls_Callback(hObject, eventdata, handles)
% hObject    handle to export_xls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global acqData

XLSFileName = fullfile(acqData.Path,[acqData.File(1:(end-4)) '.xls']);
[File,Path,FilterIndex] = uiputfile('*.xls', ...
    'Please select the file to export or type a new name to create the file' , XLSFileName );

if File~=0
    XLSFileName  = [Path File];
    export_to_xls( acqData , XLSFileName );   
else
    warndlg('File not selected, Can''t export results!');
end

