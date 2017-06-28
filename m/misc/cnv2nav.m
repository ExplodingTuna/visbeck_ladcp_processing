%% Copyright (C) 2017 user
%% 
%% This program is free software; you can redistribute it and/or modify it
%% under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%% 
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%% 
%% You should have received a copy of the GNU General Public License
%% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*- 
%% @deftypefn {Function File} {@var{retval} =} getPos (@var{input1}, @var{input2})
%%
%% @seealso{}
%% @end deftypefn

%% Author: user <user@ubuntu>
%% Created: 2017-06-27

function retval=cnv2nav(fileName)
% yo
fid=fopen(fileName);
numOfColumns=0;
numOfLines=1;
      while ~feof(fid)
        tline = fgetl(fid);
         if ~isempty(strfind(tline,'timeJ:')) && ~isempty(strfind(tline,'name'))
                 match = regexp( tline,'^#\s*name\s*(\d+)\s*=\s*(.+?):\s*(.+?)$', 'tokens');
                 timeIndex=str2num(match{1}{1});
            %disp(tline);
         end          
         if ~isempty(strfind(tline,'longitude:')) && ~isempty(strfind(tline,'name'))
                 match = regexp( tline,'^#\s*name\s*(\d+)\s*=\s*(.+?):\s*(.+?)$', 'tokens');
                 lonIndex=str2num(match{1}{1});
            %disp(tline);
         end
         if ~isempty(strfind(tline,'latitude:')) && ~isempty(strfind(tline,'name'))
                 match = regexp( tline,'^#\s*name\s*(\d+)\s*=\s*(.+?):\s*(.+?)$', 'tokens');
                 latIndex=str2num(match{1}{1});
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
       disp(fSpec);
       disp(numOfLines);
       
       retval=textscan(fid,fSpec,'headerlines',numOfLines);
       fclose(fid);