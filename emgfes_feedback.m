function ACTIVEFES=emgfes_feedback(ACTIVEFES,x,onFESThresh,stage)
% The main Active FES visual feedback. 
%
% x is a three or more dimensional vector where ...
% x(1)=center left bar position and
% x(2) centre right bar position
% x(3)=indicator of a third position/ pointer position
% x(4)=Extension FES pulsewidth
% x(5)=Flex FES pulsewidth
% onFESThresh: the threshold used when FES is on where ...
% onFESThresh(1:2) =singleThresh values
% onFESThresh(3:6) = doubleThresh values
persistent hand sdthresh t_update t_pwUpdate;
showOnFESThresh=1;% When true updates the thresh makers to show onFESThresh
if(nargin<4)
    stage=1;
end

if(stage==0)
    %Init variables
    t_update=0;
    t_pwUpdate=0;
    
    fpos=0;
    %close figure if it exists
    if isfield(ACTIVEFES,'feedback')
        if isfield(ACTIVEFES.feedback,'figureHdl')
            if ishandle(ACTIVEFES.feedback.figureHdl)
                fpos=get(ACTIVEFES.feedback.figureHdl,'position');
                ACTIVEFES=emgfes_feedback(ACTIVEFES,0,[],4);
            end
        end
    end
    
    % Which hand
    hand=1;%'left'
    if strcmpi(ACTIVEFES.hand,'right')
        hand=0;% right
    end
    
    %Init new figure
    [ACTIVEFES.feedback.figureHdl,ACTIVEFES.feedback.axes1, ACTIVEFES.feedback.centreLeftBarHdl,ACTIVEFES.feedback.centreRightBarHdl,ACTIVEFES.feedback.posIndicatorHdl,...
        ACTIVEFES.feedback.pwExt,ACTIVEFES.feedback.pwFlex]=createfigure(hand);
    if fpos~=0
        set(ACTIVEFES.feedback.figureHdl,'position',fpos);
    end
    
    %set the threshold makers
    
    
    if ACTIVEFES.useDoubleThresh
        ACTIVEFES.feedback.dThreshMakerHdl=doubleThreshMaker(ACTIVEFES.doubleThresh,ACTIVEFES.feedback.axes1);
        sdthresh=ACTIVEFES.doubleThresh;
    else
        ACTIVEFES.feedback.sThreshMakerHdl=singleThreshMaker(ACTIVEFES.singleThresh,ACTIVEFES.feedback.axes1);
        sdthresh=ACTIVEFES.singleThresh;
    end
    
elseif stage==1
    t_update=t_update+1;
    t_pwUpdate=t_pwUpdate+1;
    
    if(t_update==50)
        t_update=0;
        

        %See if we need to switch feedback to make sense
        if(hand==0)
            x(1)=-x(1);
            x(2:3)=[x(3);x(2)];
        end

        set(ACTIVEFES.feedback.posIndicatorHdl,'XData',x(1))

        if(x(2)<=0 || isnan(x(2)))
            x(2)=0.00001;
        end
        set(ACTIVEFES.feedback.centreLeftBarHdl,'position',[-abs(x(2)),0.45,abs(x(2)),0.1])

        if(x(3)<=0 || isnan(x(3)))
            x(3)=0.00001;
        end
        set(ACTIVEFES.feedback.centreRightBarHdl,'position',[0,0.45,x(3),0.1])

        % Check if we need to chnage the threshold position
        if(ACTIVEFES.useDoubleThresh)
            doubleThresh=ACTIVEFES.doubleThresh;
            %onFESThresh=onFESThresh';
            
            % CHeck if we should be showing onFESThresh
            if(showOnFESThresh && any(doubleThresh~=onFESThresh(3:6)))
                doubleThresh=onFESThresh(3:6);
            end
            
            if(any(sdthresh~=doubleThresh))
                mkrs=doubleThresh;
                if (hand==0)%If feed back is switched, we should also switch the correspoding thresh
                    mkrs=[mkrs(3:4);mkrs(1:2)];
                end
                mkrs=[-mkrs(1:2);mkrs(3:4)];

                for hi=1:length(mkrs)
                    p_temp=get(ACTIVEFES.feedback.dThreshMakerHdl(hi),'position');
                    p_temp(1)=mkrs(hi);
                    set(ACTIVEFES.feedback.dThreshMakerHdl(hi),'position',p_temp);
                end

                sdthresh=doubleThresh;
            end
        else % Single thresh is in use so update it
            singleThresh=ACTIVEFES.singleThresh;
            onFESThresh=onFESThresh';
            
            % CHeck if we should be showing onFESThresh
            if(showOnFESThresh && any(singleThresh~=onFESThresh(1:2)))
                singleThresh=onFESThresh(1:2);
            end
            if(any(sdthresh~=singleThresh))
                mkrs=singleThresh;
                if (hand==0)%If feedback is switched, we should also switch the correspoding thresh
                    mkrs=[mkrs(2);mkrs(1)];
                end
                mkrs=[-mkrs(1);mkrs(2)];

                for hi=1:length(mkrs)
                    p_temp=get(ACTIVEFES.feedback.sThreshMakerHdl(hi),'position');
                    p_temp(1)=mkrs(hi);
                    set(ACTIVEFES.feedback.sThreshMakerHdl(hi),'position',p_temp);
                end

                sdthresh=singleThresh;
            end
        end
    end

    % Update the applied threshold
    if(t_pwUpdate==100)
        t_pwUpdate=0;
        set(ACTIVEFES.feedback.pwExt,'String',x(4))
        set(ACTIVEFES.feedback.pwFlex,'String',x(5))
    end
    
elseif stage==4
    close(ACTIVEFES.feedback.figureHdl)
    ACTIVEFES.feedback=rmfield(ACTIVEFES.feedback,'figureHdl');
    ACTIVEFES.feedback=rmfield(ACTIVEFES.feedback,'centreLeftBarHdl');
    ACTIVEFES.feedback=rmfield(ACTIVEFES.feedback,'centreRightBarHdl');
    ACTIVEFES.feedback=rmfield(ACTIVEFES.feedback,'posIndicatorHdl');
    ACTIVEFES.feedback=rmfield(ACTIVEFES.feedback,'axes1');
    if isfield(ACTIVEFES.feedback,'sThreshMakerHdl')
        ACTIVEFES.feedback=rmfield(ACTIVEFES.feedback,'sThreshMakerHdl');
    end
    if isfield(ACTIVEFES.feedback,'dThreshMakerHdl')
        ACTIVEFES.feedback=rmfield(ACTIVEFES.feedback,'dThreshMakerHdl');
    end
    ACTIVEFES.feedback=rmfield(ACTIVEFES.feedback,'pwExt');
    ACTIVEFES.feedback=rmfield(ACTIVEFES.feedback,'pwFlex');
    clear hand;
    
end


function [figure1,axes1,centreLeftBarHdl,centreRightBarHdl,posIndicatorHdl,pwExt,pwFlex]=createfigure(hand_idx)
% CREATEFIGURE

%  Auto-generated by MATLAB on 10-Nov-2016 17:58:29

% Create figure
figure1 = figure('NumberTitle','off',...
    'Name','Stoke Mandeville Spinal Research Active FES',...
    'Color',[1 1 1],'units','normalized','position',[0.2344,0.1982,0.5242,0.5977],'ToolBar','none',...
    'Resize','off');

% Create axes
axes1 = axes('Visible','off','Parent',figure1);
hold on;
%% Uncomment the following line to preserve the X-limits of the axes
 xlim(axes1,[-1.2 1.2]);
%% Uncomment the following line to preserve the Y-limits of the axes
 ylim(axes1,[0 1]);

% Create rectangle
rectangle('Parent',axes1,'Position',[-1 0.45 2 0.1],'LineWidth',4,...
    'EdgeColor',[0.952941179275513 0.905882358551025 0.0901960805058479],...
    'FaceColor',[1 1 1],...
    'Curvature',[0.1 1]);

% Create text
text('Parent',axes1,'String','|','Position',[-0.01 0.42 0],'FontWeight','bold',...
    'FontSize',10,...
    'Color',[0.952941179275513 0.905882358551025 0.0901960805058479]);

% Create rectangle
centreLeftBarHdl =rectangle('Parent',axes1,...
    'Position',[-0.0140825270404854 0.45 0.0140825270404854 0.1],...
    'LineStyle','none',...
    'EdgeColor',[1 1 0],...
    'FaceColor',[0.952941179275513 0.905882358551025 0.0901960805058479],...
    'Curvature',[0.5 0.5]);

% Create rectangle
centreRightBarHdl =rectangle('Parent',axes1,...
    'Position',[-0.0140825270404854 0.45 0.0140825270404854 0.1],...
    'LineStyle','none',...
    'EdgeColor',[1 1 0],...
    'FaceColor',[0.952941179275513 0.905882358551025 0.0901960805058479],...
    'Curvature',[0.5 0.5]);

% Create ellipse
annotation(figure1,'ellipse',...
    [0.813186813186813 0.809443507588505 0.163265306122449 0.175379426644179],...
    'FaceColor',[0.364705890417099 0.768627464771271 0.929411768913269],...
    'Color','none');

% Create textbox
annotation(figure1,'textbox',...
    [0.846153846153862 0.885328836424946 0.149136577708006 0.0809443507588533],...
    'String',{'Improving','quality of'},...
    'FontWeight','light',...
    'FontSize',11,...
    'LineStyle','none',...
    'Color',[0.301960796117783 0.137254908680916 0.474509805440903]);

% Create textbox
annotation(figure1,'textbox',...
    [0.844583987441135 0.816875210792573 0.139717425431711 0.0843170320404722],...
    'String',{'life after','paralysis'},...
    'FontWeight','bold',...
    'FontSize',11,...
    'LineStyle','none',...
    'Color',[1 1 1]);

% Create ellipse
annotation(figure1,'ellipse',...
    [0.676609105180542 0.809443507588529 0.166405023547881 0.177065767284986],...
    'FaceColor',[0.301960796117783 0.137254908680916 0.474509805440903],...
    'Color','none');

% Create textbox
annotation(figure1,'textbox',...
    [0.692307692307696 0.880956155143337 0.135007849293564 0.0775716694772344],...
    'String',{'stoke','mandeville'},...
    'LineStyle','none',...
    'Color',[1 1 1]);

% Create textbox
annotation(figure1,'textbox',...
    [0.692307692307696 0.820247892074194 0.160125588697017 0.0843170320404722],...
    'String',{'spinal','research...'},...
    'FontWeight','bold',...
    'FontSize',11,...
    'LineStyle','none',...
    'Color',[1 1 1]);

% Create textbox
annotation(figure1,'textbox',...
    [0.681318681318689 0.730871838111285 0.346938775510204 0.0556492411467116],...
    'String',{'lifeafterparalysis.com'},...
    'FontWeight','bold',...
    'FontSize',14,...
    'LineStyle','none',...
    'Color',[0.301960796117783 0.137254908680916 0.474509805440903]);

% Create textbox
annotation(figure1,'textbox',...
    [0.298273155416018 0.0765716694772216 0.445839874411303 0.0505902192242833],...
    'String',{'Active functional electrical stimulation'},...
    'FontWeight','light',...
    'FontSize',12,...
    'LineStyle','none',...
    'Color',[0.301960796117783 0.137254908680916 0.474509805440903]);

% Create plot for arrow
posIndicatorHdl=plot(axes1,0,0.58,...
    'MarkerFaceColor',[0.952941179275513 0.905882358551025 0.0901960805058479],...
    'MarkerEdgeColor',[0.952941179275513 0.905882358551025 0.0901960805058479],...
    'MarkerSize',12,...
    'Marker','v',...
    'LineStyle','none');

%set(axes1,'Visible','off');


% Directional text
left_right_pos=[[0.72976304023845 0.500815660685155 0.088418777943368 0.0358890701468222];
                [0.202818181818182 0.500391517128876 0.10120566318927 0.0358890701468222]];
idx_=[1,2];
if(hand_idx==0)
    idx_=[2,1];
end
annotation(figure1,'textbox',...
    left_right_pos(idx_(1),:),...
    'String',{'Flexion'},...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0.8 0.8 0.8]);

annotation(figure1,'textbox',...
    left_right_pos(idx_(2),:),...
    'String',{'Extension'},...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0.8 0.8 0.8]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create holder for FES pulsewidth
%Left FES pulsewidth holder
annotation(figure1,'textbox',...
    [0.204308494783906 0.58685154975531 0.129521609538002 0.039151712887439],...
    'String',{'Pw:       \mus'},...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0.831372549019608 0.815686274509804 0.784313725490196]);

%Right FES pulsewidth holder
annotation(figure1,'textbox',...
    [0.72889865871833 0.58848287112562 0.129521609538002 0.039151712887439],...
    'String',{'Pw:       \mus'},...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0.831372549019608 0.815686274509804 0.784313725490196]);

left_right_pos=[[0.249643815201193 0.586427406199034 0.0528897168405356 0.039151712887439];
    [0.774233979135618 0.586427406199034 0.0528897168405356 0.039151712887439]];
idx_=[1,2];
if(hand_idx==0)
    idx_=[2,1];
end
% Create Extension FES pulsewidth textbox
pwExt=annotation(figure1,'textbox',...
    left_right_pos(idx_(1),:),...
    'String',{'Ext:0'},...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0.831372549019608 0.815686274509804 0.784313725490196]);

% Create Flexion FES pulsewidth textbox
pwFlex=annotation(figure1,'textbox',...
    left_right_pos(idx_(2),:),...
    'String',{'Flex:0'},...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0.831372549019608 0.815686274509804 0.784313725490196]);

end
    function sThreshMakerHdl=singleThreshMaker(thresh1,axes1)
        %% Sets plots activation threshold makers on the feedback bar
        %
        %thresh1: is a 2d-vector of threshold values where thresh1(1) is OFF
        %thresh and thresh1(2) is the ON thresh
        %
        %axes1: The axes to plot the markers on.
        
        pts=thresh1;
        if (hand==0)%If feedback is switched, we should also switch the correspoding thresh
            pts=[pts(2);pts(1)];
        end
        pts=[-pts(1);pts(2)];
        
        %pts=[-thresh1 thresh1];
        sThreshMakerHdl=zeros(length(pts),1);
        
        color1=[
                [0.87058824300766 0.952941179275513 0.984313726425171]
                [0.87058824300766 0.952941179275513 0.984313726425171]
                ];
        
        % Create ellipse
        cj=0;
        if iscolumn(pts)
            pts=pts';
        end
        for ci=pts
            cj=cj+1;
            
            sThreshMakerHdl(cj)=rectangle('Parent',axes1,...
                'Position',[ci 0.457300884955752 0.00631452455590387 0.0839964601769911],...
                'LineStyle','none',...
                'EdgeColor',[1 1 0],...
                'FaceColor',color1(cj,:),...
                'Curvature',[0.5 0.5]);
            
        end
    end


    function dThreshMakerHdl=doubleThreshMaker(thresh1,axes1)
        %% Sets plots activation threshold makers on the feedback bar
        %
        %thresh1: is a 2d-vector of threshold values where thresh1(1) is OFF
        %thresh and thresh1(2) is the ON thresh
        %
        %axes1: The axes to plot the markers on.
        
        pts=thresh1;
        if (hand==0)%If feedback is switched, we should also switch the correspoding thresh
            pts=[pts(3:4);pts(1:2)];
        end
        pts=[-pts(1:2);pts(3:4)];
        
        %pts=[-thresh1 thresh1];
        dThreshMakerHdl=zeros(length(pts),1);
        
        color1=[
                [0.87058824300766 0.952941179275513 0.984313726425171]
                [0.807843148708344 0.929411768913269 0.976470589637756]
                [0.87058824300766 0.952941179275513 0.984313726425171]
                [0.807843148708344 0.929411768913269 0.976470589637756]
                ];
        color2=[
                [0.95686274766922 0.917647063732147 0.180392161011696]
                [0.960784316062927 0.925490200519562 0.270588248968124]
                [0.95686274766922 0.917647063732147 0.180392161011696]
                [0.960784316062927 0.925490200519562 0.270588248968124]
                ];
        color3=[
                [0.760784327983856 0.725490212440491 0.0705882385373116]
                [0.854901969432831 1 0.0784313753247261]
                [0.760784327983856 0.725490212440491 0.0705882385373116]
                [0.854901969432831 1 0.0784313753247261]
                ];
        % Create ellipse
        cj=0;
        if iscolumn(pts)
            pts=pts';
        end
        for ci=pts
            cj=cj+1;
            
            dThreshMakerHdl(cj)=rectangle('Parent',axes1,...
                'Position',[ci 0.457300884955752 0.00631452455590387 0.0839964601769911],...
                'LineStyle','none',...
                'EdgeColor',[1 1 0],...
                'FaceColor',color1(cj,:),...
                'Curvature',[0.5 0.5]);
            
        end
    end
    
end