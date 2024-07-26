function [options] = compi_mmn_erp_options(options)
%--------------------------------------------------------------------------
% COMPI_MMN_ERP_OPTIONS ERP analysis options for COMPI MMN study.
% IN
%       options       (subject-independent) analysis pipeline options
%                     options = compi_set_analysis_options
%--------------------------------------------------------------------------

options.eeg.erp.averaging   = 'r'; % s (standard), r (robust)
switch options.eeg.erp.averaging
    case 'r'
        options.eeg.erp.addfilter = 'f';
    case 's'
        options.eeg.erp.addfilter = '';
end

options.eeg.erp.contrastWeighting   = 1;
options.eeg.erp.contrastPrefix      = 'diff_';
options.eeg.erp.contrastName        = 'mmn';
options.eeg.erp.percentPe           = 10;

options.eeg.erp.electrode   = 'Fz';
options.eeg.erp.channels    = {'C1', 'Cz', 'C3', 'C5', 'CP5',...
                               'P7', 'P8', 'PO7', 'PO8', ...
                               'FC1', 'FC2', 'FC3', 'FCz', 'Fz', 'F1', 'F2', 'F3'};

options.eeg.erp.overwrite   = 1;
end
