function ga = compi_grandmean_with_error(erpfiles, electrode, regressor, keepdata)
%--------------------------------------------------------------------------
% COMPI_GRANDMEAN_WITH_ERROR Computes the mean, standard deviation and
% standard error of the mean of multiple ERPs in one electrode.
% 
%   IN:     erpfiles    - cell array of size nFiles containing the
%                       filenames and paths of the input EEG files
%           electrode   - electrode label (string)
%           regressor   - regressor of interest
%           keepdata    - if 1/yes (default), all data from which the mean
%                       was computed, will be kept in the output variable
%   OUT:    ga          - grand average struct with a field per
%                       condition/trial and subfields containing the mean
%                       and variance estimates
% 
% Adapted from: TNUEEG_GRANDMEAN_WITH_ERROR
%--------------------------------------------------------------------------

numSubjects = numel(erpfiles);
D = spm_eeg_load(erpfiles{1});

% collect information on dimensions, using the first file
conlist = condlist(D);
numConditions = numel(conlist);
numSamples = nsamples(D);
ga.time = time(D).*1000;
ga.electrode = electrode;

% loop over all conditions present in the EEG files
for iCon = 1: numConditions
    
    % get the data to be averaged
    data = NaN(numSubjects, numSamples);
    for iSub = 1: numSubjects
        D = spm_eeg_load(erpfiles{iSub});
        
        indEl = indchannel(D, electrode);
        data(iSub, :) = squeeze(D(indEl, :, iCon));
    end

    % reload conlist incase it's different than first file
    conlist = condlist(D);
    conlabel = char(conlist{iCon});
    
    % do the actual averaging
    ga.(conlabel).mean = mean(data);
    ga.(conlabel).sd = std(data);
    ga.(conlabel).error = std(data)/sqrt(numSubjects);
    ga.(conlabel).time = time(D).*1000;
    
    if keepdata
        ga.(conlabel).data = data;
    end
    
end

% calculate the high low wave difference and do averaging
switch regressor
    case {'oddball'}
        diffwaves = ga.deviant.data - ga.standard.data;
        nsubjects = size(ga.standard.data, 1);
        ga.diff.data = diffwaves;
        ga.diff.mean = mean(diffwaves);
        ga.diff.sd  = std(diffwaves);
        ga.diff.error  = std(diffwaves)/sqrt(nsubjects);
        ga.diff.time = ga.time;
        ga.diff.electrode = ga.electrode;
    case {'oddball_stable'}
        diffwaves = ga.devStab.data - ga.standStab.data;
        nsubjects = size(ga.standStab.data, 1);
        ga.diff.data = diffwaves;
        ga.diff.mean = mean(diffwaves);
        ga.diff.sd  = std(diffwaves);
        ga.diff.error  = std(diffwaves)/sqrt(nsubjects);
        ga.diff.time = ga.time;
        ga.diff.electrode = ga.electrode;
    case {'oddball_volatile'}
        diffwaves = ga.devVol.data - ga.standVol.data;
        nsubjects = size(ga.standVol.data, 1);
        ga.diff.data = diffwaves;
        ga.diff.mean = mean(diffwaves);
        ga.diff.sd  = std(diffwaves);
        ga.diff.error  = std(diffwaves)/sqrt(nsubjects);
        ga.diff.time = ga.time;
        ga.diff.electrode = ga.electrode;
    otherwise 
        diffwaves = ga.high.data - ga.low.data;
        nsubjects = size(ga.low.data, 1);
        ga.diff.data = diffwaves;
        ga.diff.mean = mean(diffwaves);
        ga.diff.sd  = std(diffwaves);
        ga.diff.error  = std(diffwaves)/sqrt(nsubjects);
        ga.diff.time = ga.time;
        ga.diff.electrode = ga.electrode;
end

end
