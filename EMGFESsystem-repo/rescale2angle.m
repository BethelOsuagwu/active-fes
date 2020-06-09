function A = rescale2angle(aFES,gonio )
% Scale the prescalled goniometer channels from [-2,2] to angle in degrees.
%
% The prescalled should be the one done in simulink: 
% "EMG_FES2/Voluntary +passive movement/Preprocessing/Signal conversion"
% with respect to the "EMG_FES2/Reference" block

% aFES: Active FES config var
% gonio: data to be converted
gonioFullRange=aFES.gonioFullRange;%mV
%gonioFullrange=aFES.gonioFullRange;
x=gonioFullRange;
p=[-2,2];%pre scale range
A=(x(2)-x(1))*( (gonio-p(1))/(p(2)-p(1)) )+x(1);
   
end


