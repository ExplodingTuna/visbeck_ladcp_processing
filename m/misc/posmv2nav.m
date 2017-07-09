function retval=posmv2nav(inFile,hourOffset,skip)
%
%    Converts a text file of properly formtted POSMV Strings into nav data
%    that the Visbeck LADCP processing program can use.
%
%    [gooddate, latitude, longitude] = posmv2nav (inFile,hourOffset,skip)
%
%       inFile     -The input filename
%       hourOffset -Hours to add or subtract. Helpful if time isn't in UTC. 
%       skip       -Lines to skip at the beginning of the file. This is useful
%                   for skipping header info.
%
%    it will parse the following formats.
%    OLD STYLE
%    Software Version Number: 1	Data File Format Number: 1	Build Version Number: 1	Error Count Since VI Started: 0	Manufacturer: TSG	 Model Number: 274	 S/N: 274	 Cal Date: Feb.2006 Wind Direction Offset:	0.00
%    Date	Time	GPS UTC	Lat Deg	Lat Min	Lat Dir	Lon Deg	Lon Min	Lon Dir	Altitude	Geoid Height	Horizontal Dilution	Satellites	Fix Quality
%    07/09/2008	06:00:01	55949.1	27	0.812570	N	79	54.566790	W	6.430000	0.000000	1.000000	0	2
%    07/09/2008	06:00:01	55950.1	27	0.811890	N	79	54.567850	W	6.330000	0.000000	1.000000	8	1
%    07/09/2008	06:00:02	55951.1	27	0.811200	N	79	54.568840	W	6.500000	0.000000	1.000000	0	2
%
%    NEW STYLE
%    Software Version Number: 1	Data File Format Number: 1	Build Version Number: 1	Error Count Since VI Started: 3	Manufacturer: Applanix	 Model Number: V3	 S/N: 274	 Cal Date: Feb. 2006	 Wind Direction Offset: 0.00	 Slope (M)1: 0.00	 Offset (B)1: 0.00	 Slope (M)2: 0.00	 Offset (B)2: 0.00	 Slope (M)3: 0.00	 Offset (B)3: 0.00	 Slope (M)4: 0.00	 Offset (B)4: 0.00	 Slope (M)5: 0.00	 Offset (B)5: 0.00	 Slope (M)6: 0.00	 Offset (B)6: 0.00
%    Computer Date	Computer Time	GPS Time	Lat Deg	Lat Min	Lat Dir	Lon Deg	Lon Min	Lon Dir	Altitude	Geoid Height	Horizontal Dilution	Satellites	Fix Quality	Mnemonic	Checksum
%    Computer Date	Computer Time	GPS Time	Lat Deg	Lat Min	Lat Dir	Lon Deg	Lon Min	Lon Dir	Altitude	Geoid Height	Horizontal Dilution	Satellites	Fix Quality	Mnemonic	Checksum
%    12/11/2008	00:00:01.591	235548.642	25	43.879390	N	80	9.724210	W	0.250000	0.000000	1.000000	9	1	$INGGA	30
%    12/11/2008	00:00:02.590	235549.642	25	43.879360	N	80	9.724200	W	0.260000	0.000000	1.000000	9	1	$INGGA	3C
%    12/11/2008	00:00:05.585	235552.642	25	43.879310	N	80	9.724150	W	0.290000	0.000000	1.000000	9	1	$INGGA	38
%
%    This script is a modified version of th rmc2nav.m script for GPRMC data
%    This script was written in vectorized form to decrease processing time.
%    
%
%    [gooddate, latitude, longitude] = posmv2nav (inFile,hourOffset,skip)
%



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
tempdate = datenum(Year,Month,Day,Hour,Minutes,Seconds) + (hourOffset/86400);
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

