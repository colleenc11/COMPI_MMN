function compi_plot_covar_vs_source_intensity(options)
%--------------------------------------------------------------------------
% COMPI_PLOT_COVAR_VS_SOURCE_INTENSITY Plot peak intensity values from
% specific source and time window
%
%   IN:     options       as set by compi_set_analysis_options();
%
%   OUT:     
%--------------------------------------------------------------------------

%% Specify parameters

% Coordinates of interest
coord = [46, 20, 8]; % right IFG

% Timepoint of interest (in ms)
timewindow = [344 400]; %[100 400], [398 398]

% Radius around the coordinate to search for the peak (in mm)
search_radius = 16;

% Covariate of interest
covariate = {'GF_social_T0'};

%% Get covariate

covars = compi_get_covariates({covariate}, ...
                        options.subjects.IDs{1}, options);
gfScores = covars.(covariate{1});

%% Extract subejct images

% prepare spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

% Create average source image based on specified time window
for i_group = 1: numel(options.subjects.group_labels)

    if strncmp(options.subjects.group_labels{i_group}, options.condition, 2)
        nSubjects = numel(options.subjects.IDs{i_group});
        prepPaths = cell(nSubjects, 1);
        for sub = 1: nSubjects
            subID = char(options.subjects.IDs{i_group}{sub});
            details = compi_get_subject_details(subID, options);

            prepPaths{sub, 1} = fullfile(details.eeg.erp.root, 'oddball_volatile', 'diff_oddball_volatile.mat');
        end
    end

    prepPaths = cellstr(prepPaths);

    job = compi_getjob_source_ppm(timewindow, prepPaths);
    spm_jobman('run', job);
    clear job;
end

% Collect output images for all subjects
for i_group = 1: numel(options.subjects.group_labels)
    if strncmp(options.subjects.group_labels{i_group}, options.condition, 2)
        nSubjects = numel(options.subjects.IDs{i_group});
        imgPaths = cell(nSubjects, 1);
        for sub = 1: nSubjects
            subID = char(options.subjects.IDs{i_group}{sub});
            details = compi_get_subject_details(subID, options);
    
            imgPaths{sub, 1} = fullfile(details.eeg.erp.root, 'oddball_volatile',...
                ['diff_oddball_volatile_1_t' num2str(timewindow(1)) '_' num2str(timewindow(2)) '_f_1.nii,1']);
        end
    end
end

subjects_img_files = cellstr(imgPaths);

%% Extract peak intensity values

% Initialize an array to store peak values for each subject
peak_values = zeros(length(subjects_img_files), 1);

% Loop Over Each Subject's Image
for subj = 1:length(subjects_img_files)
    % Load the image
    nii = spm_read_vols(spm_vol(subjects_img_files{subj}));
    
    % Convert mm coordinates to voxel indices
    mat = spm_get_space(subjects_img_files{subj});
    voxel_coord = round(mat \ [coord, 1]');
    voxel_coord = voxel_coord(1:3)';

    % Ensure voxel indices are within valid range
    voxel_coord(voxel_coord < 1) = 1;
    
    % Convert search_radius from mm to voxels
    voxel_dims = sqrt(sum(mat(1:3, 1:3).^2, 1)); % Extract voxel dimensions from the affine matrix
    search_radius_voxels = round(search_radius ./ voxel_dims);
    
    % Extract a small cube of values around the specified coordinate using the converted search_radius
    x_range = max(1, voxel_coord(1)-search_radius_voxels(1)):min(size(nii,1), voxel_coord(1)+search_radius_voxels(1));
    y_range = max(1, voxel_coord(2)-search_radius_voxels(2)):min(size(nii,2), voxel_coord(2)+search_radius_voxels(2));
    z_range = max(1, voxel_coord(3)-search_radius_voxels(3)):min(size(nii,3), voxel_coord(3)+search_radius_voxels(3));

    
    sub_volume = nii(x_range, y_range, z_range);
    
    % Find the peak intensity value within the sub-volume
    % peak_values(subj) = mean(sub_volume(:));
    peak_values(subj) = max(sub_volume(:));
end

%% Plot the peak values
figure;
set(gcf,'position',[500,500,400,300])
scatter(peak_values, gfScores, 'filled', 'k', 'SizeData', 70);
ylim([5,11])
% title(['Mean Intensity Value [' num2str(timewindow(1)) '-' num2str(timewindow(2)) '] vs. GF Social']);
title(['Max Intensity Value [' num2str(timewindow(1)) '-' num2str(timewindow(2)) '] vs. GF Social']);

% Fit a linear regression model to the data
p = polyfit(peak_values, gfScores, 1);

% Add the regression line to the plot
hline = refline(p);
hline.Color = 'k';
hline.LineWidth = 1.5;

[r, pValue] = corr(peak_values, gfScores');
disp(pValue);

