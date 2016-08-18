function [f] = misc_composefilenames(params,stn);
% function [f] = misc_composefilenames(params,stn);
%
% compose the output filenames, this can't be done earlier
%
% input  :      params          - parameter structure
%               stn             - station number
%
% output :      f               - modified filename structure
%
% version 0.2  last change 08.11.2012

% GK, IFM-GEOMAR, Sep 2010

% moved stuff from default_params.m to here    GK, 08.11.2012  0.1-->0.2

% directory names
f.logs_dir        = 'logs';
f.plots_dir       = ['plots',filesep,int2str0(stn,3)]; %% line modified by RHS 25NOV2013
f.prof_dir        = ['profiles',filesep,int2str0(stn,3)]; %% line modified by RHS 25NOV2013
f.raw_dir         = ['data',filesep,'raw_ladcp'];
f.ctd_ts_dir      = ['data',filesep,'ctdtime'];
f.ctd_prof_dir    = ['data',filesep,'ctdprof'];
f.nav_dir         = ['data',filesep,'nav'];
f.sadcp_dir       = ['data',filesep,'sadcp'];
f.ladcp_dir       = ['data',filesep,'ladcp'];  %% line added by RHS 25NOV2013

% file names
stn_fmt         = '%03d';
dn_file_fmt     = '%03dDN000.000';
up_file_fmt     = '%03dUP000.000';

% line commented out by RHS 25NOV2013
% f.ladcpdo = sprintf([f.raw_dir '/' stn_fmt '/' dn_file_fmt],stn,stn); %

% line added by RHS 25NOV2013: replaced / with filesep Pedro Pena 8.12.16
f.ladcpdo = sprintf([f.ladcp_dir, filesep, stn_fmt ,filesep ,dn_file_fmt],stn,stn); %

if (~exist(f.ladcpdo,'file')) 
  dn_file_fmt     = '%03dDN000.000'; % changed dn to DN Pedro Pena 8.11.16

  % line commented out and added by RHS 25NOV2013  replaced / with filesep Pedro Pena 8.12.16
%  f.ladcpdo = sprintf([f.raw_dir '/' stn_fmt '/' dn_file_fmt],stn,stn);
  f.ladcpdo = sprintf([f.ladcp_dir , filesep,  stn_fmt , filesep,  dn_file_fmt],stn,stn);

end;

  % line commented out and added by RHS 25NOV2013   replaced / with filesep Pedro Pena 8.12.16
% f.ladcpup = sprintf([f.raw_dir '/' stn_fmt '/' up_file_fmt],stn,stn);
f.ladcpup = sprintf([f.ladcp_dir , filesep,  stn_fmt , filesep,  up_file_fmt],stn,stn);


if (~exist(f.ladcpup,'file')) 
  up_file_fmt     = '%03dUP000.000'; % changed up to UP Pedro Pena 8.11.16

  % line commented out and added by RHS 25NOV2013   replaced / with filesep Pedro Pena 8.12.16
%  f.ladcpup = sprintf([f.raw_dir '/' stn_fmt '/' up_file_fmt],stn,stn);
  f.ladcpup = sprintf([f.ladcp_dir , filesep,  stn_fmt , filesep,  up_file_fmt],stn,stn);

end;
if ~isfield(f,'ladcpup') 
  f.ladcpup = ''; 
end;
   %replaced / with filesep Pedro Pena 8.12.16
f.nav = ['data',filesep,'nav',filesep,'nav',int2str0(stn,3),'.mat'];
f.ctdprof = ['data',filesep,'ctdprof',filesep,'ctdprof',int2str0(stn,3),'.mat'];
f.ctdtime = ['data',filesep,'ctdtime',filesep,'ctdtime',int2str0(stn,3),'.mat'];
f.sadcp = ['data',filesep,'sadcp',filesep,'sadcp',int2str0(stn,3),'.mat'];

% file name for results (extensions will be added by software)
%  *.bot            bottom referenced ASCII data
%  *.lad            profile ASCII data
%  *.mat            MATLAB  format >> dr p ps f
%  *.cdf            NETCDF  (binary) LADCP data format 
%  *.log            ASCII log file of processing
%  *.txt            ASCII short log file
%  *.ps             post-script figure of result 


f.res = [f.prof_dir,filesep,params.name];
f.prof = [f.prof_dir,filesep,params.name];
f.plots = [f.plots_dir,filesep,params.name];
f.log = [f.logs_dir,filesep,params.name];

if length(f.log) > 1                    % open log file
  if exist([f.log,'.log'],'file')==2
    delete([f.log,'.log'])
  end
  diary([f.log,'.log'])
  diary on
end

