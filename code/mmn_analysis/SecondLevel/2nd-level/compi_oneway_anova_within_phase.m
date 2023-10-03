function [job] = compi_oneway_anova_within_phase(facdir, subjects)
%-------------------------------------------------------------------
%TNUEEG_GETJOB_2NDLEVEL_ANOVA_WITHIN Creates a job for running a within-subject ANOVA on the 2nd 
%level. No contrasts are predefined as these depend on the research question.
%   IN:     facdir      - directory (string) for saving the SPM.mat
%           subjects    - cell struct with nSubjects entries and a substruct field 'scans' 
%                       (subjects(iSub).scans) specifying the paths and names of the images for 
%                       each subject in each condition. nConditions will be read from the number
%                       of scans in the first subject.
%   OUT:    job         - the job for the 2nd level statistics that can be run using the spm_jobman
%-------------------------------------------------------------------

%% Job: Anova Within
nSubjects = numel(subjects);
nConditions = numel(subjects(1).scans);

% job 1: factorial design
job{1}.spm.stats.factorial_design.dir = {facdir};

for iSub = 1: nSubjects
    job{1}.spm.stats.factorial_design.des.anovaw.fsubject(iSub).scans = subjects(iSub).scans;
    job{1}.spm.stats.factorial_design.des.anovaw.fsubject(iSub).conds = 1: nConditions;
end

job{1}.spm.stats.factorial_design.des.anovaw.dept = 1;
job{1}.spm.stats.factorial_design.des.anovaw.variance = 1;
job{1}.spm.stats.factorial_design.des.anovaw.gmsca = 0;
job{1}.spm.stats.factorial_design.des.anovaw.ancova = 0;

job{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
job{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
job{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
job{1}.spm.stats.factorial_design.masking.im = 1;
job{1}.spm.stats.factorial_design.masking.em = {''};
job{1}.spm.stats.factorial_design.globalc.g_omit = 1;
job{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
job{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% job 2: estimate SPM
job{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', ...
    substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
    substruct('.','spmmat'));
job{2}.spm.stats.fmri_est.write_residuals = 0;
job{2}.spm.stats.fmri_est.method.Classical = 1;


% job 3: Speciffy contrasts
job{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}), substruct('.','spmmat'));
 
% %%% PHASE COMPARISON %%%
job{3}.spm.stats.con.consess{1}.tcon.name = 'Stable1>Volatile';
job{3}.spm.stats.con.consess{1}.tcon.convec = [1 -1 0];
job{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
job{3}.spm.stats.con.consess{2}.tcon.name = 'Stable1<Volatile';
job{3}.spm.stats.con.consess{2}.tcon.convec = [-1 1 0];
job{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

job{3}.spm.stats.con.consess{3}.tcon.name = 'Stable1>Stable2';
job{3}.spm.stats.con.consess{3}.tcon.convec = [1 0 -1];
job{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
job{3}.spm.stats.con.consess{4}.tcon.name = 'Stable1<Stable2';
job{3}.spm.stats.con.consess{4}.tcon.convec = [-1 0 1];
job{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

job{3}.spm.stats.con.consess{5}.tcon.name = 'Volatile>Stable2';
job{3}.spm.stats.con.consess{5}.tcon.convec = [0 1 -1];
job{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
job{3}.spm.stats.con.consess{6}.tcon.name = 'Volatile<Stable2';
job{3}.spm.stats.con.consess{6}.tcon.convec = [0 -1 1];
job{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';

%%% PHASE %%%
% job{3}.spm.stats.con.consess{7}.fcon.name = 'Stable1';
% job{3}.spm.stats.con.consess{7}.fcon.convec = [1 0 0];
% job{3}.spm.stats.con.consess{7}.fcon.sessrep = 'none';
% job{3}.spm.stats.con.consess{8}.fcon.name = ['Volatile'];
% job{3}.spm.stats.con.consess{8}.fcon.convec = [0 1 0];
% job{3}.spm.stats.con.consess{8}.fcon.sessrep = 'none';
% job{3}.spm.stats.con.consess{9}.fcon.name = 'Stable2';
% job{3}.spm.stats.con.consess{9}.fcon.convec = [0 0 1];
% job{3}.spm.stats.con.consess{9}.fcon.sessrep = 'none';

job{3}.spm.stats.con.delete = 1;
job{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
job{4}.spm.stats.results.conspec.titlestr = '';
job{4}.spm.stats.results.conspec.contrasts = Inf;
job{4}.spm.stats.results.conspec.threshdesc = 'none';
job{4}.spm.stats.results.conspec.thresh = 0.001;
job{4}.spm.stats.results.conspec.extent = 0;
job{4}.spm.stats.results.conspec.conjunction = 1;
job{4}.spm.stats.results.conspec.mask.none = 1;
job{4}.spm.stats.results.units = 2;
job{4}.spm.stats.results.print = 'pdf';
job{4}.spm.stats.results.write.none = 1;

return;