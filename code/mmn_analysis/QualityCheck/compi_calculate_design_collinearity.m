function compi_calculate_design_collinearity(options)
%--------------------------------------------------------------------------
% COMPI_CALCULATE_DESIGN_COLLINEARITY calculate design collinearity for each subject
% 
%   IN:     options - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------
% Calculate design collinearity for each subject
collinearityTable = array2table(zeros(length(options.subjects.all), length(options.eeg.stats.design_types)), ...
                                'VariableNames', options.eeg.stats.design_types);

for i_reg = 1:length(options.eeg.stats.design_types)

    design_type = options.eeg.stats.design_types{i_reg};
    options = compi_get_design_regressors(design_type, options);

    for idCellIdx = 1:length(options.subjects.all)
        idCell = options.subjects.all{idCellIdx};
        id = char(idCell);

        details = compi_get_subject_details(id, options);
    
        fileDesignMatrix = fullfile(details.dirs.preproc, 'design_Pruned.mat');
        design = getfield(load(fileDesignMatrix), 'design');
    
        [R,~] = corrcoef(design.(options.eeg.stats.regressors{1}), design.(options.eeg.stats.regressors{2}));
        collinearityValue = R(1, 2);
    
        % Append a new row to the table for the current subject
        newRow = table(collinearityValue);
        collinearityTable{idCellIdx, i_reg} = collinearityValue;
    end
end

% Save table
save(fullfile(options.roots.results_behav, 'collinearityTable.mat'),'collinearityTable');