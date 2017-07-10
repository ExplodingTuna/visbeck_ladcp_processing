function [] = clear_prep(stn,files)
% function [] = clear_prep(stn)
%
% clear the MAT files from prepare_cast
%
% input  :  stn     - station number
%
% version 0.1   last change 06.03.2006

% G.Krahmann, IFM-GEOMAR, March 2006
ladcpFiles=[files.ladcp_dir,filesep,int2str0(abs(stn),3)];
logFiles=[files.logs_dir,filesep,int2str0(abs(stn),3)];
disp(' ');
disp(['clear_prep : removing files for station ',int2str(abs(stn))]);

if exist(files.ctdprof,'file')
    delete(files.ctdprof);
end

if exist(files.ctdtime,'file')
    delete(files.ctdtime);
end

if exist(files.nav,'file')
    delete(files.nav);
end

if exist(files.rawnav,'file')
    delete(files.rawnav);
end

if exist(files.sadcp,'file')
    delete(files.sadcp);
end

if exist(files.plots_dir,'file')
    delete([files.plots_dir,filesep,'*.*']);
    rmdir(files.plots_dir);
end

if exist(files.prof_dir,'file')
    delete([files.prof_dir,filesep,'*.*']);
    rmdir(files.prof_dir);
end

if exist(logFiles,'file')
    delete([logFiles,filesep,'*.*']);
    rmdir(logFiles);
end

if exist(files.tmp_dir,'file')
    delete([files.tmp_dir,filesep,'*.*']);
    rmdir(files.tmp_dir);
end


if exist(ladcpFiles,'file')
    delete([ladcpFiles,filesep,'*.*']);
    rmdir(ladcpFiles);
end

