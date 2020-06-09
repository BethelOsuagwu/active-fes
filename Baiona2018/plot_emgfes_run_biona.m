function plot_emgfes_run_biona(aFES,rawProcSignal,trace_out)
% Plots the results of the Active FES run, for biona abstract.
%
% aFES: the run settings structure
% rawProcSignal: the main dta output from the run
% trace_out: the tracing output from the run
%
% e.g: plot_emgfes_run(aFES,rawProcSignal,trace_out)
%      plot_emgfes_run(aFES,rawProcSignal)
%
%

if nargin<3
     trace_out=[];
end
Fs=1000;

%% Prepar data
rawProcSignal=squeeze(rawProcSignal);
sz=size(rawProcSignal);
if(sz(1)<sz(2))
    rawProcSignal=rawProcSignal';
end

% Scall EMG channels from analogue Volts to EMG in mV
EMG_chs=[2,3];
emgFullRange=[-3,3];%mV
%emgFullrange=aFES.emgFullRange;
x=emgFullRange;
for EMG_ch=EMG_chs  
    A=rawProcSignal(:,EMG_ch);
    rawProcSignal(:,EMG_ch)=(x(2)-x(1))*( (A-0)/(4-0) )+x(1);
end

% Scale uncalled goniometer channels from analogue Volts to angle in degrees
GONIO_chs=1;
gonioFullRange=[-180,180];%mV
%gonioFullrange=aFES.gonioFullRange;
x=gonioFullRange;
for GONIO_ch=GONIO_chs  
    A=rawProcSignal(:,GONIO_ch);
    rawProcSignal(:,GONIO_chs)=(x(2)-x(1))*( (A-0)/(4-0) )+x(1);
end
%
%
%% Plot unprocessed versus processed data EMG *****************************************
next_subplot=0;
nsubplots=5;%Total number of rows of subplot
figure('position',[275,49,560,892]);
% plot unprocessed EMG
%first find the largest amplitude channel and use it for ylim
%raw_bias=-2;
%rawProcSignal(:,2)=rawProcSignal(:,2)+raw_bias;
%rawProcSignal(:,3)=rawProcSignal(:,3)+raw_bias;
yl1=max(rawProcSignal(:,2))+std(rawProcSignal(:,2)*0.5);
yl2=max(rawProcSignal(:,3))+std(rawProcSignal(:,3)*0.5);
yl=max([yl1,yl2]);
yl=[-yl,yl];


t=(0:1:length(rawProcSignal)-1)/Fs;
next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,2))
set(gca,'xticklabel',[])
box off
ylim(yl)
title('EDC')
%legend({'Raw EDC EMG'});%EDC
ylabel('FES-EMG(mV)')
%xlabel('Time(ms)')

next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,3),'g')
box off
set(gca,'yticklabel',[])
set(gca,'xticklabel',[])
ylim(yl)
%legend({'FES-EMG'});%FDS
%ylabel('A(mV)')
title('FDS');


% plot filtered EMG
%first find the largest amplitude channel and use it for ylim
yl1=max(rawProcSignal(:,5))+std(rawProcSignal(:,5)*0.5);
yl2=max(rawProcSignal(:,6))+std(rawProcSignal(:,6)*0.5);
yl=max([yl1,yl2]);
yl=[-yl,yl];


t=(0:1:length(rawProcSignal)-1)/Fs;
next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,5))
box off
set(gca,'xticklabel',[])
ylim(yl)
%legend({'EDC EMG estimate'});%EDC
ylabel('EMG(mV)')
%xlabel('Time(ms)')

next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,6),'g')
box off
set(gca,'yticklabel',[])
set(gca,'xticklabel',[])
ylim(yl)
%legend({'EMG'});%FDS
%ylabel('A(mV)')
%xlabel('Time(s)')
%
%
%% Plot filtered EMG with computed power and pulsewidth

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
box off
set(gca,'xticklabel',[])
ylim(yl)
hold on
if(aFES.useDoubleThresh==0)
    % Compute and plot the relative EMG power equivalent of the threshold
    temp=aFES.singleThresh(1);
    mx=aFES.activeSensorMax(2);
    mn=aFES.activeSensorMin(2);
    temp=((mx-mn)*temp)+mn;
    plot([min(t);max(t)],[temp; temp]);
    %legend({'EDC EMG power','ON'});%EDC
else
    % Compute and plot the relative EMG power equivalent of the threshold
    temp=aFES.doubleThresh(1:2);
    mx=aFES.activeSensorMax(2);
    mn=aFES.activeSensorMin(2);
    temp=((mx-mn)*temp)+mn; %compute the relative EMG power equivalent of the threshold
    plot([min(t);max(t)],[temp(1);temp(1)],':r');
    plot([min(t);max(t)],[temp(2);temp(2)],'-r');
    %legend({'EMG Power','OFF','ON'});%EDC
end
hold off
ylabel('Mag |(mV)|')
%xlabel('Time(ms)')
%FDS
next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,9),'g')
box off
set(gca,'yticklabel',[])
set(gca,'xticklabel',[])
ylim(yl)
hold on
if(aFES.useDoubleThresh==0)
    % Compute and plot the relative EMG power equivalent of the threshold
    temp=aFES.singleThresh(2);
    mx=aFES.activeSensorMax(3);
    mn=aFES.activeSensorMin(3);
    temp=((mx-mn)*temp)+mn;
    plot([min(t);max(t)],[temp; temp]);
    legend({'EMG power','Threshold'});%FDS
    legend BOXOFF
else
    % Compute and plot the relative EMG power equivalent of the threshold
    temp=aFES.doubleThresh(3:4);
    mx=aFES.activeSensorMax(3);
    mn=aFES.activeSensorMin(3);
    temp=((mx-mn)*temp)+mn; %compute the relative EMG power equivalent of the threshold
    plot([min(t);max(t)],[temp(1);temp(1)],':r');
    plot([min(t);max(t)],[temp(2);temp(2)],'-r');
    legend({'EMG power','OFF threshold','ON threshold'});%FDS
end
hold off
%ylabel('Magnitude |(mV)|')
%xlabel('Time(s)')
%
%
%now applied pulsewidth
yl1=max(rawProcSignal(:,12))+std(rawProcSignal(:,12)*1);
yl2=max(rawProcSignal(:,13))+std(rawProcSignal(:,13)*1);
yl=max([yl1,yl2]);
yl=[0,max([yl,1])];

t=(0:1:length(rawProcSignal)-1)/Fs;
next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,12))
box off
%set(gca,'xticklabel',[])
ylim(yl)
%legend({'Pw'});%EDC
ylabel('Pulse width(\mus)')
xlabel('Time(s)')

next_subplot=next_subplot+1;
subplot(nsubplots,2,next_subplot)
plot(t,rawProcSignal(:,13),'g')
box off
set(gca,'yticklabel',[])
%set(gca,'xticklabel',[])
ylim(yl)
%legend({'Pulse width'});%FDS
%ylabel('Pulsewidth(\mus)')
%xlabel('Time(s)')




%% Plot the tracing
if ~isempty(trace_out)
    t=(0:1:length(trace_out)-1)/Fs;
    %next_subplot=next_subplot+1;
    subplot(nsubplots,1,nsubplots)
    plot(t,trace_out(:,1));
    box off
    hold on
    plot(t,trace_out(:,2),'--k');
    hold off
    legend({'Target','Trace'});
    legend(gca, 'BOXOFF')
    ylabel('Position (norm.)')
    xlabel('Time(s)')
    
end