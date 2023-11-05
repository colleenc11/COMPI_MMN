function options = compi_get_design_regressors(design, options)
%--------------------------------------------------------------------------
% COMPI_GET_DESIGN_REGRESSORS Get model or erp-based regressors for 
% specific design matrix 
% 
%   IN:     design  - design matrix type
%           options - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

options.eeg.stats.design = design;

switch design
    case 'epsilons'
        options.eeg.stats.regressors = {'epsilon2', 'epsilon3'};
    case 'lowPE'
        options.eeg.stats.regressors = {'delta1', 'psi2'};
    case 'highPE'
        options.eeg.stats.regressors = {'delta2', 'psi3'};
    case 'oddball' 
        options.eeg.stats.regressors = {'oddball'}; 
    case 'oddball_stable' 
        options.eeg.stats.regressors = {'oddball_stable'};
    case 'oddball_volatile' 
        options.eeg.stats.regressors = {'oddball_volatile'};
end



end