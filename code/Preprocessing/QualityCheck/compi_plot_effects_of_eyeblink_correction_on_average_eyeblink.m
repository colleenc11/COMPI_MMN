function [fh1] = compi_plot_effects_of_eyeblink_correction_on_average_eyeblink( id, options )
% -------------------------------------------------------------------------
% COMPI_PLOT_EFFECTS_OF_EYEBLINK_CORRECTION_ON_AVERAGE_EYEBLINK Plots the 
% average eyeblink epoch before and after EB correction method was applied. 
% Also creates the averaged and corrected EB epoch data sets if they 
% haven't been created before.
%   IN:     id          - subject identifier string, e.g. '001'
%           options     - the struct that holds all analysis options
%   OUT:    fh1         - figure handle of the created plot
% -------------------------------------------------------------------------

% Retrieve the details for the subject
details = compi_get_subject_details(id, options);

if ~exist(details.eeg.quality.root, 'dir')
    mkdir(details.eeg.quality.root);
end

% Define number of trials
trials = 1;

% Get average eyeblink response before and after correction
[Dbefore, Dafter] = compi_get_average_EB_responses(details, options);

% Define channels to plot
channels = {'Fp1', 'Fp2', 'Fpz', 'HEOG'};

% Plot diagnostic effect of eyeblink correction
fh1 = compi_diagnostics_effect_of_EB_corr(Dbefore, Dafter, channels, trials);

if ~exist(fullfile(options.roots.diag_eeg, 'eb_correction'), 'dir')
    mkdir(fullfile(options.roots.diag_eeg, 'eb_correction'));
end

% Save figures
saveas(fh1, details.eeg.quality.averageeyeblinkcorrectionfigure,'fig');
saveas(fh1, fullfile(options.roots.diag_eeg, 'eb_correction', [id '_eb1']),'png');

close all

end


function [ Dbefore, Dafter ] = compi_get_average_EB_responses( details, options )
% Retrieves the average eyeblink responses before and after correction

    % Depending on preprocessing method and subject name, select appropriate file
    if strcmp(lower(details.eeg.preproc.eyeCorrMethod), 'pssp')
        if strcmp(details.eeg.subproname, 'COMPI_0118')
            list = dir(fullfile(details.eeg.preproot, ['afeafdfMMspmeeg_' details.eeg.subproname '.mat'])); %ceaffMspmeeg_
        else
            list = dir(fullfile(details.eeg.preproot, ['afeafdfMspmeeg_' details.eeg.subproname '.mat'])); %'afceaffMspmeeg_'
        end
    
    elseif strcmp(details.eeg.subproname, 'COMPI_0118')
        list = dir(fullfile(details.eeg.preproot, ['eafdfMMspmeeg_' details.eeg.subproname '.mat'])); %ceaffMspmeeg_
    
    else
        list = dir(fullfile(details.eeg.preproot, ['eafdfMspmeeg_' details.eeg.subproname '.mat'])); %ceaffMspmeeg_
    end
    
    if numel(list) ~= 1
        error(['Could not unambiguously determine EEG file epoched to eyeblinks (uncorrected)' ...
            ' for subject ' details.eeg.subproname]);
    end

    % Load EEG data and copy to designated directory
    D = spm_eeg_load(fullfile(details.eeg.preproot, list.name)); 
    Dinitial = copy(D, details.eeg.quality.epoched_EB_uncorrected);
    
    % Average the EEG data
    D = tnueeg_average(Dinitial, 's');
    Dbefore = copy(D, details.eeg.quality.average_EB_uncorrected);
    
    % Correct the epoched eyeblink and average
    Dcorr = compi_correct_epoched_EB(Dinitial, details, options);
    D = tnueeg_average(Dcorr, 's');
    Dafter = copy(D, details.eeg.quality.average_EB_corrected);
    
    
    Dcorr = spm_eeg_load(details.eeg.quality.epoched_EB_corrected);
    D = tnueeg_average(Dcorr, 's');
    Dafter = copy(D, details.eeg.quality.average_EB_corrected);
    
end

