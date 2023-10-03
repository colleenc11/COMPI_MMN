function [job] = compi_msp_job(D, VOI, outputFile, options)
% -------------------------------------------------------------------------
% COMPI_MSP_JOB Create job for MSP source reconstruction and extraction of 
% sources.
% IN
%   D           data structure of SPM EEG Analysis
%   VOI         coordinates of sources to extract
%   outputFile  output file name
%   options     general analysis options - options = compi_mmn_options();
% OUT
%   job         spm job for source reconstruction and extraction
% -------------------------------------------------------------------------

% source locations
coordinates = cell2mat(VOI(:,2));

% source inversion
job{1}.spm.meeg.source.invert.D = {fullfile(D)};
job{1}.spm.meeg.source.invert.val = 1;
job{1}.spm.meeg.source.invert.whatconditions.all = 1;
job{1}.spm.meeg.source.invert.isstandard.custom.invtype = options.eeg.source.invtype;
job{1}.spm.meeg.source.invert.isstandard.custom.woi = [-Inf Inf];
job{1}.spm.meeg.source.invert.isstandard.custom.foi = options.eeg.source.freqOfInterest;
job{1}.spm.meeg.source.invert.isstandard.custom.hanning = 1;
job{1}.spm.meeg.source.invert.isstandard.custom.priors.priorsmask = options.eeg.source.priorsmask;
job{1}.spm.meeg.source.invert.isstandard.custom.priors.space = 1;
job{1}.spm.meeg.source.invert.isstandard.custom.restrict.locs = coordinates; % matrix of source locations
job{1}.spm.meeg.source.invert.isstandard.custom.restrict.radius = options.eeg.source.radiusInvert; %32
job{1}.spm.meeg.source.invert.modality = {'EEG'};

% source extraction
job{2}.spm.meeg.source.extract.D(1) = cfg_dep('Source inversion: M/EEG dataset(s) after imaging source reconstruction', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','D'));
job{2}.spm.meeg.source.extract.val = 1;

for i = 1:size(VOI, 1)
    job{2}.spm.meeg.source.extract.source(i).label = VOI{i, 1};
    job{2}.spm.meeg.source.extract.source(i).xyz = VOI{i, 2};
end

job{2}.spm.meeg.source.extract.rad = options.eeg.source.radiusExtract; %16
job{2}.spm.meeg.source.extract.type = 'trials';
job{2}.spm.meeg.source.extract.fname = outputFile;

end