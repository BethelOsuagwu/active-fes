function load_afes_mdl(aFES)
% Load the main model and set it up with the given parameters.
%
% aFES : An Active FES structure.
%
    load_system('EMG_FES2');
    
    % Set parameters
    for ni=1:length(aFES.blk.stimCurr_BLK)
        set_param(aFES.blk.stimCurr_BLK{ni},'Value',mat2str(aFES.stimCurr))
    end
    
    set_param(aFES.blk.pwFactor_BLK,'Value',mat2str(aFES.pwFactor))
    set_param(aFES.blk.pwThresh_BLK,'Value',mat2str(aFES.pwThresh))
   
    set_param(aFES.blk.singleThresh_BLK,'Value',mat2str(aFES.singleThresh)) 
    set_param(aFES.blk.useDoubleThresh_BLK,'Value',mat2str(aFES.useDoubleThresh)) 
    set_param(aFES.blk.doubleThresh_BLK,'Value',mat2str(aFES.doubleThresh))
    
    set_param(aFES.blk.monoStim_BLK,'Value',mat2str(aFES.monoStim))
end