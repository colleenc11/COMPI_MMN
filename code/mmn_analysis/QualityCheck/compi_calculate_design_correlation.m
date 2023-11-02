function compi_calculate_design_correlation(options)
%--------------------------------------------------------------------------
% COMPI_CALCULATE_DESIGN_CORRELATION calculate design correlation for 
% each subject.
% 
%   IN:     options - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

% Initalize table to store correlation values for each subject and design type
correlationTable = array2table(zeros(length(options.subjects.all), ...
                    length(options.eeg.stats.design_types)), ...
                    'VariableNames', options.eeg.stats.design_types);

% Loop through each design type
for i_reg = 1:length(options.eeg.stats.design_types)

    design_type = options.eeg.stats.design_types{i_reg};
    options = compi_get_design_regressors(design_type, options);

    % Loop through each subject to compute correlation
    for idCellIdx = 1:length(options.subjects.all)
        idCell = options.subjects.all{idCellIdx};
        id = char(idCell);

        % Get subject-specific details
        details = compi_get_subject_details(id, options);
    
        % Load pruned design matrix for current subejct
        fileDesignMatrix = fullfile(details.dirs.preproc, 'design_Pruned.mat');
        design = getfield(load(fileDesignMatrix), 'design');
    
        % Calculate correlation between two regressors
        [R,~] = corrcoef(design.(options.eeg.stats.regressors{1}), design.(options.eeg.stats.regressors{2}));
        correlationValue = R(1, 2);
    
        % Store correlation value in table
        correlationTable{idCellIdx, i_reg} = correlationValue;
    end
end

% Save table
save(fullfile(options.roots.behav, 'correlationTable.mat'),'correlationTable');