function hg_save(varargin)
fName=[varargin{1},'.ps'];
if ~exist(fName,'file') || ~isempty(strfind(varargin{1},'16'))
    if is_octave < 1
        eval(['print -djpeg -r300 ',fName]);
    else
        %eval(['print -djpg -r300 ',fName]);
        eval(['print -dpsc ',fName]);
    end
end
% if ~isempty(strfind(varargin{1},'16'))
%     hgsave(varargin{1})
% end