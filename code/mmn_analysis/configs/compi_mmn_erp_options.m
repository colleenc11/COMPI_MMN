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
options.eeg.erp.channels    = {'C3', 'C1', 'Cz', 'FC1', 'FC2', 'FC3', 'FC4', ...
                              'FC6', 'FCz', 'F1', 'F2', 'Fz', 'Fpz', 'P5', ...
                              'P7', 'P8', 'P9', 'P10', 'PO7', 'PO8','POz', ...
                              'Pz', 'O2', 'O1', 'TP7', 'C6', 'TP8', 'T8', ...
                              'Oz', 'PO3', 'P4'};

options.eeg.erp.overwrite   = 1;
end
