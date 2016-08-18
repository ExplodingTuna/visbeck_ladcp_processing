function [values] = prepctdprof(stn,values)
% function [values] = prepctdprof(stn,values)
%
% prepare CTD profile for LADCP
% requires the m file: ctd_rd2.m
%
%
% MODIFY LINE BELOW FOR YOUR CRUISE.
% NOTE, CTDPROF SHOULD BE DOWNCAST ONLY!
cnv=ctd_rd2(['data',filesep,'raw_ctdprof',filesep,'WS1501_profile_FS',int2str0(stn,2),'.cnv'],'NMEA');

ctdprof = [cnv.prDM, cnv.t090C, cnv.sal00];
values.ctd_time = julian(cnv.gtime);
values.ctd_lat = cnv.latitude;
values.ctd_lon = cnv.longitude;

% store data at the standard location
save6(['data',filesep,'ctdprof',filesep,'ctdprof',int2str0(stn,3)],'ctdprof')
% 
% save filename
file = ['data',filesep,'ctdprof',filesep,'ctdprof',int2str0(stn,3)];
