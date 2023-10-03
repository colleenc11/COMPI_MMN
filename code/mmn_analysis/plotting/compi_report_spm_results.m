function [] = compi_report_spm_results( options, flag )
%--------------------------------------------------------------------------
% COMPI_REPORT_SPM_RESULTS
%   IN:     options - the struct that holds all analysis options
%           flag    - string indicating either the condition ('HC',
%           'CHR') or 'groupdiff'
%   OUT:    --
%--------------------------------------------------------------------------

% general analysis options
if nargin < 1
    options = mnCHR_set_analysis_options;
    flag = options.condition;
end

% prepare SPM, as always
spm('Defaults', 'EEG');

% record what we're doing
diary(fullfile(options.roots.log, sprintf('results report%s')));

% names of the single-trial regressor
regressor = options.eeg.stats.currRegressor{1};

% scalpmap images of first regressor

if strcmp(options.condition, 'groupdiff')
    switch options.eeg.stats.mode
        case 'modelbased'
            spmRoot = fullfile(options.roots.results_hgf, options.condition, ...
                    regressor);
        case 'erpbased'
            switch options.eeg.erp.type
                case {'oddball', 'oddball_phases'}
                    spmRoot = fullfile(options.roots.erp, options.condition, ...
                            regressor, 'SPM', 'diffwave');
                case 'oddball_stable'
                    spmRoot = fullfile(options.roots.erp, options.condition, ...
                            regressor, 'SPM', 'stable');
                case 'oddball_volatile'
                    spmRoot = fullfile(options.roots.erp, options.condition, ...
                            regressor, 'SPM', 'volatile');
            end
    end
    pngFiles = fullfile(spmRoot, regressor, 'scalpmaps_*.png');
    % adjust title depending on comparison
    contrastTitle = [options.subjects.group_labels{1} ' > ' options.subjects.group_labels{2}];
    nVoxMin = 1;
elseif any(strncmp(options.subjects.group_labels, options.condition, 2))
    switch options.eeg.stats.mode
        case 'modelbased'
            spmRoot = fullfile(options.roots.results_hgf, options.condition, options.eeg.stats.design,...
                    regressor);
        case 'erpbased'
            
            switch options.eeg.erp.type
                case {'oddball', 'oddball_phases'}
                    spmRoot = fullfile(options.roots.erp, options.condition, ...
                            regressor, 'SPM', 'diffwave');
                case 'oddball_stable'
                    spmRoot = fullfile(options.roots.erp, options.condition, ...
                            regressor, 'SPM', 'stable');
                case 'oddball_volatile'
                    spmRoot = fullfile(options.roots.erp, options.condition, ...
                            regressor, 'SPM', 'volatile');
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
        disp(['2nd level results for regressors in ' options.eeg.erp.type ...
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
        options.eeg.erp.type  ' design...']);
    
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
    % save xSPM for later convenience
    save(fullfile(xSPM.swd, ...
        ['xSPM_' xSPM.STAT '_' options.eeg.stats.pValueMode '.mat']), ...
        'xSPM');
    
    %-- significant clusters: info & plotting ------------------------%
    locs = xSPM.XYZ;
    % only continue if there are surviving voxels
    if ~isempty(locs)
        % extract all plotting-relevant contrast info 
        con = tnueeg_extract_contrast_results(xSPM, ...
            [options.condition ':']);
        
        save(fullfile(con.swd, ...
            ['con_' con.stat '_' options.eeg.stats.pValueMode '.mat']), ...
            'con');

        % plot all sections overlays 
        cd(con.swd);
        sectionsFolder = ['con' con.stat '_sections'];
        scalpmapsFolder = ['con' con.stat '_scalpmaps'];
        mkdir(sectionsFolder);
        mkdir(scalpmapsFolder);
        cd(sectionsFolder);
        
        % reduce blobs in xSPM to the significant ones
        sigIdx = [];
        for iSigClus = 1: con.nClusters.sig
            [~, iA] = intersect(xSPM.XYZ', con.clusters(iSigClus).allvox', 'rows');
            sigIdx = [sigIdx; iA];
        end
        xSPM.XYZ = xSPM.XYZ(:, sigIdx);
        xSPM.Z = xSPM.Z(sigIdx);
        tnueeg_overlay_sections_per_cluster(xSPM, con);
        % cd('..');
        % cd(contoursFolder);
        % tnueeg_overlay_sections_per_cluster(xSPM, con);

        % plot all scalpmaps 
        cd('..');
        cd(scalpmapsFolder);
        conf = tayeeg_configure_scalpmaps(con, options, xSPM.STAT, abs(max(xSPM.Z)));
        tnueeg_scalpmaps_per_cluster(con, conf);

    end
end
cd(options.roots.results);

diary OFF
end