function F=emgfesgui()
% Creates The main Active-FES gui

global aFES;
MDL_NAME=aFES.model;%'EMG_FES2';
F=localCreateUI('EMG-FES');
figure(F);



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function to create the user interface
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function f = localCreateUI(fname)
        

        %% Create the figure, setting appropriate properties
        f = figure('Tag','EMG-FES-main-figure',...
            'Toolbar','none',...
            'MenuBar','none',...
            'IntegerHandle','off',...
            'Units','normalized',...
            'Resize','on',...
            'NumberTitle','off',...
            'HandleVisibility','callback',...
            'Name',fname,...
            'Visible','off',...
            'CloseRequestFcn',@f_main_CloseRequestFcn);
        
        
        %% Create menus
        %Settings menu
        settings_menu=uimenu(f,'Label','Settings');
        uimenu(settings_menu,'Label','Load settings','Callback',@cb_loadSettings);
        
        %calibration menu
        calibration_menu = uimenu(settings_menu,'Label','Calibration');
        uimenu(calibration_menu,'Label','Calibrate EMG with last run','Callback',@cb_calibrateEMGWithLastRun);
        uimenu(calibration_menu,'Label','Calibrate Wrist with last run','Callback',@cb_calibrateWristWithLastRun);
        uimenu(calibration_menu,'Label','Calibrate ALL with last run','Callback',@cb_calibrateWithLastRun);
        
        
        %View menu
        view_menu = uimenu(f,'Label','View');
        uimenu(view_menu,'Label','Tracing feedback window', 'Callback',@cb_tracingFeedbackWindow);
        
        plot_menu=uimenu(f,'Label','Plot');
        uimenu(plot_menu,'Label','Current data','Callback',@cb_plotCurrentData);
        uimenu(plot_menu,'Label','Current data with trace','Callback',@cb_plotCurrentDataWithTrace);
        
        
        
        help_menu = uimenu(f,'Label','Help');
        uimenu(help_menu,'Label','About', 'Callback',@cb_about);
        uimenu(help_menu,'Label','How to','Callback',@cb_howto);
        
        

        %% Create an axes on a new figure for tracing
        f_tracing=figure('name','Tracing feedback window',...
            'Toolbar','none',...
            'MenuBar','none',...
            'Units','normalized',...
            'NumberTitle','off',...
            'Visible','off',...
            'CloseRequestFcn', @f_tracing_CloseRequestFcn);
        
        ha = axes('Parent',f_tracing,...
            'HandleVisibility','callback',...
            'Unit','normalized',...
            'Xlim',[0 90],...
            'YLim',[-2.5 2.5],...
            'Tag','plotAxes');%'OuterPosition',[0.25 0.4 0.7 0.6],...
        xlabel(ha,'Time(s)');
        %ylabel(ha,'Signal Value');
        title(ha,'Feedback window');
        grid(ha,'on');
        %box(ha,'on');
        aFES.plot.ax1=ha;
        aFES.plot.p1=line(0,0,'parent',ha,'linewidth',4,'Color',[0.5 .3 .2],'Marker','o','MarkerSize',12);
        aFES.plot.p2=line(0,0,'parent',ha,'linewidth',2,'Color',[0.3 .5 .7],'Marker','+','MarkerSize',12);

        
        
        %% Create an edit box containing the model name
        uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.05 0.95 0.15 0.03],...
            'String',sprintf('%s.mdl',aFES.model),...
            'Backgroundcolor',[1 1 1],...
            'HandleVisibility','callback',...
            'Tag','modelNameLabel');
        
        %% Create popup for selecting which hand to work with
        init_hand_idx=1;
        if(strcmpi(aFES.hand,'right'))
            init_hand_idx=2;
        end
        uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.01 0.84 0.07 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String','Hand');
        uicontrol('Parent',f,'Style','popupmenu',...
            'String',{'Left';'Right'},...
            'Units','normalized',...
            'Value',init_hand_idx,...
            'Position',[0.1 0.85 0.1 0.03],...
            'callback',@cb_selectHand,...
            'Tag','emgfes-select-hand-gui');
        

        
        %% Create popup for selecting which mode
        uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.3 0.84 0.07 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String','Mode');
        uicontrol('Parent',f,'Style','popupmenu',...
            'String',{'Calibration','Normal','Tracing','Wrist Tracing'},...
            'Units','normalized',...
            'Value',aFES.mode,...
            'Position',[0.4 0.85 0.1 0.03],...
            'callback',@cb_selectMode,...
            'Tag','emgfes-select-mode-gui');

       %% Create popup for selecting monoStim
       monoStim_str=[0:0.1:1];
       init_monoStim=round(aFES.monoStim*10)/10;%round to one decimal place
       init_monoStim_idx=find(monoStim_str==init_monoStim,1);
        uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.7 0.84 0.07 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String','monoStim');
        uicontrol('Parent',f,'Style','popupmenu',...
            'String', {monoStim_str},...
            'Units','normalized',...
            'Value',init_monoStim_idx,...
            'Position',[0.8 0.85 0.1 0.03],...
            'callback',@cb_selectMonoStim,...
            'Tag','emgfes-select-monoStim-gui');
        

        %% Current Slider
        init_current=str2num(  get_param(aFES.blk.stimCurr_BLK{1},'Value'));
        if isempty(init_current)
            init_current=max(aFES.stimCurr);
        end
        uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.02 0.75 0.1 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String','Current,ED:',...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            );
        current_txtb1=uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.15 0.75 0.05 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String',sprintf('%s',mat2str(init_current(1))),...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'); 
        
        %Extension current slider
        uicontrol('Parent',f,'Style','slider','Units','normalized','Position',[0.02 0.7 0.2  0.05],...
                      'value',init_current(1), 'min',0, 'max',45, 'Tag','currentSLider_ext', 'callback',@cb_currentSlider1,'UserData',current_txtb1);
        
                  
             uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.02 0.65 0.1 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String','Current,FDS:',...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            );
        current_txtb2=uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.15 0.65 0.05 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String',sprintf('%s',mat2str(init_current(2))),...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left');          
        %Flex current slider 
        uicontrol('Parent',f,'Style','slider','Units','normalized','Position',[0.02 0.6 0.2  0.05],...
                      'value',init_current(2), 'min',0, 'max',45, 'Tag','currentSLider_flex', 'callback',@cb_currentSlider2,'UserData',current_txtb2);
         
      
                    
         %% pwFactor Slider
         init_pwFactor=aFES.pwFactor;
         uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.02 0.55 0.1 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String','Pw factor: ',...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            );
        pwFactor_txtb=uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.15 0.55 0.05 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String',mat2str(init_pwFactor),...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            ); 
               
        
        uicontrol('Parent',f,'Style','slider','Units','normalized','Position',[0.02 0.5 0.2  0.05],...
                      'value',init_pwFactor, 'min',0, 'max',400, 'Tag','pwFactorSLider', 'callback',@cb_pwFactorSlider,'UserData',pwFactor_txtb);
        
        %% pwThresh Slider
         init_pwThresh=aFES.pwThresh;
         uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.02 0.45 0.1 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String','Pw Thresh: ',...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            );
        pwThresh_txtb=uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.15 0.45 0.05 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String',mat2str(init_pwThresh),...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            ); 
               
        
        uicontrol('Parent',f,'Style','slider','Units','normalized','Position',[0.02 0.4 0.2  0.05],...
                      'value',init_pwThresh, 'min',0, 'max',200, 'Tag','pwThreshSLider', 'callback',@cb_pwThreshSlider,'UserData',pwThresh_txtb);
        
                  
         %% singleThresh Sliders CHANNEL 1=ext
         init_singleThresh=aFES.singleThresh;
         if(aFES.useDoubleThresh==0)
             enable_singleThresh_ui='on';
         else
             enable_singleThresh_ui='off';
         end
         
         uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.02+0.3 0.35+0.4 0.28 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String','Single Thresh[ON,ON]',...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            );
        singleThresh_txtb=uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.15+0.3 0.2+0.4 0.13 0.1],...
            'BackgroundColor',get(f,'Color'),...
            'String',sprintf('[EDC   FES]\n%s',mat2str(init_singleThresh,2)),...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            ); 
               
        %single thresh ch1=>EDC
        chnl=1;
        uicontrol('Parent',f,'Style','slider','Units','normalized','Position',[0.02+0.3 0.2+0.4 0.03  0.15],...
                      'value',init_singleThresh(1), 'min',0, 'max',1, 'Tag','singleThreshSliderCh1', 'callback',@cb_singleThreshSlider,'UserData',[singleThresh_txtb chnl],'enable',enable_singleThresh_ui);
        %single thresh ch2 FDS
        chnl=2;
        uicontrol('Parent',f,'Style','slider','Units','normalized','Position',[0.08+0.3 0.2+0.4 0.03  0.15],...
                      'value',init_singleThresh(2), 'min',0, 'max',1, 'Tag','singleThreshSliderCh2', 'callback',@cb_singleThreshSlider,'UserData',[singleThresh_txtb,chnl],'enable',enable_singleThresh_ui);
        

          

          %% doubleThresh Sliders CHANNEL 1=ext
         init_doubleThresh_ch1=aFES.doubleThresh(1:2);
         if(aFES.useDoubleThresh==0)
             enable_doubleThresh_ui='off';
         else
             enable_doubleThresh_ui='on';
         end
         
         uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.02 0.35 0.28 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String','Dbl Thresh Ch1,ED:[OFF,ON]',...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            );
        doubleThresh_ch1_txtb=uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.15 0.2 0.13 0.1],...
            'BackgroundColor',get(f,'Color'),...
            'String',sprintf('[OFF   ON]\n%s',mat2str(init_doubleThresh_ch1,2)),...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            ); 
               
        %double thresh OFF
        uicontrol('Parent',f,'Style','slider','Units','normalized','Position',[0.02 0.2 0.03  0.15],...
                      'value',init_doubleThresh_ch1(1), 'min',0, 'max',1, 'Tag','doubleThreshOffSLiderCh1', 'callback',@cb_doubleThreshSliderOffCh1,'UserData',doubleThresh_ch1_txtb,'enable',enable_doubleThresh_ui);
        %double thresh ON
        uicontrol('Parent',f,'Style','slider','Units','normalized','Position',[0.08 0.2 0.03  0.15],...
                      'value',init_doubleThresh_ch1(2), 'min',0, 'max',1, 'Tag','doubleThreshOnSLiderCh1', 'callback',@cb_doubleThreshSliderOnCh1,'UserData',doubleThresh_ch1_txtb,'enable',enable_doubleThresh_ui);
        
                  
         %% doubleThresh Sliders CHANNEL 2=flex
         init_doubleThresh_ch2=aFES.doubleThresh(3:4);
         uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.02+0.3 0.35 0.28 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String','Dbl Thresh Ch2,FDS:[OFF,ON]',...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            );
        doubleThresh_ch2_txtb=uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.15+0.3 0.2 0.13 0.1],...
            'BackgroundColor',get(f,'Color'),...
            'String',sprintf('[OFF   ON]\n%s',mat2str(init_doubleThresh_ch2,2)),...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            ); 
               
        %double thresh OFF
        uicontrol('Parent',f,'Style','slider','Units','normalized','Position',[0.02+0.3 0.2 0.03  0.15],...
                      'value',init_doubleThresh_ch2(1), 'min',0, 'max',1, 'Tag','doubleThreshOffSLiderCh2', 'callback',@cb_doubleThreshSliderOffCh2,'UserData',doubleThresh_ch2_txtb,'enable',enable_doubleThresh_ui);
        %double thresh ON
        uicontrol('Parent',f,'Style','slider','Units','normalized','Position',[0.08+0.3 0.2 0.03  0.15],...
                      'value',init_doubleThresh_ch2(2), 'min',0, 'max',1, 'Tag','doubleThreshOnSLiderCh2', 'callback',@cb_doubleThreshSliderOnCh2,'UserData',doubleThresh_ch2_txtb,'enable',enable_doubleThresh_ui);
        
       
       %% useDoubleThresh
          uicontrol('Parent',f,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.7 0.35 0.28 0.03],...
            'BackgroundColor',get(f,'Color'),...
            'String','Toggle Dbl Thresh',...
            'HandleVisibility','callback',...
            'HorizontalAlignment','left'...
            );
          uicontrol(f,'Style','checkbox', 'Value',aFES.useDoubleThresh,...
              'BackgroundColor',get(f,'Color'),...
              'Units','normalized',...
            'Position',[0.7 0.32 0.03 0.03],...
              'callback',@cb_useDoubleThresh_checkbox,'Tag','emgfes-useDoubleThresh-gui');
          
          
          
        %% Buttons
        uicontrol('Parent',f,'Style', 'pushbutton', 'String', ' Start ','Units','normalized',...
        'Position', [0.02 0.08 0.2  0.05],...
        'Callback', @cb_startBtn,'Tag', 'emgfes_gui_start_btn'); 
       
        uicontrol('Parent',f,'Style', 'pushbutton', 'String', ' Stop ','Units','normalized',...
        'Position', [0.02 0.02 0.2  0.05],...
        'Callback', @cb_stopBtn); 
        
        uicontrol('Parent',f,'Style', 'pushbutton', 'String', 'Connect wrist trace','Units','normalized',...
        'Position', [0.6 0.02 0.2  0.05],...
        'Callback', @cb_connectPlotWrist); 
    
        uicontrol('Parent',f,'Style', 'pushbutton', 'String', 'Connect  trace','Units','normalized',...
        'Position', [0.8 0.02 0.2  0.05],...
        'Callback', @cb_connectPlot); 
     
                  
    
                            
         %% callbacks
         
         
         function f_main_CloseRequestFcn(hObject, eventdata, handles)
            % hObject    handle to figure1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            % Hint: delete(hObject) closes the figure
            delete(findobj('name','Tracing feedback window'));
            delete(hObject);
         end
        
        function f_tracing_CloseRequestFcn(hObject, eventdata, handles)
            % hObject    handle to figure1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            % Hint: delete(hObject) closes the figure
            
            set(hObject,'visible','off');
        end
        
        function cb_tracingFeedbackWindow(src,evt)
            set(findobj('name','Tracing feedback window'),'visible','on');
        end
        
        
         
         function cb_selectHand(src, evt)
            items = get(src,'String');
            index_selected = get(src,'Value');
            item_selected = items{index_selected};
            aFES.hand=  lower(item_selected);
            
         end
         
        function cb_selectMode(src,evt)
            aFES.mode=get(src,'value');
        end
        
        function cb_selectMonoStim(src,evt)
            idx=get(src,'value');
            str=get(src,'string');
            val=str{idx};
            aFES.monoStim=str2double(val);
            
            set_param(aFES.blk.monoStim_BLK,'Value',mat2str(aFES.monoStim))
        end
         
        function cb_currentSlider1(src,evt)
            current_idx=1;
            
            sv=round(get(src,'value'));
            for ni=1:length(aFES.blk.stimCurr_BLK)
                val=str2num(get_param(aFES.blk.stimCurr_BLK{ni},'Value'));
                val(current_idx)=sv;
                set_param(aFES.blk.stimCurr_BLK{ni},'Value',mat2str(val));
            end
            %set(current_txtb,'string',round(get(src,'value')));
            set(get(src,'UserData'),'string',sprintf('%s',mat2str(val(current_idx))));
            aFES.stimCurr=val;
        end   
        function cb_currentSlider2(src,evt)
            current_idx=2;
            
            sv=round(get(src,'value'));
            for ni=1:length(aFES.blk.stimCurr_BLK)
                val=str2num(get_param(aFES.blk.stimCurr_BLK{ni},'Value'));
                val(current_idx)=sv;
                set_param(aFES.blk.stimCurr_BLK{ni},'Value',mat2str(val));
            end
            %set(current_txtb,'string',round(get(src,'value')));
            set(get(src,'UserData'),'string',sprintf('%s',mat2str(val(current_idx))));
            aFES.stimCurr=val;
            
        end
        
        
        
        function cb_startBtn(src,evt)
            %aFES=emgfes_feedback(aFES,0,[],0);
            set_param(MDL_NAME,'SimulationCommand', 'start');
            set(src,'Enable','Off');
            %evalin('base','run_afes');
            %set(findobj('Tag','emgfes_gui_start_btn'),'Enable','On');
            set(findobj('Tag','emgfes-select-hand-gui'),'Enable','Off');
            set(findobj('Tag','emgfes-select-mode-gui'),'Enable','Off');
            set(findobj('Tag','emgfes-useDoubleThresh-gui'),'Enable','Off');
            disp(['Model ' MDL_NAME ' is started'])
        end 
        function cb_stopBtn(src,evt)
            set_param(MDL_NAME,'SimulationCommand', 'stop');
            gui_obj=findobj('Tag','emgfes_gui_start_btn');
            if ~isempty(gui_obj)
                set(gui_obj,'Enable','On');
                set(findobj('Tag','emgfes-select-hand-gui'),'Enable','On');
                set(findobj('Tag','emgfes-select-mode-gui'),'Enable','On');
                set(findobj('Tag','emgfes-useDoubleThresh-gui'),'Enable','On');
            end

            disp(['Model ' MDL_NAME ' is stopped'])
        end 
    
        function cb_pwFactorSlider(src,evt)
            set_param(aFES.blk.pwFactor_BLK,'Value',mat2str(round(get(src,'value'))))
            set(get(src,'UserData'),'string',round(get(src,'value')));
            aFES.pwFactor=round(get(src,'value'));
        end
        
        function cb_pwThreshSlider(src,evt)
            
            set_param(aFES.blk.pwThresh_BLK,'Value',mat2str(round(get(src,'value'))))
            set(get(src,'UserData'),'string',round(get(src,'value')));
            
            aFES.pwThresh=round(get(src,'value'));
        end
        
        function cb_singleThreshSlider(src,evt)
            ud=get(src,'Userdata');
            this_chnl=ud(2);
            
            val=str2num(get_param(aFES.blk.singleThresh_BLK,'Value'));
            val(this_chnl)=get(src,'value');
                        
            set_param(aFES.blk.singleThresh_BLK,'Value',mat2str(val))
            set(ud(1),'string',sprintf('[EDC   FDS]\n%s',mat2str(val,2)));
            aFES.singleThresh=val;
        end
        
        function cb_doubleThreshSliderOffCh1(src,evt)
            val=str2num(get_param(aFES.blk.doubleThresh_BLK,'Value'));
            vi=(get(src,'value'));
            
            if(val(2)>=vi) 
                val(1)=vi;
            else
                disp('OFF% cannot be greater than ON%');
                set(src,'value',val(1));
                beep
                return
            end
            set_param(aFES.blk.doubleThresh_BLK,'Value',mat2str(val))
            set(get(src,'UserData'),'string',sprintf('[OFF   ON]\n%s',mat2str(val(1:2),2)));
            aFES.doubleThresh=val;
            
        end
        function cb_doubleThreshSliderOnCh1(src,evt)
            val=str2num(get_param(aFES.blk.doubleThresh_BLK,'Value'));
            vi=(get(src,'value'));
            
            if(vi>=val(1)) 
                val(2)=vi;
            else
                disp('OFF% cannot be greater than ON%');
                set(src,'value',val(2));
                beep
                return
            end
            
            set_param(aFES.blk.doubleThresh_BLK,'Value',mat2str(val))
            set(get(src,'UserData'),'string',sprintf('[OFF   ON]\n%s',mat2str(val(1:2),2)));
            aFES.doubleThresh=val;
            
        end
        
        function cb_doubleThreshSliderOffCh2(src,evt)
            val=str2num(get_param(aFES.blk.doubleThresh_BLK,'Value'));
            vi=(get(src,'value'));
            
            if(val(4)>=vi) 
                val(3)=vi;
            else
                disp('OFF% cannot be greater than ON%');
                set(src,'value',val(3));
                beep
                return
            end
            
            set_param(aFES.blk.doubleThresh_BLK,'Value',mat2str(val))
            set(get(src,'UserData'),'string',sprintf('[OFF   ON]\n%s',mat2str(val(3:4),2)));
            aFES.doubleThresh=val;
            
        end
        function cb_doubleThreshSliderOnCh2(src,evt)
            val=str2num(get_param(aFES.blk.doubleThresh_BLK,'Value'));
            vi=(get(src,'value'));
            
            if(vi>=val(3)) 
                val(4)=vi;
            else
                disp('OFF% cannot be greater than ON%');
                set(src,'value',val(4));
                beep
                return
            end
            
            set_param(aFES.blk.doubleThresh_BLK,'Value',mat2str(val))
            set(get(src,'UserData'),'string',sprintf('[OFF   ON]\n%s',mat2str(val(3:4),2)));
            aFES.doubleThresh=val;
            
        end
        
        function cb_useDoubleThresh_checkbox(src,evt)
            
            val=get(src,'value');
            set_param(aFES.blk.useDoubleThresh_BLK,'Value',mat2str(val))
           
            % Now enable or disable some UI
                doubleThresh_sliders={'doubleThreshOffSLiderCh1' 
                'doubleThreshOnSLiderCh1'
                'doubleThreshOffSLiderCh2' 
                'doubleThreshOnSLiderCh2'
                };
            
            singleThresh_sliders={'singleThreshSliderCh1' 
                'singleThreshSliderCh2'
                };
            if val==0
                for xn=1:length(doubleThresh_sliders)
                    set(findobj('Tag',doubleThresh_sliders{xn}),'enable','off');
                end
                %update single thresh sliders also
                for xn=1:length(singleThresh_sliders)
                    set(findobj('Tag',singleThresh_sliders{xn}),'enable','on');
                end
            else 
                for xn=1:length(doubleThresh_sliders)
                    set(findobj('Tag',doubleThresh_sliders{xn}),'enable','on');
                end
                %update single thresh sliders also
                for xn=1:length(singleThresh_sliders)
                    set(findobj('Tag',singleThresh_sliders{xn}),'enable','off');
                end
            end
            aFES.useDoubleThresh=val;
        end
        
        
        
        function cb_connectPlot(src,evt)
           
           %set_param('EMG_FES2/Tracing/TraceFcn','UserData',aFES.plot.p1);
           
           %Needs to run in a workspace so that the output of
           %add_exec_event_listener stays alife during the callbacks
           set(aFES.plot.p1,'YData',[],'XData',[]);
           set(aFES.plot.p2,'YData',[],'XData',[]);
           grid(aFES.plot.ax1,'off');
            set(aFES.plot.ax1,'Ylim',[-2.5,2.5]);
           %set(aFES.plot.ax1,'Xlim',[0,13]);
           
           lowrate=1;
           if lowrate
               evalin('base',['h_keepalife= add_exec_event_listener(''',aFES.model,'/Voluntary +passive movement/Motor to FES/Tracing/TraceFcn_lowrate'',''PostOutputs'', @emgfesgui_plot_listener)']);
           else
               evalin('base',['h_keepalife= add_exec_event_listener(''',aFES.model,'/Voluntary +passive movement/Motor to FES/Tracing/TraceFcn'',''PostOutputs'', @emgfesgui_plot_listener)']);
           end
        end
        
        function cb_connectPlotWrist(src,evt)
           
           %set_param('EMG_FES2/Tracing/TraceFcn','UserData',aFES.plot.p1);
           
           %Needs to run in a workspace so that the output of
           %add_exec_event_listener stays alife during the callbacks
           set(aFES.plot.p1,'YData',[],'XData',[]);
           set(aFES.plot.p2,'YData',[],'XData',[]);
           grid(aFES.plot.ax1,'off');
           set(aFES.plot.ax1,'Ylim',-[aFES.activeSensorMax(1),aFES.activeSensorMin(1)]*(aFES.tracing.wristMaxHeightFactor+0.3));
           
           lowrate=1;
           if lowrate
               evalin('base',['h_keepalife= add_exec_event_listener(''',aFES.model,'/Wrist angle tracing/TraceFcn_lowrate'',''PostOutputs'', @emgfesgui_wrist_plot_listener)']);
           else
               evalin('base',['h_keepalife= add_exec_event_listener(''',aFES.model,'/Wrist angle tracing/TraceFcn'',''PostOutputs'', @emgfesgui_wrist_plot_listener)']);
           end
        end
        
        
        %% Menu call backs ****************************************************
        function cb_loadSettings(src,evt)
            settngsFile='C:\SMSR1\activeFES-Feasibility\data\';
            if isfield(aFES,'settngsFile')
                settngsFile=aFES.settngsFile;
            end
            [fn, pn] = uigetfile('*.mat', 'Select the file that contains aFES var',settngsFile);
            if(pn)
                
                
                if(true)% Load everything
                    evalin('base',['load(fullfile(''',pn,''',''',fn,'''))']);
                    aFES.settngsFile=fullfile(pn,fn);
                   
                else% Or load just the settings
                    a=load(fullfile(pn,fn),'aFES');
                    evalin('base','clear output_data_define rawProcSignal trace_out');
                    a.aFES.settngsFile=fullfile(pn,fn);
                    aFES=[];
                    aFES=a.aFES;
                end
                
                uiwait(msgbox('Settings loaded','Load settings','modal'))
                %aFES.useDoubleThresh=1; %delete this line
                fobj=findobj('Tag','EMG-FES-main-figure');
                win_pos=[];
                if fobj
                    win_pos=get(fobj,'position');
                    delete(fobj)
                    delete(findobj('name','Tracing feedback window'));%also delete the tracing window
                end
                load_afes_mdl(aFES);
                emgfesgui;
                fobj=findobj('Tag','EMG-FES-main-figure');
                if(any(win_pos))
                    set(fobj,'position',win_pos);
                end
            end
        end
        
        function cb_calibrateWithLastRun(src,evt)
            %%
            % Calibrates both EMG and wrist position with last run
            %
            aFES.activeSensorMin=aFES.temp.activeSensorMin;%We can also evalutes these in the base workspace using evalin
            aFES.activeSensorMax=aFES.temp.activeSensorMax;%We can also evalutes these in the base workspace using evalin
            uiwait(msgbox('Signal input was successfully calibrated with the last run','All calibrations','modal'));
        end
        function cb_calibrateEMGWithLastRun(src,evt)
            %%
            % Calibrates only EMG with last run
            %
            aFES.activeSensorMin(2:3)=aFES.temp.activeSensorMin(2:3);%We can also evalutes these in the base workspace using evalin
            aFES.activeSensorMax(2:3)=aFES.temp.activeSensorMax(2:3) ;%We can also evalutes these in the base workspace using evalin
            uiwait(msgbox('Signal input was successfully calibrated with the last run','EMG calibration','modal'));
        end
        
        function cb_calibrateWristWithLastRun(src,evt)
            %%
            % Calibrates only wrist position with last run
            %
            aFES.activeSensorMin(1)=aFES.temp.activeSensorMin(1);%We can also evalutes these in the base workspace using evalin
            aFES.activeSensorMax(1)=aFES.temp.activeSensorMax(1) ;%We can also evalutes these in the base workspace using evalin
            uiwait(msgbox('Signal input was successfully calibrated with the last run','Wrist calibration','modal'));
        end
        
        function cb_plotCurrentData(src,evt)
            evalin('base','plot_emgfes_run(aFES,rawProcSignal)');
        end
        function cb_plotCurrentDataWithTrace(src,evt)
            evalin('base','plot_emgfes_run(aFES,rawProcSignal,trace_out)');
        end
        
        function cb_howto(src,evt)
            
            edit howto.txt
        end
        function cb_about(src,evt)
            
            uiwait(msgbox('SMSR EMG-FES system. Written by Bethel Osuagwu. 07-07-2017','About','modal'));
        end        
    end

end


