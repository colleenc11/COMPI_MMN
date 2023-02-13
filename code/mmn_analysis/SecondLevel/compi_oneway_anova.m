function [actual_job] = compi_oneway_anova(imagePaths, scndlvlroot, covars, options)
%-------------------------------------------------------------------
% Computes 2nd level statistics for multiple regression of the 
% EEG signal with single-trial (modelbased) regressors, using a 
% one-way ANOVA.
%
% IN:     imagePaths        - name and path (string) of the beta images
%         scndlvlroot       - directory (string) for saving the SPM.mat
%         covars            - covariates (table) for all subjects
%         options           - the struct that holds all analysis options
% OUT:    --
%-------------------------------------------------------------------

%% Select beta images

% make sure we have a results directory
outputdir = fullfile(scndlvlroot);
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end

%% Prepare ANOVA job
job{1}.spm.stats.factorial_design.dir = {outputdir};

% collect the regressor's beta image from each group
for i_group = 1: numel(options.subjects.group_labels)
    scans = imagePaths(:,i_group);
    job{1}.spm.stats.factorial_design.des.anova.icell(i_group).scans = ...
        scans(~cellfun('isempty',scans));
end

job{1}.spm.stats.factorial_design.des.anova.dept = 0; % 0 = independence
job{1}.spm.stats.factorial_design.des.anova.variance = 1; % 1 = unequal
job{1}.spm.stats.factorial_design.des.anova.gmsca = 0;
job{1}.spm.stats.factorial_design.des.anova.ancova = 0;

% Load covariate
for i_cov = 1:width(covars)
    job{1}.spm.stats.factorial_design.cov(i_cov).c = (covars.(i_cov));
    job{1}.spm.stats.factorial_design.cov(i_cov).cname = covars.Properties.VariableNames{i_cov};
    job{1}.spm.stats.factorial_design.cov(i_cov).iCFI = 2;
    job{1}.spm.stats.factorial_design.cov(i_cov).iCC = 1;
end

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

% Speciffy regressor contrasts
job{3}.spm.stats.con.consess{1}.fcon.name = options.subjects.group_labels{1};
job{3}.spm.stats.con.consess{1}.fcon.convec = [1 0];
job{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
job{3}.spm.stats.con.consess{2}.fcon.name = options.subjects.group_labels{2};
job{3}.spm.stats.con.consess{2}.fcon.convec = [0 1];
job{3}.spm.stats.con.consess{2}.fcon.sessrep = 'none';
job{3}.spm.stats.con.consess{3}.tcon.name = strcat(options.subjects.group_labels{1}, '>', ...
                                                options.subjects.group_labels{2});
job{3}.spm.stats.con.consess{3}.tcon.convec = [1 -1];
job{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
job{3}.spm.stats.con.consess{4}.tcon.name = strcat(options.subjects.group_labels{1}, '<', ...
                                                options.subjects.group_labels{2});
job{3}.spm.stats.con.consess{4}.tcon.convec = [-1 1];
job{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

% Speciffy covariate t-contrasts
for i_cov = 1:width(covars)
    i_zero = times(2, i_cov); % zero padding for contrast
    i_con1 = (4 + i_cov); % contrast number

    job{3}.spm.stats.con.consess{i_con1}.tcon.name = ...
            [strcat(covars.Properties.VariableNames{i_cov}, ': ', ...
            options.subjects.group_labels{1}, '>', ...
            options.subjects.group_labels{2})];

    job{3}.spm.stats.con.consess{i_con1}.tcon.weights = [(zeros(1, i_zero)) 1 -1];
    job{3}.spm.stats.con.consess{i_con1}.tcon.sessrep = 'none';
end

for i_cov = 1:width(covars)
    i_zero = times(2, i_cov); % zero padding for contrast
    i_con2 = (i_con1 + i_cov); % contrast number

    job{3}.spm.stats.con.consess{i_con2}.tcon.name = ...
            [strcat(covars.Properties.VariableNames{i_cov}, ': ', ...
            options.subjects.group_labels{1}, '<', ...
            options.subjects.group_labels{2})];

    job{3}.spm.stats.con.consess{i_con2}.tcon.weights = [(zeros(1, i_zero)) -1 1];
    job{3}.spm.stats.con.consess{i_con2}.tcon.sessrep = 'none';
end

% Speciffy covariate f-contrasts
for i_cov = 1:width(covars)
    i_zero = times(2, i_cov); % zero padding for contrast
    i_con3 = (i_con2 + i_cov); % contrast number
    job{3}.spm.stats.con.consess{i_con3}.fcon.name = ['Effect of ' covars.Properties.VariableNames{i_cov}];
    job{3}.spm.stats.con.consess{i_con3}.fcon.weights = [(zeros(1, i_zero)) 1 1];
    job{3}.spm.stats.con.consess{i_con3}.fcon.sessrep = 'none';
end


job{3}.spm.stats.con.delete = 1;

job{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}), substruct('.','spmmat'));
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

% Which modules really to include?
actual_job = {job{1},job{2},job{3},job{4}};


return;