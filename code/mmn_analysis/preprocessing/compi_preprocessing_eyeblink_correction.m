function D = compi_preprocessing_eyeblink_correction( id, options )
% -------------------------------------------------------------------------
% COMPI_PREPROCESSING_EYEBLINK_CORRECTION Performs all preprocessing steps 
% for one subject of the COMPI study (up until first level statistics).
%   IN:     id          subject identifier string, e.g. '0101'
%           options     as set by compi_mmn_options();
%   OUT:    D           Data structure of SPM EEG Analysis
% ------------------------------------------------------------------------- 

%% Get subject details
details = compi_get_subject_details(id, options);

if ~exist(details.eeg.preproot, 'dir')
    mkdir(details.eeg.preproot);
end

% record what we're doing
diary(details.eeg.logfile);
tnueeg_display_analysis_step_header('preprocessing', 'compi', id, options.eeg.preproc);

%% paths and files

% check destination folder
pathBefore = pwd;
cd(details.eeg.preproot);

try
    % check for previous preprocessing
    D = spm_eeg_load(details.eeg.prepfile);
    disp(['Subject ' id ' has been preprocessed before.']);
    if options.eeg.preproc.overwrite
        clear D;
        disp('Overwriting...');
        error('Continue to preprocessing script');
    else
        disp('Nothing is being done.');
    end
catch
    disp(['Preprocessing subject ' id ' ...']);
    
    %-- original preprocessing function ----------------------------------%
    D = compi_preprocessing(id, options);
    
    %-- remaining artefact rejection -------------------------------------%
    D = tnueeg_reject_remaining_artefacts(D, options);
    
    %-- finish -----------------------------------------------------------%
    D = copy(D, details.eeg.prepfilename);

    %-- collect trial stats ----------------------------------------------%
    compi_count_artefacts(D, details);
    
    %--optional:conversion and smoothing----------------------------------%
    D = spm_eeg_load(details.eeg.prepfile);

    switch options.eeg.preproc.smoothing
        case 'yes'
            try
                % check for previous smoothing
                im = spm_vol(details.eeg.conversion.sensor.smoofile{1});
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

    end

    cd(pathBefore);
    
    diary OFF
end

end
