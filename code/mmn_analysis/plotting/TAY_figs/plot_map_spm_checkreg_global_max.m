function  plot_map_spm_checkreg_global_max(fileName, fileUnsmoothedForContour, ...
   maxStat, cmap, threshContourF)
% plots statistical map using SPM check reg, using a one-color-based
% colormap and maximum adjustment to the global stat max
% - also is able to plot peak threshold clusters within cluster threshold FWE
%   correction as contours
% - also is able to plot binary mask only of significant voxels in primary
%   color (leave fileName empty then and use fileUnsmoothedForContour
%   instead)
%
% IN
%   fileName    F map (thresholded by cluster/peak FWE correction)
%               if empty, and fileUnsmoothedForContour is specified, a
%               binary mask of activated voxels (height threshold
%               threshSignificantF!) is plotted, to make small clusters
%               more visible, e.g. for peak-FWE correction
%   doSmooth    set false for display with nearest neighbour
%               if true, smoothing of F map is recommended, since linear
%               interpolation misrepresents edges of significant clusters
%   threshSignificantF
%               threshold for significance (above that color map is
%               started)
%   maxStat     max statistical value in map, reflects white color in
%               colormap
%   startColor  an RGB color (usually a primary/secondary color) used at
%               the significance threshold
%   nColorsTotal
%               numnber of colors in color map (e.g. 64)
%   threshContourF
%               second threshold (lower than max, typicially higher than
%               threshSignificantF), puts additional contour in plot
%               leave [] to omit plotting
%               useful for plotting peak-FWE extent within cluster level correction
%   fileUnsmoothedForContour
%               when plotting a peak level FWE correction extent contour
%               for a smoothed map, there could be contours missing due to
%               the height reduction of the smoothing. Therefore, contours
%               are better drawn on the unsmoothed data. However, this
%               usually needs the transformed map image data (by CheckReg)
%               and needs a different plotting procedure plotting both
%               images.
%               default: []
%               if set, 2 check-regs are plotted and the contour option
%               of SPM used; otherwise, the contour is drawn with a
%               modified version of spm_ov_contour in this file using the
%               (smoothed) map from the MIP plot itself as a basis
%   See also tnufmri/Utils/spm_add_contour and spm_ov_contour

global st; % global variable holding internal information about checkreg images


% if nargin < 7
%     threshContourF = [];
% end
% 
% if nargin < 8
%     fileUnsmoothedForContour = {};
% end

doSmooth = true;

doUseUnsmoothedMapForContour = doSmooth && ~isempty(fileUnsmoothedForContour);

doPlotUnsmoothedMapAsMaskOnly = isempty(fileName);
% loading F-map, switch off crosshairs

if doUseUnsmoothedMapForContour
    
    %% write binaryMask for contour, plot with checkReg to get Coloring
    V = spm_vol(fileUnsmoothedForContour);
    M = spm_read_vols(V);
    
    fileMaskUnsmoothedForContour = spm_file(fileUnsmoothedForContour, 'prefix', 'contour_mask_');
    V.fname = fileMaskUnsmoothedForContour;
    M(M<threshContourF) = 0;
    M(M>=threshContourF) = 1;
    spm_write_vol(V, M);
    
    spm_check_registration(fileMaskUnsmoothedForContour);
    
    % Get SPM-computed adjusted image data for mask;
    for d = 1:3
        CDataPerProjection{d} = st.vols{1}.ax{d}.d.CData;
    end
    
end

%% Plot with specified interpolation, but without crosshairs
if doPlotUnsmoothedMapAsMaskOnly
    fileName = fileMaskUnsmoothedForContour;
    threshSignificantF = 0.1; % to have all significant voxels still plotted. even after interpolation
    maxStat = 2; % to remain at primary color for plot!
end

% same image for contour and MIP plot
spm_check_registration(fileName);


spm_orthviews('Xhairs','off');

%%%% go to global max %%%%%
%spm_orthviews('reposition',glmaxpositionArray(iFile,:));
spm_orthviews('goto_max', 'global', 1);

%% adjust window from command line
st.vols{1}.window = [0 maxStat]; % window for first image (one displayed only)
spm_orthviews('Redraw')

colormap(cmap);

%%
doPlotContour = ~isempty(threshContourF) && ~doPlotUnsmoothedMapAsMaskOnly;

if doPlotContour
    
    % copied and modified from spm_ov_contour('display')
    
    %% Use matlab contour with a single line
    
    % plot params
    linewidth = 4;
    nblines = 1;
    linestyle = 'k:';
    i = 1; % only single image in this checkReg
    o = 1; % ...and used itself for plotting contour on it
    
    % determine color map scaling Fmap -> CheckReg (SPM rescales to 64 colors
    % color map
    maxCheckRegCData = max([
        reshape(st.vols{i}.ax{1}.d.CData, [],1)
        reshape(st.vols{i}.ax{2}.d.CData, [],1)
        reshape(st.vols{i}.ax{2}.d.CData, [],1)
        ]);
    scalingCheckRegFmap = maxCheckRegCData/maxStat;
    threshContourF = threshContourF * scalingCheckRegFmap;
    
    %% basically copy of spm_ov_contour, l. 119 ff from here:
    lh = {};
    sw = warning('off','MATLAB:contour:ConstantData');
    
    %% all three ortho views of checkReg
    for d = 1:3
        
        if doUseUnsmoothedMapForContour
            CData = CDataPerProjection{d};
        else
            % Make mask from same MIP image on the fly (possibly
            % smoothed!)
            CData = sqrt(sum(get(st.vols{i}.ax{d}.d,'CData').^2, 3));
            CData(isinf(CData)) = NaN;
            CData(isnan(CData)) = 0;
            
            % make binary mask for single contour
            CData(CData < threshContourF) = 0;
            CData(CData >= threshContourF) = 1;
        end
        
        for h = o(:)'
            set(st.vols{h}.ax{d}.ax,'NextPlot','add');
            [C,lh{end+1}] = ...
                contour(st.vols{h}.ax{d}.ax,CData,...
                nblines,linestyle,'LineWidth',linewidth);
        end
    end
    warning(sw);
    set(cat(1,lh{:}),'HitTest','off');
    
    st.vols{i}.contour.images = o;
    st.vols{i}.contour.handles = lh;
    
end





