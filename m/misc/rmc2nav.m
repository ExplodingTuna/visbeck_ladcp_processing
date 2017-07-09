function retval=rmc2nav(inFile,hourOffset,skip)
%
%    Converts a text file of properly formatted RMC Strings into nav data
%    that the Visbeck LADCP processing program can use.
%
%    [gooddate, latitude, longitude] = rmc2nav(inFile,hourOffset,skip)
%
%       inFile     -The input filename
%       hourOffset -Hours to add or subtract. Helpful if time isn't in UTC. 
%       skip       -Lines to skip at the beginning of the file. This is useful
%                   for skipping header info.
%
%    it will parse the following format.
%
%    $GPRMC,142436,A,2607.7739,N,07954.0164,W,10.9,82.9,080517,7.3,W*71
%    $GPRMC,203043,A,2603.1339,N,07851.2177,W,10.2,9.4,080517,8.0,W*4A
%
%    this script was written in vectorized form to decrease processing time.
%    
%
%    [gooddate, latitude, longitude] = rmc2nav(inFile,hourOffset,skip)
%    


% parse file 
[a,gCtime,c,Clat,ClatDir,Clon,ClonDir,h,i,gCdate,k,l]=textread(inFile,'%s %s %s %s %s %s %s %s %s %s %s %s','delimiter',',','headerlines',skip);

gTime=cell2mat(gCtime);
gDate=cell2mat(gCdate);

gHour=str2num(gTime(:,1:2));
gMinutes=str2num(gTime(:,3:4));
gSeconds=str2num(gTime(:,5:6));

gDay=str2num(gDate(:,1:2));
gMonth=str2num(gDate(:,3:4));
gYear=str2num(gDate(:,5:6));
gYear=gYear + 2000;

% Convert lattitude to decimal lattitude
lat=cell2mat(Clat);
latI=str2num(lat(:,1:2));
latD=str2num(lat(:,3:9));
decLat=latI+latD/60;
latDir=cell2mat(ClatDir);
latNegVal=find(latDir == 'S');
decLat(latNegVal)=decLat(latNegVal).* -1;

% Convert longitude to decimal longitude 
lon=cell2mat(Clon);
lonI=str2num(lon(:,1:3));
lonD=str2num(lon(:,4:10));
decLon=lonI+lonD/60;
lonDir=cell2mat(ClonDir);
lonNegVal=find(lonDir == 'W');
decLon(lonNegVal)=decLon(lonNegVal).* -1;

% Convert time to Julian time 
tempdate = datenum(gYear,gMonth,gDay,gHour,gMinutes,gSeconds) + (hourOffset/86400);
refdate  = datenum(gYear-1,12,31,0,0,0 );
gooddate = (tempdate-refdate-1);

%%% Next few lines added by CSM to address reversals in time in GPS file
[newdate,goodindx]=sort(gooddate);
newLat=decLat(goodindx);
newLon=decLon(goodindx);
clear goodindx
gooddate=newdate;clear newdate
decLat=newLat;clear newLat
decLon=newLon;clear newLon
bad=find(diff(gooddate)<=0);
gooddate(bad+1)=[];decLat(bad+1)=[];decLon(bad+1)=[];
clear bad
%%% CSM edits here

retval=[gooddate, decLat, decLon];


