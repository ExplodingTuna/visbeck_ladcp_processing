function val = get_matlab_version
% GET_MATLAB_VERSION approximates and returns the version of matlab
% being used.
  vv = version;
  ind = findstr(vv,'.');
  v1 = str2num(vv(1:ind(1)-1));
  v2 = str2num(vv(ind(1)+1:ind(2)-1));
  val= str2num([num2str(v1),'.',num2str(v2)]);
end
