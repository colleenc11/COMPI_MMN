function fileBatch = compi_save_subject_batch(matlabbatch, fileBatch)
% -------------------------------------------------------------------------
% save matlabbatch (job-variable) to .m file
% -------------------------------------------------------------------------

% set up matlabbatch as job
jobId = cfg_util('initjob', matlabbatch);

pathBatch = fileparts(fileBatch);
[~,~] = mkdir(pathBatch);
% write out job
cfg_util('genscript', jobId, pathBatch, fileBatch);
