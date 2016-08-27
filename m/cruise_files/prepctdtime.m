function [values] = prepctdtime(stn,values,files,cruiseVars)
% function [values] = prepctdtime(stn,values)
%
% prepare CTD time-series for LADCP
% requires the m file: ctd_rd2.m
%
% YOU NEED TO EDIT THE LINE BELOW FOR YOUR CRUISE...
cruise_id=get_cruise_variable_value(cruiseVars,'cruise_id');
cruise_id_prefix=get_cruise_variable_value(cruiseVars,'cruise_id_prefix');
cruise_id_suffix=get_cruise_variable_value(cruiseVars,'cruise_id_suffix');
fName=[cruise_id_prefix,cruise_id,'_time_',cruise_id_suffix];
cnv=ctd_rd2([files.raw_ctd_ts_dir,filesep,fName,int2str0(stn,2),'.cnv'],'NMEA');

data = [cnv.prDM, cnv.t090C, cnv.sal00];

values.ctd_time = julian(cnv.gtime);
values.ctd_lat =cnv.latitude;
values.ctd_lon = cnv.longitude;
% keyboard
% if the time is save in timeS use this line:
timctd = [cnv.timeS/24/3600 + julian(cnv.gtime)];
% if the time is saved in Julian Days use this line:
% timctd = cnv.timeJ + julian([2013,1,0,0,0,0]);

if ~isfield(values,'ctd_time')
  values.ctd_time = nmedian(timctd);
end

% store data at the standard location
save6([files.ctd_ts_dir,filesep,'ctdtime',int2str0(stn,3)],'timctd data')


