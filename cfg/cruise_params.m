% Parameters setting files are called in this order
%
% default_params.m
% cruise_params.m   <--- you are here
% cast_params.m
%
% this is the location to enter special settings which apply
% to a whole cruise or to your special LADCP system setup



disp('IFM-GEOMAR LADCP v10.20 modified for NOAA/AOML/PhOD (R.Smith, May 2014)')

% remove the following three lines after modifying the parameters
% disp('edit  cruise_id/cruise_params.m before processing')
% pause
% return


%
% set the  Cruise id
%
% this will appear on the top of all plots
% and in all file names
%
%p.cruise_id	= 'AWS1501A';
% p.name  = ['XXXXXX_NO_SADCP_',int2str0(stn,3)];
% p.name  = ['XXXXXX_UNCUT_',int2str0(stn,3)];
%p.name  = [p.cruise_id,'_FINAL_',int2str0(stn,3)];


% to enable gps set to 1
p.enable_nav=str2num(get_cruise_variable_value(cruiseVars,'enable_nav'));
% to enable ctd profiles set to 1
p.enable_ctdprof=str2num(get_cruise_variable_value(cruiseVars,'enable_ctdprof'));
% to enable ctd time series set to 1
p.enable_ctdtime=str2num(get_cruise_variable_value(cruiseVars,'enable_ctdtime'));
% to enable shipboard adcp set to 1
%p.enable_sadcp=1;
%
% some software does only record the day of the year
% to be able to process such data properly enter the
% year which will be used for data without year information
%
% if you are measuring over newyear, you will need to introduce an
% if-statement here
%
p.correct_year = str2num(get_cruise_variable_value(cruiseVars,'correct_year'));
%keyboard
%
% If you want you can give the serial numbers of up and down instrument
%
% this is just used in one plot
%
p.down_sn = 2222222; %MASTER
p.up_sn = 3333333; % SLAVE


%
% Output resolution and superensemble averaging depth
%
% 20 is good for standard full ocean depth
% smaller (10 or even 5) can be used for special shallow casts
%
% default is down-looker bin-length
% 
ps.dz	= str2num(get_cruise_variable_value(cruiseVars,'dz'));			% output depth resolution
p.avdz = ps.dz;		% pre-average data


%
% Standard thresholds, beyond which data will be discarded
%
% elim : ADCP internal error velocity limit   0.5 is reasonable and default
% vlim : ADCP horizontal velocity limit       2.5 is reasonable and default
% wlim : ADCP vertical velocity bin limit     0.2 is reasonable and default
%
% (wlim is the deviation from the median of all bins in each ensemble)
%

%our special defaults...
%p.elim= 0.2;
%
%p.vlim= 2.5;
%
%p.wlim= 0.08;
% 
% p.elim= 0.2;
% %
% p.vlim= 2.5;
% %
% p.wlim= 0.2;


% things to consider setting (mostly for experts)
% see default_params.m for descriptions
%
% inverse solve parameter = 1 to solve down and up individually
%ps.down_up=1;
%
%% p.btrk_mode (and other related ones)
% try to get bottom track out of water bins (for old RDI systems)
% p.btrk_ts is in dB to detect bottom above bin1 level (for own btm track)
%p.btrk_ts = 10;
% p.btrk_range gives maximum distance for bottom track
% mode = 1 :   use only RDI bottom track
%        2 :   use only own bottom track
%        3 :   use RDI, if existent, own else (default)
%        0 :   use not bottom track at all
%p.btrk_mode = 3;
%
% Disregard first bin of WH300 if set with zero blank-after-transmit
% Comment out to disable - do NOT set as zero because processing
% will fall over
% NOTE, IF USING A DOWNWARD-LOOKING WH150, YOU MUST COMMENT OUT:
% p.edit_mask_dn_bins...
%
%p.edit_mask_up_bins = [1];
%p.edit_mask_dn_bins = [1];
%
% p.rotup2down
%
% p.offsetup2down
%
% p.outlier
%
%% p.pglim
% minimum % good
%p.pglim=0.3; 
%
%p.maxlag  maximum lag 
%p.maxlag=50;
% p.tiltmax
%p.tiltmax=[20 4]; % for BB % FOR CHEESY POOF ONLY
%p.tiltmax=[30 4]; % for WH

%p.tiltmax=[90 20];

%
% p.tiltweight
%
% p.trusted_i
%
% p.barofac
%
% p.botfac
%ps.botfac = 5;

% p.smoofac
% to smooth high-mode shear increase smmofac:
% ps.smoofac = 0;%
% p.smallfac
% (recommended) uncomment the following:
%ps.smallfac = [1 0];
% ps.sadcpfac	
%ps.sadcpfac=5;
%
% p.dragfac
%
% p.urange/zrange
%
% p.sadcp_dtok
%ps.shear = 1;


% DO NOT MODIFY....
% p.edit_hardremove_mask_dn_bins = [];
% p.edit_hardremove_mask_up_bins = [];
% p.remove_first_pings_of_uplooker = [];
% p.remove_first_pings_of_dnlooker = [];
% p.timoff_uplooker = [];
% p.timoff_dnlooker = [];
% p.force_resample_uplooker = [];
% p.force_resample_dnlooker = [];
% p.use_3beam_w_for_lag = [];
% p.set_lag_up2down = [];
% p.bestlag_testing_on = [];
% p.down_deviation_table = [];
% p.up_deviation_table = [];
% p.minimum_correlation_threshold = [];
% p.set_hdg_offset = [];
% p.down_up_weight_factors = [];
%p.print_formats = ['ps'];