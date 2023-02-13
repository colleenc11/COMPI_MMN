function compi_conversion(id, options)
%--------------------------------------------------------------------------
% Convert preprocessed epoched EEG data to 3D images & smooth them for one
% subject.
%--------------------------------------------------------------------------

%% Get subject details
details = compi_get_subject_details(id, options);

%% Main
% record what we're doing
diary(details.eeg.logfile);

regressor = 'phase';

% determine the preprocessed file to use for conversion
prepfile = fullfile(details.eeg.erp.root, [regressor '.mat']);

% try whether this file exists
try
    D = spm_eeg_load(prepfile);
catch
    disp('This file: ')
    disp(prepfile)
    disp('could not been found.')
    error('No final preprocesed EEG file')
end

% check for previous smoothing
try
    im = spmvol(fullfile(details.eeg.erp.root, regressor, ...
               ['images_' regressor '_erp_' id], ...
               'smoothed_condition_mmn.nii,1'));
    disp(['Images for subject ' id ' have been converted and smoothed before.']);
    if options.eeg.conversion.overwrite
        clear im;
        disp('Overwriting...');
        error('Continue to conversion step');
    else
        disp('Nothing is being done.');
    end
catch
    disp(['Converting subject ' id ' ...']);

    % convert EEG data
    [images, ~] = tnueeg_convert2images(D, options);
    disp(['Converted EEG data for subject ' id]);

    % and smooth the resulting images
    tnueeg_smooth_images(images, options);
    disp(['Smoothed images for subject ' id]);
end

cd(options.roots.results);

diary OFF
end