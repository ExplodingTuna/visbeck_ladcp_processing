function retval=posmv2nav(inFile,skip)
%    posmv2nav converts a text file of properly formtted POSMV Strings into nav data
%    that the Visbeck LADCP processing program can use.
%    This script is a modified version of th rmc2nav.m script for GPRMC data
%    This script was written in vectorized form to decrease processing time.
%
%    posmv2nav(inFile,skip)
%
%    inFile -The input filename
%    skip   -Lines to skip at the beginning of the file. This is useful
%    for skipping header info.


% parse file 
[cellComputerDate,cellComputerTime,GPSTime,latitudeIntegerPart,latitudeDecimalPart,cellLatitudeDirection,longitudeIntegerPart,longitudeDecimalPart,cellLongitudeDirection,a,b,c,d,e,f,g]=textread(inFile,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s','headerlines',skip);

StrComputerTime=cell2mat(cellComputerTime);
StrComputerDate=cell2mat(cellComputerDate);

Hour=str2num(StrComputerTime(:,1:2));
Minutes=str2num(StrComputerTime(:,4:5));
Seconds=str2num(StrComputerTime(:,7:end));

Day=str2num(StrComputerDate(:,4:5));
Month=str2num(StrComputerDate(:,1:2));
Year=str2num(StrComputerDate(:,7:10));


% Convert lattitude to decimal lattitude
latitude=str2double(latitudeIntegerPart)+str2double(latitudeDecimalPart)/60;
latitudeDirection=cell2mat(cellLatitudeDirection);
latNegVal=find(latitudeDirection == 'S');
latitude(latNegVal)=latitude(latNegVal).* -1;

% Convert longitude to decimal longitude 
longitude=str2double(longitudeIntegerPart)+str2double(longitudeDecimalPart)/60;
longitudeDirection=cell2mat(cellLongitudeDirection);
lonNegVal=find(longitudeDirection == 'W');
longitude(lonNegVal)=longitude(lonNegVal).* -1;

% Convert time to Julian time 
tempdate = datenum(Year,Month,Day,Hour,Minutes,Seconds);
refdate  = datenum(Year-1,12,31,0,0,0 );
gooddate = (tempdate-refdate-1);

%%% Next few lines added by CSM to address reversals in time in GPS file
[newdate,goodindx]=sort(gooddate);
newLat=latitude(goodindx);
newLon=longitude(goodindx);
clear goodindx
gooddate=newdate;clear newdate
latitude=newLat;clear newLat
longitude=newLon;clear newLon
bad=find(diff(gooddate)<=0);
gooddate(bad+1)=[];latitude(bad+1)=[];longitude(bad+1)=[];
clear bad
%%% CSM edits here
%fprintf(fidout,'%10.7f %12.6f %12.6f \n',[gooddate, latitude, longitude]');
%fclose(fidout);
retval=[gooddate, latitude, longitude];

