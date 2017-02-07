function [file] = prepladcp(stn,files,cruiseVars)
% function [file] = prepladcp(stn)
%
% prepare LADCP data for LADCP processing
%
% we need the raw LADCP data to be in the correct place and
% have the correct names.
%
%
% to create a file for your own cruise, modify this file
%
% you will just need to copy and possibly rename the files
% In case of old BB and NB systems you might need to append
% the raw data files.
%
% the convention for filenames is
%
% xxxDN000.000  and  xxxUP000.000  	with xxx the 3-digit station number
%
% they need to be copied into one directory per station
% data/raw_ladcp/xxx		with xxx the 3-digit station number

% G.Krahmann, IFM-GEOMAR, Aug 2005
% disp('YOU FIRST NEED TO EDIT THE FILE cruise_id/m/prepladcp.m !')
% pause
% return
% YOU MUST EDIT THIS FILE PRIOR TO PROCESSING YOUR CRUISE!
cruise_id=get_cruise_variable_value(cruiseVars,'cruise_id');
cruise_str = [cruise_id,'_'];
cruisedir = cruise_id;
stncaststr = sprintf('%03d_01',stn);



  if ~exist([files.ladcp_dir ,filesep,int2str0(stn,3)])
    mkdir([files.ladcp_dir ,filesep,int2str0(stn,3)])
  end
  
%   if ~exist([files.raw_dir,filesep,'cut',filesep,int2str0(stn,3)])
%     mkdir([files.raw_dir,filesep,'cut',filesep,int2str0(stn,3)])
%   end

%eval(['!del data\raw_ladcp\',int2str0(stn,3),'\*.000'])
%eval(['! copy data\raw_ladcp\cut\',cruise_str,stncaststr,'m.000 data\ladcp\',int2str0(stn,3),'\',int2str0(stn,3),'DN000.000'])
%eval(['! copy data\raw_ladcp\cut\',cruise_str,stncaststr,'s.000 data\ladcp\',int2str0(stn,3),'\',int2str0(stn,3),'UP000.000'])

% changed to platform independent copyfile Pedro Pena 8.11.16 
use_master_only=str2num(get_cruise_variable_value(cruiseVars,'use_master_only'));

copyfile([files.raw_cut_dir,filesep,cruise_str,stncaststr,'m.000'],...
    [files.ladcp_dir,filesep,int2str0(stn,3),filesep,int2str0(stn,3),'DN000.000'])
if ~use_master_only
    copyfile([files.raw_cut_dir,filesep,cruise_str,stncaststr,'s.000'],...
        [files.ladcp_dir,filesep,int2str0(stn,3),filesep,int2str0(stn,3),'UP000.000'])
end

% set file name
file = [files.ladcp_dir,filesep,int2str0(stn,3)];
