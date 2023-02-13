function compi_plot_channel_prep(D, f, id, options)
% -------------------------------------------------------------------------
% Performs all analysis steps for one subject of the COMPI study (up until 
% first level modelbased statistics)
%
%   IN:     id          subject identifier string, e.g. '0001'
%           options     as set by compi_set_analysis_options();
%
%   OUT:    D           Data structure of SPM EEG Analysis
% -------------------------------------------------------------------------

chanTime = {75000, 150000, 212500};
for iTime = 1:length(chanTime)
    t = chanTime{iTime};

    tiledlayout(length(options.eeg.preproc.checkChannel),1)
    for i = 1:length(options.eeg.preproc.checkChannel)
        chan = options.eeg.preproc.checkChannel{i};
        
        chanInd = indchannel(D, chan);
        
        % plot channel timecourse
        eval(['ax' num2str(i) '= nexttile;'])
        plot(D(chanInd,t:(t+2999)))
        title([chan ' Time Course']);
        xlabel('Time'); ylabel('Amplitude');
        
    end

    ax1.YLim = [-100 100];
    linkaxes([ax1 ax2 ax3],'xy')
    set(gcf,'Position',[100 100 900 700])

    sgtitle(['Prep chan data at ' num2str(iTime*5) ' minutes'])
      
    if ~exist(fullfile(options.roots.diag_eeg, ['ChannelCheck_Prep']), 'dir')
        mkdir(fullfile(options.roots.diag_eeg, ['ChannelCheck_Prep']));
    end
    
    saveas(gca, fullfile(options.roots.diag_eeg, 'ChannelCheck_Prep', ['Chan_' id '_Run' num2str(f) '_' num2str(iTime*5) '_prep']),'png');
end 
close all;