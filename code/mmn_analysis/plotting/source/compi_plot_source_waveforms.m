function compi_plot_source_waveforms (options)
%--------------------------------------------------------------------------
% COMPI_PLOT_SOURCE_WAVEFORMS Plots source waveforms for modelbased 
% single-trial EEG analysis in the COMPI study
%   IN:     --
%   OUT:    --
%--------------------------------------------------------------------------


for i_group = 1:length(options.subjects.group_labels)
    options.condition = char(options.subjects.group_labels{i_group});
    
    fh = compi_plot_source_waveforms_as_subplots(options);

end


end
