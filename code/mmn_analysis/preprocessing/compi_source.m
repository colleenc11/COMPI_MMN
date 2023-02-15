function D = compi_source(id, options, doVisualize)
%
% IN
%   id          subject id string, only number (e.g. '153')
%   doVisualize if true, dmpad_visualise_beamformer_job will be called
%               default: false
%   options     general analysis options
%               options = dmpad_set_analysis_options;
% 
% OUT
%   D           Data structure of SPM EEG Analysis


% paths and files
details = compi_get_subject_details(id, options);

% add some additional functions for beamforming
if nargin<3
    doVisualize = false;
end

% record what we're doing
diary(details.eeg.source.logfile);
tnueeg_display_analysis_step_header('source analysis', 'dmpad', id, options.eeg.source);

try
    D = spm_eeg_load(details.eeg.prepfile);
catch
    D = dmpad_preprocessing(id);
end

VOI    = getfield(load(options.eeg.source.mmnVOI), 'VOI');
radius = options.eeg.source.radius;%mm
usemsp = options.eeg.source.msp;

if usemsp   
    mspJob = dmpad_msp_job(D, VOI, details, options);
    spm_jobman('run', mspJob);    
else
    beamformerJob = dmpad_beamformer_job(D, VOI, details);  
    spm_jobman('run', beamformerJob);    
    if doVisualize        
        vis_beamformerJob = dmpad_visualise_beamformer_job(VOI, details);  
    end
    write_beamformerJob = dmpad_write_beamformer_job(details);  
    spm_jobman('run', write_beamformerJob);
    
end

D = spm_eeg_load(details.eeg.source.savefilename);
D = chantype(D, D.indchannel(VOI(:, 1)), 'LFP');
save(D);

cd(options.roots.results);

diary OFF