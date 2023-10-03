function [ clusterTimeWindow ] = compi_extract_all_sig_voxels( xSPM, titleStr )
%COMPI_EXTRACT_ALL_SIG_VOXELS Extracts all information on significant
%clusters that may be used in subsequent plotting: thresholding parameters,
%peak coordinates per cluster, p-values and extent of clusters, significant
%time window per cluster. 
%   IN:     xSPM        - the struct that contains the thresholded SPM, or
%                       the parameters needed for thresholding (see below)
%           titleStr    - a string that will form the title of the contrast,
%                       together with the contrast title saved in the xSPM.
%   OUT:    con         - a struct that contains all plotting-relevant
%                       information per cluster (e.g. peak coordinates and 
%                       significant time windows)
% If run without input arguments, the SPM and the thresholding parameters
% will be queried interactively. If the input xSPM has not been thresholded
% yet, the parameters indicated by xSPM will be used for thresholding
% (silent). Necessary fields for this are:
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

%-- check input ----------------------------------------------------------%
if ~nargin
    [~, xSPM] = spm_getSPM;
    titleStr = '';
end
if nargin == 1
    if ischar(xSPM)
        titleStr = xSPM;
        xSPM = [];
    else
        titleStr = '';
    end
end
try 
    allVox = xSPM.XYZ;
catch
    [~, xSPM] = spm_getSPM(xSPM);
    allVox = xSPM.XYZ;
end


%-- store results info for plotting --------------------------------------%
con.swd     = xSPM.swd;
con.name    = [titleStr ' ' xSPM.title];
con.stat    = xSPM.STAT;
con.statMax = nanmax(xSPM.Z);
con.conIdx  = xSPM.Ic;
con.imgFile = fullfile(con.swd, ...
    ['spm' con.stat '_000' num2str(con.conIdx) '.nii']);

switch xSPM.thresDesc 
    case 'p<0.001 (unc.)'
        con.peak.correction     = 'None';
        con.peak.threshold      = 0.001;
        con.clust.correction    = 'FWE';
        con.clust.threshold     = 0.05;
    case 'p<0.05 (FWE)'
        con.peak.correction     = 'FWE';
        con.peak.threshold      = 0.05;
end
        

%-- collect results info from xSPM ---------------------------------------%
DIM     = xSPM.DIM > 1;
FWHM    = full(xSPM.FWHM);          % Full width at half max
FWHM    = FWHM(DIM);
V2R     = 1/prod(FWHM);             % voxels to resels
Resels  = full(xSPM.R);  
Resels  = Resels(1: find(Resels ~= 0, 1, 'last')); 
        
minz        = abs(min(min(xSPM.Z)));
statValue   = 1 + minz + xSPM.Z;
[numVoxels, statValue, XYZ, clustAssign, ~]  = spm_max(statValue, allVox);

nClusters   = max(clustAssign);    

XYZmmAll    = xSPM.XYZmm;

clusterTimeWindow = XYZmmAll(3, 1);

for i_vox = 1:length(XYZmmAll)

    if i_vox == length(XYZmmAll)
        val_voxFinal = XYZmmAll(3, i_vox);
        clusterTimeWindow(end+1) = val_voxFinal;

    else
        val_vox1 = XYZmmAll(3, i_vox);
        val_vox2 = XYZmmAll(3, [i_vox+1]);
    
        if (val_vox2 - val_vox1) > 5 || (val_vox1 - val_vox2) > 5
            clusterTimeWindow(end+1) = val_vox1;
            clusterTimeWindow(end+1) = val_vox2;
        end
    end

end
 
end