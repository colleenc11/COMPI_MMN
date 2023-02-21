function [erpWave] = compi_get_sourcewaveforms_all_subjects(options, sourceArray)
% retrieves ERP waves of specific source for all trials 
%
% IN
%   [erpWave] = dmpad_get_sourcewaveforms_all_subjects(options, ...
%                  sourceArray, iContrastArray)
% OUT
%   erpWave         cell(nSubjects, nContrasts) erp waveforms of specific
%                   channel for all subjects and specified contrasts
%

nSubjects = numel(options.subjects.all);
nContrasts = numel(sourceArray);
erpWave{nSubjects,nContrasts} = [];

for iSubject = 1:nSubjects
    id = char(options.subjects.all(iSubject));
    details = compi_get_subject_details(id, options);
    data = spm_eeg_load([details.eeg.source.savefilename]);
    T = data.fttimelock;
    for iContrast = 1:nContrasts
        chan = sourceArray{iContrast};
        sources =str2num(chan);
        erpWave{iSubject, iContrast} = squeeze(T.trial(:,sources,:));

    end
end