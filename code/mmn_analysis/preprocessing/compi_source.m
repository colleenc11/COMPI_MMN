function D = compi_source(id, options)
% -------------------------------------------------------------------------
% COMPI_SOURCE Create and run job for source reconstruction. 
% 
% IN
%   id          subject id string, only number (e.g. '0101')
%   options     general analysis options
%               options = compi_mmn_options;
% 
% OUT
%   D           Data structure of SPM EEG Analysis
% -------------------------------------------------------------------------

%% paths and files
details = compi_get_subject_details(id, options);

% record what we're doing
diary(details.eeg.logfile);
tnueeg_display_analysis_step_header('model_source_analysis', 'compi', id, options.eeg.source);

% load preprocessed file
try
    D = spm_eeg_load(details.eeg.prepfile);
catch
    error('ERP file is missing for subject %s. Generate ERP data using compi_erp.\n', id);
end

%% souce reconstruction

VOI    = getfield(load(options.eeg.source.VOI), 'VOI');

outputFile = details.eeg.source.filename;

mspJob = compi_msp_job(D, VOI, outputFile, options);
spm_jobman('run', mspJob);    

% save output
D = spm_eeg_load(details.eeg.source.savefilename);
D = chantype(D, D.indchannel(VOI(:, 1)), 'LFP');
save(D);

cd(options.roots.results);

diary OFF
end