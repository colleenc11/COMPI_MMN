function compi_stats_adaptable(id, options)
% -------------------------------------------------------------------------
% COMPI_STATS_ADAPTABLE Perform first-level GLM. It will convert / smooth
% trials into images if the image file does not exist. 
%
% IN
%   id          subject id string, only number (e.g. '0101')
%   options     general analysis options
%               options = compi_set_analysis_options;
%
% OUT
%   D           Data structure of SPM EEG Analysis
% -------------------------------------------------------------------------

details = compi_get_subject_details(id, options); % subject-specific information
type = options.eeg.type;

fileDesignMatrix = fullfile(details.dirs.preproc, 'design_Pruned.mat');

%% Check whether files needed for stats exist, error otherwise
switch lower(type)
    case 'sensor'
        fileToLoad = details.eeg.prepfile;
        stringRerunFunction = 'compi_preprocessing_eyeblink_correction';
        pathImages  = details.eeg.firstLevel.sensor.pathImages;
        pathStats   = fullfile(details.eeg.firstLevel.sensor.pathStats);
        analysisWindow = options.eeg.stats.firstLevelAnalysisWindow;
        switch options.eeg.preproc.smoothing
            case 'yes'
                fileImage   = details.eeg.conversion.sensor.smoofile;
            case 'no'
                fileImage   = details.eeg.firstLevel.sensor.fileImage;
        end
        
        
    case 'source'
        fileToLoad = details.eeg.source.savefilename;
        stringRerunFunction = 'compi_source';
        pathImages  = details.eeg.firstLevel.source.pathImages;
        pathStats  = fullfile(details.eeg.firstLevel.source.pathStats, options.eeg.stats.design);
        pfxImages = details.eeg.firstLevel.source.prefixImages;
        analysisWindow = options.eeg.source.firstLevelAnalysisWindow;
        switch options.eeg.preproc.smoothing
            case 'yes'
                fileImage   = details.eeg.conversion.source.smoofile;
            case 'no'
                fileImage   = details.eeg.firstLevel.source.fileImage;
        end
end

hasConvertedImages = exist(fileImage, 'file');

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
factors = options.eeg.stats.regressors;

%% Set up GLM design and estimate job
% Preparation
spm('defaults', 'eeg');

job = {};

if hasConvertedImages
    iJobFactorialDesign = 1;
    for i=1:size(design.(options.eeg.stats.regressors{1}),1)
        scans{i,1}=[fileImage ',' num2str(i)];
    end
    
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.scans = scans;
else % convert2Images is first job
    iJobFactorialDesign = 2;
    % same for all conversion jobs
    job{1}.spm.meeg.images.convert2images.conditions = cell(1, 0);
    job{1}.spm.meeg.images.convert2images.timewin = analysisWindow;
    job{1}.spm.meeg.images.convert2images.D = {fullfile(D)};
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.scans(1) = cfg_dep('Convert2Images: M/EEG exported images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
end

iJobFcon = iJobFactorialDesign + 2;


%% Factorial design specification

for i = 1: (numel(factors))
    regressor = design.(factors{i});
    regressor_z = (regressor - mean(regressor)) / std(regressor);

    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.mcov(i).c = regressor_z;
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.mcov(i).cname = factors{i};
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.mcov(i).iCC = 1;
end

job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.incint = 1;
job{iJobFactorialDesign}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
job{iJobFactorialDesign}.spm.stats.factorial_design.masking.tm.tm_none = 1;
job{iJobFactorialDesign}.spm.stats.factorial_design.masking.im = 1;
job{iJobFactorialDesign}.spm.stats.factorial_design.masking.em = {''};
job{iJobFactorialDesign}.spm.stats.factorial_design.globalc.g_omit = 1;
job{iJobFactorialDesign}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
job{iJobFactorialDesign}.spm.stats.factorial_design.globalm.glonorm = 1;
job{iJobFactorialDesign+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{iJobFactorialDesign}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
job{iJobFactorialDesign+1}.spm.stats.fmri_est.write_residuals = 0;
job{iJobFactorialDesign+1}.spm.stats.fmri_est.method.Classical = 1;

job{iJobFcon}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{iJobFactorialDesign+1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));


%% Change analysis type in function
switch type
    case 'sensor'
        % Set up converted Image input file dependencies for GLM
        if ~hasConvertedImages
            % image conversion job
            job{1}.spm.meeg.images.convert2images.mode = 'scalp x time';
            job{1}.spm.meeg.images.convert2images.channels{1}.type = 'EEG';
            job{1}.spm.meeg.images.convert2images.prefix = details.eeg.firstLevel.sensor.prefixImages;
        end
        
    case 'source'
        % images are always converted...
        D = copy(D, spm_file(fullfile(D), 'prefix', 'abs'));
        chan = D.indchantype('LFP');
        D(chan, :, :) = abs(D(chan, :, :));
        job{1}.spm.meeg.images.convert2images.mode = 'time';

end


%% F - contrast creation job
job{iJobFcon}.spm.stats.con.delete = 1;

for i = 1:numel(factors)
    % all other quantities with F-contrast
    job{iJobFcon}.spm.stats.con.consess{i}.fcon.name    = factors{i};
    job{iJobFcon}.spm.stats.con.consess{i}.fcon.weights = zeros(1, numel(factors)+1);
    job{iJobFcon}.spm.stats.con.consess{i}.fcon.weights(i+1) = 1;
    job{iJobFcon}.spm.stats.con.consess{i}.fcon.sessrep = 'none';
end

%% use dependencies for all other submodules of batch
job{iJobFcon + 1} = compi_get_job_contrast_manager(iJobFcon, type);

[~,~] = mkdir(pathImages);
fprintf('Trying to run job of compi_stats_adaptable\n');

switch type
    case 'sensor'
        
        job{iJobFactorialDesign}.spm.stats.factorial_design.dir = {pathStats};
        compi_save_subject_batch(job, details.eeg.log.batches.statsfile);
        
        if ~hasConvertedImages
            warning off
            fprintf('Subject Id %s: File %s does not exist\n Converting images now...\n', id, fileImage);
        end
        warning on
        
        compi_save_subject_batch(job, details.eeg.log.batches.statsfile);
        
        spm_jobman('run', job);
    case {'source'}
        for i = 1:length(chan)
            stringChannel = char(D.chanlabels(chan(i)));
            pathSpmChannel = fullfile(pathStats, stringChannel);
            job{1}.spm.meeg.images.convert2images.channels{1}.chan = stringChannel;
            job{1}.spm.meeg.images.convert2images.prefix = [pfxImages stringChannel '_'];
            
            res = mkdir(pathSpmChannel);
            if exist(fullfile(pathSpmChannel, 'SPM.mat'), 'file')
                delete(fullfile(pathSpmChannel, 'SPM.mat'));
            end
            
            job{iJobFactorialDesign}.spm.stats.factorial_design.dir = {pathSpmChannel};
            
            compi_save_subject_batch(job, ...
                spm_file(details.eeg.log.batches.statsfile, 'suffix', ['_' stringChannel]));
            
            spm_jobman('run', job);
            
        end
end


