function retval=get_print_format_extension(OPT)

% postscript
if strcmpi(OPT,'ps') || strcmpi(OPT,'ps2') || strcmpi(OPT,'psc') || strcmpi(OPT,'psc2')
    retval = 'ps';
    return;
end

%eps
if strcmpi(OPT,'eps') || strcmpi(OPT,'eps2') || strcmpi(OPT,'epsc') || strcmpi(OPT,'epsc2')
    retval = 'eps';
    return;
end

if strcmpi(OPT,'jpg') || strcmpi(OPT,'jpeg')
    retval = 'jpg';
    return;
end

if strcmpi(OPT,'png')
    retval = 'png';
    return;
end

if strcmpi(OPT,'svg')
    retval = 'svg';
    return;
end

if strcmpi(OPT,'pdf')
    retval = 'pdf';
    return;
end

retval='none';

end

