function compi_grand_average_source_inversion(tPoint, factor, options)
% -------------------------------------------------------------------------
% COMPI_GRAND_AVERAGE_SOURCE_INVERSION Create and run a job for MSP source 
% reconstruction for grand-averaged ERP data. This includes creating a head 
% model and extracting a posterior parametric map based on a specified time 
% point (saved as an image)
% 
%   IN:     tPoint          Peak time point in milliseconds (integer)
%           factor          Name of factor to plot (string) 
%           options         Options structure as set by compi_mmn_options()
% -------------------------------------------------------------------------

%% headmodel

%  load FID from one example subject (for head model)
id = '0101';
details = compi_get_subject_details(id, options);
fid = details.eeg.fid;

% load grand-averaged ERP file
gaFile      = fullfile(options.roots.erp, options.condition, factor, 'GA', ['GA_' factor]);
D           = spm_eeg_load(gaFile);

% create a head model
hmJob = compi_headmodel_job(D, fid, details, options);
spm_jobman('run', hmJob);
D = reload(D);
clear job;

%% source inversion

% source locations
VOI         = getfield(load(options.eeg.source.VOI), 'VOI');
coordinates = cell2mat(VOI(:,2));

% create job for source inversion
job{1}.spm.meeg.source.invert.D                                     = {fullfile(D)};
job{1}.spm.meeg.source.invert.val                                   = 1;
job{1}.spm.meeg.source.invert.whatconditions.all                    = 1;
job{1}.spm.meeg.source.invert.isstandard.custom.invtype             = options.eeg.source.invtype;
job{1}.spm.meeg.source.invert.isstandard.custom.woi                 = [-Inf Inf];
job{1}.spm.meeg.source.invert.isstandard.custom.foi                 = options.eeg.source.freqOfInterest;
job{1}.spm.meeg.source.invert.isstandard.custom.hanning             = 1;
job{1}.spm.meeg.source.invert.isstandard.custom.priors.priorsmask   = options.eeg.source.priorsmask;
job{1}.spm.meeg.source.invert.isstandard.custom.priors.space        = 1;
job{1}.spm.meeg.source.invert.isstandard.custom.restrict.locs       = coordinates; % matrix of source locations
job{1}.spm.meeg.source.invert.isstandard.custom.restrict.radius     = options.eeg.source.radiusInvert;
job{1}.spm.meeg.source.invert.modality = {'EEG'};

% create job to create an image (.nii) from posterior parametric map
job{2}.spm.meeg.source.results.D            = {fullfile(D)};
job{2}.spm.meeg.source.results.val          = 1;
job{2}.spm.meeg.source.results.woi          = [tPoint tPoint];
job{2}.spm.meeg.source.results.foi          = [0 0]; % frequency of interest
job{2}.spm.meeg.source.results.ctype        = 'evoked';
job{2}.spm.meeg.source.results.space        = 1;
job{2}.spm.meeg.source.results.format       = 'image';
job{2}.spm.meeg.source.results.smoothing    = 8;

% run job
spm_jobman('run', job);

% save PPM as an image
outputFigurePath = fullfile(options.roots.paper_fig, [factor '_sourcePPM_' num2str(tPoint) 'ms']);
saveas(gcf, outputFigurePath, 'jpg');

end