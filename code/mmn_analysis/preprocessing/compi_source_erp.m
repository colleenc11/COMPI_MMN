function D = compi_source_erp(id, options, doVisualize)
% -------------------------------------------------------------------------
% COMPI_SOURCE_ERP Create headmodel and extracts sources based on fMRI 
% priors or MSP.
% Adapted from dmpad-toolbox: dmpad_source.
%
% IN
%   id          subject id string, only number (e.g. '0101')
%   doVisualize if true, dmpad_visualise_beamformer_job will be called
%               default: false
%   options     general analysis options
%               options = compi_set_analysis_options;
% 
% OUT
%   D           Data structure of SPM EEG Analysis
% -------------------------------------------------------------------------

% paths and files
details = compi_get_subject_details(id, options);

% add some additional functions for beamforming
if nargin<3
    doVisualize = false;
end

% record what we're doing
diary(details.eeg.source.logfile);
tnueeg_display_analysis_step_header('source analysis', 'compi', id, options.eeg.source);

% input (erp) file
inputFile   = fullfile(details.eeg.erp.root, 'oddball', ['diff_oddball.mat']);

% output file
erpFile     = fullfile(details.eeg.erp.root, 'oddball', ['B_diff_oddball.mat']);

try
    D = spm_eeg_load(inputFile);
catch
    D = dmpad_preprocessing(id);
end

%-- headmodel ------------------------------------------------------------%
fid = details.eeg.fid;
hmJob = dmpad_headmodel_job(D, fid, details, options);
spm_jobman('run', hmJob);
D = reload(D);


%-- source analysis ------------------------------------------------------%
VOI    = getfield(load(options.eeg.source.mmnVOI), 'VOI');
radius = options.eeg.source.radius;%mm
usemsp = options.eeg.source.msp;

if usemsp   
    mspJob = compi_msp_job_erp(D, VOI, erpFile, options);
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

D = spm_eeg_load(erpFile);
D = chantype(D, D.indchannel(VOI(:, 1)), 'LFP');
save(D);

%-- create images --------------------------------------------------------%
options.eeg.conversion.space = 'source';
chan = D.indchantype('LFP');
pathStats  = fullfile(details.eeg.erp.source.pathStats, options.eeg.erp.regressors{1});
pfxImages = details.eeg.firstLevel.source.prefixImages;

D = copy(D, pathStats);
D = spm_eeg_load(pathStats);

for i = 1:length(chan)

    stringChannel = char(D.chanlabels(chan(i)));

    S.D = D;
    S.mode = 'time';
    S.conditions = cell(1, 0);
    S.timewin = options.eeg.stats.firstLevelSourceAnalysisWindow;
    S.channels = stringChannel;
    S.prefix = [pfxImages stringChannel '_'];

    [images, ~] = spm_eeg_convert2images(S);

    % and smooth the resulting images
    tnueeg_smooth_images(images, options);
    disp(['Smoothed images for subject ' id]);
    
end

cd(options.roots.results);

diary OFF