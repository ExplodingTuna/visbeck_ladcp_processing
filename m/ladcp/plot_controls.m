function [] = plot_controls(fig,figExt,files)
% function [] = plot_controls(fig)
%
% reloads the stored figure into the display window
%
% input  :  fig             - figure number
%
% version 2  last change 13.07.2013

% G.Krahmann, GEOMAR

% added clf                                 GK, 13.07.2013  1-->2

global mh

sfigure(2);
clf

if isempty(fig) 
fig=1;
end

fName=[files,filesep,int2str(fig),'.',figExt];

if exist(fName,'file')
    clf;
    ha = axes('units','normalized','position',[0 0 1 1]);
    % Move the background axes to the bottom
    %uistack(ha,'bottom');
    h=imread(fName);
    image(h);
    %set(ha,'handlevisibility','off', 'visible','off');

else
set(gcf,'Color', 'white')
text(0.3,0.5,'No Figure Available','fontsize',16,'color','r')

end
%figload(['tmp',filesep,int2str(fig),'.',figExt]);
%openfig(['tmp',filesep,int2str(fig),'.fig']);

sfigure(1);
for n=1:length(mh)
    if mh(n)~=0
        set(mh(n),'foregroundcolor',[0,0,0]);
    end
end
set(mh(fig),'foregroundcolor',[1,0,0]);
