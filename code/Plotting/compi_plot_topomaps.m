function compi_plot_topomaps(options)

% First create, difference grand-average
% Second, convert grand-average to image

options.condition = 'HC';
factor = 'oddball';
timewindow = [150 200]; % [150 200]

GAroot = fullfile(options.roots.erp, options.condition, factor, 'GA');

% choose on subject ID for plotting electrode locations
id = '0101';
details =  compi_get_subject_details(id, options);
% determine the preprocessed file to use for conversion
prepfile = details.eeg.prepfile;
conf.D = spm_eeg_load(prepfile);

% use the T/F-statistic image of the contrast for the scalpmap
conf.img = fullfile(GAroot, ['diff_GA_' factor], 'condition_diff.nii');

map = colormap('jet');
conf.cfg.colormap = map;
conf.cfg.colorbar = 'yes';

conf.colmap.limits = [-2 2];
conf.cfg.zlim = [-2 2];

conf.cfg.marker = 'on'; % 'on', 'labels'
conf.cfg.markersymbol       = '.';
conf.cfg.markercolor        = [0 0 0];
conf.cfg.markersize         = 20;
conf.cfg.markerfontsize     = 12;
conf.cfg.comment            = 'xlim';

S.image     = fullfile(GAroot, ['diff_GA_' factor], 'condition_diff.nii');

S.D         = conf.D;
S.configs   = conf;

S.window = timewindow;
S.style = 'ft';

F = tnueeg_spm_eeg_img2maps(S);


end