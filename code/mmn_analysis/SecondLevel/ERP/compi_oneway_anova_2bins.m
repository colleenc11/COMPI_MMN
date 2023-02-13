function [job] = compi_oneway_anova_2bins(imagePaths, scndlvlroot, covars, options)
%-------------------------------------------------------------------
% Description.
%-------------------------------------------------------------------



%% Job 1: Anova
job{1}.spm.stats.factorial_design.dir = {scndlvlroot};

for iSet = 1: length(imagePaths(1,:))

    scans = imagePaths(:,iSet);

    job{1}.spm.stats.factorial_design.des.anova.icell(iSet).scans = ...
        scans(~cellfun('isempty',scans));

end

job{1}.spm.stats.factorial_design.des.anova.dept = 0; % 0 = independence
job{1}.spm.stats.factorial_design.des.anova.variance = 1; % 1 = unequal
job{1}.spm.stats.factorial_design.des.anova.gmsca = 0;
job{1}.spm.stats.factorial_design.des.anova.ancova = 0;

% Load covariate
% for i_cov = 1:length(options.eeg.covar.all)
%     job{1}.spm.stats.factorial_design.cov(i_cov).c = ([covars.(i_cov); covars.(i_cov)]);
%     job{1}.spm.stats.factorial_design.cov(i_cov).cname = covars.Properties.VariableNames{i_cov};
%     job{1}.spm.stats.factorial_design.cov(i_cov).iCFI = 2;
%     job{1}.spm.stats.factorial_design.cov(i_cov).iCC = 1;
% end

job{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
   
job{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
job{1}.spm.stats.factorial_design.masking.im = 1;
job{1}.spm.stats.factorial_design.masking.em = {''};

job{1}.spm.stats.factorial_design.globalc.g_omit = 1;
job{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
job{1}.spm.stats.factorial_design.globalm.glonorm = 1;

job{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
job{2}.spm.stats.fmri_est.write_residuals = 0;
job{2}.spm.stats.fmri_est.method.Classical = 1;
job{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}), substruct('.','spmmat'));

%% Speciffy contrasts

%%% PHASE %%%
job{3}.spm.stats.con.consess{1}.fcon.name = 'Stable';
job{3}.spm.stats.con.consess{1}.fcon.convec = [1 0];
job{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
job{3}.spm.stats.con.consess{2}.fcon.name = ['Volatile'];
job{3}.spm.stats.con.consess{2}.fcon.convec = [0 1];
job{3}.spm.stats.con.consess{2}.fcon.sessrep = 'none';

%%% PHASE COMPARISON %%%
job{3}.spm.stats.con.consess{3}.tcon.name = 'Stable>Volatile';
job{3}.spm.stats.con.consess{3}.tcon.convec = [1 -1];
job{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
job{3}.spm.stats.con.consess{4}.tcon.name = 'Stable<Volatile';
job{3}.spm.stats.con.consess{4}.tcon.convec = [-1 1];
job{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

%%% COVARIATES %%%
% job{3}.spm.stats.con.consess{5}.fcon.name = 'Age';
% job{3}.spm.stats.con.consess{5}.fcon.convec = [0 0 1];
% job{3}.spm.stats.con.consess{5}.fcon.sessrep = 'none';

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