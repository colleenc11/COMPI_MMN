function [firstVoxel,peakVoxel,minClusterStatsValue, maxClusterStatsValue, threshStatsValue] = ...
    compi_first_last_significant_time_clusterLevelsignificance(options,iRegressor, group)

if nargin < 3
    group = options.part;
end

if nargin < 4
    significanceThreshold = 0.001;
end

if nargin < 5
    methodCorrection = 'none';
end

% Script for extracting first and last significant time point (i.e., z
% value) for a significant activation blob in SPM for EEG. What you need
% is:
% - an estimated SPM.mat
% - a height threshold ('FWE', 'none', and p-value)
% - an extent threshold (k - minimum number of voxels per blob) - this needs to
% result in only one blob surviving (or, if more blobs survive, you need to
% know that this script extracts the first significant time point of the
% first blob and the last significant time point of the last blob).

%% Evaluated fields in xSPM (input)
%
% xSPM      - structure containing SPM, distribution & filtering details
% .swd      - SPM working directory - directory containing current SPM.mat
% .title    - title for comparison (string)
% .Ic       - indices of contrasts (in SPM.xCon)
% .n        - conjunction number <= number of contrasts
% .Im       - indices of masking contrasts (in xCon)
% .pm       - p-value for masking (uncorrected)
% .Ex       - flag for exclusive or inclusive masking
% .u        - height threshold
% .k        - extent threshold {voxels}
% .thresDesc - description of height threshold (string)
%% Possible other fields of xSPM:
%
% .Z        - minimum of Statistics {filtered on u and k}
% .n        - conjunction number <= number of contrasts
% .STAT     - distribution {Z, T, X, F or P}
% .df       - degrees of freedom [df{interest}, df{residual}]
% .STATstr  - description string
% .Ex       - flag for exclusive or inclusive masking
% .XYZ      - location of voxels {voxel coords}
% .XYZmm    - location of voxels {mm}
% .S        - search Volume {voxels}
% .R        - search Volume {resels}
% .FWHM     - smoothness {voxels}
% .M        - voxels -> mm matrix
% .iM       - mm -> voxels matrix
% .VOX      - voxel dimensions {mm} - column vector
% .DIM      - image dimensions {voxels} - column vector
% .Vspm     - Mapped statistic image(s)
% .Ps       - uncorrected P values in searched volume (for voxel FDR)
% .Pp       - uncorrected P values of peaks (for peak FDR)
% .Pc       - uncorrected P values of cluster extents (for cluster FDR)
% .uc       - 0.05 critical thresholds for FWEp, FDRp, FWEc, FDRc
% .thresDesc - description of height threshold (string)


% Andreea Diaconescu 04.04.2018

regressorNames = options.eeg.stats.regressors;

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

% go through all regressors
for iReg = 1: numel(regressorNames)

    spmRoot = fullfile(options.roots.results_source, options.condition, ...
            regressorNames{iReg}, 'MSP_leftA1');

    contrastTitle = 'Effect of ';
    contrastIdx = 3;
    nVoxMin = 1;

    switch queryMode
        case 'gui'
            [SPM, xSPM] = spm_getSPM;
        case 'xSPM'
            % setup xSPM input struct
            xSPM.swd    = spmRoot;
            xSPM.title  = [contrastTitle regressorNames{iReg}];
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
%     xSPM = tayeeg_write_table_results(xSPM, ...
%         options.eeg.stats.pValueMode, false, nVoxMin);
%     % save xSPM for later convenience
%     save(fullfile(xSPM.swd, ...
%         ['xSPM_' xSPM.STAT '_' options.eeg.stats.pValueMode '.mat']), ...
%         'xSPM');
% 
%     con = tnueeg_extract_contrast_results(xSPM, ...
%                 [options.condition ':']);

    %-- find first and last significant voxels ---------------------------%
    table = spm_list('Table', xSPM);
    clusterP         = table.dat(:,3);
    clusterSigVoxels = reshape(cell2mat(table.dat(:,12)),3,size(clusterP,1));
    statsValue       = cell2mat(table.dat(:,9)); %cell2mat(table.dat(:,10));

    % fill up empty values of clusterP with Inf and transform to mat for easier
    % extraction of min/max indices
    clusterP(cell2mat(cellfun(@isempty, clusterP, 'UniformOutput', false))) = {Inf};
    clusterP             = cell2mat(clusterP);
    iBelowThresh         = clusterP < 0.05;
    minPBelowThresh      = min(clusterP(iBelowThresh));
    maxPBelowThresh      = max(clusterP(iBelowThresh));
    [tmp,iMinK]          = ismember(minPBelowThresh, clusterP);
    maxCluster           = clusterSigVoxels(:,iMinK);
    maxClusterStatsValue = statsValue(iMinK);
    
    [tmp,iMaxK]          = ismember(maxPBelowThresh, clusterP);
    minCluster           = clusterSigVoxels(:,iMaxK);
    minClusterStatsValue = statsValue(iMaxK);
    
    sigVoxels     = xSPM.XYZmm;
    sigTimePoints = sigVoxels(3, :);
    threshStatsValue = minClusterStatsValue;
    lastVoxel     = max(sigTimePoints);
    firstVoxel    = minCluster(3);
    peakVoxel     = maxCluster(3);

    % % save this info
    save([spmRoot '/sig_time_window.mat'], 'peakVoxel', 'firstVoxel', 'lastVoxel', ...
        'minClusterStatsValue', 'maxClusterStatsValue', 'threshStatsValue', 'xSPM');


end