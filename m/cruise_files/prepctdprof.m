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

fName=[files.raw_ctd_prof_dir,filesep,cruise_id_prefix,cruise_id,'_profile_',cruise_id_suffix,int2str0(stn,3),'.cnv'];
cnv=ctd_rd2(fName,'NMEA');
ctdprof = [cnv.prDM, cnv.t090C, cnv.sal00];
values.ctd_time = julian(cnv.gtime);
values.ctd_lat = cnv.latitude;
values.ctd_lon = cnv.longitude;

% store data at the standard location
save6([files.ctd_prof_dir,filesep,'ctdprof',int2str0(stn,3),'.mat'],'ctdprof')
% 
% save filename
file = [files.ctd_prof_dir,filesep,'ctdprof',int2str0(stn,3),'.mat'];
