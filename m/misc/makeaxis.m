function h=makeaxis(bottommar,leftmar,xlen,ylen);
%
% function h=makeaxis(bottommar,leftmar,xlen,ylen);
%
% This function creates an axis of the size input in inches.  
% The inputs are (respectively) the bottom margin, the left margin, 
% the x axis length, and the y axis length.  After running this 
% function simply go ahead and invoke contour or plot or whatever 
% combination of plotting routines you need.  This figure window will 
% remain the active window until you either delete it or invoke another
% figure command.
%
% by C. Meinen
%
axset=[leftmar bottommar xlen ylen];
h=axes('units','inches','Position',axset,'units','normalized');
%
