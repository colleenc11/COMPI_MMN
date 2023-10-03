function [erpWave] = compi_get_sourcewaveforms_all_subjects(factor, sourceArray, options)
%--------------------------------------------------------------------------
% COMPI_GET_SOURCE_WAVEFORMS_ALL_SUBJECTS Retrieves ERP waves for all 
% sources and all trials 
%
%   IN:     factor        a string with the name of the factor of interest
%           sourceArray   array of sources
%           options       as set by compi_set_analysis_options();
%
%   OUT:    erpWave       cell(nSubjects, nContrasts) erp waveforms of all
%                         sources and specified subjects
%
% See also dmpad_get_sourcewaveforms_all_subjects 
%--------------------------------------------------------------------------

for i_group = 1: numel(options.subjects.group_labels)
    if strcmp(options.subjects.group_labels{i_group}, options.condition)
        
        nSubjects = numel(options.subjects.IDs{i_group});
        nContrasts = numel(sourceArray);
        erpWave{nSubjects,nContrasts} = [];
        
        % loop through subjects
        for iSubject = 1:nSubjects
            id = char(options.subjects.IDs{i_group}(iSubject));
            details = compi_get_subject_details(id, options);

            % collect source waveform data
            if startsWith(factor, 'oddball')
                data = spm_eeg_load(fullfile(details.eeg.erp.root, factor, ['B_diff_' factor '.mat']));
                T = data.fttimelock;
                for iContrast = 1:nContrasts
                    erpWave{iSubject, iContrast} = squeeze(T.avg(iContrast,:));
                end
            elseif startsWith(factor, 'delta1')
                data = spm_eeg_load(fullfile(details.eeg.erp.root, factor, ['B_diff_' factor '.mat']));
                T = data.fttimelock;
                for iContrast = 1:nContrasts
                    erpWave{iSubject, iContrast} = squeeze(T.avg(iContrast,:));
                end
            else
                data = spm_eeg_load([details.eeg.source.savefilename]);
                T = data.fttimelock;
                for iContrast = 1:nContrasts
                    erpWave{iSubject, iContrast} = squeeze(T.trial(:,iContrast,:));
                end
            end
            
        end
    end
end