function [varargout]=plotww3(ww3,rng,fgcolor,bgcolor,ax)
%PLOTWW3    Plots WaveWatch III data (requires READ_GRIB struct)
%
%    Usage:    h=plotww3(ww3)
%              h=plotww3(ww3,rng)
%              h=plotww3(ww3,rng,fgcolor,bgcolor)
%              h=plotww3(ww3,rng,fgcolor,bgcolor,h)
%
%    Description: H=PLOTWW3(WW3) plots the WaveWatch III data contained in
%     the struct WW3 generated by READ_GRIB.  This has only been tested on
%     plotting the global significant wave heights.  H is the handle to the
%     axes that the map was plotted in.
%
%     H=PLOTWW3(WW3,RNG) sets the limits for coloring the data. The default
%     is [0 15] which works well for significant wave height.
%
%     H=PLOTWW3(WW3,RNG,FGCOLOR,BGCOLOR) specifies foreground and
%     background colors of the plot.  The default is 'w' for FGCOLOR & 'k'
%     for BGCOLOR.  Note that if one is specified and the other is not, an
%     opposing color is found using INVERTCOLOR.  The color scale is also
%     changed so the noise clip is at BGCOLOR.
%
%     H=PLOTWW3(WW3,RNG,FGCOLOR,BGCOLOR,H) sets the axes to draw in.  This
%     is useful for subplots, guis, etc.
%
%    Notes:
%
%    Examples:
%     Read the first record of a NOAA WW3 grib file and plot it up:
%      ww3=read_grib('nww3.hs.200607.grb',1);
%      ax=plotww3(ww3);
%
%    See also: READ_GRIB, WW3MOV

%     Version History:
%        June 15, 2010 - initial version
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated June 15, 2010 at 22:00 GMT

% todo:

% check nargin
error(nargchk(1,5,nargin));

% check grib
% need fields fltarray, description, units, stime
%             gds (La1, La2, Dj, Nj, Lo1, Lo2, Di, Ni)
top={'fltarray' 'description' 'units' 'stime' 'gds'};
gds={'La1' 'La2' 'Dj' 'Nj' 'Lo1' 'Lo2' 'Di' 'Ni'};
if(~isstruct(ww3) || ~isscalar(ww3) ...
        || any(~ismember(top,fieldnames(ww3))) ...
        || any(~ismember(gds,fieldnames(ww3.gds))))
    error('seizmo:plotww3:badWW3',...
        'WW3 must be a struct generated by READ_GRIB!');
end

% default/check color limits
if(nargin==1 || isempty(rng)); rng=[0 15]; end
if(~isreal(rng) || numel(rng)~=2)
    error('seizmo:plotww3:badRNG',...
        'RNG must be a real valued 2 element vector!');
end
rng=sort([rng(1) rng(2)]);

% check colors
if(nargin<3)
    fgcolor='w';
    bgcolor='k';
elseif(nargin<4)
    if(isempty(fgcolor))
        fgcolor='w'; bgcolor='k';
    else
        bgcolor=invertcolor(fgcolor,true);
    end
else
    if(isempty(fgcolor))
        if(isempty(bgcolor))
            fgcolor='w'; bgcolor='k';
        else
            fgcolor=invertcolor(bgcolor,true);
        end
    elseif(isempty(bgcolor))
        if(isempty(fgcolor))
            fgcolor='w'; bgcolor='k';
        else
            bgcolor=invertcolor(fgcolor,true);
        end
    end
end

% check handle
if(nargin<5 || isempty(ax) || ~isscalar(ax) || ~isreal(ax) ...
        || ~ishandle(ax) || ~strcmp('axes',get(ax,'type')))
    figure('color',bgcolor);
    ax=gca;
else
    axes(ax);
end

% get lat/lons
% - global grid is extended 90deg to have some overlap
% - location corresponds to Center-Left of pixel
lat=ww3.gds.La2:ww3.gds.Dj:ww3.gds.La1;
overlap=0; if(ww3.gds.Di*ww3.gds.Ni==360); overlap=-90; end
lon=(ww3.gds.Lo1+overlap:ww3.gds.Di:ww3.gds.Lo2)+ww3.gds.Di/2;

% get array
map=reshape(ww3.fltarray,ww3.gds.Ni,ww3.gds.Nj).';

% wrap 90deg to front
if(overlap); map=[map(:,end*3/4+1:end) map]; end

% plot map
imagesc(lon,lat,map);
set(ax,'xcolor',fgcolor,'ycolor',fgcolor,...
    'color',bgcolor,'fontweight','bold','clim',rng);

% set ticks on global map
if(overlap); set(ax,'xtick',-90:90:360,'ytick',-90:30:90); end

% labeling
title(ax,{'NOAA WaveWatch III Hindcast' ww3.description ww3.stime},...
    'fontweight','bold','color',fgcolor);
xlabel(ax,'Longitude (deg)',...
    'fontweight','bold','color',fgcolor);
ylabel(ax,'Latitude (deg)',...
    'fontweight','bold','color',fgcolor);

% colormap
if(strcmp(bgcolor,'w') || isequal(bgcolor,[1 1 1]))
    colormap(flipud(fire));
elseif(strcmp(bgcolor,'k') || isequal(bgcolor,[0 0 0]))
    colormap(fire);
else
    colormap(fire);
end

% colorbar
c=colorbar('eastoutside','peer',ax,...
    'fontweight','bold','xcolor',fgcolor,'ycolor',fgcolor);
xlabel(c,ww3.units,'fontweight','bold','color',fgcolor)
axis equal tight;

% output if wanted
if(nargout); varargout{1}=ax; end

end
