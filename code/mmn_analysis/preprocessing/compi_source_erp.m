function D = compi_source_erp(id, options, doVisualize)
% -------------------------------------------------------------------------
% COMPI_SOURCE_ERP Create headmodel and extracts sources based on fMRI 
% priors or MSP for averaged ERP data. 
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

% add some additional functions for beamforming
if nargin<3
    doVisualize = false;
end

% record what we're doing
diary(details.eeg.source.logfile);
tnueeg_display_analysis_step_header('source analysis', 'compi', id, options.eeg.source);

switch options.eeg.stats.design
    case 'oddball'
        inputFile      = fullfile(details.eeg.erp.root, 'oddball', ['diff_oddball.mat']);
        outputFile     = fullfile(details.eeg.erp.root, 'oddball', ['B_diff_oddball.mat']);
        % inputFile      = fullfile(details.eeg.erp.root, 'oddball', ['oddball.mat']);
        % outputFile     = fullfile(details.eeg.erp.root, 'oddball', ['B_oddball.mat']);
    case 'oddball_stable'
        inputFile      = fullfile(details.eeg.erp.root, 'oddball_stable', ['diff_oddball_stable.mat']);
        outputFile     = fullfile(details.eeg.erp.root, 'oddball_stable', ['B_diff_oddball_stable.mat']);
    
    case 'oddball_volatile'
        inputFile      = fullfile(details.eeg.erp.root, 'oddball_volatile', ['diff_oddball_volatile.mat']);
        outputFile     = fullfile(details.eeg.erp.root, 'oddball_volatile', ['B_diff_oddball_volatile.mat']);

    case 'delta1'
        inputFile      = fullfile(details.eeg.erp.root, 'delta1', ['diff_delta1.mat']);
        outputFile     = fullfile(details.eeg.erp.root, 'delta1', ['B_diff_delta1.mat']);        
end

% load erp file
try
    D = spm_eeg_load(inputFile);
catch
    D = compi_erp(id, options);
end

%-- headmodel ------------------------------------------------------------%
fid = details.eeg.fid;
hmJob = dmpad_headmodel_job(D, fid, details, options);
spm_jobman('run', hmJob);
D = reload(D);


%-- source analysis ------------------------------------------------------%
VOI    = getfield(load(options.eeg.source.VOI), 'VOI');
usemsp = options.eeg.source.msp;

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

D = spm_eeg_load(outputFile);
D = chantype(D, D.indchannel(VOI(:, 1)), 'LFP');
save(D);

%-- create images --------------------------------------------------------%
options.eeg.conversion.space = 'source';
chan = D.indchantype('LFP');

switch options.eeg.stats.design
    case 'oddball'
       pathStats  = fullfile(details.eeg.erp.source.pathStats, [options.eeg.stats.regressors{1} '_stdev']);
    case 'oddball_stable'
       pathStats  = fullfile(details.eeg.erp.source.pathStats, 'oddball_stable_stdev');
    case 'oddball_volatile'
       pathStats  = fullfile(details.eeg.erp.source.pathStats, 'oddball_volatile_stdev');
    case 'delta1'
       pathStats  = fullfile(details.eeg.erp.source.pathStats, 'delta1');
end

pfxImages = details.eeg.firstLevel.source.prefixImages;

D = copy(D, pathStats);
D = spm_eeg_load(pathStats);

for i = 1:length(chan)

    stringChannel = char(D.chanlabels(chan(i)));

    S.D = D;
    S.mode = 'time';
    S.conditions = cell(1, 0);
    S.timewin = options.eeg.source.firstLevelAnalysisWindow;
    S.channels = stringChannel;
    S.prefix = [pfxImages stringChannel '_'];

    [images, ~] = spm_eeg_convert2images(S);

    % and smooth the resulting images
    tnueeg_smooth_images(images, options);
    disp(['Smoothed images for subject ' id]);
    
end

cd(options.roots.results);

diary OFF