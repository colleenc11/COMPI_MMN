function [] = compi_extract_first_last_sig_voxel( options, regressor, flag )
%--------------------------------------------------------------------------
% COMPI_EXTRACT_FIRST_LAST_SIG_VOXEL
%   IN:     options - the struct that holds all analysis options
%           flag    - string indicating either the condition ('HC',
%           'CHR') or 'groupdiff'
%   OUT:    --
%--------------------------------------------------------------------------

% general analysis options
if nargin < 2
    flag = options.condition;
end

% prepare SPM, as always
spm('Defaults', 'EEG');

% record what we're doing
diary(fullfile(options.roots.log, sprintf('results report%s')));

% scalpmap images of first regressor
if strcmp(options.condition, 'groupdiff')
    switch options.eeg.stats.mode
        case 'modelbased'
            spmRoot = fullfile(options.roots.results_hgf, options.condition, ...
                    option.eeg.stats.design, regressor);
        case 'erpbased'
            switch regressor
                case 'oddball'
                    spmRoot = fullfile(options.roots.erp, options.condition, ...
                            'oddball', 'SPM', 'diffwave');
                case 'oddball_phase'
                    spmRoot = fullfile(options.roots.erp, options.condition, ...
                            'oddball', 'SPM', 'diffwave_phase');
                    case {'oddball_stable', 'oddball_volatile'}
                        spmRoot = fullfile(options.roots.erp, options.condition, ...
                                regressor, 'SPM');
            end
    end
    pngFiles = fullfile(spmRoot, regressor, 'scalpmaps_*.png');
    % adjust title depending on comparison
    contrastTitle = [options.subjects.group_labels{1} ' > ' options.subjects.group_labels{2}];
    nVoxMin = 1;
elseif any(strncmp(options.subjects.group_labels, options.condition, 2))
    switch options.eeg.stats.mode
        case 'modelbased'
            spmRoot = fullfile(options.roots.hgf, options.condition, ...
                    options.eeg.stats.design, regressor);
        case 'erpbased'
            switch regressor
                case 'oddball'
                    spmRoot = fullfile(options.roots.erp, options.condition, ...
                            'oddball', 'SPM', 'diffwave');
                case 'oddball_phase'
                    spmRoot = fullfile(options.roots.erp, options.condition, ...
                            'oddball', 'SPM', 'diffwave_phase');
                case {'oddball_stable', 'oddball_volatile'}
                    spmRoot = fullfile(options.roots.erp, options.condition, ...
                            regressor, 'SPM');
            end
    end
    pngFiles = fullfile(spmRoot, regressor, 'scalpmaps_*.png');
    contrastTitle = 'Effect of ';
    nVoxMin = 1;
end


%%% FIX THIS %%%
try
    % check for previous results report
    listDir = dir(pngFiles);
    list = {listDir(~[listDir.isdir]).name};
    if ~isempty(list)
        disp(['2nd level results for regressors in ' regressor ...
        ' design in condition ' options.condition ...
        ' have been reported before.']);
        if options.eeg.stats.overwrite
            disp('Overwriting...');
            error('Continue to results report step');
        else
            disp('Nothing is being done.');
        end
    else
        error('Cannot find previous report');
    end
catch
    disp(['Reporting 2nd level results for regressors for ' ...
        options.condition ' condition in the ' ...
        regressor  ' design...']);
    
    % p value thresholding
    switch options.eeg.stats.pValueMode
        case 'clusterFWE'
            u = 0.001;
            thresDesc = 'none';
        case 'peakFWE'
            u = 0.05;
            thresDesc = 'FWE';
    end

    xSPM = struct;
    xSPM.swd      = spmRoot;
    xSPM.title    = [contrastTitle regressor];
    xSPM.Ic       = options.eeg.fig.contrastIdx;
    xSPM.n        = 1;
    xSPM.Im       = [];
    xSPM.pm       = [];
    xSPM.Ex       = [];
    xSPM.u        = u;
    xSPM.k        = 0;
    xSPM.thresDesc = thresDesc;

    %-- save results table as csv ------------------------------------%
    xSPM = tayeeg_write_table_results(xSPM, ...
        options.eeg.stats.pValueMode, false, nVoxMin);
    
    %-- significant clusters: info & plotting ------------------------%
    locs = xSPM.XYZ;
    % only continue if there are surviving voxels
    if ~isempty(locs)
        % extract all plotting-relevant contrast info 
        clusterTimeWindow = compi_extract_all_sig_voxels(xSPM, ...
                                [options.condition ':']);

        save(['clusterTimeWindow' xSPM.STAT '_000' num2str(options.eeg.fig.contrastIdx) '_' options.eeg.stats.pValueMode],...
            'clusterTimeWindow');

    end
end

diary OFF
end