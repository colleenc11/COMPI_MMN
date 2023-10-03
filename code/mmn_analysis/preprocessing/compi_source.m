function D = compi_source(id, options, doVisualize)
% -------------------------------------------------------------------------
% COMPI_SOURCE Create and run job for source reconstruction. 
% 
% IN
%   id          subject id string, only number (e.g. '0101')
%   options     general analysis options
%               options = compi_mmn_options;
%   doVisualize if true, dmpad_visualise_beamformer_job will be called
%               default: false
% 
% OUT
%   D           Data structure of SPM EEG Analysis
% -------------------------------------------------------------------------

%% paths and files
details = compi_get_subject_details(id, options);

% add some additional functions for beamforming option
if nargin<3
    doVisualize = false;
end

% record what we're doing
diary(details.eeg.source.logfile);
tnueeg_display_analysis_step_header('source analysis', 'compi', id, options.eeg.source);

% load preprocessed file
try
    D = spm_eeg_load(details.eeg.prepfile);
catch
    D = compi_preprocessing_eyeblink_correction(id, options);
end

%% souce reconstruction

VOI    = getfield(load(options.eeg.source.VOI), 'VOI');
usemsp = options.eeg.source.msp;

outputFile = details.eeg.source.filename;

if usemsp   
    mspJob = compi_msp_job(D, VOI, outputFile, options);
    spm_jobman('run', mspJob);    
else
    beamformerJob = dmpad_beamformer_job(D, VOI, details);  
    spm_jobman('run', beamformerJob);    
    if doVisualize        
        vis_beamformerJob = dmpad_visualise_beamformer_job(VOI, details);
        spm_jobman('run', vis_beamformerJob);
    end
    write_beamformerJob = dmpad_write_beamformer_job(details);  
    spm_jobman('run', write_beamformerJob);
end

% save output
D = spm_eeg_load(details.eeg.source.savefilename);
D = chantype(D, D.indchannel(VOI(:, 1)), 'LFP');
save(D);

cd(options.roots.results);

diary OFF