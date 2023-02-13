function compi_loop_analyze_subject(options)
% -------------------------------------------------------------------------
% Loops over subjects in COMPI study and executes all analysis steps
% IN
%       options     (subject-independent) analysis pipeline options,
%                   retrieve via options = compi_set_analysis_options
% ------------------------------------------------------------------------- 

%% Preperation: preprocessing, eye-blink correction, image smoothing


for idCell = options.subjects.all
    id = char(idCell);

    compi_eeg_subject_analysis(id, options);

end


end