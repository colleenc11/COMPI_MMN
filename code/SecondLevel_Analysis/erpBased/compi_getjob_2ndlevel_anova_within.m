function [ job ] = compi_getjob_2ndlevel_anova_within(facdir, pairs, factorName, label1, label2)
%--------------------------------------------------------------------------
% COMPI_GETJOB_2NDLEVEL_ANOVA_WITHIN Creates a job for running a 
% within-subject ANOVA on the 2nd level. Performs two t-contrasts comparing
% label1 vs. label2
%   IN:     facdir      - directory (string) for saving the SPM.mat
%           pairs       - cell struct with nSubjects entries and substruct 
%                       field 'scans' (subjects(iSub).scans) specifying the
%                       paths and names of the images for each subject in
%                       each condition. nConditions will be read from the
%                       number of scans in the first subject. 
%           factorName  - a string with the name of the factor 
%           label1      - name of first condition
%           label2      - name of second condition
%   OUT:    job         - job for the 2nd level statistics
% 
% Adapted from TNUEEG_GETJOB_2NDLEVEL_ANOVA_WITHIN
%--------------------------------------------------------------------------
% make sure we have a results directory
outputdir = fullfile(facdir);
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end

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
job{3}.spm.stats.con.consess{1}.tcon.name = [factorName ': ' label1 ' > ' label2];
job{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
job{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
job{3}.spm.stats.con.consess{2}.tcon.name = [factorName ': ' label1 ' < ' label2];
job{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
job{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
job{3}.spm.stats.con.delete = 0;

% job 4: print results
job{4}.spm.stats.results.spmmat(1) = ...
    cfg_dep('Contrast Manager: SPM.mat File', ...
    substruct('.','val', '{}',{3}, ...
            '.','val', '{}',{1}, ...
            '.','val', '{}',{1}), ...
            substruct('.','spmmat'));

for i = 1:length(job{3}.spm.stats.con.consess)
    job{4}.spm.stats.results.conspec(i).titlestr = '';
    job{4}.spm.stats.results.conspec(i).contrasts = i;
    job{4}.spm.stats.results.conspec(i).threshdesc = 'none';
    job{4}.spm.stats.results.conspec(i).thresh = 0.001;
    job{4}.spm.stats.results.conspec(i).extent = 0;
    job{4}.spm.stats.results.conspec(i).mask = ...
        struct('contrasts', {}, 'thresh', {}, 'mtype', {});
end

job{4}.spm.stats.results.units = 2;
job{4}.spm.stats.results.print = 'pdf';
job{4}.spm.stats.results.write.none = 1;

end

