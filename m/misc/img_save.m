function img_save(fileName,print_formats)
ext=get_print_format_extension(print_formats);
fName=[fileName,'.',ext];

if ~is_octave && strcmpi(print_formats,'jpg')
    print_formats='jpeg';
end

if strcmpi(ext,'jpg') || strcmpi(ext,'png')
    print_formats=[print_formats,' -r300'];
end
if ~exist(fName,'file') || ~isempty(strfind(fName,'16'))
    eval(['print -d',print_formats,' ',fName]);
end
