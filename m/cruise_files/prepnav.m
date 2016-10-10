function prepnav(stn,values,files,cruiseVars)
% function prepnav(stn,values)
%
% prepare navigational data for LADCP
% we an array 'data' containing the 2 columns
% latitude in decimal degrees    longitude in decimal degrees
% and the vector 'timnav' containing the time of the navigational
% data in Julian days
%
% to create a file for your own cruise, modify this file
%
% The navigational data should be at a resolution of 1 per second.
% Lower resolution will lead to worse processing results.

% G.Krahmann, IFM-GEOMAR, Aug 2005

% if you do no have navigational data to be used in the
% LADCP processing, uncomment the next two lines. Otherwise edit the

%%% NOTE: COLUMN ONE IN DATA FILE SHOULD BE YEAR DAY, NOT JULIAN DAY!!!
%%% YOU MUST MODIFY THE LINES BELOW!!!
% load data\raw_nav\XXXXXX_nav.dat
% data.latitude=XXXXXX_nav(:,2);
% data.longitude=XXXXXX_nav(:,3);
% timnav=XXXXXX_nav(:,1)+1+julian([2014,1,0,0,0,0]);
% data = [data.latitude,data.longitude];

%load(['data',filesep,'raw_nav',filesep,'nav_WS1501.mat']);

cruise_id=get_cruise_variable_value(cruiseVars,'cruise_id');
cruise_id_prefix=get_cruise_variable_value(cruiseVars,'cruise_id_prefix');
cruise_id_s=get_cruise_variable_value(cruiseVars,'cruise_id_suffix');
correct_year=str2num(get_cruise_variable_value(cruiseVars,'correct_year'));
use_mat_for_nav=str2num(get_cruise_variable_value(cruiseVars,'use_mat_for_nav'));


if use_mat_for_nav == 1
    ext='mat';
    fName=[cruise_id_prefix,cruise_id,'_nav',cruise_id_s,'.',ext];
    load([files.raw_nav_dir,filesep,fName]);
else
    ext='vis'
    fName=[cruise_id_prefix,cruise_id,'_nav',cruise_id_s,'.',ext];
    navtemp=load([files.raw_nav_dir,filesep,fName]);
    navgood=[navtemp(:,1),navtemp(:,2),navtemp(:,3)];
end


data.latitude=navgood(:,2);
data.longitude=navgood(:,3);
timnav=navgood(:,1)+1+julian([correct_year,1,0,0,0,0]);
data = [data.latitude,data.longitude];

% USE CODAS3 GPS FILE INSTEAD!!!

% load D:\ladcp\v10.8\WS1311\data\raw_nav\WS1311_from_UHDAS.gps
% 
% data.latitude=WS1311_from_UHDAS(:,3);
% data.longitude=WS1311_from_UHDAS(:,2)-360;
% timnav=WS1311_from_UHDAS(:,1)+1+julian([2013,1,0,0,0,0]);
% data = [data.latitude,data.longitude];


% To reduce the amount of data we crop the navigational data to
% the same time as the CTD-TIME data. In our example case that
% was an unnecessary exercise since they are the same data, but if
% you have independent navigational data (e.g. daily navigational files)
% this will reduce file size.
% good = find(timnav>=values.start_cut & timnav<=values.end_cut);
% timnav = timnav(good);
% data = data(good,:);

% store data in the standard location
savefile=['save6 ',files.nav,' timnav data'];
eval(savefile)
