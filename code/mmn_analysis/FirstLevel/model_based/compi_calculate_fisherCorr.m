function [z] = compi_calculate_fisherCorr(options)



for idCell = options.subjects.all
    id = char(idCell);

    details = compi_get_subject_details(id, options); % subject-specific information

    fileDesignMatrix = fullfile(details.dirs.preproc, 'design_Pruned.mat');
    design = getfield(load(fileDesignMatrix), 'design');

    factors = options.eeg.stats.regressors;

    
    for i = 1: (numel(factors))
        regressor = design.(factors{i});
        regressor_z = (regressor - mean(regressor)) / std(regressor);
    end





end

%FISHERZ Fisher's Z-transform.
% Z = FISHERZ(R) returns the Fisher's Z-transform of the correlation
% coefficient R.

% Save size
dims = size(r);

% Fisher transform
r = r(:);
z = .5.*log((1+r)./(1-r));

% Reshape
z = reshape(z,dims);

% Save size
dims = size(z);

z = z(:);
r = (exp(2*z)-1)./(exp(2*z)+1);

% Reshape
r = reshape(r,dims);