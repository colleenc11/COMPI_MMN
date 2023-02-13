function compi_delta1_GFSocial(options)


chanlabel = {'F5'};
regressor = 'delta1';

% specify groups
low_social = {'0103','0113','0115','0122','0129','0130','0136'};

high_social = setdiff(options.subjects.IDs{1},{ ...
    '0103','0113','0115','0122','0129','0130','0136'})';


% Output groups (just in case)
subjects.group_labels = {'low_social','high_social'};
subjects.IDs{1} = low_social;
subjects.IDs{2} = high_social;

%% Collect Data

% data from both conditions serve as input for drug differences in
% difference waves
for i_group = 1:length(subjects.group_labels)
    options.condition = char(subjects.group_labels{i_group});
    
    allChanData.(options.condition).data = [];
    for sub = 1: length(subjects.IDs{i_group})
        subID = char(subjects.IDs{i_group}{sub});

        details = compi_get_subject_details(subID, options);

        erpfiles{sub, 1} = fullfile(details.eeg.erp.root, regressor, [regressor '.mat']);
  
    end

    channel = char(chanlabel{1});
    ga = tnueeg_grandmean_with_error(erpfiles, channel, regressor, 1);

    diffData.(options.condition).mean = ga.diff.mean;
    diffData.(options.condition).std = ga.diff.sd;
    diffData.(options.condition).nsubjects = length(subjects.IDs{i_group});
    diffData.(options.condition).error = std(ga.diff.data)/diffData.(options.condition).nsubjects;
    diffData.(options.condition).time = ga.diff.time;

end

%% -- Figure ---------------------------------------------------%

cols.lightred   = [255 0 0]/255;
cols.blue = [0, 0.4470, 0.7410];

lineColors = [cols.blue; cols.lightred];
lineWidth = 2;

titleStr = [regressor ' difference waves at ' channel];
saveName = fullfile(options.roots.diag_eeg, ['ga_' regressor '.fig']);

tnueeg_plot_grandmean_with_sem(diffData, titleStr, subjects.group_labels, saveName, lineColors, lineWidth);

end