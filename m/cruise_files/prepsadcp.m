function [] = prepsadcp(stn,values,p,files,cruiseVars)
% function [] = prepsadcp(stn,values)
%
% prepare Ship-ADCP data for LADCP processing
%
% we need the vectors 'tim_sadcp' , 'lon_sadcp' , 'lat_sadcp'
% and 'z_sadcp'
% and the arrays 'u_sadcp' and 'v_sadcp'
%
% 
% to create a file for your own cruise, modify this file
%
% the data should be the result of shipboard or later
% SADCP processing

% G.Krahmann, IFM-GEOMAR, Aug 2005


% if you do no have SADCP data to be used in the
% LADCP processing, uncomment the next two lines. Otherwise edit the following.


% % pause 
if p.use_sadcp == 0 % sadcp processing can be turned off in default_params.cfg Pedro Pena 8.19.2016
     disp('AT SEA PROCESSING. NO SADCP!!!')
    return
end 


% first copy the SADCP files to the raw SADCP data directory
% data/raw_sadcp
% In our example
% this is data mounted via SMBMOUNT from //peale/adcp_home
%!copy z:\pos350\VMADCP\* data\raw_sadcp

% load this data and convert to standard format
%
% in this example we load the velocity and position/time files
% (the processing of the SADCP was also done in matlab which
% made the loading of files easy)
% and extract the necessary information
%
% again make sure that the time is in Julian days
% In the example the cruise was in 2004 and the processing
% stored only the day of the year not the actual year !!!
% fnames = dir('data/raw_sadcp/*.mat');
% uv = [];
% xyt = [];
% for n=1:length(fnames)
%     load(['data/raw_sadcp/',fnames(n).name])
%     if n==1
%         uv = b.vel;
%         xyt = b.nav.txy1;
%     else
%         uv = cat(3,uv,b.vel);
%         xyt = cat(2,xyt,b.nav.txy1);
%     end
% end
% lon_sadcp = xyt(2,:);
% lat_sadcp = xyt(3,:);
% tim_sadcp = xyt(1,:) + julian([2007 1 1 0 0 0]);
% u_sadcp = squeeze(uv(:,1,:));
% v_sadcp = squeeze(uv(:,2,:));
% z_sadcp = c.depth;
% [tim_sadcp,ind] = sort(tim_sadcp);
% lon_sadcp = lon_sadcp(ind);
% lat_sadcp = lat_sadcp(ind);
% u_sadcp = u_sadcp(:,ind);
% v_sadcp = v_sadcp(:,ind);
% first check for NaNs
%
% YOU MUST MODIFY THE LINE BELOW BEFORE PROCESSING!!!

cruise_id=get_cruise_variable_value(cruiseVars,'cruise_id');
cruise_id_prefix=get_cruise_variable_value(cruiseVars,'cruise_id_prefix');
cruise_id_suffix=get_cruise_variable_value(cruiseVars,'cruise_id_suffix');
fName=[cruise_id_prefix,cruise_id,'_codas3_sadcp',cruise_id_suffix,'.mat'];

load([files.raw_sadcp_dir,filesep,fName]);

% adp = adp_os75nb_only

i=find(isnan(adp.tday));
if length(i)~=0
    adp.tday(i)=[];
    adp.lat(i)=[];
    adp.lon(i)=[];
    adp.u(:,i)=[];
    adp.v(:,i)=[];
end

% make sure that longitude is given as +/-180
%if adp.lon > 180
%    adp.lon = adp.lon-360;
%end

% now write out into required format
yearbase = p.correct_year;
% keyboard
tim_sadcp = julian(to_date(yearbase,adp.tday,'n'))';   
lat_sadcp = adp.lat;
lon_sadcp = adp.lon;
u_sadcp = adp.u./100;
v_sadcp = adp.v./100;
z_sadcp = adp.depth;

% restrict the data to the time of the cast
%good = find( tim_sadcp>values.start_time-0.1 & tim_sadcp<values.end_time+0.1);
good = find( tim_sadcp>values.start_cut-0.1 & tim_sadcp<values.end_cut+0.1);
tim_sadcp = tim_sadcp(good);
lat_sadcp = lat_sadcp(good);
lon_sadcp = lon_sadcp(good);
u_sadcp = u_sadcp(:,good);
v_sadcp = v_sadcp(:,good);
z_sadcp = z_sadcp;

% % delete deepest two bins
% z_sadcp = z_sadcp(1:end-2);
% u_sadcp = u_sadcp(1:end-2,:);
% v_sadcp = v_sadcp(1:end-2,:);


% store the data
save6([files.sadcp_dir,filesep,'sadcp',int2str0(stn,3)],...
	'tim_sadcp','lon_sadcp','lat_sadcp','u_sadcp','v_sadcp','z_sadcp')
