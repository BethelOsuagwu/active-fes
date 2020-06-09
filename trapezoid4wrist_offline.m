function wrist_trace_shape = trapezoid4wrist_offline(aFES,trace_out )
%Gets the shape for wrist tracing used for offline analysis.
%
%   Wrist Tracing shape offline
%   aFES: Active FES config var
%   trace_out: tracing output var
%   wrist_trace_shape:  the shape traced online

    % Defiien output
    wrist_trace_shape=[];
    
    % Check if data contains wrist trace first
    if ~isfield(aFES.tracing,'wristMaxHeightFactor')
        return
    end
        
    scale_fac=abs([aFES.activeSensorMin(1), aFES.activeSensorMax(1)]).*aFES.tracing.wristMaxHeightFactor;
    wrist_trace_shape=zeros(length(trace_out),1);
    for n=1:length(trace_out);
        if trace_out(n,1)>0
            wrist_trace_shape(n)=trace_out(n,1)*scale_fac(1);
        elseif trace_out(n,1)<0
            wrist_trace_shape(n)=trace_out(n,1)*scale_fac(2);
        end
    end
end

