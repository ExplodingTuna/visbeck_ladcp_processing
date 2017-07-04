% LADCP processing software
%
% set default values for parameter in LADCP processing
% 
%  INPUT is provided by three structures.
%  some of this may get changed by the software
%
% structure f.??? contains file names
% structure p.??? contains parameter relevant to reading and preparing
%             the data
% structure ps.??? contains parameter for the solution
%
% version 0.8  last change 02.12.2013

% changed handling of cruise_id              GK, 20.05.2011  0.1-->0.2
% new parameter to fully remove bins         GK, 29.08.2011  0.2-->0.3
% new parameter to force resampling          GK, 07.03.2012  0.3-->0.4
% new parameter to handle wrong clocks       GK, 14.02.2013  0.4-->0.5
% several new parameters                     GK, 12.07.2013  0.5-->0.6
% timoff_downlooker                          GK, 02.12.2013  0.7-->0.8


% params.software = 'GEOMAR LADCP software: Version 10.20: 2014-05-13';
vv='';
if is_octave < 1
vv=['Processed with Matlab ',version];
else
vv=['Processed with Octave ',version];
end

params.software = ['GEOMAR LADCP software: Version 10.20: ' ,vv,char(10),'(Modified for NOAA/AOML, May 15, 2014)'];

%
% unix computers know this
%
params.whoami = whoami;


%
% extract cruise id from upper directory name
%
pd = pwd;
params.name = get_cruise_variable_value(cruiseVars,'cruise_id');%added by Pedro Pena 8.19.16
params.name = [params.name,'_',int2str0(stn,3)]; 
% commented by Pedro Pena 8.19.16
% if exist('logs')==7
%   if ispc
%     ind = findstr(pd,'\');
%   else
%     ind = findstr(pd,'/');
%   end
%   if ~isempty(ind)
%     params.name = pd(ind(end)+1:end);
%   else
%     params.name = pd;
%   end
% params.name = [params.name,'_',int2str0(stn,3)];
% end



%if 0

% % directory names
% f.logs_dir        = 'logs';
% f.plots_dir       = ['plots',filesep,int2str0(stn,3)]; %% line modified by RHS 25NOV2013
% f.prof_dir        = ['profiles',filesep,int2str0(stn,3)]; %% line modified by RHS 25NOV2013
% f.raw_dir         = ['data',filesep,'raw_ladcp'];
% f.ctd_ts_dir      = ['data',filesep,'ctdtime'];
% f.ctd_prof_dir    = ['data',filesep,'ctdprof'];
% f.nav_dir         = ['data',filesep,'nav'];
% f.sadcp_dir       = ['data',filesep,'sadcp'];
% f.ladcp_dir       = ['data',filesep,'ladcp'];  %% line added by RHS 25NOV2013




% % file names
% stn_fmt         = '%03d';
% dn_file_fmt     = '%03dDN000.000';
% up_file_fmt     = '%03dUP000.000';
% f.ladcpdo = sprintf([f.raw_dir,filesep,stn_fmt,filesep,dn_file_fmt],stn,stn);
% if (~exist(f.ladcpdo,'file')) 
%   dn_file_fmt     = '%03dDN000.000';
%   f.ladcpdo = sprintf([f.raw_dir,filesep,stn_fmt,filesep,dn_file_fmt],stn,stn);
% end;
% f.ladcpup = sprintf([f.raw_dir,filesep,stn_fmt,filesep,up_file_fmt],stn,stn);
% if (~exist(f.ladcpup,'file')) 
%   up_file_fmt     = '%03dUP000.000';
%   f.ladcpup = sprintf([f.raw_dir,filesep,stn_fmt,filesep,up_file_fmt],stn,stn);
% end;
% if ~isfield(f,'ladcpup') 
%   f.ladcpup = ''; 
% end;

% % check for multiple file cases
% count = 1;
% while exist(f.ladcpdo(end,:),'file')
%   nname = f.ladcpdo(end,:);
%   nname(end-[6:-1:4]) = int2str0(count,3);
%   if exist(nname,'file')
%     f.ladcpdo(end+1,:) = nname;
%     count = count+1;
%   else
%     break
%   end
% end
% count = 1;
% while exist(f.ladcpup(end,:),'file')
%   nname = f.ladcpup(end,:);
%   nname(end-[6:-1:4]) = int2str0(count,3);
%   if exist(nname,'file')
%     f.ladcpup(end+1,:) = nname;
%     count = count+1;
%   else
%     break
%   end
% end

% f.nav = [f.nav_dir,filesep,'nav',int2str0(stn,3),'.mat'];
% f.ctdprof = [f.ctdprof_dir,filesep,'ctdprof',int2str0(stn,3),'.mat'];
% f.ctdtime = [f.ctdtime_dir,filesep,'ctdtime',int2str0(stn,3),'.mat'];
% f.sadcp = [f.sadcp,filesep,'sadcp',int2str0(stn,3),'.mat'];

% file name for results (extensions will be added by software)
%  *.bot            bottom referenced ASCII data
%  *.lad            profile ASCII data
%  *.mat            MATLAB  format >> dr p ps f
%  *.cdf            NETCDF  (binary) LADCP data format 
%  *.log            ASCII log file of processing
%  *.txt            ASCII short log file
%  *.ps             post-script figure of result 
%end


%--------------------------------------------------------------
% Parameter for loading and primary error check  p.* structure
%--------------------------------------------------------------

% preset start and end time vectors
params.time_start = str2num(get_cruise_variable_value(cruiseVars,'time_start'));
params.time_end = str2num(get_cruise_variable_value(cruiseVars,'time_end'));


%
% store station number
%
params.ladcp_station = stn;


% restrict time range to profile and disregard data close to surface
% p.cut = 0 dont restrict
% p.cut > 0 restrict time to adcp depth below a depth of p.cut
params.cut = str2num(get_cruise_variable_value(cruiseVars,'cut'));


% manually set POSITION of the start and end point
% [degree lat, minute lat, degree lon, minute lon]
%  i.e. [-59 -30.5697 -44 -22.4986]
params.pose = str2num(get_cruise_variable_value(cruiseVars,'pose'));
params.poss = str2num(get_cruise_variable_value(cruiseVars,'poss'));
params.position_fixed = str2num(get_cruise_variable_value(cruiseVars,'position_fixed'));
params.lat_for_calc = str2num(get_cruise_variable_value(cruiseVars,'lat_for_calc'));
params.lon_for_calc = str2num(get_cruise_variable_value(cruiseVars,'lon_for_calc'));


%
% navigation error in m
%
% This one is later used to determine the weight of the ship
% movement constraint. It should be set to something like the
% uncertainty of the position of the CTD when it is coming on 
% deck. I.e. the GPS error plus something accounting for the
% position difference between GPS antenna and CTD (remember
% the ship can rotate !).
% 30 m is a reasonable number.
%
params.nav_error = str2num(get_cruise_variable_value(cruiseVars,'nav_error'));
 

% SUPER ENSEMBLES 
% 	are calculated in prepinv.m to reduce the number of raw profiles
% 	The ides is to obtain one average profile for each vertical dz=const
% 	that the CTD traveled through. As a result a constant number of super
% 	ensembles are obtained for the up and down cast.
%   but a fixed number of ensembles can also be averaged


%
% p.avdz sets the depth interval between adjacent super-ensembles
% default one bin length
%
% since the bin length is profile dependent we can not set it here
%
% if avdz is negative, -avdz bin lengths will be used for avdz
% if avdz is positive, avdz will be used as is
% the calculation takes place in  calc_ens_av.m
%
% p.avens will take precedence over p.avdz
%
params.avdz = str2num(get_cruise_variable_value(cruiseVars,'avdz'));


%
% p.avens overrides p.avdz and sets a fixed number of ensembles to average
% default NAN means that it is not used
%
params.avens = str2num(get_cruise_variable_value(cruiseVars,'avens'));


%
% BOTTOM TRACK
% 	The are several options to get bottom track data
% 
% mode = 1 :   use only RDI bottom track
%        2 :   use only own bottom track
%        3 :   use RDI, if existent, own else (default)
%        0 :   use not bottom track at all
%
% btrk_mode is the one you set to be used, btrk_used is the 
% the routine has used. They do not need to agree since the
% software can override your command, e.g. in case some
% necessary data is missing or all BTRK are bad.
%
params.btrk_mode = str2num(get_cruise_variable_value(cruiseVars,'btrk_mode'));
params.btrk_used = str2num(get_cruise_variable_value(cruiseVars,'btrk_used'));	


%
% p.btrk_ts is in dB to detect bottom above bin1 level (for own btm track)
%
% The following parameter (bottom-tracking target strength)
% is quite iffy. Setting it to too small a value (e.g. 10, the old default)
% makes instrument interference appear as a false bottom, which can
% be a problem. For example, on CLIVAR P02 station 32 there was a
% long stop 16m above the sea bed, which is too close for bottom
% tracking.  True bottom detection is only possible during the approach
% and the beginning of the upcast. These two short times are swamped
% out by the interference-related false bottom detections. On the other
% hand, when this value is set to too large a value, true seabed returns
% are rejected. It would be fairly easy to set the correct value in
% terms of instrument-returned target strength by plotting the target
% strength with imagesc(d.wts). However, the values of this parameter
% are not instrument-returned target strengths but db. The current value
% is valid for the combo of downlooking BB150 / uplooking WH300 used on
% the CLIVAR P02 cruise. It was derived by trial and error, involving
% stations 2 and 32.
%
params.btrk_ts = str2num(get_cruise_variable_value(cruiseVars,'btrk_ts'));


%
% p.btrk_below gives binoffset used below target strength maximum
% to make bottom track velocity
%
params.btrk_below = str2double(get_cruise_variable_value(cruiseVars,'btrk_below'));


%
% p.btrk_range gives minumum / maximum distance for bottom track
% will be set to 2 / 10 binlength later
%  params.btrk_range = [50 300];


%
% p.btrk_wstd gives maximum accepted wstd for super ensemble averages
%
% this one is usually calculated from the BTRK data but you can
% override it
%
% p.btrk_wstd = 0.1;


%
% maximum allowed difference between reference layer W and W bottom track
%
params.btrk_wlim = str2double(get_cruise_variable_value(cruiseVars,'btrk_wlim'));


%
% force to recalculate bottom distance using target strength
% this is turned off (0) by default and is being automatically
% turned on (1), if the routine recognizes a large number of
% bad (equal 0) RDI distances to the bottom
%
params.bottomdist = str2num(get_cruise_variable_value(cruiseVars,'bottomdist'));


%
% p.surfdist = 1 use surface reflections of up looking ADCP to get start
% depth
%
params.surfdist = str2num(get_cruise_variable_value(cruiseVars,'surfdist'));


%
% MAGNETIC deviation in degree
%
params.magdev = str2double(get_cruise_variable_value(cruiseVars,'magdev'));


%
% COMPASS manipulation
% experts only 
% fix_compass:1 means hdg_offset gets added
% fix_compass:2 means up looker gets down compass + hdg_offset
% fix_compass:3 means down looker gets up compass + hdg_offset
% 
params.fix_compass = str2num(get_cruise_variable_value(cruiseVars,'fix_compass'));


%
% In case the two instruments are running not synchronous, one
% is resampled onto the other. This is done by simply taking
% one instrument as the reference (default the downlooker) and
% each of its ensembles pick the closest in time of the other
% instrument. Depending on the ping rates and which instrument
% is pinging faster, this will result in whole ensembles being
% dropped or used multiple times.
%
% params.up2down==1 will resample the uplooker onto the downlooker
%
params.up2down = str2num(get_cruise_variable_value(cruiseVars,'up2down'));

%
% give compass offset in addition to declination (1) for down (2) for up
%
% p=setdefv(p,'hdg_offset',[0 0]);


% COMPASS: 
% how to best adjust compass to best match 
% if 1 rotate up-looking and down-looking instrument to mean heading
%    2 rotate up-looking and down-looking velocities to match up velocities
%        (not really recommended and very likey buggy !!!)
%    3 rotate up-looking velocities to down heading
%        (use if you suspect that the up heading is bad)
%    4 rotate down-looking velocities to up heading
%        (use if you suspect that the down heading is bad)
%    5 no rotation applied to compensate for compass differences
params.rotup2down = str2num(get_cruise_variable_value(cruiseVars,'rotup2down'));


% Offset correction
% if 1 remove velocity offset between up and down looking ADCP
% this will correct errors due to tilt biases etc.
params.offsetup2down = str2num(get_cruise_variable_value(cruiseVars,'offsetup2down'));


%
% DEPTH of the start, bottom and end of the profile
% positive downwards
%
params.zpar = str2num(get_cruise_variable_value(cruiseVars,'zpar'));


%
% maximum number of bins to be used
% 0 : all will get used 
%
params.maxbinrange = str2num(get_cruise_variable_value(cruiseVars,'maxbinrange'));


%
% set ctdmaxlag.=100 to the maximum pings that the ADCP data can be shifted to 
% best match W calculated from CTD pressure time series (loadctd)
% If you have good times set it to 10... if your time base is questionable
% you can set it 100 or more
%
params.ctdmaxlag = str2num(get_cruise_variable_value(cruiseVars,'ctdmaxlag'));
params.ctdmaxlagnp = str2num(get_cruise_variable_value(cruiseVars,'ctdmaxlagnp'));


%
% set forced_adcp_ctd_lag in case the built-in routine does not
% properly recognize the lag
% usually this is not set at all
%
% params.forced_adcp_ctd_lag;

% save individual target strength p.ts_save=[1 2 3 4]
params.ts_save = str2num(get_cruise_variable_value(cruiseVars,'ts_save'));
% save individual correlation p.cm_save=[1 2 3 4]
params.cm_save = str2num(get_cruise_variable_value(cruiseVars,'cm_save'));
% save individual percent good pings p.pg_save=[1 2 3 4]
params.pg_save = str2num(get_cruise_variable_value(cruiseVars,'pg_save'));


%
% 1200kHz WH data is too high resolution to be merged with other data
% it thus needs to be averaged before being used
% this gives the number of values to be averaged
%
params.nav_1200 = str2num(get_cruise_variable_value(cruiseVars,'nav_1200'));


%
% a 1200kHz measures very close to the rosette
% high error velocities result when measured in the eddy tail of the rosette
% this parameter sets the threshold of values to be discarded
%
params.error_limit_1200 = str2num(get_cruise_variable_value(cruiseVars,'error_limit_1200'));	% not used GK
params.extra_blank_1200 = str2num(get_cruise_variable_value(cruiseVars,'extra_blank_1200'));    % extra blank in meters


%
%OUTLIER detection is called twice once to clean the raw data
%	and a second time to clean the super ensembles
%        [n1 n2 n3 ...] the length gives the number of scans and
%	each value the maximum allowed departure from the mean in std
%	applied for the u,v,w fields for each bin over blocks 
%   of p.outlier_n profiles
%
% 2: very strong  3: medium  4:only largest outliers
%
params.outlier = str2num(get_cruise_variable_value(cruiseVars,'outlier_detect'));

% default for p.outlier_n is number of profiles in 5 minutes
% p=setdefv(p,'outlier_n',100);
% minimum std for horizontal velocities of super ensemble
% p=setdefv(p,'superens_std_min',0.01);


%SPIKES
% 	maximum value for abs(V-error) velocity
params.elim = str2double(get_cruise_variable_value(cruiseVars,'elim'));
% 	maximum value for horizontal velocity 
params.vlim = str2double(get_cruise_variable_value(cruiseVars,'vlim'));
% 	minimum value for %-good
params.pglim = str2double(get_cruise_variable_value(cruiseVars,'pglim'));
%	maximum value for W difference between the mean W and actual
%        W(z) for each profile. 
params.wlim = str2double(get_cruise_variable_value(cruiseVars,'wlim'));

% TILT  flag data with large tilt or tilt differences as bad
% [22  (max tilt allowed) 
%  4 (maximum tilt difference between pings allowed)]
% WH systems have reported decent profiles with up to 35 deg tilt ...
params.tiltmax = str2num(get_cruise_variable_value(cruiseVars,'tiltmax'));

%
% TILT  reduce weight for large tilts
% calculated after an obscure formula in prepinv.m GK
% have a look at
% plot([0:0.1:30],1.-tanh([0:0.1:30]/params.tilt_weight)/2)
% to see the effect
% 10 means a weight of 1.0 for tilts of  0 deg
%          a weight of 0.6 for tilts of 10 deg
%          a weight of 0.5 for tilts of 30 deg
%
% a tilt_weight of 20 appears to be more gentle, GK
%
params.tilt_weight = str2num(get_cruise_variable_value(cruiseVars,'tilt_weight'));


%
% fix TIME of the ADCP in days
% positive numbers shift the ADCP's time to a later time
% (i.e. timoff is added to the julian time of the ADCP)
% Please note that here is only one offset possible.
% This is the offset of the MASTER system.
% Should the LADCP slave system have a different offset, it
% will be handled by the data shifting of the slave.
%
params.timoff = str2num(get_cruise_variable_value(cruiseVars,'timoff'));


%
% fix time of uplooking ADCP relative to downlooking ADCP
% e.g. when the clocks were never properly set
%
% Usually that is taken care of by the automatic shifting.
% But this will fail when the uplooking system apparently start
% before the downlooking one, but in reality starts later.
%
% In that case you can shift the uplooking data to later
% times by giving a positive number. Units are days.
% There will be a paused control plot to compare the vertical
% velicities.
%
params.timoff_uplooker = str2num(get_cruise_variable_value(cruiseVars,'timoff_uplooker'));
params.timoff_downlooker = str2num(get_cruise_variable_value(cruiseVars,'timoff_downlooker'));


%
% by up to how many ensembles shall the slave be shifted 
% against the master so that the vertical velocities match
% usually 20 is enough. But if the times of master and
% slave were not properly set a much larger number might
% be necessary
%
params.maxlag = str2num(get_cruise_variable_value(cruiseVars,'maxlag'));


%
% there is still an old slower up/down lag routine implemented
% it is turnned off by default and the newer one is used
%
% it will automatically turn on, if the bestlag found has a correlation
% of less than 0.9
%
params.bestlag_testing_on = str2num(get_cruise_variable_value(cruiseVars,'bestlag_testing_on'));


%
% I found a case where we had nearly only 3 beam solutions. This
% prevented the lag determination routine from finding the correct lag.
% Here one can force the routine to also use 3 beam data.
%
params.use_3beam_w_for_lag = str2num(get_cruise_variable_value(cruiseVars,'use_3beam_w_for_lag'));


%
% in case the instruments do not ping in sync but the ping rates differ only by a
% tiny amount the routine will not automatically resample the uplooker onto the
% downlooker timing. This can be forced by setting the following parameter to 1.
%
params.force_resample_uplooker = str2num(get_cruise_variable_value(cruiseVars,'force_resample_uplooker'));


% apply tilt correction
% tiltcor(1)=down-pitch bias
% tiltcor(2)=down-rol bias
% tiltcor(3)=up-pitch bias
% tiltcor(4)=up-rol bias
params.tiltcor = str2num(get_cruise_variable_value(cruiseVars,'tiltcor'));


% Give bin number for the best W to compute depth of the ADCP
%	default uses bin 2-3 but be careful when up/down instruments
%	are used. The good bins are in the middle! 
params.trusted_i = str2num(get_cruise_variable_value(cruiseVars,'trusted_i'));


%
% SET ambiguity velocity used [m/s]
% not used for anything, but stored in the archival data !? GK
%
params.ambiguity = str2double(get_cruise_variable_value(cruiseVars,'ambiguity'));


%
% Give single ping accuracy;
% another strange one, set to NaN, multiplies something and
% that's it  GK
%
% not used anymore
%params.single_ping_accuracy = NaN;


%
% clear LADCPs pressure sensor
% sometimes has strange data and w integration might be preferred
%
% 1 clears the pressure records
%
params.clear_ladcp_pressure = str2num(get_cruise_variable_value(cruiseVars,'clear_ladcp_pressure'));
params.weight_ladcp_pressure = str2double(get_cruise_variable_value(cruiseVars,'weight_ladcp_pressure'));

% Write matlab file
params.savemat = str2num(get_cruise_variable_value(cruiseVars,'savemat'));

% Write netcdf file
params.savecdf = str2num(get_cruise_variable_value(cruiseVars,'savecdf'));

% Save Plots 
% Save figure numbers to ps file
%    1 : Summary Plot
%    2 : Engineering Data
%    3 : Data Quality
%    4 : Depth
%    5 : Heading Corrections 
%    6 : Up/Down Differences
%    7 : CTD Position
%    8 : Shear
%    9 : SADCP U, V 
%   10 : U, V Offsets, Tilt Error
%   11 : Processing Warnings
%   12 : Inversion Constraints
%   13 : Bottom Track detail
%   14 : Target Strength
%   15 : Correlation
%   16 : Weights
params.saveplot = str2num(get_cruise_variable_value(cruiseVars,'saveplot'));



%--------------------------------------------------------------
% Parameter for inversion   ps.* structure
%--------------------------------------------------------------

% Process data using shear based method
% compute shear based solution
% ps.shear=2  ; use super ensemble
% ps.shear=1  ; use raw data
ps.shear = str2num(get_cruise_variable_value(cruiseVars,'shear'));


% decide how to weigh data 
% 1 : use super ensemble std 
% 0 : use correlation based field
ps.std_weight = str2num(get_cruise_variable_value(cruiseVars,'std_weight'));


% Weight for the barotropic constraint
ps.barofac = str2num(get_cruise_variable_value(cruiseVars,'barofac'));

% Weight for the bottom track constraint
ps.botfac = str2num(get_cruise_variable_value(cruiseVars,'botfac'));

% Additionally process up and down cast seperately.
% This gives just an extra consistency and quality check.
ps.down_up = str2num(get_cruise_variable_value(cruiseVars,'down_up'));

% Depth resolution for final profile
%	default one bin length
% ps=setdefv(ps,'dz',medianan(abs(diff(di.izm(:,1)))));

% Smoothing of the final profile
ps.smoofac = str2num(get_cruise_variable_value(cruiseVars,'smoofac'));

% Request that shears are small  (experts only)
% disabled by default
% use the command    ps = rmfield(ps,'smallfac');  
% to enable the automatic version
ps.smallfac = str2num(get_cruise_variable_value(cruiseVars,'smallfac'));

% weight bottom track data with distance of bottom
%  use Gaussian with offset (btrk_weight_nblen(1) * bin)
%  and width (btrk_weight_nblen(2) * bin) 
%  one might set this to [15 5] to reduce the weight of close by bottom track data
ps = setdefv(ps,'btrk_weight_nblen',[0 0]);

% Weight for SADCP data
% ps.sadcpfac=1 about equal weight for SDACP profile
ps.sadcpfac = str2num(get_cruise_variable_value(cruiseVars,'sadcpfac'));

% The following parameter (slack time for including SADCP data outside
% LADCP-cast time interval) is by default set to 5 minutes. On CLIVAR_P02
% this is too much, since we ran an efficient operation. Sometimes, the
% ship was getting underway less than 5 minutes after the end of the cast.
% This led to SADCP data outliers, which increases the standard deviation,
% which makes the inversion reject all SADCP data (low weight).

params.sadcp_dtok = str2num(get_cruise_variable_value(cruiseVars,'sadcp_dtok'));            % no time slack for SADCP near ends of stn


%
% use SADCP data (1) or not (0)
% default is to use the data. This is just a simple switch
% to simplify testing of results
%
params.use_sadcp = str2num(get_cruise_variable_value(cruiseVars,'use_sadcp'));


% average over data within how many standard deviations
ps=setdefv(ps,'shear_stdf',2);


% the minimum weight a bin must have to be accepted for shear
ps.shear_weightmin = str2double(get_cruise_variable_value(cruiseVars,'shear_weightmin'));


% restrict inversion to one instrument only 1: up+dn, 2:dn only  3:up only
ps.up_dn_looker = str2double(get_cruise_variable_value(cruiseVars,'up_dn_looker'));


% super ensemble velocity error
% try to use the scatter in W to get an idea of the "noise"
% in the velocity measurement
%% This is a bit of code used in GETINV.m
%% nmax=min(length(di.izd),7);
%% sw=nstd(di.rw(di.izd(1:nmax),:)); ii=find(sw>0);
%% sw=medianan(sw(ii))/tan(p.Beam_angle*pi/180);
%% ps=setdefv(ps,'velerr',max([sw,0.02]));
%
% ps=setdefv(ps,'velerr',0.02);


% How to solve the inverse
%     ps.solve = 0  Cholseky transform
%              = 1  Moore Penrose Inverse give error for solution
ps.solve = str2num(get_cruise_variable_value(cruiseVars,'solve')); 


% Threshold for minimum weight, data with smaller weights
%  	will be ignored
ps.weightmin = str2double(get_cruise_variable_value(cruiseVars,'weightmin'));

% Change the weights by 
%	weight=weight^ps.weightpower 
ps.weightpower = str2num(get_cruise_variable_value(cruiseVars,'weightpower')); 

% Remove 1% of outliers (values in a superensemble deviating most from 
% the inversion result) after solving the inversion
% ps.outlier defines how many times 1% is removed and the
% inversion is recalculated.
ps.outlier = str2num(get_cruise_variable_value(cruiseVars,'outlier')); 


% Weight for the cable drag constraint
% only for experts
ps.dragfac = str2num(get_cruise_variable_value(cruiseVars,'dragfac')); 
ps.drag_tilt_vel = str2double(get_cruise_variable_value(cruiseVars,'drag_tilt_vel'));

% average ctdvel back in time to take the inertia of wire into account
% smooth over max of 20 minutes for depth ~ 2000m
ps.drag_lag_tim = str2num(get_cruise_variable_value(cruiseVars,'drag_lag_tim'));
ps.drag_lag_depth = str2num(get_cruise_variable_value(cruiseVars,'drag_lag_depth'));


% 
% set the ranges for the main velocity plot
% [nan,nan,nan,0] will use standard variable axis ranges
% with this setting you can set it to something fixed for easier 
% comparison
% units are [cm/s cm/s m m] (depth is negative)
%
params.plot_range = str2num(get_cruise_variable_value(cruiseVars,'plot_range'));


%
% set the maximum distance for the bottom track velocity plot
%
params.btrk_plot_range = str2num(get_cruise_variable_value(cruiseVars,'btrk_plot_range'));

%
% PARAMETERS FOR EDIT_DATA
%

%
% Set list of bins to always remove from data.
%
params.edit_mask_dn_bins = str2num(get_cruise_variable_value(cruiseVars,'edit_mask_dn_bins'));
params.edit_mask_up_bins = str2num(get_cruise_variable_value(cruiseVars,'edit_mask_up_bins'));


%
% set list of bins to fully remove from data
% this will be done already at the loading stage and should very rarely be
% necessary
%
params.edit_hardremove_mask_dn_bins = str2num(get_cruise_variable_value(cruiseVars,'edit_hardremove_mask_dn_bins'));
params.edit_hardremove_mask_up_bins = str2num(get_cruise_variable_value(cruiseVars,'edit_hardremove_mask_up_bins'));


%
% Set to 1 to remove side-lobe contaminated data near seabed and
% surface.
%
params.edit_sidelobes = str2num(get_cruise_variable_value(cruiseVars,'edit_sidelobes'));


%
% Set to finite value to implement time-domain spike filter on the data; 
% this removes interference from other acoustic instruments but,
% more importantly, can get rid of PPI when staggered pings
% are used.
%
% Spike filtering is done using 2nd-difference
% peak detection in time. This parameter gives the maximum
% target-strength 2nd derivative that's allowed. Set to larger
% values to weaken the filtering. (Check figure 14 to see if
% filter is too strong or too weak.)
%
% has been normalized to handle different instruments 
% old values from pre-10 versions will not work !!!  GK
%
params.edit_spike_filter_max_curv = str2double(get_cruise_variable_value(cruiseVars,'edit_spike_filter_max_curv'));


%
% Set to 1 to remove data contaminated by previous-ping interference.
% NB: using the spike filter seems to work more robustly, as long
%     as staggered pings are used.
%
params.edit_PPI = str2num(get_cruise_variable_value(cruiseVars,'edit_PPI'));


%
% PPI layer thickness in meters; the value is taken directly from Eric
% Firing's default (2*clip_margin = 180m).
%
params.edit_PPI_layer_thickness = str2num(get_cruise_variable_value(cruiseVars,'edit_PPI_layer_thickness'));


%
% max distance from seabed at which PPI should be removed. This is
% an observed parameter and depends on the clarity of the water.
% Check Figure 14 to see whether this should be changed.
%
params.edit_PPI_max_hab = str2num(get_cruise_variable_value(cruiseVars,'edit_PPI_max_hab'));


%
% set this vector to enable skipping of ensembles; skipping vector
% is wrapped around, i.e. [1 0] skips all odd ensembles, [0 1 0] skips
% ensembles 2 5 8 11.... This filter is useful to process the casts
% with only half the data to see whether the two halves agree, which
% probably means that the cast can be trusted. Note that if staggered
% ping setup is used to avoid PPI, the skipping vector should leave
% adjacent ensembles intact, i.e. use something like [1 1 0 0] and
% [0 0 1 1].
%
params.edit_skip_ensembles = str2num(get_cruise_variable_value(cruiseVars,'edit_skip_ensembles'));



%
% a detection alogrithm for asynchronous ping interference between
% master and slave has been developed. This is by default off, as
% we assume that the system is run synchronous
%
params.detect_asynchronous = str2num(get_cruise_variable_value(cruiseVars,'detect_asynchronous'));


%
% bottom depth derived from data
% this one is used later for editing data
%
% if  0    : will be calculated, if data is available
%     nan  : will not be used
%
params.zbottom = str2num(get_cruise_variable_value(cruiseVars,'zbottom'));
params.zbottomerror = str2num(get_cruise_variable_value(cruiseVars,'zbottomerror'));


%
% from experience it appears as if the most distant data containing
% bin is very often not good. This can be seen in Plot 3 where the
% fringes of the data in the leftmost subplot are colored. 
% With this parameter this data is always discarded. 
%
params.edit_mask_last_bin = str2num(get_cruise_variable_value(cruiseVars,'edit_mask_last_bin')); 


messages.warn = get_cruise_variable_value(cruiseVars,'warn');
messages.warnp = str2num(get_cruise_variable_value(cruiseVars,'messages_warnp'));


% misc other

% LADCP cast number
params.ladcp_cast = str2num(get_cruise_variable_value(cruiseVars,'ladcp_cast'));
params.warnp =get_cruise_variable_value(cruiseVars,'warnp');

%
% serial numbers of instruments
% this is just used in one plot
% overwrite them in cruise_params.m
%
params.down_sn = str2num(get_cruise_variable_value(cruiseVars,'down_sn'));
params.up_sn = str2num(get_cruise_variable_value(cruiseVars,'up_sn'));


%
% distance between up and downlooker
% this will be added in rdiload to the distance of the
% first bin from the uplooking instrument
% 
params.dist_up_down = str2num(get_cruise_variable_value(cruiseVars,'dist_up_down'));


%
% what is the format of the output plots
% can be multiple ones, separated by comma
% e.g.  params.print_formats = 'ps,jpg';
%
params.print_formats = get_cruise_variable_value(cruiseVars,'print_formats');


%
% another editing parameter
%
% discard all values in bins higher than the first one that is below
% the threshold
% the two values are for down and up looking instruments
% if there is only a single value, it will be applied to both
%
params.minimum_correlation_threshold = str2num(get_cruise_variable_value(cruiseVars,'minimum_correlation_threshold'));


%
% multiply the weight of up and/or down looker by a factor
%
params.down_up_weight_factors = str2num(get_cruise_variable_value(cruiseVars,'down_up_weight_factors'));


%
% special treatment for one instrument that often did 8 pings then
% had a long gap and then continued
% we are here removing these first pings. Just increase the number
% and the first pings will be removed
%
params.remove_first_pings_of_uplooker = str2num(get_cruise_variable_value(cruiseVars,'remove_first_pings_of_uplooker'));

params.set_lag_up2down = str2num(get_cruise_variable_value(cruiseVars,'set_lag_up2down'));


%
% override the data derived heading offset between the up and down-looking
% instruments
%
params.set_hdg_offset = str2num(get_cruise_variable_value(cruiseVars,'set_hdg_offset'));


%
% Should you know the heading dependent deviation of the downlooker
% you can correct it here.
%
params.down_deviation_table = str2num(get_cruise_variable_value(cruiseVars,'down_deviation_table'));


%
% allow 3 beam solution calculation in beam2earth conversion
% and set a particular beam fully to NaN
% often bad beams contain already NaN as data, but sometimes it is just bad
% and one has to overwrite it.
%
params.beam2earth_allow_3beam_solutions = str2num(get_cruise_variable_value(cruiseVars,'beam2earth_allow_3beam_solutions'));
params.beam2earth_bad_up_beam = str2num(get_cruise_variable_value(cruiseVars,'beam2earth_bad_up_beam'));
params.beam2earth_bad_down_beam = str2num(get_cruise_variable_value(cruiseVars,'beam2earth_bad_down_beam'));


disp(params.software);                       % show version

p = params;
clear params
