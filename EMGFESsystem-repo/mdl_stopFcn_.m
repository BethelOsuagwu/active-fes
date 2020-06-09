%% Model stop function

%save the calibration data but don't apply it
aFES.temp.activeSensorMin=calib1_activeSensorMin(1:3);
aFES.temp.activeSensorMax=calib1_activeSensorMax(1:3);

clear calib1_activeSensorMin calib1_activeSensorMax;

%save(['data/afes_data_run',mat2str(aFES.runNum),'.mat'],'aFES','pw_applied','rawProcSignal');
%save(aFES.fn,'aFES','pw_applied','rawProcSignal');
output_data_define=fileread('output_data_define.ini');
name_tag=[];
switch(aFES.mode)
    case 1
        name_tag='calibration_';
    case 2
        name_tag='normal_';
    case 3
        name_tag='tracing_';
    case 4
        name_tag='wristtracing_';

end

if(any(aFES.stimCurr>1))
    name_tag=[name_tag 'FES_'];
else
    name_tag=[name_tag 'noFES_'];
end

if(aFES.useDoubleThresh)
    name_tag=[name_tag 'doubleThresh_'];
else
    name_tag=[name_tag 'singleThresh_'];
end

name_tag=[name_tag,aFES.hand,'_'];

save(sprintf(aFES.fn,name_tag,aFES.runNum),'aFES','rawProcSignal','trace_out','output_data_define');
disp('Run data is saved');
clear output_data_define

disp('Calibration data is updated but not applied. ');
disp('To apply it run: aFES.activeSensorMin=aFES.temp.activeSensorMin;  aFES.activeSensorMax=aFES.temp.activeSensorMax; ');

%see if h_keepalife which is use for block event listener attachment object is present and clear it
if exist('h_keepalife','var')
        clear h_keepalife;
end

%Turn back gui objects to active
gui_obj=findobj('Tag','emgfes_gui_start_btn');
if ~isempty(gui_obj)
    set(gui_obj,'Enable','On');
    set(findobj('Tag','emgfes-select-hand-gui'),'Enable','On');
end