function compi_plot_source_waveforms (options)
%--------------------------------------------------------------------------
% COMPI_PLOT_SOURCE_WAVEFORMS Plots source waveforms for modelbased 
% single-trial EEG analysis in the COMPI study
%   IN:     --
%   OUT:    --
%--------------------------------------------------------------------------

for i_group = 1:length(options.subjects.group_labels)
    options.condition = char(options.subjects.group_labels{i_group});
    
    compi_plot_source_waveforms_as_subplots(options);
    
    for iReg = 1:length(options.eeg.stats.regressors)
        regressor = char(options.eeg.stats.regressors{iReg});
        
        % extract first and last significant voxel based on source stats
        compi_first_last_significant_time_significance(options, regressor);
    end

end


end
