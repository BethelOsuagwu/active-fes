%% Initialize EMG-FES
% This file is the starting point for initialisation of EMG-FES system.

%% Main global structure
global aFES

%% GUI
% Check if a new gui is needed.
if(isempty(aFES))
    aFES = struct;
else
    quest_init = questdlg('This will reset all settings. Are your sure?','Re-initialise EMG-FES', ...
                       'No', 'Yes','No');
    switch quest_init,
    case 'No',        
         emgfesgui;
         clear quest_init
         return
    otherwise
        aFES=[];
    end % switch
    clear quest_init
end


%% Paths
% If required add the path where hasomed stimulator simulink block is
% located. You should remove this line of code if it is not needed.
addpath c:\SMSR1\sw\hasomed_stimulator\simulink\;

%% Model information
% Model
%The simulink model for the main EMG-FES system.
aFES.model='EMG_FES2';

% Define Simulink block with dynamic/tunable values.
blk.stimCurr_BLK={[aFES.model,'/Voluntary +passive movement/Motor to FES/CURRENT'],...
                  [aFES.model,'/Voluntary +passive movement/Motor to FES/stimCurr']};
blk.pwFactor_BLK=[aFES.model,'/Voluntary +passive movement/Motor to FES/PulsewidthFactor'];
blk.pwThresh_BLK=[aFES.model,'/Voluntary +passive movement/Motor to FES/pwThresh'];
blk.singleThresh_BLK=[aFES.model,'/Voluntary +passive movement/Motor to FES/singleThresh'];
blk.useDoubleThresh_BLK=[aFES.model,'/Voluntary +passive movement/Motor to FES/usedoubleThresh'];
blk.doubleThresh_BLK=[aFES.model,'/Voluntary +passive movement/Motor to FES/doubleThresh'];
blk.monoStim_BLK=[aFES.model,'/Voluntary +passive movement/Motor to FES/monoStim'];
aFES.blk=blk;


%% Subject/session details
% The subject number
aFES.subjectNo=6;

% Subject group
% Examples: {'h','ap','cp'}
aFES.subjectGrp='h';

% Session number
aFES.sessionN=1;

%% Data
% Set directory where data will be saved. An auto generated run number will
% be appended to filenames to avoid overwriting. But if for any reason a
% a file with the same filename exists (even with appended run number)
% , it will be overwritten silently. This will not happen normally.
saveDir='C:/SMSR1/activeFES-Feasibility/data/'; 

%% Simulation parameters
% Hand to be stimulated.
aFES.hand='left';

% Main samplerate
aFES.Fs=1000;

% [ED,FDS] FES current per channel
aFES.stimCurr=[15,15];

% FES frequency
aFES.stimFreq=25;

% Max subject specific pulsewidth. This a factor that converts a motor 
% command into pulsewidth using equ: pwThresh+VolEMG_Ratio*pwFactor.
aFES.pwFactor=40;

% The starting pulsewidth once activation is reached 
aFES.pwThresh=200;% 

%% Simultaneous stimulation
% monoStim: {0<=monoStim<=1}, When 1=> only one channel is allowed to be
% active at a time; when 0=>the two channels are allowed to be active
% simutanousely etc;  The pulsewidth of the channel other than the  
% MAIN active channel is scaled by S(1-monoStim), a fraction of
% its current pulsewidth in relation to its EMG activity e.g:
% __monoStim__S__
%      1      0
%      0.9     0.1
%      0.8    0.2
%      0.5    0.5
%      0.3    0.7
%      0.1    0.9
%      0      1
aFES.monoStim=1;


%% Thresholds: 
% (NOTE THAT THIS THRESHOLD ARE APPLIED AFTER ACTIVATION HAS ALREADY BEEN 
% DETECTED with a mvc RATIO-LIKE MATHS IN REFERENCE BLOCK IN simulink.)
%
% Single Thresh
% [OFF% ch1, OFF% ch2] The threshold is the percetage of the MVC power
% that must be exceeded for each muscle before FES can be activated. 
aFES.singleThresh=[0.7,0.7];

% Ambrosini double threshold
% {0=>do not use double thresh; 1=>use double thresh;} This allows for the
% use of two individual threshold for starting and stopping stimulation.
aFES.useDoubleThresh=1;

% [[OFF% ch1; ON% ch1;];[OFF% ch2; ON% ch2]]. Defines the double threshold.
aFES.doubleThresh=[0.5,0.7,0.5,0.7]';

%% Thresh update
% [EXT,FLEX]When true (i.e. > 0) the threshold will be increased by this 
% amount during stimulation, which makes it difficult to activate but 
% easier to deactivate. This helps with residual stimulation noise.
aFES.increaseThreshOnFESBy=[0.1,0];

%% Activation
% True to turn ON supplimentary activation when the wrist is moved above 
% threshold :: wristActSuppON(1)=>ext; wristActSuppON(2)=>flex. Other 
% wrist related activation is hardcoded into the Dynamic reference 
% block {see \KODE *~#1 in Dynamic reference block in SIMULINK).
aFES.wristActSuppON=[0;0];

%% Mode
% {0=calibration run, 1=normal run,3=tracing run 4=wristtracing} The mode
% is used to mark a saved file to identify the task that was performed.
aFES.mode=1;%



%% Device units conversions
% For converting analogue voltages to mV. This should be set to the -+ 
% the current fullrange on the EMG ADC. See the instrument's manual.
aFES.emgFullRange=[-3,3];% 

% For converting analogu voltages to degrees. This should be set to the -+ 
% the current fullrange on the goniometer ADC. Check your device manual.
aFES.gonioFullRange=[-180,180];% 

%% Calibration [NO NEED TO CHANGE THESE VALUES].
% Min values for sensors. 
% {wrist_position,ED,FDS}
aFES.activeSensorMin = [-0.1 0.01 0.01];

% Max sensor values.
% {wrist_position,ED,FDS}
aFES.activeSensorMax = [0.01 0.5 0.5];

% Unapplied calibration values.
aFES.temp = struct;
% {wrist_position,ED,FDS}
aFES.temp.activeSensorMin = [-0.1 0.01 0.01];

%{wrist_position,ED,FDS}
aFES.temp.activeSensorMax = [0.01 0.5 0.5];

 
%% Bias and offsets
% Set the goniometer reading at zeros flexion and extension.
aFES.wristPosZeroBias=0;

%% FES limit
% Maxmum FES intensity =current x pulsewidth *freq.
aFES.maxFESIntens= 45*500*30;

% [TODO implement these] Set the upper and lower safty limit of the sensor. 
sensorUpperSafety1=aFES.activeSensorMax+(aFES.activeSensorMax-aFES.activeSensorMin)/4 ;
sensorLowerSafety1=aFES.activeSensorMin-(aFES.activeSensorMax-aFES.activeSensorMin)/4 ;

%% Filter
% Set EMG bandpass FIlters. Warning this setting has been changed from
% 40-400 to 30-400. You may need to change it back if relaxation to 
% turn off FES is hard for a user because of low frequency noise. 
[aFES.EMG_bandpass_b,aFES.EMG_bandpass_a]=butter(5,2*[30,400]/aFES.Fs);


%% Tracing
% Generate trapezium to be traced
% We use e.g 90% or 1.10 of max wrist angle as the target shape height.
aFES.tracing.wristMaxHeightFactor=1.10; 

% Normalised/PW/EMG tracing
% When <1 scales down the max traceable height for PW tracing. When > 1; 
% scales up the max traceable hieght relative to calibration MVC EMG.
aFES.tracing.MaxHeightFactor=0.9;

%**********************************************************************
% NO NEED TO MAKE CHANGES FROM HERE TO THE END OF FILE.
%*********************************************************************

% Compute the shape to be traced
[~,trap_y]=trapezoid4trace();
n_z=5;
zero_pad=zeros(n_z*aFES.Fs,1);

% Add time to the trap and zero padding
trap_yt=[( 0:1/aFES.Fs:((((n_z*aFES.Fs)+2*length(trap_y))/aFES.Fs))-(1/aFES.Fs) )', [zero_pad;trap_y;-trap_y]]; 



%% Run number
if (isfield(aFES,'runNum'))
     aFES.runNum=aFES.runNum+1;
else
     aFES.runNum=1;
end

%% Generate file name details for saving data
sav_fld=[saveDir ,aFES.subjectGrp,mat2str(aFES.subjectNo),'/s',mat2str(aFES.sessionN),'/'];
if ~exist(sav_fld,'dir')
    mkdir(sav_fld)
end

sav_fn=['afes_feas_%s',aFES.subjectGrp,mat2str(aFES.subjectNo),'_s',mat2str(aFES.sessionN),'_run%d.mat'];
aFES.fn=[sav_fld,sav_fn];
clear saveDir sav_fld sav_fn afes_mode


%% Load the defined model
load_afes_mdl(aFES);


%% Open GUI used to run simulation
emgfesgui;


%% Final clear up
clearvars -except aFES trap_yt