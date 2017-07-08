function retval=cnv2nav(fileName)
%    cnv2nav converts a properly formatted processed Seabird  data file 
%    into nav data
%    that the Visbeck LADCP processing program can use.
%    this script was written in vectorized form to decrease processing 
%    time.
%    
%
%    cnv2nav(inFile)
%    


fid=fopen(fileName);
numOfColumns=0;
numOfLines=1;
columnOrder=0;
timeOrder=-1;
lonOrder=-1;
latOrder=-1;
timeIndex=-1;
lonIndex=-1;
latIndex=-1;
time_start=[];
gooddate=0;

while ~feof(fid)
    tline = fgetl(fid);
    
    if ~isempty(strfind(tline,'# start_time')) && ~isempty(strfind(tline,'[NMEA time, header]'))
        match = strsplit(tline);
        year = match{6};
        month = match{4};
        day = match{5};
        time =match{7};
        c=regexp(time,'(\d\d)','tokens');
        hour=c{1};
        min=c{2};
        sec=c{3};        
        
        yy=str2double(year);
        
        formatIn='dd-mmm-yyyy HH:MM:SS';
        dateString=[day,'-',month,'-',year,' ',time];
        jd=datenum(dateString,formatIn);
        time_start=str2double(strsplit(datestr(jd,'yyyy mm dd HH MM SS')));
        tempdate = datenum(dateString,formatIn);
        refdate  = datenum(yy-1,12,31,0,0,0 );
        gooddate = (tempdate-refdate-1);
        


        
    end    
    if ~isempty(strfind(tline,'timeS:')) && ~isempty(strfind(tline,'name'))
        match = regexp( tline,'^#\s*name\s*(\d+)\s*=\s*(.+?):\s*(.+?)$', 'tokens');
        timeIndex=str2num(match{1}{1});
        columnOrder = columnOrder +1;
        timeOrder = columnOrder;
        %disp(tline);
    end
    if ~isempty(strfind(tline,'longitude:')) && ~isempty(strfind(tline,'name'))
        match = regexp( tline,'^#\s*name\s*(\d+)\s*=\s*(.+?):\s*(.+?)$', 'tokens');
        lonIndex=str2num(match{1}{1});
        columnOrder = columnOrder +1;
        lonOrder = columnOrder;        
        %disp(tline);latIndex
    end
    if ~isempty(strfind(tline,'latitude:')) && ~isempty(strfind(tline,'name'))
        match = regexp( tline,'^#\s*name\s*(\d+)\s*=\s*(.+?):\s*(.+?)$', 'tokens');
        latIndex=str2num(match{1}{1});
        columnOrder = columnOrder +1;
        latOrder = columnOrder;        
        %disp(tline);
    end
    if ~isempty(strfind(tline,'*END'))  % end of header
        break;
    end
 
    if ~isempty(strfind(tline,'#')) && ~isempty(strfind(tline,'name'))
        match = regexp( tline,'^#\s*name\s*(\d+)\s*=\s*(.+?):\s*(.+?)$', 'tokens');
        numOfColumns=numOfColumns+1;
        %disp(tline);
    end
    numOfLines = numOfLines + 1;
end
fclose(fid);

  if latIndex == -1 || lonIndex == -1 || timeIndex == -1
  retval = [];
  return;
  end

fid=fopen(fileName);

%disp(numOfColumns);
fSpec='';
for n = 0:numOfColumns-1
    if n == latIndex || n == lonIndex || n == timeIndex
        fSpec=[fSpec,'%f'];
    else
        fSpec=[fSpec,'%*f'];
        
    end
    
end
%timeOrder 
%latOrder 
%lonOrder


navVar=textscan(fid,fSpec,'headerlines',numOfLines);
x=navVar;
x{1}=navVar{timeOrder};
x{2}=navVar{latOrder};
x{3}=navVar{lonOrder};

asd=cell2mat(x);
asd(:,1)=(asd(:,1)/24/3600) + gooddate;
[x,y] = find(asd(:,3)~=-9.990e-29); % remove bad values from longitude.
asd=asd(x,:);
[x,y] = find(asd(:,2)~=-9.990e-29); % remove bad values from latitude.
fclose(fid);
retval=asd(x,:);


end