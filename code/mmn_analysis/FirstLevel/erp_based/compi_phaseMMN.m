function compi_phaseMMN(id, options)

%% Get subject details
details = compi_get_subject_details(id, options); % subject-specific information


%-- preparation -------------------------------------------------------------------------------%
% prepare spm
spm('defaults', 'EEG');

label = 'oddball_phases';

stableMMN = fullfile(details.eeg.erp.root, label, 'sensor_diff_stable_oddball_phases', 'condition_mmn.nii,1');
volatileMMN = fullfile(details.eeg.erp.root, label, 'sensor_diff_volatile_oddball_phases', 'condition_mmn.nii,1');

% make sure we have a results directory
outputDir = fullfile(details.eeg.erp.root, label, 'sensor_phaseMMN');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end 

cd(outputDir);

%-----------------------------------------------------------------------
% Job saved on 08-Jun-2023 11:50:38 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
job{1}.spm.util.imcalc.input = {stableMMN
                                volatileMMN};
job{1}.spm.util.imcalc.output = 'phaseMMN';
job{1}.spm.util.imcalc.outdir = outputDir;
job{1}.spm.util.imcalc.expression = 'i1 - i2';
job{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
job{1}.spm.util.imcalc.options.dmtx = 0;
job{1}.spm.util.imcalc.options.mask = 0;
job{1}.spm.util.imcalc.options.interp = 1;
job{1}.spm.util.imcalc.options.dtype = 4;

spm_jobman('run', job);

% and smooth the resulting images

imageFile = fullfile(outputDir, 'phaseMMN.nii,1');

job_smooth{1}.spm.spatial.smooth.data = {imageFile};
job_smooth{1}.spm.spatial.smooth.fwhm = [16 16 0];
job_smooth{1}.spm.spatial.smooth.dtype = 0;
job_smooth{1}.spm.spatial.smooth.im = 0;
job_smooth{1}.spm.spatial.smooth.prefix = 'smoothed_';

spm_jobman('run', job_smooth);

disp(['Smoothed images for subject ' id]);

end
