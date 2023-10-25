function [ job ] = compi_getjob_2ndlevel_onesample_ttest_cov(facdir, scans, factorName, covars)
%--------------------------------------------------------------------------
% COMPI_GETJOB_2NDLEVEL_ONESAMPLE_TTEST_COV Creates a job for running a
% one-sample t-test on the second level for the effect of factorName.
%   
% The function automatically specifies 3 contrasts (2 t-contrasts for
%   positive and negative effects of factorName, and 1 F-contrast for the
%   overall effect of factorName.
% 
% If covariates are present, 3 additional contrasts (2 t-contrasts and 
%   1 F-contrastare specified for each covariate of interest.
% 
%   IN:     facdir      - directory (string) for saving the SPM.mat
%           scans       - cell array list of image filenames, including paths
%           factorName  - string with a name for the effect
%           covars      - covariates (table) for all subjects
%   OUT:    job         - the job for the 2nd level statistics that can be
%                       run using the spm_jobman
% 
% Adapted from: TNUEEG_GETJOB_2NDLEVEL_ONESAMPLE_TTEST
%--------------------------------------------------------------------------

%% Set up job
% job 1: factorial design
job{1}.spm.stats.factorial_design.dir = {facdir};
job{1}.spm.stats.factorial_design.des.t1.scans = scans;

for i_cov = 1:width(covars)
    job{1}.spm.stats.factorial_design.cov(i_cov).c = (covars.(i_cov));
    job{1}.spm.stats.factorial_design.cov(i_cov).cname = covars.Properties.VariableNames{i_cov};
    job{1}.spm.stats.factorial_design.cov(i_cov).iCFI = 1;
    job{1}.spm.stats.factorial_design.cov(i_cov).iCC = 1;
end


job{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
%job{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});

job{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
job{1}.spm.stats.factorial_design.masking.im = 1;
job{1}.spm.stats.factorial_design.masking.em = {''};
job{1}.spm.stats.factorial_design.globalc.g_omit = 1;
job{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
job{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% job 2: estimate factorial design
job{2}.spm.stats.fmri_est.spmmat(1) = ...
    cfg_dep('Factorial design specification: SPM.mat File', ...
    substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
    substruct('.','spmmat'));
job{2}.spm.stats.fmri_est.write_residuals = 0;
job{2}.spm.stats.fmri_est.method.Classical = 1;

% job 3: specify contrasts
job{3}.spm.stats.con.spmmat(1) = ...
    cfg_dep('Model estimation: SPM.mat File', ...
    substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
    substruct('.','spmmat'));

i_con = 1;

job{3}.spm.stats.con.consess{i_con}.fcon.name = ['Effect of ' factorName];
job{3}.spm.stats.con.consess{i_con}.fcon.weights = [1];
job{3}.spm.stats.con.consess{i_con}.fcon.sessrep = 'none';

job{3}.spm.stats.con.consess{i_con+1}.tcon.name = ['Neg effect of ' factorName];
job{3}.spm.stats.con.consess{i_con+1}.tcon.weights = [-1];
job{3}.spm.stats.con.consess{i_con+1}.tcon.sessrep = 'none';

job{3}.spm.stats.con.consess{i_con+2}.tcon.name = ['Pos effect of ' factorName];
job{3}.spm.stats.con.consess{i_con+2}.tcon.weights = [1];
job{3}.spm.stats.con.consess{i_con+2}.tcon.sessrep = 'none';

% i_con = i_con + 3;

for i_cov = 1:width(covars)

    job{3}.spm.stats.con.consess{i_con}.fcon.name = ['Effect of ' covars.Properties.VariableNames{i_cov}];
    job{3}.spm.stats.con.consess{i_con}.fcon.weights = [(zeros(1, i_cov)) 1];
    job{3}.spm.stats.con.consess{i_con}.fcon.sessrep = 'none';

    job{3}.spm.stats.con.consess{i_con+1}.tcon.name = ['Neg effect of ' covars.Properties.VariableNames{i_cov}];
    job{3}.spm.stats.con.consess{i_con+1}.tcon.weights = [(zeros(1, i_cov)) -1];
    job{3}.spm.stats.con.consess{i_con+1}.tcon.sessrep = 'none';

    job{3}.spm.stats.con.consess{i_con+2}.tcon.name = ['Pos effect of ' covars.Properties.VariableNames{i_cov}];
    job{3}.spm.stats.con.consess{i_con+2}.tcon.weights = [(zeros(1, i_cov)) 1];
    job{3}.spm.stats.con.consess{i_con+2}.tcon.sessrep = 'none';

    i_con = i_con + 3;
end

job{3}.spm.stats.con.delete = 0;

% job 4: print results
job{4}.spm.stats.results.spmmat(1) = ...
    cfg_dep('Contrast Manager: SPM.mat File', ...
    substruct('.','val', '{}',{3}, ...
            '.','val', '{}',{1}, ...
            '.','val', '{}',{1}), ...
            substruct('.','spmmat'));

job{4}.spm.stats.results.conspec.titlestr = '';
job{4}.spm.stats.results.conspec.contrasts = Inf;
job{4}.spm.stats.results.conspec.threshdesc = 'none';
job{4}.spm.stats.results.conspec.thresh = 0.001;
job{4}.spm.stats.results.conspec.extent = 0;
job{4}.spm.stats.results.conspec.mask = ...
    struct('contrasts', {}, 'thresh', {}, 'mtype', {});

job{4}.spm.stats.results.units = 2;
job{4}.spm.stats.results.print = 'pdf';
job{4}.spm.stats.results.write.none = 1;


end