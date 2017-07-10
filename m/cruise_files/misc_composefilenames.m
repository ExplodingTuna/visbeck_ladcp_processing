function [f] = misc_composefilenames(params,stn,cruiseVars)
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


% directory names made relative Pedro Pena 8.21.16


cruise_id=get_cruise_variable_value(cruiseVars,'cruise_id');
cruise_id_prefix=get_cruise_variable_value(cruiseVars,'cruise_id_prefix');
cruise_id_s=get_cruise_variable_value(cruiseVars,'cruise_id_suffix');

f.working_directory=get_cruise_variable_value(cruiseVars,'working_directory');
if (f.working_directory == '.')
    f.working_directory =pwd();
end

f.data_directory=[f.working_directory,filesep,'data'];
f.logs_dir        = [f.working_directory,filesep,'logs'];
f.plot_dir        = [f.working_directory,filesep,'plots'];
f.profiles_dir    = [f.working_directory,filesep,'profiles'];
f.plots_dir       = [f.plot_dir,filesep,int2str0(stn,3)]; %% line modified by RHS 25NOV2013
f.prof_dir        = [f.profiles_dir,filesep,int2str0(stn,3)]; %% line modified by RHS 25NOV2013
f.ctd_ts_dir      = [f.data_directory,filesep,'ctdtime'];
f.raw_ctd_ts_dir  = [f.data_directory,filesep,'raw_ctdtime'];
f.ctd_prof_dir    = [f.data_directory,filesep,'ctdprof'];
f.raw_ctd_prof_dir= [f.data_directory,filesep,'raw_ctdprof'];
f.nav_dir         = [f.data_directory,filesep,'nav'];
f.raw_nav_dir     = [f.data_directory,filesep,'raw_nav'];
f.external_nav_dir    = [f.data_directory,filesep,'external_nav'];
f.sadcp_dir       = [f.data_directory,filesep,'sadcp'];
f.raw_sadcp_dir   = [f.data_directory,filesep,'raw_sadcp'];
f.ladcp_dir       = [f.data_directory,filesep,'ladcp'];  %% line added by RHS 25NOV2013
f.raw_dir         = [f.data_directory,filesep,'raw_ladcp'];
f.raw_cut_dir     = [f.raw_dir ,filesep,'cut'];
f.tmp_dir         = [f.working_directory,filesep,'tmp'];
f.cfg_dir         = [pwd(),filesep,'cfg'];

if ~exist(f.data_directory)
    mkdir(f.data_directory);
end

if ~exist(f.logs_dir)
    mkdir(f.logs_dir);
end

if ~exist([f.logs_dir,filesep,int2str0(stn,3)])
    mkdir([f.logs_dir,filesep,int2str0(stn,3)]);
end

if ~exist(f.plot_dir )
    mkdir(f.plot_dir );
end
if ~exist(f.profiles_dir)
    mkdir(f.profiles_dir);
end
if ~exist(f.ctd_ts_dir)
    mkdir(f.ctd_ts_dir);
end
if ~exist(f.ctd_prof_dir)
    mkdir(f.ctd_prof_dir);
end
if ~exist(f.ctd_ts_dir)
    mkdir(f.ctd_ts_dir);
end
if ~exist(f.raw_ctd_ts_dir)
    mkdir(f.raw_ctd_ts_dir);
end
if ~exist(f.ctd_prof_dir)
    mkdir(f.ctd_prof_dir);
end

if ~exist(f.raw_ctd_prof_dir)
    mkdir(f.raw_ctd_prof_dir);
end  

if ~exist(f.nav_dir)
    mkdir(f.nav_dir);
end
if ~exist(f.raw_nav_dir)
    mkdir(f.raw_nav_dir);
end
if ~exist(f.external_nav_dir)
    mkdir(f.external_nav_dir);
end
if ~exist(f.sadcp_dir)
    mkdir(f.sadcp_dir);
end
if ~exist(f.raw_sadcp_dir)
    mkdir(f.raw_sadcp_dir);
end
if ~exist(f.ladcp_dir)
    mkdir(f.ladcp_dir);
end
if ~exist(f.raw_dir)
    mkdir(f.raw_dir);
end

if ~exist(f.tmp_dir)
    mkdir(f.tmp_dir);
end
if ~exist(f.raw_cut_dir )
    mkdir(f.raw_cut_dir );
end


% file names
stn_fmt         = '%03d';
dn_file_fmt     = '%03dDN000.000';
up_file_fmt     = '%03dUP000.000';

% line commented out by RHS 25NOV2013
% f.ladcpdo = sprintf([f.raw_dir '/' stn_fmt '/' dn_file_fmt],stn,stn); %
% line added by RHS 25NOV2013: replaced / with filesep Pedro Pena 8.12.16
t0=sprintf([stn_fmt],stn);

t1=sprintf([dn_file_fmt],stn);
f.ladcpdo = [f.ladcp_dir, filesep, t0 ,filesep ,t1]; %
% % % 
% % % if (~exist(f.ladcpdo,'file') == 0) %exist was being negated Pedor Pena 8.22.16
% % %   dn_file_fmt     = '%03ddn000.000'; % changed dn to DN Pedro Pena 8.11.16
% % % 
% % %   % line commented out and added by RHS 25NOV2013  replaced / with filesep Pedro Pena 8.12.16
% % % %  f.ladcpdo = sprintf([f.raw_dir '/' stn_fmt '/' dn_file_fmt],stn,stn);
% % % t1=sprintf([dn_file_fmt],stn);
% % % f.ladcpdo = [f.ladcp_dir, filesep, t0 ,filesep ,t1]; %
% % % 
% % % end;
% % % 
% % %   % line commented out and added by RHS 25NOV2013   replaced / with filesep Pedro Pena 8.12.16
% % % % f.ladcpup = sprintf([f.raw_dir '/' stn_fmt '/' up_file_fmt],stn,stn);
% % % %f.ladcpup = sprintf([f.ladcp_dir , filesep,  stn_fmt , filesep,  up_file_fmt],stn,stn);
% % % 
% % % t1=sprintf([up_file_fmt],stn);
% % % f.ladcpup = [f.ladcp_dir, filesep, t0 ,filesep ,t1]; %
% % % 
% % % 
% % % if (~exist(f.ladcpup,'file') == 0 ) %exist was being negated Pedor Pena 8.22.16
% % %   up_file_fmt     = '%03dup000.000'; % changed up to UP Pedro Pena 8.11.16
% % % 
% % %   % line commented out and added by RHS 25NOV2013   replaced / with filesep Pedro Pena 8.12.16
% % % %  f.ladcpup = sprintf([f.raw_dir '/' stn_fmt '/' up_file_fmt],stn,stn);
% % %   %f.ladcpup = sprintf([f.ladcp_dir , filesep,  stn_fmt , filesep,  up_file_fmt],stn,stn);
  t1=sprintf([up_file_fmt],stn);
f.ladcpup = [f.ladcp_dir, filesep, t0 ,filesep ,t1]; %

% % % end;
if ~isfield(f,'ladcpup') 
  f.ladcpup = ''; 
end;
   %replaced / with filesep Pedro Pena 8.12.16
% f.nav = ['data',filesep,'nav',filesep,'nav',int2str0(stn,3),'.mat'];
% f.ctdprof = ['data',filesep,'ctdprof',filesep,'ctdprof',int2str0(stn,3),'.mat'];
% f.ctdtime = ['data',filesep,'ctdtime',filesep,'ctdtime',int2str0(stn,3),'.mat'];
% f.sadcp = ['data',filesep,'sadcp',filesep,'sadcp',int2str0(stn,3),'.mat'];
%fName=[cruise_id_prefix,cruise_id,'_ctdprof',int2str0(stn,3),cruise_id_s,'.mat'];

f.nav = [f.nav_dir,filesep,cruise_id_prefix,cruise_id,'_nav_',cruise_id_s,int2str0(stn,3),'.mat'];
f.ctdprof = [f.ctd_prof_dir,filesep,cruise_id_prefix,cruise_id,'_ctdprof_',cruise_id_s,int2str0(stn,3),'.mat'];
f.ctdtime = [f.ctd_ts_dir,filesep,cruise_id_prefix,cruise_id,'_ctdtime_',cruise_id_s,int2str0(stn,3),'.mat'];
f.sadcp = [f.sadcp_dir,filesep,cruise_id_prefix,cruise_id,'_sadcp_',cruise_id_s,int2str0(stn,3),'.mat'];
% delete this one too.
f.rawnav = [f.raw_nav_dir,filesep,cruise_id_prefix,cruise_id,'_nav_',cruise_id_s,int2str0(stn,3),'.vis'];

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
f.log = [f.logs_dir,filesep,int2str0(stn,3),filesep,params.name];

if length(f.log) > 1                    % open log file
  if exist([f.log,'.log'],'file')==2
    delete([f.log,'.log'])
  end
  diary([f.log,'.log'])
  diary on
end

