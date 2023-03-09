function [options] = compi_mmn_stats_options(options)
%--------------------------------------------------------------------------
% COMPI_MMN_STATS_OPTIONS 2nd-level options for sensor and source analysis.
% IN
%       options       (subject-independent) analysis pipeline options
%                     options = compi_set_analysis_options
%--------------------------------------------------------------------------

%% EEG Sensor Analysis----------------------------------------------------%
options.eeg.stats.firstLevelAnalysisWindow = [100 450];
options.eeg.stats.priors        = 'volTrace';           % omega35, default, mypriors, kappa2, peIncrease, volTrace
options.eeg.stats.designPruned  = true;                 % if true, rejected trials are removed from conversion and design matrix

switch options.eeg.stats.design
    case 'epsilon'
        options.eeg.stats.regressors = {'epsilon2', 'epsilon3'};
        options.eeg.stats.regDesignSplit = 1;
    case 'delta'
        options.eeg.stats.regressors = {'delta1', 'delta2'};
        options.eeg.stats.regDesignSplit = 1;
    case 'precision'
        options.eeg.stats.regressors = {'pi1', 'pi2', 'pi3'};
        options.eeg.stats.regDesignSplit = 1;
    case 'lowPE'
        options.eeg.stats.regressors = {'delta1', 'psi2'};
        options.eeg.stats.regDesignSplit = 0;
    case 'highPE'
        options.eeg.stats.regressors = {'delta2', 'psi3'};
        options.eeg.stats.regDesignSplit = 0;
    case 'epsilons'
        options.eeg.stats.regressors = {'epsilon2', 'epsilon3'};
        options.eeg.stats.regDesignSplit = 0;
end

options.eeg.stats.pValueMode    = 'clusterFWE';
options.eeg.stats.exampleID     = '0001';
options.eeg.stats.overwrite     = 1;

%% EEG Source Analysis----------------------------------------------------%
options.eeg.stats.firstLevelSourceAnalysisWindow = [100 449];

options.eeg.source.mmnVOI         = fullfile(options.roots.config, 'compi_voi_msp_mmn.mat');
options.eeg.source.radius         = 16;
options.eeg.source.msp            = true;
options.eeg.source.priors         = fullfile(options.roots.config, 'priors.mat');
options.eeg.source.priorsmask     = {''};
options.eeg.source.doVisualize    = false;
options.eeg.source.type           = 'source';

options.eeg.source.exampleLabel   = 'MSP_leftA1';
options.eeg.source.labels         = {'MSP_leftA1', 'MSP_rightA1', 'MSP_leftSTG', 'MSP_rightSTG', 'MSP_leftIFG', 'MSP_rightIFG'};
options.eeg.source.overwrite      = 1;

end