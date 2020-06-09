function emg = scale2emg(aFES,raw )
% Scall EMG channels from analogue Volts to EMG in mV
%
% aFES: Active FES config var
% raw: data to be converted
emgFullRange=[-3,3];%mV
if isfield(aFES,'emgFullRange')
    emgFullRange=aFES.emgFullRange;%mV
end
%emgFullrange=aFES.emgFullRange;
x=emgFullRange;

emg=(x(2)-x(1))*( (raw-0)/(4-0) )+x(1);

   
end


