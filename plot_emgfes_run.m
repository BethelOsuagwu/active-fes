function plot_emgfes_run(aFES,rawProcSignal,trace_out)
% Plots the results of the Active FES run.
%
% aFES: the run settings structure
% rawProcSignal: the main dta output from the run
% trace_out: the tracing output from the run
%
% Usage: plot_emgfes_run(aFES,rawProcSignal,trace_out)
%      plot_emgfes_run(aFES,rawProcSignal)
%
%

if nargin<3
     trace_out=[];
end
Fs=1000;


%% Prepare data
rawProcSignal=squeeze(rawProcSignal);
sz=size(rawProcSignal);
if(sz(1)<sz(2))
    rawProcSignal=rawProcSignal';
end
%rawProcSignal_orig=rawProcSignal;

% Scall EMG channels from analogue Volts to EMG in mV
EMG_chs=[2,3];
for EMG_ch=EMG_chs  
    A=rawProcSignal(:,EMG_ch);
    rawProcSignal(:,EMG_ch)=scale2emg(aFES,A);
end

% Scale uncalled goniometer channels from analogue Volts to angle in degrees
GONIO_chs=[1];
for GONIO_ch=GONIO_chs  
    A=rawProcSignal(:,GONIO_ch);
    rawProcSignal(:,GONIO_ch)=scale2angle(aFES,A);
end




%% More settings
nsubplots=2;%total number of possible subplots minus one
next_subplot=0;
figure(201)
%% plot the tracing
if ~isempty(trace_out)
    nsubplots=nsubplots+1;
    t=(0:1:length(trace_out)-1)/Fs;
    next_subplot=next_subplot+1;
    subplot(nsubplots,1,next_subplot)
    plot(t,trace_out);
    legend({'Target','Trace'});
    ylabel('Height(Normalised)')
    %xlabel('Time(ms)')
    
    
%% Plot wrist tracing, whether the trial is wrist tracing or not
    %First compute wrist tracing shape
    wrist_trace_shape=trapezoid4wrist_offline(aFES,trace_out);
    % now plot
    %corrected_raw_gonio=-((rawProcSignal_orig(:,1))); 
    nsubplots=nsubplots+1;
    next_subplot=next_subplot+1;
    subplot(nsubplots,1,next_subplot)
    if true % Plot angles
        plot(t,rescale2angle(aFES,wrist_trace_shape),'linewidth',2)
        hold on
        plot(t,rescale2angle(aFES,-rawProcSignal(:,7)),':r','linewidth',2)
        
        hold off;
        ylabel('Angle (Degrees)')
    
    else %% plot raw values
        plot(t,wrist_trace_shape,'linewidth',2)
        hold on
        plot(t,-rawProcSignal(:,7),':r','linewidth',2)
        hold off;
        
        ylabel('Shape position')   
    end
    legend({'Shape','Wrist Tracing'});
    xlabel('Time(s)')
    
    
end
%% plot filtered EMG

%first find the largest amplitude channel and use it for ylim
yl1=max(rawProcSignal(:,5))+std(rawProcSignal(:,5)*3);
yl2=max(rawProcSignal(:,6))+std(rawProcSignal(:,6)*3);
yl=max([yl1,yl2]);
yl=[-yl,yl];


t=(0:1:length(rawProcSignal)-1)/Fs;
next_subplot=next_subplot+1;
subplot(nsubplots,1,next_subplot)
plot(t,rawProcSignal(:,5))
ylim(yl)
legend({'EDC EMG estimate'});
ylabel('Amplitude (mV)')
%xlabel('Time(ms)')

next_subplot=next_subplot+1;
subplot(nsubplots,1,next_subplot)
plot(t,rawProcSignal(:,6))
ylim(yl)
legend({'FDS EMG estimate'});
ylabel('Amplitude (mV)')
xlabel('Time(s)')

if false
    %% Plot processed gonio
    yl=max(rawProcSignal(:,1))+std(rawProcSignal(:,1)*5);
    yl=[-yl,yl];
    next_subplot=next_subplot+1;
    subplot(nsubplots,1,next_subplot)
    plot(t,rawProcSignal(:,1))

    try
        %Try to set ylim but ignore if it does not work
        ylim(yl)
    catch e
    end
    legend({'Goniometer'});
    ylabel('Wrist Angle (Degrees)')
    xlabel('Time(s)')
end

%*
%*
%
%
%
%
%
%
%
%
%
%
%
%% Plot unprocessed versus processed data EMG *****************************************
next_subplot=0;
nsubplots=4;
figure
% plot unprocessed EMG
%first find the largest amplitude channel and use it for ylim
%raw_bias=-2;
%rawProcSignal(:,2)=rawProcSignal(:,2)+raw_bias;
%rawProcSignal(:,3)=rawProcSignal(:,3)+raw_bias;
yl1=max(rawProcSignal(:,2))+std(rawProcSignal(:,2)*3);
yl2=max(rawProcSignal(:,3))+std(rawProcSignal(:,3)*3);
yl=max([yl1,yl2]);
yl=[-yl,yl];


t=(0:1:length(rawProcSignal)-1)/Fs;
next_subplot=next_subplot+1;
subplot(nsubplots,1,next_subplot)
plot(t,rawProcSignal(:,2))
ylim(yl)
legend({'Raw EDC EMG'});
ylabel('Amplitude (mV)')
%xlabel('Time(ms)')

next_subplot=next_subplot+1;
subplot(nsubplots,1,next_subplot)
plot(t,rawProcSignal(:,3),'g')
ylim(yl)
legend({'Raw FDS EMG'});
ylabel('Amplitude (mV)')


% plot filtered EMG
%first find the largest amplitude channel and use it for ylim
yl1=max(rawProcSignal(:,5))+std(rawProcSignal(:,5)*3);
yl2=max(rawProcSignal(:,6))+std(rawProcSignal(:,6)*3);
yl=max([yl1,yl2]);
yl=[-yl,yl];


t=(0:1:length(rawProcSignal)-1)/Fs;
next_subplot=next_subplot+1;
subplot(nsubplots,1,next_subplot)
plot(t,rawProcSignal(:,5))
ylim(yl)
legend({'EDC EMG estimate'});
ylabel('Amplitude (mV)')
%xlabel('Time(ms)')

next_subplot=next_subplot+1;
subplot(nsubplots,1,next_subplot)
plot(t,rawProcSignal(:,6),'g')
ylim(yl)
legend({'FDS EMG estimate'});
ylabel('Amplitude (mV)')
xlabel('Time(s)')
%
%
%
%
%
%
%
%
%
%
%
%
%% Plot filtered EMG with computed power and pulsewidth
next_subplot=0;
nsubplots=4;
figure
%first find the largest amplitude channel and use it for ylim
yl1=max(rawProcSignal(:,5))+std(rawProcSignal(:,5)*3);
yl2=max(rawProcSignal(:,6))+std(rawProcSignal(:,6)*3);
yl=max([yl1,yl2]);
yl=[-yl,yl];


t=(0:1:length(rawProcSignal)-1)/Fs;
next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,5))
ylim(yl)
legend({'EDC EMG estimate'});
ylabel('Amplitude (mV)')
%xlabel('Time(ms)')

next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,6),'g')
ylim(yl)
legend({'FDS EMG estimate'});
ylabel('Amplitude (mV)')
xlabel('Time(s)')

% Now plot the EMG power
yl1=max(rawProcSignal(:,8))+std(rawProcSignal(:,8)*1);
yl2=max(rawProcSignal(:,9))+std(rawProcSignal(:,9)*1);
yl=max([yl1,yl2]);
yl=[0,yl];
%EDC
t=(0:1:length(rawProcSignal)-1)/Fs;
next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,8))
ylim(yl)
hold on
if(aFES.useDoubleThresh==0)
    % Compute and plot the relative EMG power equivalent of the threshold
    temp=aFES.singleThresh(1);
    mx=aFES.activeSensorMax(2);
    mn=aFES.activeSensorMin(2);
    temp=((mx-mn)*temp)+mn;
    plot([min(t);max(t)],[temp; temp]);
    legend({'EDC EMG power','ON'});
else
    % Compute and plot the relative EMG power equivalent of the threshold
    temp=aFES.doubleThresh(1:2);
    mx=aFES.activeSensorMax(2);
    mn=aFES.activeSensorMin(2);
    temp=((mx-mn)*temp)+mn; %compute the relative EMG power equivalent of the threshold
    plot([min(t);max(t)],[temp(1);temp(1)],':r');
    plot([min(t);max(t)],[temp(2);temp(2)],'-r');
    legend({'EDC EMG power','OFF','ON'});
end
hold off
ylabel('Magnitude |(mV)|')
%xlabel('Time(ms)')
%FDS
next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,9),'g')
ylim(yl)
hold on
if(aFES.useDoubleThresh==0)
    % Compute and plot the relative EMG power equivalent of the threshold
    temp=aFES.singleThresh(2);
    mx=aFES.activeSensorMax(3);
    mn=aFES.activeSensorMin(3);
    temp=((mx-mn)*temp)+mn;
    plot([min(t);max(t)],[temp; temp]);
    legend({'FDS EMG power','ON'});
else
    % Compute and plot the relative EMG power equivalent of the threshold
    temp=aFES.doubleThresh(3:4);
    mx=aFES.activeSensorMax(3);
    mn=aFES.activeSensorMin(3);
    temp=((mx-mn)*temp)+mn; %compute the relative EMG power equivalent of the threshold
    plot([min(t);max(t)],[temp(1);temp(1)],':r');
    plot([min(t);max(t)],[temp(2);temp(2)],'-r');
    legend({'FDS EMG power','OFF','ON'});
end
hold off
ylabel('Magnitude |(mV)|')
xlabel('Time(s)')

%now computed pulsewidth
yl1=max(rawProcSignal(:,10))+std(rawProcSignal(:,10)*1);
yl2=max(rawProcSignal(:,11))+std(rawProcSignal(:,11)*1);
yl=max([yl1,yl2]);
yl=[0,max([yl,1])];

t=(0:1:length(rawProcSignal)-1)/Fs;
next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,10))
ylim(yl)
legend({'EDC pulsewidth estimate'});
ylabel('\mus')
%xlabel('Time(ms)')

next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,11),'g')
ylim(yl)
legend({'FDS pulsewidth estimate'});
ylabel('Pulsewidth(\mus)')
xlabel('Time(s)')

%now applied pulsewidth
yl1=max(rawProcSignal(:,12))+std(rawProcSignal(:,12)*1);
yl2=max(rawProcSignal(:,13))+std(rawProcSignal(:,13)*1);
yl=max([yl1,yl2]);
yl=[0,max([yl,1])];

t=(0:1:length(rawProcSignal)-1)/Fs;
next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,12))
ylim(yl)
legend({'EDC pulsewidth applied'});
ylabel('Pulsewidth(\mus)')
%xlabel('Time(ms)')

next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,13),'g')
ylim(yl)
legend({'FDS pulsewidth appled'});
ylabel('Pulsewidth(\mus)')
xlabel('Time(s)')


