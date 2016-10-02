function h = sfigure(h)
% SFIGURE  Create figure window (minus annoying focus-theft).
%
% Usage is identical to figure.
%
% Daniel Eaton, 2005
%
% See also figure

if nargin>=1 
	if ishandle(h)
		set(0, 'CurrentFigure', h);
	else
		%h = figure(h);
    h =makefigexact4(4.25,5.5);
    set(h,'Color',[.867,.867,.867]);
	end
else
	%h = figure;
   h =makefigexact4(4.25,5.5);
   set(h,'Color',[.867,.867,.867]);
end
