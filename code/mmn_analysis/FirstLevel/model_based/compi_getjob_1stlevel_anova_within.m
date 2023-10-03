function [ job ] = compi_getjob_1stlevel_anova_within(id, factors, options)
%TNUEEG_GETJOB_2NDLEVEL_ANOVA_WITHIN Creates a job for running a within-subject ANOVA on the 2nd 
%level. No contrasts are predefined as these depend on the research question.
%   IN:     facdir      - directory (string) for saving the SPM.mat
%           subjects    - cell struct with nSubjects entries and a substruct field 'scans' 
%                       (subjects(iSub).scans) specifying the paths and names of the images for 
%                       each subject in each condition. nConditions will be read from the number
%                       of scans in the first subject.
%   OUT:    job         - the job for the 2nd level statistics that can be run using the spm_jobman


details = compi_get_subject_details(id, options); % subject-specific information

fileDesignMatrix = fullfile(details.dirs.preproc, 'design_Pruned.mat');

fileToLoad = details.eeg.prepfile;
stringRerunFunction = 'dmpad_preprocessing_eyeblink_correction';
pathImages  = details.eeg.firstLevel.sensor.pathImages;
pathStats   = fullfile(details.eeg.firstLevel.sensor.pathStats, factors{1});
analysisWindow = options.eeg.stats.firstLevelAnalysisWindow;
switch options.eeg.preproc.smoothing
    case 'yes'
        fileImage   = details.eeg.conversion.sensor.smoofile;
    case 'no'
        fileImage   = details.eeg.firstLevel.sensor.fileImage;
end

if exist(fileToLoad, 'file')
    D = spm_eeg_load(fileToLoad);
else
    error(sprintf(...
        ['EEG data not found \n\tfile: %s\nCannot perform single subject stats.\n', ...
        'Please run preprocessing again, starting from %s!\n'], ...
        fileToLoad, stringRerunFunction))
end

%% delete existing SPM folder and create non-existing one
fileSpm     = fullfile(pathStats, 'SPM.mat');

if exist(fileSpm, 'file')
    delete(fileSpm);
else
    if ~exist(pathStats, 'dir')
        res = mkdir(pathStats);
    end
end

design = getfield(load(fileDesignMatrix), 'design');


%% Set up GLM design and estimate job
% Preparation
spm('defaults', 'eeg');
spm_jobman('initcfg');

job = {};

iJobFactorialDesign = 1;
i_st = 0;
i_vo = 0;
for i=1:size(design.phase,1)
    if design.phase{i} = 0 % stable
        i_st += 1
        scans{1, i_st}=[fileImage ',' num2str(i)];
    elseif design.phase{i} = 1 % volatile
        i_vo += 1
        scans{2, i_vo}=[fileImage ',' num2str(i)];
    end
end

job{iJobFactorialDesign}.spm.stats.factorial_design.des.scans = scans;
job{iJobFactorialDesign}.spm.stats.factorial_design.des.anovaw.conds = 2;

iJobFcon = iJobFactorialDesign + 2;

%% Factorial design specification

for i = 1: (numel(factors))

    regressor = design.(factors{i});
    regressor_z = (regressor - mean(regressor)) / std(regressor);
    

    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.mcov(i).c = regressor_z;
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.mcov(i).cname = factors{i};
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.mcov(i).iCC = 1;
end

if contains(lower(options.eeg.stats.design), 'phase')
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.mcov(i+1).c = design.phase;
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.mcov(i+1).cname = 'phase';
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.mcov(i+1).iCC = 1;

    factors{end+1} = 'phase';
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
