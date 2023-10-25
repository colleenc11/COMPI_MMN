function D = compi_source_erp(id, options)
% -------------------------------------------------------------------------
% COMPI_SOURCE_ERP Create headmodel and extracts sources based on fMRI 
% priors or MSP for averaged ERP data. 
%
% IN
%   id          subject id string, only number (e.g. '0101')
%   options     general analysis options
%               options = compi_mmn_options;
% 
% OUT
%   D           Data structure of SPM EEG Analysis
% -------------------------------------------------------------------------

%% Initalize paths and files
details = compi_get_subject_details(id, options);

% Record what we're doing
diary(details.eeg.logfile);
tnueeg_display_analysis_step_header('erp_source_analysis', 'compi', id, options.eeg.source);

% File paths
design = options.eeg.stats.design;
inputFile = fullfile(details.eeg.erp.root, design, ['diff_' design '.mat']);
outputFile = fullfile(details.eeg.erp.root, design, ['B_diff_' design '.mat']);

% Load erp file
try
    D = spm_eeg_load(inputFile);
catch
    error('ERP file is missing for subject %s. Generate ERP data using compi_erp.\n', id);
end

%% Headmodel 

% Locations of the fiducials
fid = details.eeg.fid;

% Create and run job to define a headmodel
hmJob = compi_headmodel_job(D, fid, details, options);
spm_jobman('run', hmJob);
D = reload(D);

%% Source analysis 
VOI    = getfield(load(options.eeg.source.VOI), 'VOI');
 
mspJob = compi_msp_job(D, VOI, outputFile, options);
spm_jobman('run', mspJob);    

D = spm_eeg_load(outputFile);
D = chantype(D, D.indchannel(VOI(:, 1)), 'LFP');
save(D);

%% Create images 
options.eeg.conversion.space = 'source';
chan = D.indchantype('LFP');

pathStats  = fullfile(details.eeg.erp.source.pathStats, options.eeg.stats.design);

pfxImages = details.eeg.firstLevel.source.prefixImages;

D = copy(D, pathStats);
D = spm_eeg_load(pathStats);

for i = 1:length(chan)

    stringChannel = char(D.chanlabels(chan(i)));

    S.D          = D;
    S.mode       = 'time';
    S.conditions = cell(1, 0);
    S.timewin    = options.eeg.source.firstLevelAnalysisWindow;
    S.channels   = stringChannel;
    S.prefix     = [pfxImages stringChannel '_'];

    [images, ~]  = spm_eeg_convert2images(S);

    % and smooth the resulting images
    tnueeg_smooth_images(images, options);
    disp(['Smoothed images for subject ' id]);
    
end

cd(options.roots.results);
diary OFF
end