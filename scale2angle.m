function A = scale2angle(aFES,gonio )
% Scale uncalled goniometer channels from analogue Volt to angle(degrees).
%
% aFES: Active FES config var
% gonio: data to be converted
gonioFullRange=aFES.gonioFullRange;%mV
%gonioFullrange=aFES.gonioFullRange;
x=gonioFullRange;

A=(x(2)-x(1))*( (gonio-0)/(4-0) )+x(1);
   
end


