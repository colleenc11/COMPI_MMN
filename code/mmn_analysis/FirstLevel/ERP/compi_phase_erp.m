function D = compi_phase_erp(id, options)
%COMPI_PHASE_ERP Computes ERPs for one subject from the COMPI study.
%   IN:     id                  - subject identifier, e.g '0001'
%   OUT:    D                   - preprocessed data set

%% Get subject details
details = compi_get_subject_details(id, options); % subject-specific information

if ~exist(details.eeg.erp.root, 'dir')
    mkdir(details.eeg.erp.root);
end

if ~exist(details.eeg.erp.erpfigs, 'dir')
    mkdir(details.eeg.erp.erpfigs);
end

cd(details.eeg.erp.root);

% record what we're doing
diary(details.eeg.logfile);

% regressor - adapt for model params
regressor = options.eeg.erp.regressors;

% figure colors
cols = compi_define_colors;

%% Main

% work on final preprocessed file
D = spm_eeg_load(fullfile(details.eeg.preproot, [id '_outcomes']));

% get condition list
condlist = compi_phase_conditions(D);

% redefine trials for averaging
D = tnueeg_redefine_conditions(D, condlist);
D = copy(D, fullfile(details.eeg.erp.root, 'redef', [regressor '.mat']));
disp(['Redefined conditions for subject ' id]);

% do the averaging
D = tnueeg_average(D, options);
D = copy(D, fullfile(details.eeg.erp.root, 'average', [regressor '.mat']));
disp(['Averaged over trials for subject ' id]);

% in case of robust filtering: re-apply the low-pass filter
switch options.eeg.erp.averaging
    case 'r'
        % make sure we don't delete ERP files during filtering
        options.eeg.preproc.keep = 1;
        D = tnueeg_filter(D, 'low', options);
        disp(['Re-applied the low-pass filter for subject ' id]);
    case 's'
        % do nothing
end

D = copy(D, fullfile(details.eeg.erp.root, 'average', [regressor '.mat']));

%% ERP Plot

D = spm_eeg_load(fullfile(details.eeg.erp.root, 'average', [regressor '.mat']));

chanlabel = options.eeg.erp.electrode;

switch options.eeg.erp.phaseType
    case {'allBins'}
        triallist = {'stable1', 'Stable1 Phase', cols.magenta; ...
                        'volatile', 'Volatile Phase', cols.cyan;...
                        'stable2', 'Stable2 Phase', cols.lightgreen};

    case {'2bins'} 
        triallist = {'stable1', 'Stable1 Phase', cols.magenta; ...
                        'volatile', 'Volatile Phase', cols.cyan};
end

% Make ERP plot
h = tnueeg_plot_subject_ERPs(D, chanlabel, triallist);
h.Children(2).Title.String = ['Subject ' id ': ' regressor ' ERPs'];
savefig(h, fullfile(details.eeg.erp.erpfigs, [regressor '_ERP.fig']));

% diagnostics: save ERP figures
if ~exist(fullfile(options.roots.diag_eeg, 'ERPs'), 'dir')
    mkdir(fullfile(options.roots.diag_eeg, 'ERPs'));
end
saveas(h, fullfile(options.roots.diag_eeg, 'ERPs', [id '_' chanlabel '_' regressor '_ERP']),'png');

fprintf('\nSaved an ERP plot for subject %s\n\n', id);

%% Image Conversion
disp(['Converting subject ' id ' ...']);

% convert EEG data
[images, ~] = tnueeg_convert2images(D, options);
disp(['Converted EEG data for subject ' id]);

% and smooth the resulting images
tnueeg_smooth_images(images, options);
disp(['Smoothed images for subject ' id]);
      
close all

diary OFF
end