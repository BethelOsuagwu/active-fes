function [trap_x,trap_y]=trapezoid4trace(Fs,trace_time)
% Generates a normalised trapezium for tracing
%
% Fs=sampling rate
% trace_time: the total time in seconds it takes to trace the trapezium
if nargin<1
    Fs=1000;
end
if nargin<2
    trace_time=20;%trace_time=30;
end
    rise_len=Fs; %rising time in samples (THE FINAL ACTUAL LENGTH WILL DEPEND ON 'step_size')
    steady_len=rise_len*3;%flat length in sasmple
    fall_len=ceil(rise_len);% fall time in samples
    
    
    step_size=(rise_len+steady_len+fall_len)/Fs;% leads to one second
    step_size=step_size/trace_time;%leads to trace_time seconds
    
    theta=pi/2;% angle of inclination

    %%rise
    n=1:step_size:rise_len;
    x=n*cos(theta);
    y=n*sin(theta);

    %%steady
    n=n(end)+step_size:step_size:n(end)+step_size+steady_len;
    x=[x,n*cos(theta)];
    y=[y,y(end)*ones(size(n))];



    %%fall
    nx=n(end)+step_size:step_size:n(end)+fall_len;
    n=rise_len-step_size:-step_size:rise_len-fall_len;%assuming that fall_len<=rise_len

    x=[x,nx*cos(theta)];
    y=[y,n*sin(theta)];
    
    %%output
    y=y/(max(y));%normalize the y-values
    trap_x=x';
    trap_y=y';
    
    %trap_x=resample(trap_x,trace_time,1);
    %trap_y=resample(trap_y,trace_time,1);

end





