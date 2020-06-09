function emgfesgui_plot_listener(block,evt)
% The Simulink event listener for normalised/PW/EMG tracing feedback.

global aFES;

% Number of previous points to plot
nPrevPts=1;

% Should we scroll the xaxis(Note that this can be vary slow)
updateXaxes=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Open to implement low rate execution%%%%%%%%%
% % % % % persistent ts_;
% % % % % if isempty(ts_)
% % % % %      ts_=0;
% % % % % end
% % % % %  ts_=ts_+1;
% % % % %  
% % % % % % Implement display frequency
% % % % % screen_update_freq=50;
% % % % % if ts_==screen_update_freq
% % % % %     ts_=0;
% % % % % else
% % % % %     return
% % % % % end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%End low rate implementation%%%%%%%%%%%%%%%%%%%

%if(ts_==1)
    %h  = get_param(block.BlockHandle,'UserData')
    st = block.CurrentTime;%get simulation time
    d = block.OutputPort(1).Data;
    
    %feeback
    d_fbk = block.OutputPort(2).Data;
    %aFES.plot.p1
    d0=get(aFES.plot.p1,'YData');
    xd0=get(aFES.plot.p1,'XData');
    
    %feeback
    d0_fbk=get(aFES.plot.p2,'YData');
    
    if(nPrevPts==1)
        d0=d;
        xd0=st;
        
        %feedback
        d0_fbk=d_fbk;
        
    else
        if(length(d0)<nPrevPts)
            d0(end+1)=d;
            xd0(end+1)=st;
            
            %feedback
            d0_fbk(end+1)=d_fbk;
            
        else
            d0(1:end-1)=d0(2:end);
            d0(end)=d;

            xd0(1:end-1)=xd0(2:end);
            xd0(end)=st;
            
            %feedback
            d0_fbk(1:end-1)=d0_fbk(2:end);
            d0(end)=d;
        end
    end
    

    set(aFES.plot.p1,'YData',d0,'XData',xd0);
    set(aFES.plot.p2,'YData',d0_fbk,'XData',xd0);
    %drawnow('expose');
    
    % The axes limits may also need changing
    if(updateXaxes)
        newXLim = [max(0,st-10) max(13,st+3)];
        set(aFES.plot.ax1,'Xlim',newXLim);
    end

    %ts_=0;
%end

end