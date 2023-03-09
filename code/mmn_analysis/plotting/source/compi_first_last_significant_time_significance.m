function compi_first_last_significant_time_significance(options,regressor)
%--------------------------------------------------------------------------
% COMPI_FIRST_LAST_SIGNIFICANT_TIME_SIGNIFICANCE % Script for extracting 
% first and last significant time point for a significant source in SPM for 
% EEG. 
%
%   IN:     options     as set by compi_set_analysis_options();
%           regressor   model-regressor correlated with sources
%
% See also dmpad_first_last_significant_time_clusterLevelsignificance
%--------------------------------------------------------------------------

% p value thresholding
switch options.eeg.stats.pValueMode
    case 'clusterFWE'
        u = 0.001;
        thresDesc = 'none';
    case 'peakFWE'
        u = 0.05;
        thresDesc = 'FWE';
end

% query SPM.mat in interactive mode (select via GUI) or use predefined xSPM struct
queryMode = 'xSPM'; % 'xSPM' or 'gui'

contrastTitle = 'Effect of ';
contrastIdx = 3;
nVoxMin = 1;

for iSource = 1:length(options.eeg.source.labels)
    label = options.eeg.source.labels{iSource};

    spmRoot = fullfile(options.roots.results_source, options.condition, ...
            regressor, label);
    
    switch queryMode
        case 'gui'
            [SPM, xSPM] = spm_getSPM;
        case 'xSPM'
            % setup xSPM input struct
            xSPM.swd    = spmRoot;
            xSPM.title  = [contrastTitle regressor ' ' label];
            xSPM.Ic     = contrastIdx;
            xSPM.n      = 1;
            xSPM.Im     = [];
            xSPM.pm     = [];
            xSPM.Ex     = [];
            xSPM.u      = u;
            xSPM.k      = 0;
            xSPM.thresDesc = thresDesc;
    
            [SPM, xSPM] = spm_getSPM(xSPM);
    end

    %-- save results table as csv ----------------------------------------%
    xSPM = tayeeg_write_table_results(xSPM, ...
        options.eeg.stats.pValueMode, false, nVoxMin);
    % save xSPM for later convenience
    save(fullfile(xSPM.swd, ...
        ['xSPM_' xSPM.STAT '_' options.eeg.stats.pValueMode '.mat']), ...
        'xSPM');

    %-- find first and last significant voxels ---------------------------%

    minz        = abs(min(min(xSPM.Z)));
    statValue   = 1 + minz + xSPM.Z;
    [~, ~, ~, clustAssign, ~]  = spm_max(statValue, xSPM.XYZ);
    
    if max(clustAssign) > 0


        con = compi_extract_contrast_results(xSPM, ...
                    [options.condition ':']);
    
        save(fullfile(con.swd, ...
        ['con_' con.stat '_' options.eeg.stats.pValueMode '.mat']), ...
        'con');
    else 
        disp('No significant clusters')
    end

end

end