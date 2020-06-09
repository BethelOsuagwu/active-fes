%% Model initialization function

if exist('aFES','var')
    %Set run number
    if (isfield(aFES,'runNum'))
        aFES.runNum=aFES.runNum+1;
    else
         aFES.runNum=1;
    end
    
    aFES=emgfes_feedback(aFES,0,[],0);
else
    error('mdl_initFcn_: Cannot find the variable ''aFES''');
    
    % THESE COMMENTED OUT BELOW WILL BE DONE BY 'run_afes.m' 
%   load('afes_param')
% 
%    aFES.Fs=1000;
%    if (~isfield(aFES,'stimCurr'))
%        aFES.stimCurr=[15,15];
%    end
%    aFES.stimFreq=25;
%    aFES.hand='left';
% 
%    %set run number
%    if (isfield(aFES,'runNum'))
%          aFES.runNum=aFES.runNum+1;
%    else
%          aFES.runNum=1;
%    end
% 
%    %Bias
%    aFES.wristPosZeroBias=1.8; %e.g: goniometer reading at zeros flexion and extension
% 
%    %Set the upper and lower safty limit of the sensor
%    sensorUpperSafety1=aFES.activeSensorMax+(aFES.activeSensorMax-aFES.activeSensorMin)/4 ;
%    sensorLowerSafety1=aFES.activeSensorMin-(aFES.activeSensorMax-aFES.activeSensorMin)/4 ;
% 
% 
%    %% Feedback
%    aFES=emgfes_feedback(aFES,0,0);
%    aFES.doubleThresh=[0.2,0.4];%Ambrosini double threshold
% 
%    %% FIlters
%    [aFES.EMG_bandpass_b,aFES.EMG_bandpass_a]=butter(5,2*[40,400]/aFES.Fs);
% 
%    %% Tracing
%    aFES.tracing.reflectFeedback =-1;% {1,-1} e.g if the -1, gonirmeter signal will be multiplied by -1.
%    aFES.tracing.MaxHeightFactor=1;%when >1 scales down the max traceable height. When < 1, scales up the max traceable hieght.
%    [~,trap_y]=trapezoid4trace();%get the trapezium to be traced
%    n_z=5;
%    zero_pad=zeros(n_z*aFES.Fs,1);
% 
%    trap_yt=[[0:1/aFES.Fs:((((n_z*aFES.Fs)+2*length(trap_y))/aFES.Fs))-(1/aFES.Fs)]', [zero_pad;trap_y;-trap_y]]; %add time to the trap

end