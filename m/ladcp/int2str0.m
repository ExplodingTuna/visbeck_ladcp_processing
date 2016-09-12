function outtext=int2str0(x,nfill,fillstr);
% function outtext=int2str0(x,[nfill],[fillstr])
%
% converts several integers in vector x into a string left-padded with
% fillstring
%
% input  :	x		: data vector
%		nfill   [x]	: to which length shall be filled
%				  default is maximum length of array
%				  changes mode to 2 !!
%				  (works only for columns)
%		fillstr ['0']   : string to fill empty places with
%
% output :	outtext		: array of characters

% added columnwise output , 		G.Krahmann, IfM Kiel, Oct 1993
% removed bug; added fillstr, 		G.Krahmann, Aug 1995
% swapped argeuments			G.K. LDEO Oct 2004
%debug_on_warning(1);

if get_matlab_version < 7.2
    v=isstr(nfill);
    else
    v=ischar(nfill);
end

if v
  dummy = nfill;
  nfill = fillstr;
  fillstr = dummy;
end
if (nargin<2)
  nfill=0;
end
if (nargin<3)
  fillstr='0';
end

outtext=[];
s=size(x);
if ( (s(1)>1) && (s(2)>1) )
  error('int2str0 is not able to handle arrays !!')
  return
end

if (s(2)==1)
  l1=length(int2str(max(x)));
  l2=length(int2str(min(x)));
  ll=max([l1,l2,nfill]);
  for i=1:length(x)
    dummy=int2str(x(i));
    while (length(dummy)<ll)
      dummy=[fillstr,dummy];
    end
    outtext=[int2str(outtext);dummy];
  end
else
  for i=1:length(x);
    outtext=[outtext int2str(x(i)) fillstr];
  end
end
