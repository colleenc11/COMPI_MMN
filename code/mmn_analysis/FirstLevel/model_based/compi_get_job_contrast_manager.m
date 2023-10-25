function job = compi_get_job_contrast_manager(idDependency, type)
% -------------------------------------------------------------------------
%Creates contrast report job
% -------------------------------------------------------------------------

job.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{idDependency}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
job.spm.stats.results.conspec.titlestr = '';
job.spm.stats.results.conspec.contrasts = 1;
job.spm.stats.results.conspec.threshdesc = 'none';
job.spm.stats.results.conspec.thresh = 0.05;
job.spm.stats.results.conspec.extent = 0;
job.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
job.spm.stats.results.print = false;
job.spm.stats.results.export = {};
% job.spm.stats.results.write.none = 1;
switch lower(type)
    case 'sensor'
        job.spm.stats.results.units = 2;
    otherwise
        job.spm.stats.results.units = 4;
end

end