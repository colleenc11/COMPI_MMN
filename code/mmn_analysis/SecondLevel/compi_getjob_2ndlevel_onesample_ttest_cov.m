function [ job ] = compi_getjob_2ndlevel_onesample_ttest_cov(facdir, scans, factorName, covars)
%TNUEEG_GETJOB_2NDLEVEL_ONESAMPLE_TTEST Creates a job for running a
%one-sample t-test on the second level for the effect of factorName.
%   The function automatically specifies 3 contrasts (2 t-contrasts for
%   positive and negative effects of factorName, and 1 F-contrast for the
%   overall effect of factorName.
%   IN:     facdir      - directory (string) for saving the SPM.mat
%           scans       - cell array list of image filenames, including paths
%           factorName  - string with a name for the effect
%           covars      - covariates (table) for all subjects
%           options     - the struct that holds all analysis options
%   OUT:    job         - the job for the 2nd level statistics that can be
%                       run using the spm_jobman

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
job{3}.spm.stats.con.consess{1}.tcon.name = [factorName '_pos'];
job{3}.spm.stats.con.consess{1}.tcon.weights = [1]; % change from [1 0] for condition_noCov - may pose problem for covariates
job{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
job{3}.spm.stats.con.consess{2}.tcon.name = [factorName '_neg'];
job{3}.spm.stats.con.consess{2}.tcon.weights = [-1];
job{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
job{3}.spm.stats.con.consess{3}.fcon.name = ['Effect of ' factorName];
job{3}.spm.stats.con.consess{3}.fcon.weights = [1];
job{3}.spm.stats.con.consess{3}.fcon.sessrep = 'none';

for i_cov = 1:width(covars)
    i_con = (3 + i_cov); % contrast number
    job{3}.spm.stats.con.consess{i_con}.tcon.name = ['Effect of ' covars.Properties.VariableNames{i_cov} ' neg'];
    job{3}.spm.stats.con.consess{i_con}.tcon.weights = [(zeros(1, i_cov)) -1];
    job{3}.spm.stats.con.consess{i_con}.tcon.sessrep = 'none';
        
    job{3}.spm.stats.con.consess{i_con+1}.tcon.name = ['Effect of ' covars.Properties.VariableNames{i_cov} ' pos'];
    job{3}.spm.stats.con.consess{i_con+1}.tcon.weights = [(zeros(1, i_cov)) 1];
    job{3}.spm.stats.con.consess{i_con+1}.tcon.sessrep = 'none';
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