function hgsave(varargin)
if is_octave < 1
    eval(['print -djpeg ', varargin{1},'.jpg']);
else
    eval(['print -djpg ', varargin{1},'.jpg']);
end
hgsave(varargin{1})