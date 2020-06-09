function compare_wrist_traces()
%% Compare wrist traces from two files. Trace targets assumed to be equal.

default_dir='C:\SMSR1\activeFES-Feasibility\data\';
[fn,pn,~]=uigetfile('*.mat','Select Active FES data file',default_dir);

[t,shape,trace]=get_trace(fullfile(pn,fn));
fig=figure;
plot(t,shape,'k-','linewidth',2);
hold on
plot(t,trace,'k:','linewidth',1);

%GET A SECOND FILE
[fn2,pn2,~]=uigetfile('*.mat','Select Active FES data file',pn);
[t2,~,trace2]=get_trace(fullfile(pn2,fn2));
c=[0.501960784313725 0.501960784313725 0.501960784313725];
plot(t2,trace2,'--','linewidth',3 , 'Color',c);

hold off
xlabel('TIME (s)')
ylabel('ANGLE(^o)')
legend({'Target','File 1','File 2'})

figure(fig)
%

end
function [t,shape,trace]=get_trace(data_file)
    load(data_file);
    %% Prepare data
    rawProcSignal=squeeze(rawProcSignal);
    sz=size(rawProcSignal);
    if(sz(1)<sz(2))
        rawProcSignal=rawProcSignal';
    end

    %% prepare output
    t=(0:1:length(trace_out)-1)/aFES.Fs;
    wrist_trace_shape=trapezoid4wrist_offline(aFES,trace_out);
    if true % return angles
        shape=rescale2angle(aFES,wrist_trace_shape);
        trace=rescale2angle(aFES,-rawProcSignal(:,7));
    else
        shape=wrist_trace_shape;
        trace=-rawProcSignal(:,7);
    end
end