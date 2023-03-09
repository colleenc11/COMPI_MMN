function [job4] = compi_msp_job_erp(D, VOI, erpFile, options)

    priors = options.eeg.source.priors;
    job4{1}.spm.meeg.source.invert.D = {fullfile(D)};
    job4{1}.spm.meeg.source.invert.val = 1;
    job4{1}.spm.meeg.source.invert.whatconditions.all = 1;
    job4{1}.spm.meeg.source.invert.isstandard.custom.invtype = 'IID'; %GS
    job4{1}.spm.meeg.source.invert.isstandard.custom.woi = [-Inf Inf];
    job4{1}.spm.meeg.source.invert.isstandard.custom.foi = [0 256];
    job4{1}.spm.meeg.source.invert.isstandard.custom.hanning = 1;
    job4{1}.spm.meeg.source.invert.isstandard.custom.priors.priorsmask = options.eeg.source.priorsmask;
    job4{1}.spm.meeg.source.invert.isstandard.custom.priors.space = 1;
    job4{1}.spm.meeg.source.invert.isstandard.custom.restrict.locs = zeros(0, 3); %%% change to a matrix of locations
    job4{1}.spm.meeg.source.invert.isstandard.custom.restrict.radius = 32; %%% change to size of the fMRI clusters
    job4{1}.spm.meeg.source.invert.modality = {'EEG'};
    job4{2}.spm.meeg.source.extract.D(1) = cfg_dep('Source inversion: M/EEG dataset(s) after imaging source reconstruction', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','D'));
    job4{2}.spm.meeg.source.extract.val = 1;
    
    for i = 1:size(VOI, 1)
        job4{2}.spm.meeg.source.extract.source(i).label = VOI{i, 1};
        job4{2}.spm.meeg.source.extract.source(i).xyz = VOI{i, 2};
    end
    
    job4{2}.spm.meeg.source.extract.rad = options.eeg.source.radius;
    job4{2}.spm.meeg.source.extract.type = 'trials';
    job4{2}.spm.meeg.source.extract.fname = erpFile;
end