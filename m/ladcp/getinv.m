function [messages,p,dr,ps,de,der]=getinv(messages,values,di,p,ps,dr,iplot)
% function [messages,p,dr,ps,de,der]=getinv(messages,values,di,p,ps,dr,iplot)
%
% solve linear inverse problem for LADCP profiles
%
% input  :  messages    - array of warnings
%           values      - structure of derived values
%           di
%           p           - structure of processing parameters
%           ps          - structure of processing parameters
%           dr
%           iplot [0]   - plot results (1) or not (0)
%
% output :  messages    - array of warnings
%           p           - structure of processing parameters
%
% - solve linear inverse problem
%
% version 0.8   last change 05.11.2013

%  Martin Visbeck, LDEO, April-2000
% small bug fix                                        GK, May 2007  0.1-->0.2
% increased minimum sadcp error to 0.01m/s             GK, Jul 2007  0.2-->0.3
% changed exist commands                               GK, Sep 2007  0.3-->0.4
% catch ps.velerr==0                                   GK, Sep 2007  0.4-->0.5
% plot supens std based weights                        GK, 10.06.2011  0.5-->0.6
% renamed cosd and sind to cos_d and sin_d             GK, 13.07.2012  0.6-->0.7
% use smallfac from setting outside, when set          GK, 05.11.2013  0.7-->0.8

%
% general function info
%
disp(' ')
disp('GETINV:  compute optimal velocity profile')


if nargin<7 
  iplot = 0; 
end



% resolution of final profile in meter
ps = setdefv(ps,'dz',nmedian(abs(diff(di.izm(:,1)))));


% how much do you want to smooth the ocean profile
imax = ceil(values.maxdepth/500);
if ~isfield(ps,'smallfac')
  smallfac = [1 0];
  for n=1:imax
    smallfac(n,1) = n;
    smallfac(n,2) = 0.02/(1+abs(n-(imax/2)))*tanh(values.maxdepth/3000);
  end
  ps.smallfac = smallfac;
end


% weigh bottom track data with distance of bottom
% ps=setdefv(ps,'btrk_weight_nblen',[15 5]);

%
% Check for magnetic deviation
%
% I do not really understand this !!!!!!!!!!!!  GK
%
if p.magdev==0 && values.lat==0 && values.lon==0
  warn = [' magnetic deviation given is NAN '];
  messages.warnp = strvcat(messages.warnp,warn);
  p.rot = 0;
  ps.sadcpfac = 0;
  ps.barofac = 0;
%  ps.botfac=0; %%% NOT NEEDED?!
  ps.dragfac = 0;
end


%
% Barotropic velocity error due to navigation error
%
ps = setdefv(ps,'barvelerr',2*p.nav_error/p.dt_profile);
disp(['    Barotropic (navigation) velocity error : ',num2str(ps.barvelerr),' [m/s]'])


%
% Super ensemble velocity error
%
maxn = min(length(di.izd),7);
sw = nstd(di.rw(di.izd(1:maxn),:)); 
ii = find(sw>0);
sw = nmedian(sw(ii))/tan(values.down_beam_angle*pi/180);
disp(['    Super ensemble velocity error : ',num2str(sw),' [m/s]'])
ps = setdefv(ps,'velerr',nmax([sw,0.02])); 
if exist('dr','var')
  if isfield(dr,'uerr')
    if any(isfinite(dr.uerr))
      ps.velerr = nmedian(dr.uerr);
      if ps.velerr==0
        ps.velerr = 0.02;
      end
      disp(['    Setting velocity error to :',num2str(ps.velerr),' [m/s]'])
      disp(['    RDI standard deviation (down,up) :',num2str(values.rdi_std),' [m/s]'])
    end
  end
end
 

disp(['    Vertical resolution (ps.dz) is ',num2str(ps.dz),' [m]'])

[nbin,nt] = size(di.ru);

%### set up matrices for inverse problem

%set up data arrays 
% restrict to up/down looker
if ps.up_dn_looker==2
  di.weight(di.izu,:) = nan;
  disp('    Restricting inversion to down looking instrument only')
elseif ps.up_dn_looker==3
  di.weight(di.izd,:) = nan;
  disp('    Restricting inversion to up looking instrument only')
  p = rmfield(p,'zbottom');
end


%
%  velocities are complex
%
d = di.ru+sqrt(-1)*di.rv;
d = reshape(d,nbin*nt,1);


%
% bottom track velocity
%
if isfield(p,'zbottom');
  bvel = di.bvel(1,:)+sqrt(-1)*di.bvel(2,:);
  bvels = sqrt(di.bvels(1,:).^2+di.bvels(2,:).^2);
  if sum(ps.btrk_weight_nblen) > 0

    % normalize btweight with gaussian centered at 5 bin-lengths from bottom
    hbot = di.z+p.zbottom;
    hm = abs(diff(di.izm([-1:0]+end,1)))*ps.btrk_weight_nblen(1);
    hs = abs(diff(di.izm([-1:0]+end,1)))*ps.btrk_weight_nblen(2);
    whbot = exp(-(hbot-hm).^2./(hs).^2);
    bvels = bvels./whbot;
    disp(['    Weighted bottom tracks with a Gaussian centered ',...
        int2str(ps.btrk_weight_nblen(1)),...
	' bins above bottom and with a width of ',...
        int2str(ps.btrk_weight_nblen(2)),' bins '])
  end
  dbot = meshgrid(bvel,1:nbin);
  dbot = reshape(dbot,nt*nbin,1);
end


%
% bin depths
%
izv = reshape(-di.izm,nbin*nt,1);


%
% profile number
%
jprof = cumsum(ones(nbin,nt)')';
jprof = reshape(jprof,nbin*nt,1);


%
% bin number
%
jbin = meshgrid(1:nbin,1:nt)';
jbin = reshape(jbin,nbin*nt,1);


%
% derive data weight
%
weight_matrix_correlation_based = di.weight.^ps.weightpower;
weight_matrix_supens_std_based = ps.velerr./di.ruvs+di.weight*0;
if ps.std_weight~=1;

  % use correlation based estimator
  disp('    Using correlation based weights (figure 16 middle graph)')
  wm  = weight_matrix_correlation_based;

else

  % use super ensemble based estimator
  disp(['    Using super ensemble std based weights normalized by ',...
       num2str(ps.velerr),' m/s (figure 16 lower graph)'])
  wm  = weight_matrix_supens_std_based;

end


if is_octave < 1
    figExt ='fig';
else
    figExt ='ofig';
end

figload(['tmp',filesep,'16.',figExt],2);
%openfig(['tmp',filesep,'16.fig'],2);
subplot(3,1,3);
imagesc(weight_matrix_supens_std_based);
csc = caxis;
colorbar
xlabel('Super Ensemble #');
ylabel('Bin #');
title('Weights based on standard deviation of super ensembles')

streamer([p.name,' Figure 16']);
hgsave(['tmp',filesep,'16'])

wm = reshape(wm,nt*nbin,1);



%
% other arrays used
%
dtiv = di.dt;
tim = di.time_jul;
zctd = di.z;
slat = di.slat;
slon = di.slon;
if isfinite(sum(slon+slat))
  xship = (slon-slon(1))*60*1852*cos_d(values.lat);
  yship = (slat-slat(1))*60*1852;
  uship = diff(xship)./diff(tim)/(86400);
  vship = diff(yship)./diff(tim)/(86400);
  shipvel = uship+sqrt(-1)*vship;
  shipvel = mean([shipvel([1,1:end]);shipvel([1:end,end])]);
  % get a smooth ship surface velocity
  tim1 = tim-tim(1);
  shipvelf = polyval(polyfit(tim1,shipvel,3),tim1);
  n = 0;
  if length(shipvel)>5
    while (n<50 & std(abs(shipvel-shipvelf))>0.15) | i==0
      shipvel=mean([shipvel([3:end,end,end]);shipvel([2:end,end]);...
         shipvel;shipvel([1,1:(end-1)]);shipvel([1,1,1:(end-2)])]);
      n = n+1;
    end
    disp(['    Preaveraged GPS ship vel ',int2str(n),' times '])
  end
else
  % no GPS ship navigation time series, assume constant ship velocity
  uship_a = values.uship+sqrt(-1)*values.vship;
  shipvel = uship_a+di.z*0;
end


%
% mean CTD vertical velocity
%
wctd = nmean(di.rw);

if ps.dragfac>0
  shipdragvel = shipvel;
  if exist('dr','var')
    % compute the ocean flow at the depth of the CTD
    ut = interp1(dr.z,dr.u,-di.z);
    vt = interp1(dr.z,dr.v,-di.z);
    shipdragvel = shipvel-(ut+sqrt(-1)*vt);
  end
  % derive estimate for CTD velocity using ship velocity
  % and vertical velocity and wireangle
  %  0.2 of W-velocity project horizontal for 1 m/s
  tiltfac = ps.drag_tilt_vel*abs(shipdragvel).*(1-tanh(-di.z/8000));
  % preject fration of vertical velocity in ships velocity direction
  wctdf = -shipdragvel./(abs(shipdragvel)+0.001).*wctd.*tiltfac;
  % make sure that this is not faster than ship velocity
  wfac = max(abs(wctdf)./(abs(shipdragvel)+0.001),1+wctd*0);
  wctdf = wctdf./wfac;

  for j=1:length(shipdragvel)
    zfac = tanh(-di.z(j)/ps.drag_lag_depth);
    % how many super ensembles need to be averaged
    nsmooth = sum(di.time_jul>(di.time_jul(j)-ps.drag_lag_tim/24/60) & di.time_jul<di.time_jul(j));
    ii = j-[0:fix(nsmooth*zfac)];
    ii = ii(find(ii>0));
    if length(ii)<2
      ii = j;
    end
    % smooth w less in time
    iw = ii(1:fix(end/10));
    if length(iw)<2
      iw = j;
    end
    % set the assumed ctd velocity as the sum between ship vel and projected w-vel
    ctdvel(j) = nmean(shipvel(ii))+nmean(wctdf(iw));
  end
else
  ctdvel = shipvel*NaN;
end


%
% remove last data bin  and one bin off the bottom and surface 
%
if isfield(p,'zbottom'),
  zbottom = p.zbottom;
else
  zbottom = 1e32;
end
[jmax,jbott] = max(izv);

ii = find(izv<(ps.dz) | izv>(ps.dz*(jmax-1)) | izv>(zbottom-ps.dz));

wm(ii) = 0;

% remove bad or weakly constained data

jm = max(jprof);
disp(['    Removed ',int2str(sum(wm<ps.weightmin)),...
	' constraints below minimum weight ']);
ii = find(isnan(d) | isnan(wm) | wm<ps.weightmin);
d(ii) = [];
if exist('dbot','var')
  dbot(ii) = [];
end
izv(ii) = [];
jprof(ii) = [];
jbin(ii) = [];
wm(ii) = [];


%
% remove empty profiles at the end
%
ii = (max(jprof)+1):jm;
tim(ii) = [];
ctdvel(ii) = [];
shipvel(ii) = [];
zctd(ii) = [];
wctd(ii) = [];
slat(ii) = [];
slon(ii) = [];
dtiv(ii) = [];
if exist('bvel','var')
  bvel(ii) = [];
  bvels(ii) = [];
end

[jmax,jbott] = max(izv);


%
% prepare some output arrays
%
dr.name = p.name;
dr.date = gregoria(median(tim));
dr.lat = values.lat;	% changed from p.lat  GK
dr.lon = values.lon;

% set up main matrices for inversion
A1 = lainseta(jprof,1);
Aocean = lainseta(izv,ps.dz);
[nt,nz] = size(Aocean);

% resulting depth vector
%z =([1:nz]'-.5)*ps.dz;
z = [1:nz]'*ps.dz;


A1o = A1;
A2o = Aocean;
d0 = d;

%### add weights to data
[Aocean,A1,d,idoc,iupc] = lainweig(Aocean,A1,d,wm);


%
% make sure time and depth dimension are different
%
if size(Aocean,2)==size(A1,2)
  disp('    Changing dimension of A2')
  Aocean = [Aocean,Aocean(:,1)*0]; 
  A2o = [A2o,A2o(:,1)*0];
  [nt,nz] = size(Aocean);
  z = [1:nz]'*ps.dz;
end


%
% save constraints
%
de.ocean_constraints = full(sum(abs(Aocean)));
de.ctd_constraints = full(sum(abs(A1)));
de.type_constraints = 'Velocity  ';


%
% smooth ocean and CTD velocity profiles
%
disp('    Smoothing Ocean velocity profile')
[Aocean,A1,d] = lainsmoo(Aocean,A1,d,ps.smoofac);

disp('    Smoothing CTD velocity profile')
[A1,Aocean,d] = lainsmoo(A1,Aocean,d,ps.smoofac);

de.ocean_constraints = [de.ocean_constraints;...
	sum(abs(Aocean))-(de.ocean_constraints)];
de.ctd_constraints = [de.ctd_constraints;sum(abs(A1))-(de.ctd_constraints)];
de.type_constraints = [de.type_constraints;'Smoothing '];


%
% add bottom track constraint
%
if exist('bvel','var')
  if sum(isfinite(bvel))>0 
    btweight = ps.velerr./bvels;
    [Aocean,A1,d,ubot,iubot] = lainbott(dbot.*wm,bvel,btweight,Aocean,A1,d,ps.botfac);
    if length(ubot)>0
      dr.zbot = z(iubot);
      dr.ubot = real(ubot(:,1));
      dr.vbot = imag(ubot(:,1));
      dr.uerrbot = ubot(:,2);
      % make length of array unique
      while length(dr.zbot)==nt | length(dr.zbot)==nz 
        dr.zbot = [dr.zbot;nan];
        dr.ubot = [dr.ubot;nan];
        dr.vbot = [dr.vbot;nan];
        dr.uerrbot = [dr.uerrbot;nan];
      end 
    else
      psbot = 0;
    end
    if ps.botfac>0
      disp(['    Weight for bottom track is (ps.botfac) ',num2str(ps.botfac)])
      psbot = 1;
    else
      disp('    Not enough bottom track data')
      psbot = 0; 
    end
  else
    disp('    No bottom track data')
    psbot = 0; 
  end
else
  psbot = 0;
end

de.ocean_constraints = [de.ocean_constraints;...
	sum(abs(Aocean))-sum(de.ocean_constraints)];
de.ctd_constraints = [de.ctd_constraints;sum(abs(A1))-sum(de.ctd_constraints)];
de.type_constraints = [de.type_constraints;'Bottomtrk '];


%
% add ship adcp constraint
%
if ~isempty(di.svel)
  if sum(isfinite(di.svel(:,1)))>2 
    [p,Aocean,A1,d,ds,messages] =...
            lainsadcp(p,di.svel,Aocean,A1,d,ps.dz,ps.sadcpfac,ps.velerr,messages);
    if length(ds.z_sadcp)>1
      dr.z_sadcp = di.svel(:,1);
      dr.u_sadcp = di.svel(:,2);
      dr.v_sadcp = di.svel(:,3);
      dr.uerr_sadcp = di.svel(:,4);
      % make length of array unique
      if isfield(dr,'zbot') 
        lzbot = length(dr.zbot); 
      else 
        lzbot = 0; 
      end
      while length(dr.z_sadcp)==nt | length(dr.z_sadcp)==nz | ...
        	 length(dr.z_sadcp)==lzbot
        dr.z_sadcp = [dr.z_sadcp;nan];
        dr.u_sadcp = [dr.u_sadcp;nan];
        dr.v_sadcp = [dr.v_sadcp;nan];
        dr.uerr_sadcp = [dr.uerr_sadcp;nan];
      end
    end
    if ps.sadcpfac>0
      disp(['    Weight for SADCP vel is (ps.sadcpfac) ',num2str(ps.sadcpfac)])
    else
      disp('    SADCP not used')
    end
  else
    disp('    Not enough SADCP data')
    ps.sadcpfac = 0;
  end
else
  disp('    No SADCP data')
  ps.sadcpfac = 0;
end

de.ocean_constraints = [de.ocean_constraints;...
	sum(abs(Aocean))-sum(de.ocean_constraints)];
de.ctd_constraints = [de.ctd_constraints;sum(abs(A1))-sum(de.ctd_constraints)];
de.type_constraints = [de.type_constraints;'Ship ADCP '];


%
% add barotropic constraint 
% check if position data exist 
%
uship_a = values.uship+sqrt(-1)*values.vship;
if (abs(uship_a)==0 && values.lat==0 && values.lon==0) ||...
	 ~isfinite(values.lon+values.lat)
  disp('    No position data ');
  ps.barofac = 0;
  ps.dragfac = 0;
end
if ps.barofac>0
  fac = ps.velerr/ps.barvelerr;
  % need to increase if parts of profile are missing
  ii = find(di.dt>3*mean(di.dt));
  if length(ii)>1
    facgap = sum(di.dt(ii))/sum(di.dt);
    disp(['    lainbaro: ',int2str(facgap*100),'% of profile have no useful data '])
    fac = fac*(1-tanh(facgap/0.15));
  end
  if ~isfinite(fac) 
    fac = 1; 
  end
  [Aocean,A1,d] = lainbaro(Aocean,A1,d,uship_a,dtiv,ps.barofac*fac);
end

de.ocean_constraints = [de.ocean_constraints;...
	sum(abs(Aocean))-sum(de.ocean_constraints)];
de.ctd_constraints = [de.ctd_constraints;sum(abs(A1))-sum(de.ctd_constraints)];
de.type_constraints = [de.type_constraints;'GPS naviga'];

%### small deep ocean velocity
if sum(ps.smallfac(:,2))>0
  [Aocean,A1,d] = lainsmal(Aocean,A1,d,ps.smallfac);
end

de.ocean_constraints = [de.ocean_constraints;...
	sum(abs(Aocean))-sum(de.ocean_constraints)];
de.ctd_constraints = [de.ctd_constraints;sum(abs(A1))-sum(de.ctd_constraints)];
de.type_constraints = [de.type_constraints;'Small flow'];

%### check if problem is well constrained
if (psbot==0 && ps.barofac==0 && ps.sadcpfac==0), 
  disp('    No bottom no barotropic no SADCP constraint => setting mean U,V to zero')
  dr.onlyshear = 1;
  [Aocean,A1,d] = lainocean(Aocean,A1,d);
elseif isfield(dr,'onlyshear') 
  dr = rmfield(dr,'onlyshear');
end

de.ocean_constraints = [de.ocean_constraints;...
	sum(abs(Aocean))-sum(de.ocean_constraints)];
de.ctd_constraints = [de.ctd_constraints;sum(abs(A1))-sum(de.ctd_constraints)];
de.type_constraints = [de.type_constraints;'Zero mean '];

%### add CTD drag constraint
if ps.dragfac>0
  disp(['    Weight for drag is (ps.dragfac) ',num2str(ps.dragfac)])
  [Aocean,A1,d] = laindrag(Aocean,A1,d,ctdvel,ps.dragfac);
end

de.ocean_constraints = [de.ocean_constraints;...
	sum(abs(Aocean))-sum(de.ocean_constraints)];
de.ctd_constraints = [de.ctd_constraints;sum(abs(A1))-sum(de.ctd_constraints)];
de.type_constraints = [de.type_constraints;'Drag Model'];

[ld,a1l] = size(A1);
[ld,a2l] = size(Aocean);


disp(['    ready for inversion  length of  d: ',num3str(ld,6,0)])
disp(['              (CTD vel)  length of A1: ',num3str(a1l,6,0)])
disp(['            (ocean vel)  length of A2: ',num3str(a2l,6,0)])

[uocean,uctd] = lainsolv(Aocean,A1,d,ps.solve);

% save results in output array
dr.z = z;
dr.u = real(uocean(:,1));
dr.v = imag(uocean(:,1));
if size(uocean,2)>1
  dr.uerr = (uocean(:,2));
end
dr.nvel = full(sum(A2o)');
dr.ubar = mean(dr.u);
dr.vbar = mean(dr.v);
dr.tim = tim;
dr.tim_hour = (tim-fix(tim(1)))*24;
if sum(isfinite(slat+slon))>0 || ps.dragfac>0
  dr.shiplon = slon;
  dr.shiplat = slat;
  dr.xship = (slon-slon(1))*60*1852*cos_d(values.lat);
  dr.yship = (slat-slat(1))*60*1852;
  dr.uship = real(shipvel);
  dr.vship = imag(shipvel);
end
dr.zctd = zctd;
dr.wctd = -wctd;
dr.uctd = -real(uctd(:,1))';
dr.vctd = -imag(uctd(:,1))';
if size(uctd,2)>1
 dr.uctderr = (uctd(:,2))';
end


dt = diff(tim)*24*3600;
dt = mean([0,dt;dt,0]);
ctdpos = -cumsum(uctd(:,1).*dt').';
dr.xctd = real(ctdpos);
dr.yctd = imag(ctdpos);

sfigure(2);
clf
orient tall
tim = dr.tim-fix(dr.tim(1));
uctd_drag = real(ctdvel);
vctd_drag = imag(ctdvel);
% plot some of the drag fac results
subplot(421)
plot(tim,dr.uctd,'-b','linewidth',1.8)
hold on
if isfield(dr,'uship')==1
  plot(tim,dr.uship,'g-')
end
ut=interp1(dr.z,dr.u,-dr.zctd);
ii=find(isfinite(ut+dr.uctd));
if length(ii)>5
  ii=ii(round((end*0.33):(end*0.67)));
  co=corrcoef([ut(ii)',dr.uctd(ii)']);
  ps.ucorr=co(1,2);
else
  ps.ucorr=NaN;
end
 
plot(tim,ut,'-k','linewidth',1.2)
if ps.dragfac~=0
  plot(tim,uctd_drag,'-r')
end
grid
title('ctd(-b) ship(-g) drag(-r) ocean(-k)')
ylabel(['U [m/s] corr: ',num2str(ps.ucorr)])
axis tight

subplot(422)
plot(tim,dr.vctd,'-b','linewidth',1.8)
hold on
grid
if isfield(dr,'uship')==1
  plot(tim,dr.vship,'g-')
end
vt=interp1(dr.z,dr.v,-dr.zctd);
ii=find(isfinite(vt+dr.vctd));
if length(ii)>5
  ii=ii(round((end*0.33):(end*0.67)));
  co=corrcoef([vt(ii)',dr.vctd(ii)']);
  ps.vcorr=co(1,2);
else
  ps.vcorr=NaN;
end
plot(tim,vt,'-k','linewidth',1.2)
if ps.dragfac~=0
  plot(tim,vctd_drag,'-r')
end
ylabel(['V [m/s] corr: ',num2str(ps.vcorr)])
axis tight

if sum(shipvel)~=prod(shipvel)
  subplot(423)
  shippos=cumsum(shipvel.*dt);
  ctddist=abs(shippos-ctdpos);
  plot(tim,ctddist,'linewidth',2)
  grid
  ylabel('CTD distance from ship [m]')
  xlabel('time in days')
  axis tight
end

subplot(424)
plot(tim,dr.wctd,'linewidth',2)
grid
ylabel('CTD vertical velocity')
xlabel('time in days')
axis tight

subplot(212)
xctd=dr.xctd;
yctd=dr.yctd;
ii=fix(linspace(1,length(xctd),10));
[m,ib]=min(dr.zctd);
plot(xctd,yctd,'linewidth',2)
hold on
plot(xctd(ii),yctd(ii),'r.','markersize',10)
plot(xctd(ib),yctd(ib),'g+','markersize',9)
if isfield(dr,'xship')
  plot(dr.xship,dr.yship,'-g',dr.xship(ii),dr.yship(ii),'k.','markersize',10)
  plot([xctd(ii);dr.xship(ii)],[yctd(ii); dr.yship(ii)],'-y','linewidth',0.5)
  xlabel('CTD-position (blue) and ship (green) east-west [m]')
else
  xlabel('CTD-position east-west [m]')
end
text(xctd(ib),yctd(ib),'bottom')
axis equal
axis tight
text(xctd(1),yctd(1),'start')
ylabel('north-south [m]')
title([p.name,' Results from Drag Fac : ',num2str(ps.dragfac)])
grid
set(gca,'fontsize',10)
streamer([p.name,'  Figure 7']);
orient tall
hgsave(['tmp',filesep,'7'])

% compute velocity error
der = geterr(dr,di,p,iplot);
if size(uocean,2)>1
  dr.uerr = dr.uerr/nmedian(dr.uerr)*...
	nmedian(sqrt(der.u_oce_s.^2+der.v_oce_s.^2));
else
  dr.uerr = sqrt(der.u_oce_s.^2+der.v_oce_s.^2)';
end


% compute mean target strength profile
% compute mean range profile
dr.range = dr.z*NaN;
if length(di.izu)>0
  dr.range_do = dr.z*NaN;
  dr.range_up = dr.z*NaN;
end
dr.ts = dr.z*NaN;
dr.ts_out = dr.z*NaN;

for n=1:length(dr.z)
  ii = find(abs(dr.z(n)+di.z)<2*ps.dz);
  if length(ii)>1
    dr.ts(n) = mean(di.tsd(ii));
    dr.ts_out(n) = mean(di.tsd_out(ii));
    zd = abs(di.izm(di.izd,1)-di.z(1));
    range = zd(sum(isfinite(di.rw(di.izd(2:end),ii)))+1);
    dr.range(n) = meanmediannan(range,ceil(length(ii)/4));
    if length(di.izu)>0
      zd = abs(di.izm(di.izu,1)-di.z(1));
      range = zd(sum(isfinite(di.rw(di.izu(1:(end-1)),ii)))+1);
      dr.range_up(n) = meanmediannan(range,ceil(length(ii)/4));
      dr.range_do(n) = dr.range(n);
      dr.range(n) = dr.range_up(n)+dr.range_do(n);
    end
  end
end
 

if nargout>2
  % prepare some output for error analysis
  de.R = sum(abs(d)>0)/(nt+nz) ;
  de.d = d;
  de.wm = wm;
  if exist('bvel','var')
    de.bvel = bvel;
    de.bvels = bvels;
  end
  de.uocean = uocean;
  de.uctd = uctd;
  de.dfit = [Aocean,A1]*[uocean(:,1);uctd(:,1)];
  de.A = [Aocean,A1];
  de.A1o = A1o;
  de.A2o = A2o;
  de.d0 = d0;
  de.jprof = jprof;
  de.jbin = jbin;
end

%### solve up and down cast seperately
if ps.down_up

  baroclinfac=10;

  %down trace
  disp('    Solving only down trace')
  A1s=A1(idoc,:);
  ii=find(full(sum(A1s))==0);
  A1s(:,ii)=[];
  A2s=Aocean(idoc,:);
  ds=d(idoc);
 
  disp('    Smoothing Ocean velocity profile')
  [A2s,A1s,ds]=lainsmoo(A2s,A1s,ds,ps.smoofac);
  
  disp('    Smoothing CTD velocity profile')
  [A1s,A2s,ds]=lainsmoo(A1s,A2s,ds,ps.smoofac);

  % add zero mean constrain
  A1s=[A1s;A1s(1,:)*0];
  A2s=[A2s;A2s(1,:)*0+baroclinfac];
  ds=[ds;0];
 
  [uocean_do,uctd_do]=lainsolv(A2s,A1s,ds);
  ii=find(abs(uocean_do(:,1))>5); 
  if length(ii)>0
    disp(['    Found ',int2str(length(ii)),' big ( >5m/s ) down cast UOCEAN:'])
    uocean_do(ii)=NaN;
  end
  dr.u_do=real(uocean_do(:,1));
  dr.v_do=imag(uocean_do(:,1));
 

  if length(iupc)>5, 
    %up trace
    disp('    Solving only up trace')
    A1s=A1(iupc,:);
    ii=find(full(sum(A1s))==0);
    A1s(:,ii)=[];
    A2s=Aocean(iupc,:);
    ds=d(iupc);

    disp('    Smoothing Ocean velocity profile')
    [A2s,A1s,ds]=lainsmoo(A2s,A1s,ds,ps.smoofac);
 
    disp('    Smoothing CTD velocity profile')
    [A1s,A2s,ds]=lainsmoo(A1s,A2s,ds,ps.smoofac);

    % add zero mean constrain
    A1s=[A1s;A1s(1,:)*0];
    A2s=[A2s;A2s(1,:)*0+baroclinfac];
    ds=[ds;0];

    [uocean_up,uctd_up]=lainsolv(A2s,A1s,ds);

    ii=find(abs(uocean_up(:,1))>5); 
    if length(ii)>0
      disp(['    Found ',int2str(length(ii)),' big >5 m/s up cast UOCEAN:'])
      uocean_up(ii)=NaN;
    end
  else
    uocean_up=uocean_do*NaN;
  end
  dr.u_up = real(uocean_up(:,1));
  dr.v_up = imag(uocean_up(:,1));
 
  u_bias = nmean(dr.u_do-dr.u_up);
  v_bias = nmean(dr.v_do-dr.v_up);
  if abs(u_bias) > 0.02 | abs(v_bias) > 0.02
    warn = sprintf(...
	'Large up/down bias (u=%.2fm/s; v=%.2fm/s) --- GPS problems?',...
	u_bias,v_bias);
    messages.warnp = strvcat(messages.warnp,warn);
    disp(['>    ' warn]);
  end

end

% compute pressure from depth
dr.p = sw_pres(dr.z,dr.lat);

% ----------------------------------------------------------
function [Aocean,Ac,d]=lainbaro(Aocean,Ac,d,uship,dt,w)
%function [Aocean,Ac,d]=lainbaro(Aocean,Ac,d,uship,dt,w)
%
% add barotropic constrain
% [uship] ship velocity over the cast from GPS positions
% w strength of constrain
%
% 
[li,ljo] = size(Aocean);
[li,ljc] = size(Ac);
if nargin<6, 
  w = 1; 
end

% normalize weights 
% fac = li./(sum(dt)*ljc);
% fac = 1/(sum(dt));
range = (full(sum(abs(Ac))));
fac = sqrt(sum(range));
disp(['    Normalized barotropic constrain weight: ',num2str(w)])
disp(['    Mean individual ctd velocity weight : ',num2str(mean(w*fac))])

Ac = [Ac;(1:ljc)*0+dt/sum(dt)*w*fac];
Aocean(li+1,1) = 0;
d = [d;-1*uship*w*fac];

% ----------------------------------------------------------
function [Aocean,Ac,d]=lainocean(Aocean,Ac,d,w)
%function [Aocean,Ac,d]=lainocean(Aocean,Ac,d,w)
%
% set barotropic constrain to be no mean ocean velocity
% w strength of constrain
%
%
[li,ljo]=size(Aocean);
[li,ljc]=size(Ac);
if nargin<4, 
  w=1; 
end

% normalize weights
fac=mean(sum(Aocean));
disp('    Adding no mean flow constraint')

Aocean=[Aocean;(1:ljo)*0+w*fac];
Ac(li+1,1)=0;
d=[d;0];

%-------------------------------------------------------------------
function [Aocean,Ac,d,ubot,ibot]=lainbott(dbvel,bvel,bvelw,Aocean,Ac,d,botfacin)
% function [Aocean,Ac,d,ubot,ibot]=lainbott(dbvel,bvel,bvelw,Aocean,Ac,d,botfacin)
%
% add bottom track to the two parts of the A matrix
%
% dbvel = bottom track velocity array 
% bvel = bottom track velocity
% bvelw = ratio between bottom track std and vel error
%
% d = cell velocity data
% Aocean = ocean matrix
% Ac = ctd matrix
% botfac = nominal weight for bottom track
%
% also compute bottom track velocity
% ubot (:,1) = mean velocity
% ubot (:,2) = error
% ibot depth index
[li,ljo] = size(Aocean);

if nargin<5, 
  botfacin = 1; 
end

ibot = find(isfinite(dbvel));
dbot = (d(ibot)-dbvel(ibot));
Aob = Aocean(ibot,:);

if nargout>3
  disp('    Bottom inversion ')
  % minimum number of estimates
  nmin = 3;
  Ab = Aob;
  s = sum(Ab>0)>=(nmin);
  ibot = find(s==1);
  % remove empty vertical depth
  id = find(s==0);
  Ab(:,id) = [];
  if length(ibot)>1
    % solve
    %[ubot,uebot]=lesqfit(dbot,Ab);
    % ubot=lesqchol(dbot,Ab);
    [m,me] = lesqfit(dbot,Ab);
    ubot = [full(m),abs(full(me))];
    velerr = min(abs(full(me)));
    botfac = botfacin./ubot(:,2)*velerr;
    igood = find(ubot(:,2)<2*median(ubot(:,2)));
    ubot = ubot(igood,:);
    ibot = ibot(igood);
  else
    disp('    Not enough bottom track data for bottom inversion ')
    ubot = [];
    botfac = botfacin;
  end 
end


% scaling needs more work
% range in fraction of total profile 
% range=5*full(sum(Ac~=0))/size(Ac,2);
% use sqrt of contraints 
iokbot=find(isfinite(bvel));

if length(iokbot>0)
  range=sqrt(full(sum(abs(Ac))));
  botfac=bvelw(iokbot)*botfacin.*range(iokbot);

  Acb=zeros(length(botfac),size(Ac,2));
  for i=1:length(botfac)
    Acb(i,iokbot(i))=botfac(i);
    db(i,1)=bvel(iokbot(i))*botfac(i);
  end

  d=[d;db];
  Ac=[Ac;Acb];
  Aocean(length(d),1)=0;
  disp(['    ',int2str(length(botfac)),...
       ' bottom track ctd-vel weights of about : ',num2str(mean(botfac))])

else
  disp('    No finite bottom track velocities ')
end

%-------------------------------------------------------------------
function [p,Aocean,Ac,d,ds,messages] = ...
    lainsadcp(p,svel,Aocean,Ac,d,dz,sadcpfac,velerr,messages)
% function [p,Aocean,Ac,d,ds,messages]=lainsadcp(p,svel,Aocean,Ac,d,dz,sadcpfac,velerr,messages)
%
% add SADCP to the two parts of the A matrix
%
% svel = ship ADCP data velocity profile
%
% d = cell velocity data
% Aocean = ocean matrix
% Ac = ctd matrix
% sadcpfac = weight for SADCP velocity
% velerr = velocity error for LADCP super ensemble
%
[li,ljo]=size(Aocean);

if nargin<8
  velerr = 0; 
end
if nargin<7
  sadcpfac = 1; 
end

%
% extract finite SADCP velocities and store in variables
%
zsadcp = abs(svel(:,1));
dsadcp = svel(:,2)+sqrt(-1)*svel(:,3);
ind = find(isfinite(dsadcp));
zsadcp = zsadcp(ind);
dsadcp = dsadcp(ind);
verr = svel(ind,4);


%
% weight according to scatter in mean SADCP profile
% first replace small or no error with large error
%
ind = find(~isfinite(verr) | verr<0.01);
verr(ind) = nmax(verr);


%
% If there is more than one profile use std for weights
%
if size(svel,1)>3
  if ~(velerr>0)
    fac0 = sort(verr);
    velerr = mean(fac0(1:ceil(end*0.2)));
  end
  fac = velerr./verr;
else
  fac = dsadcp*0+1;
end


%
% Apply constraint
%
if sadcpfac>0
  % weight down by factor of 2 because it directly
  % influences velocity (up and down)
  fac2 = sqrt(full(sum(abs(Aocean))))/2;
  for n=1:length(dsadcp)
    % sort to depth
    jz = round(zsadcp(n)/dz);
    jz = min(max(jz,1),ljo);
    % fac(n)=fac(n)*fac2(jz);
    Aocean(li+n,jz) = sadcpfac*fac(n);
    d = [d;dsadcp(n)*sadcpfac.*fac(n)];
  end
  Ac(length(d),1) = 0;
  disp(['    Mean SADCP weight : ',num2str(mean(sadcpfac.*fac))])
end

iok = find(fac>0.1);
if length(iok) < length(fac)
  disp(sprintf(...
	'    %d out of %d SADCP profiles removed because of low weight',...
     			length(fac)-length(iok),length(fac)));
end
if isempty(iok)
  warn = ('All SADCP values removed because of low weight');
  messages.warnp = strvcat(messages.warnp,warn);
  disp(['>   ' warn]);
end

ds.z_sadcp = zsadcp(iok);
ds.u_sadcp = real(dsadcp(iok));
ds.v_sadcp = imag(dsadcp(iok));
ds.uerr_sadcp = verr(iok);


%-------------------------------------------------------------------
function [Aocean,Ac,d]=laindrag(Aocean,Ac,d,ctdvel,w)
%function [Aocean,Ac,d]=laindrag(Aocean,Ac,d,ctdvel,w)
%
% use drag law to constrain UCTD
% ctdvel  GPS derived ship velocity modified for drag
% w strength of constrain
% 
if nargin<5, 
  w=1; 
end
[li,ljo] = size(Aocean);
[li,ljc] = size(Ac);

% how often to constrain CTD velocity
izz = find(isfinite(ctdvel));
in = 0;

% normalize weights
sumw = sqrt(sum(abs(Ac(1:(end-1),:))));
wfac = w*sumw;
disp(['    Typical drag CTD velocity weight is: ',num2str(median(wfac))])

% loop over depth
for i=1:length(izz);
  iz = izz(i); 
  % set weights for A matrix
  iz0 = zeros(1,ljc);
  iz0(iz) = wfac(iz);
  Ac = [Ac;iz0];
  % try to take ocean velocity drag into account
  if 1
    iz1 = zeros(1,ljo);
    % get index for ocean velocity above point (assume up-down length)
    izl = length(izz)/2;
    izmax = round((izl-abs(iz-izl))*ljo/izl);
    izmax = min(ljo,izmax);
    izmax = max(1,izmax);
    % drag works on difference between ocean and shipvel
    % but nearby ocean velocity is felt more
    iz1(1:izmax) = (1:izmax).^2;
    iz1 = iz1*sum(iz0)/sum(iz1);
    Aocean = [Aocean;-iz1];
  else 
    in = in+1;
    Aocean(li+in,1) = 0;
  end
  % set U_CTD = - ctdvel as constrain
  d = [d;-ctdvel(iz)*sum(iz0)];
end
%-------------------------------------------------------------------
function [A]=lainseta(zbin,dz)
% function [A]=lainseta(zbin,dz)
%
% set up LADCP inversion matrix A
% given the depth of each measurement zbin (m) (or profile number)
% and increment of target depth (m) (number of profiles for Uctd)
%

% convert variable to index
izv = zbin/dz;

% factor first
j = round(izv);

% fix outliers
ii = find(j<1);
j(ii) = 1;

% row index
ind = (1:length(izv))';

%set up sparse matrix
A = sparse(ind,j,ind*0+1);


%-------------------------------------------------------------------
function [A,Ap,d]=lainsmoo(A,Ap,d,fs0,cur);
%function [A,Ap,d]=lainsmoo(A,Ap,d,fs0,cur);
%
% smooth results by minimizing curvature
% also smooth if elements are not constrained
%
if nargin<4 
  fs0 = 1; 
end
if nargin<5 
  cur = [-1 2 -1]; 
end

[ld,ls] = size(A);
fs = sqrt(full(sum(A)));
fsm = max(median(fs),0.01);

% find ill constrained data
ibad = find(fs<(fsm*0.3));

% increase weight for poorly constrained data
fs = max(fs,fsm*0.1);
fs1 = fsm./fs ;
fs = fs1 * fs0(1);


if length(ibad)>0
  % set ill constrainded data to a minimum weight
  fs(ibad) = max(fs1(ibad),0.5);
  if fs0==0
    disp(['    Found ',int2str(length(ibad)),' ill constrained elements will smooth '])
  else
    disp(['    Found ',int2str(length(ibad)),' ill constrained elements'])
  end
end

if sum(fs>0)>0

  cur = cur-mean(cur);

  lc = length(cur);
  lc2 = fix(lc/2);
  fs2 = fs((lc2+1):(end-lc2));
  inc = [1:length(cur)]-lc2;

  ii = find(fs2>0);
  % find how many smooth constraints to apply

  if length(ii)>0 
    [i1,i2] = meshgrid(inc,ii+lc2-1);
    [curm,fsm] = meshgrid(cur,fs2(ii));

    As = sparse(i2,i1+i2,curm.*fsm);
    [lt,lm] = size(A);
    if size(As,2)<lm 
      As(1,lm) = 0;
    end
    A = [A;As];
    
  end

  % smooth start and end of vector
  for j=1:lc2
    j0 = j-1;
    [lt,lm] = size(A);
    if fs(1+j0)>0
      A(lt+1,[1:2]+j0) = [2 -2]*fs(1+j0);
    end
    if fs(end-j0)>0
      A(lt+2,end-[1,0]-j0) = [-2 2]*fs(end-j0);
    end
  end

  [lt,lm] = size(A);
  Ap(lt,1) = 0;
  d(lt) = 0;
else
  disp('    No smoothness constraint applied ')
end

%-------------------------------------------------------------------
function [A,Ap,d]=lainsmal(A,Ap,d,fs0);
%function [A,Ap,d]=lainsmal(A,Ap,d,fs0);
%
% require small shear for certain vertical wave length
%
if nargin<4
  fs0=[3, 0.1]; 
end

[ld,ls] = size(A);
fs = full(sum(abs(A(1:(end-3),:))));
fac = mean(sqrt(fs));
iz = [1:ls];

for j=1:size(fs0,1)
  disp(['    Small shear for wavelength ',int2str(fs0(j,1)),...
      ' weight:  ',num2str(fs0(j,2))])
  isin = sin(iz*2*pi/length(iz)*fs0(j,1));
  icos = cos(iz*2*pi/length(iz)*fs0(j,1));
  A = [A;[isin;icos]*fs0(j,2)*fac];
end
disp(['    Typical small shear velocity weight is: ',num2str(fac)])
[lt,lm] = size(A);
Ap(lt,1) = 0;
d(lt) = 0;

%-------------------------------------------------------------------
function [uocean,uctd,uoceanerr,uctderr]=lainsolv(Aocean,Actd,dladcp,nsolve);
%function [uocean,uctd,uoceanerr,uctderr]=lainsolv(Aocean,Actd,dladcp,nsolve);
% 
% solve LADCP current profiling using an invers technique.
% dladcp = [Aocean,Actd] * [uocean,uctd]
% 
% nsolve = 0  Cholseky transform
%        = 1  Moore Penrose Inverse
%
%   Martin Visbeck LDEO 15/12/1998
%   need LESQFIT and LESQCHOL routines
%

if nargin<4 
  nsolve = 0; 
end
if nargout>2 
  nsolve = 1; 
end

% set up big matrix
A = [Aocean,Actd];
d = dladcp;

[ldata,lao] = size(Aocean);
[ldata,lac] = size(Actd);

% solve system
if nsolve==1
  disp('  Moore-Penrose inverse')
  [m,me] = lesqfit(d,A);
  me = full(me);
else
  disp('  Cholesky transform')
  m = lesqchol(d,A);
end

% split results up 
i1 = [1:lao];
i2 = max(i1)+[1:lac];
uctd = m(i2);
uocean = m(i1);

if nsolve==1
  if nargout>2
    uoceanerr = abs(me(i1));
    uctderr = abs(me(i2));
  else
    uctd = [uctd,abs(me(i2))];
    uocean = [uocean,abs(me(i1))];
  end
end

%-------------------------------------------------------------------
function [Ao,Ac,d,ido,iup]=lainweig(Ao,Ac,d,w)
%function [Ao,Ac,d,ido,iup]=lainweig(Ao,Ac,d,w)
%
% apply weights to ensembles
% w of dimension d applied to all
%
[li,ljo] = size(Ao);
[li,ljc] = size(Ac);

ii = find(sum(Ao)>0);
im = max(ii);
nbot = round(median(find(Ao(:,im)>0)));
ido = [1:nbot];
iup = [nbot:li];

[m,io] = max(Ao');
[m,ic] = max(Ac');
ii = [1:length(d)];

d = d.*w;
Ao = Ao.*sparse(ii,io,w);
Ac = Ac.*sparse(ii,ic,w);

%-------------------------------------------------------------------
function [m,me,c,dm,gi]=lesqfit(d,g)
% function [m,me,c,dm,gi]=lesqfit(d,g)

% fit least squares method to linear problem Menke(1984)
%input parameters:
%  d:= data vector ;  g:= model matrix
% output parameters:
% m=model factors; me=error of factors; c=correlation ;gi= general inverse

n = length(d);
[i,j] = size(g);
if i~=n; 
  disp('    Wrong arguments to lesqfit')
  return
end
in = inv( g' * g);
gi = in * g';
m  = gi * d ;
if nargout<2 
  return 
end
dm = g * m;
me = diag( sqrt( in * ( (d-dm)' * (d-dm)) ./ ( i-j) ) );
if nargout<3 
  return 
end
co = cov([d,dm]);
c  = co(1,2) / sqrt( co(1,1)*co(2,2) );
