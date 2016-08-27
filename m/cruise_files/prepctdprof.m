function [values] = prepctdprof(stn,values,files,cruiseVars)
% function [values] = prepctdprof(stn,values)
%
% prepare CTD profile for LADCP
% requires the m file: ctd_rd2.m
%
%
% MODIFY LINE BELOW FOR YOUR CRUISE.
% NOTE, CTDPROF SHOULD BE DOWNCAST ONLY!
cruise_id=get_cruise_variable_value(cruiseVars,'cruise_id');
cruise_id_prefix=get_cruise_variable_value(cruiseVars,'cruise_id_prefix');
cruise_id_suffix=get_cruise_variable_value(cruiseVars,'cruise_id_suffix');
fName=[cruise_id_prefix,cruise_id,'_profile_',cruise_id_suffix];

cnv=ctd_rd2([files.raw_ctd_prof_dir,filesep,fName,int2str0(stn,2),'.cnv'],'NMEA');


ctdprof = [cnv.prDM, cnv.t090C, cnv.sal00];
values.ctd_time = julian(cnv.gtime);
values.ctd_lat = cnv.latitude;
values.ctd_lon = cnv.longitude;

% store data at the standard location
save6([files.ctd_prof_dir,filesep,'ctdprof',int2str0(stn,3)],'ctdprof')
% 
% save filename
file = [files.ctd_prof_dir,filesep,'ctdprof',int2str0(stn,3)];
