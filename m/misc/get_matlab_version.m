function retval = get_matlab_version
% GET_MATLAB_VERSION approximates and returns the version of matlab
% being used.

vv=version;
nums=strread(vv,'%s','delimiter','.');
v1=nums{1};
v2=sprintf('%02s',nums{2});

vers=[v1,'.',v2];
val=str2num(vers);

if is_octave < 1
    retval=val;
else
    retval=7.01;
end
end
