function [hf] = getSubplot(ax)
ha = ax;
ud.ha = ha;
ud.op = get (ha, 'parent');
ud.pos = get (ha, 'position');
ud.unit = get (ha, 'units');
ud.fontsize = get (ha, 'fontsize');
ud.col = get (getParentFigure (ha), 'colormap');

% first deal with potential associated colorbars
ud.hclb = [];
hclb = intersect(findobj('tag','Colorbar'),get(get(ha,'parent'),'children'));
for i=1:length(hclb)
    [haa] = findAxes4Colorbar(hclb(i),hclb);
    if isequal(haa,ha)
        ud.hclb = hclb(i);
        ud.clbFontsize = get(hclb(i),'fontsize');
        break
    end
end

% then deal with potential legends
ud.leg = [];
hleg = intersect(findobj('tag','legend'),get(get(ha,'parent'),'children'));
for i=1:length(hleg)
    try % matlab 7.1?
        tmp = get(hleg(i),'userdata');
        pos = get(hleg(i),'position');
        haa = tmp.PlotHandle;
        if isequal(haa,ha)
            ud.leg.h = hleg(i);
            ud.leg.pos = pos;
            break
        end
    end
end

% get new graphical object properties
%huic = findobj('Label','Export axes to figure');
%big = get(huic(1),'userdata');
big = struct;

hf = figure('visible','off','color',[1 1 1],'colormap',ud.col);
set(ha,'parent',hf,'position',[0.15,0.15,0.65,0.75],'fontsize',16);

if ~isempty(ud.hclb)
    set(ud.hclb,'parent',hf);
    set(ud.hclb,'fontsize',16);
end
if ~isempty(ud.leg)
    set(ud.leg.h,'parent',hf);
end

hli = findobj('type','line');
hhg = findobj('type','hggroup');
hc = get(ha,'children');
hc0 = intersect(hc,hhg);
hc2 = [];
for i=1:length(hc0)
    hc2 = [hc2;intersect(get(hc0(i),'children'),hli)];
end
hc = [intersect(hc,hli);hc2];

nc = length(hc);
for i=1:nc
    try
        ud.linewidth(i) = get(hc(i),'linewidth');
        set(hc(i),'linewidth',big.LineWidth);
        ud.MarkerSize(i) = get(hc(i),'MarkerSize');
        set(hc(i),'MarkerSize',big.MarkerSize);
    end
end

ht = get(ha,'title');
ud.titleFontsize = get(ht,'fontsize');
set(ht,'fontsize',16);

hlx = get(ha,'xlabel');
ud.xlbFontsize = get(hlx,'fontsize');
set(hlx,'fontsize',16);

hly = get(ha,'ylabel');
ud.ylbFontsize = get(hly,'fontsize');
set(hly,'fontsize',16);

hlz = get(ha,'zlabel');
ud.zlbFontsize = get(hlz,'fontsize');
set(hlz,'fontsize',16);

set(hf,'visible','on','userdata',ud,'DeleteFcn',{@closeFig,big})

% 
% % callback that put back the axes in place when closing the popup
% % =========================================================================
% function closeFig(hf,e2,big)
% ud = get(hf,'userdata');
% try
%     hfig = getParentFigure (ud.op);
%     hcmenu = uicontextmenu('parent',hfig);
%     uimenu(hcmenu,'Label','Export axes to figure','Callback',@getSubplot,'userdata',big);
%     set(ud.ha,'parent',ud.op,'position',ud.pos,'units',ud.unit,'fontsize',ud.fontsize,'uicontextmenu',hcmenu)
%     hli = findobj('type','line');
%     hhg = findobj('type','hggroup');
%     hc = get(ud.ha,'children');
%     hc0 = intersect(hc,hhg);
%     hc2 = [];
%     for i=1:length(hc0)
%         hc2 = [hc2;intersect(get(hc0(i),'children'),hli)];
%     end
%     hc = [intersect(hc,hli);hc2];
%     nc = length(hc);
%     for i=1:nc
%         try
%             set(hc(i),'linewidth',ud.linewidth(i));
%             set(hc(i),'MarkerSize',ud.MarkerSize(i));
%         end
%     end
%     ht = get(ud.ha,'title');
%     set(ht,'fontsize',ud.titleFontsize);
%     hlx = get(ud.ha,'xlabel');
%     set(hlx,'fontsize',ud.xlbFontsize);
%     hly = get(ud.ha,'ylabel');
%     set(hly,'fontsize',ud.ylbFontsize);
%     hlz = get(ud.ha,'zlabel');
%     set(hlz,'fontsize',ud.zlbFontsize);
%     if ~isempty(ud.hclb)
%         set(ud.hclb,'parent',ud.op);
%         set(ud.hclb,'fontsize',ud.clbFontsize);
%     end
%     if ~isempty(ud.leg)
%         set(ud.leg.h,'parent',ud.op,'position',ud.leg.pos);
%     end
% end
% 
% % 
% % =========================================================================
% function [haa] = findAxes4Colorbar(hclbi,hclb)
% pos0 = get(hclbi,'position');
% ha = intersect(findobj('type','axes'),get(get(hclbi,'parent'),'children'));
% ha = setdiff(ha,hclb);
% pos = zeros(length(ha),4);
% for i=1:length(ha)
%     pos(i,:) = get(ha(i),'position');
% end
% dx1 = pos0(1) - pos(:,1);
% dx2 = pos0(1) - (pos(:,1)+pos(:,3));
% dy1 = pos0(2) - pos(:,2);
% dy2 = pos0(2) - (pos(:,2)+pos(:,4));
% switch get(hclbi,'Location')
%     case {'North', 'NorthOutside', 'north', 'northoutside'}
%         ind = find(dy1>=0);
%         [~,subind] = min(dx1(ind).^2+dy2(ind).^2);
%         haa = ha(ind(subind));
%     case {'South', 'SouthOutside', 'south', 'southoutside'}
%         ind = find(dy1<=0);
%         [~,subind] = min(dx1(ind).^2+dy2(ind).^2);
%         haa = ha(ind(subind));
%     case {'East','EastOutside', 'east', 'eastoutside'}
%         ind = find(dx1>=0);
%         [~,subind] = min(dy1(ind).^2+dx2(ind).^2);
%         haa = ha(ind(subind));
%     case {'West','WestOutside', 'west', 'westoutside'}
%         ind = find(dx1<=0);
%         [~,subind] = min(dy1(ind).^2+dx2(ind).^2);
%         haa = ha(ind(subind));
% end


       
% get handle of hosting figure
% =========================================================================        
function h = getParentFigure (h)
    while ~ isequal (get (h, 'type'), 'figure')
        h = get(h,'parent');
    end