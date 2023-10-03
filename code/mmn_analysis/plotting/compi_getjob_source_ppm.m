function matlabbatch = compi_getjob_source_ppm(timewindow, scans)
%-----------------------------------------------------------------------
% Job saved on 11-Sep-2023 12:31:15 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.meeg.source.results.D = scans;
matlabbatch{1}.spm.meeg.source.results.val = 1;
matlabbatch{1}.spm.meeg.source.results.woi = timewindow;
matlabbatch{1}.spm.meeg.source.results.foi = [0 0];
matlabbatch{1}.spm.meeg.source.results.ctype = 'evoked';
matlabbatch{1}.spm.meeg.source.results.space = 1;
matlabbatch{1}.spm.meeg.source.results.format = 'image';
matlabbatch{1}.spm.meeg.source.results.smoothing = 8;