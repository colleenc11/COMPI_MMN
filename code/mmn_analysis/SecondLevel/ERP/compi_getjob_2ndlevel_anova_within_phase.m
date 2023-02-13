function [ job ] = compi_getjob_2ndlevel_anova_within_phase(facdir, pairs, factorName, labels)
%TNUEEG_GETJOB_2NDLEVEL_ANOVA_WITHIN Creates a job for running a within-subject ANOVA on the 2nd 
%level. No contrasts are predefined as these depend on the research question.
%   IN:     facdir      - directory (string) for saving the SPM.mat
%           subjects    - cell struct with nSubjects entries and a substruct field 'scans' 
%                       (subjects(iSub).scans) specifying the paths and names of the images for 
%                       each subject in each condition. nConditions will be read from the number
%                       of scans in the first subject.
%   OUT:    job         - the job for the 2nd level statistics that can be run using the spm_jobman

% make sure we have a results directory
outputdir = fullfile(facdir);
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end

% Initialize
spm('defaults', 'EEG');
spm_jobman('initcfg');

%% Prepare ANOVA job

nConditions = length(pairs(1).scans);

% job 1: factorial design
job{1}.spm.stats.factorial_design.dir = {facdir};

for iSub = 1: length(pairs)
    job{1}.spm.stats.factorial_design.des.anovaw.fsubject(iSub).scans = pairs(iSub).scans;
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

% job 3: specify contrasts
job{3}.spm.stats.con.spmmat(1) = ...
    cfg_dep('Model estimation: SPM.mat File', ...
    substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
    substruct('.','spmmat'));

% standStab > standVol
job{3}.spm.stats.con.consess{1}.tcon.name = [factorName ': ' labels{1} ' > ' labels{2}];
job{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0];
job{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
% standStab < standVol
job{3}.spm.stats.con.consess{2}.tcon.name = [factorName ': ' labels{1} ' < ' labels{2}];
job{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1 0 0];
job{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
% devStab > devVol
job{3}.spm.stats.con.consess{3}.tcon.name = [factorName ': ' labels{3} ' > ' labels{4}];
job{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 -1];
job{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
% devStab < devVol
job{3}.spm.stats.con.consess{4}.tcon.name = [factorName ': ' labels{3} ' < ' labels{4}];
job{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 -1 1];
job{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
% standStab > devStab
job{3}.spm.stats.con.consess{5}.tcon.name = [factorName ': ' labels{1} ' > ' labels{3}];
job{3}.spm.stats.con.consess{5}.tcon.weights = [1 0 -1 0];
job{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
% standStab < devStab
job{3}.spm.stats.con.consess{6}.tcon.name = [factorName ': ' labels{1} ' < ' labels{3}];
job{3}.spm.stats.con.consess{6}.tcon.weights = [-1 0 1 0];
job{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
% standVol > devVol
job{3}.spm.stats.con.consess{7}.tcon.name = [factorName ': ' labels{2} ' > ' labels{4}];
job{3}.spm.stats.con.consess{7}.tcon.weights = [0 1 0 -1];
job{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
% standVol < devVol
job{3}.spm.stats.con.consess{8}.tcon.name = [factorName ': ' labels{2} ' < ' labels{4}];
job{3}.spm.stats.con.consess{8}.tcon.weights = [0 -1 0 1];
job{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';

job{3}.spm.stats.con.delete = 0;

% job 4: print results
job{4}.spm.stats.results.spmmat(1) = ...
    cfg_dep('Contrast Manager: SPM.mat File', ...
    substruct('.','val', '{}',{3}, ...
            '.','val', '{}',{1}, ...
            '.','val', '{}',{1}), ...
            substruct('.','spmmat'));

job{4}.spm.stats.results.conspec(1).titlestr = '';
job{4}.spm.stats.results.conspec(1).contrasts = 1;
job{4}.spm.stats.results.conspec(1).threshdesc = 'none';
job{4}.spm.stats.results.conspec(1).thresh = 0.001;
job{4}.spm.stats.results.conspec(1).extent = 0;
job{4}.spm.stats.results.conspec(1).mask = ...
    struct('contrasts', {}, 'thresh', {}, 'mtype', {});

job{4}.spm.stats.results.conspec(2).titlestr = '';
job{4}.spm.stats.results.conspec(2).contrasts = 2;
job{4}.spm.stats.results.conspec(2).threshdesc = 'none';
job{4}.spm.stats.results.conspec(2).thresh = 0.001;
job{4}.spm.stats.results.conspec(2).extent = 0;
job{4}.spm.stats.results.conspec(2).mask = ...
    struct('contrasts', {}, 'thresh', {}, 'mtype', {});

job{4}.spm.stats.results.units = 2;
job{4}.spm.stats.results.print = 'pdf';
job{4}.spm.stats.results.write.none = 1;

end
