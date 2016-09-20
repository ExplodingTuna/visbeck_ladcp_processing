function [] = process_cast(stnS,ctd_lagS,extraarg)
% function [] = process_cast(stn,extraarg)
%
% Process LADCP cast, including GPS, SADCP, and BT data.
%
% input  :    stn             - station number, all data needs to be
%                               numbered in this way
%                               Enter a negative number to clear loaded
%                               and saved ancillary data for that station.
%             extraarg  []    - add 'noplots' to not save plots
%                               useful to speed up testing
%
% version 0.10  last change 31.10.2013

% G.Krahmann, IFM-GEOMAR

% orient statements for figure saving     GK, 14.07.2008  0.1-->0.2
% orient gone, several drawnow's          GK, 15.07.2008  0.2-->0.3
% call clear_prep for negative stn        GK, 07.02.2009  0.3-->0.4
% variable p.print_formats                GK, 28.05.2011  0.4-->0.5
% noplots                                 GK, 04.11.2012  0.5-->0.6
% f as output of rdiload.m                GK, 08.11.2012  0.6-->0.7
% act on p.savemat                        GK, 13.01.2013  0.7-->0.8
% catch too shallow profiles              GK, 13.07.2013  0.8-->0.9
% added messages argument to getbtrack    GK, 31.10.2013  0.9-->0.10

%
% handle extra arguments
%
% When passed as an argument from the command line, the MRC interprets
% the value as a strng rather than a number. This check will allow both
% strings and numbers to be passed
tic;					% start timer
global fig16h; % handle to  figure 16
global fig8h;  % handle to figure 8
if is_octave ==1
close all;
warning ('off', 'Octave:divide-by-zero');
graphics_toolkit('gnuplot');
set (0, 'defaultaxesfontname', 'Helvetica');
end
if isnumeric(stnS) %Pedro Pena 8.11.16
    stn=stnS;
else
    stn=str2num(stnS)
end

if nargin > 1
    if isnumeric(ctd_lagS) %Pedro Pena 8.11.16
        ctd_lag=ctd_lagS;
    else
        ctd_lag=str2num(ctd_lagS)
    end
end

if nargin==1
    ctd_lag = 0;
end

noplots = 0;
if nargin>2
    if strcmp(extraarg,'noplots')
        noplots = 1;
    end
end


%=========================================================================
% This piece loads the contents cruise_params.cfg into
% cell matrix 'cruiseVars'
fileToRead=['cfg',filesep,'cruise_params.cfg'];
fid=fopen(fileToRead,'r');
cruiseVars=textscan(fid,'%s%s','Delimiter','=','CommentStyle','#');
%get_cruise_variable_value(cruiseVars,'')
fclose(fid);
%=========================================================================


% commented Pedro Pena 8.21.16
%
% check current directory
%
%if exist('logs')~=exist(pwd);
%    disp('>   This directory is not prepared for the LADCP software ')
%    disp('>   Sorry EXIT ')
%    return
%end


%
% clear already loaded and saved data for reloading and reprocessing
%
if stn<0
    clear_prep(-stn);
    return
end




%
% Initialize the processing by loading parameters
% and make sure that we have no leftovers from previous processings
%
default_params;
cruise_params;
cast_params;
files = misc_composefilenames(p,stn,cruiseVars);

% clear temp files
%
%
%
imgFileExt=get_print_format_extension(p.print_formats);
for n=1:16
    fName=['tmp',filesep,int2str(n),'.',imgFileExt];
    if exist(fName);
        delete(fName);
    end
end
%
% prepare the various data files for easy loading
%
% [values] = prepare_cast(stn);
cruise_id=get_cruise_variable_value(cruiseVars,'cruise_id');%added by Pedro Pena 8.19.16
[values] = prepare_cast(stn,p,files,cruiseVars); % added p variable RHS MAY 2014

%
% load RDI data
% and perform some simple processing steps
%

% override automatically detected Serial Numbers
% and use the ones from cruise_params.cfg  added by Pedro Pena 8.20.16
override_sn = str2num(get_cruise_variable_value(cruiseVars,'override_sn'));

[data,values,messages,p,files] = rdiload(files,p,messages,values);

if override_sn == 1
    values.inst_serial(1) = str2num(get_cruise_variable_value(cruiseVars,'down_sn'));
    values.inst_serial(2) = str2num(get_cruise_variable_value(cruiseVars,'up_sn'));
end
[data,messages] = misc_prepare_rdi(data,p,messages);



%
% plot the display menu
%
if is_octave && ~strcmp(graphics_toolkit,'gnuplot')
plot_menu(imgFileExt);
drawnow;
end

if ~is_octave && ~strcmpi(imgFileExt,'ps') && ~strcmpi(imgFileExt,'pdf')
plot_menu(imgFileExt);
drawnow;
end



%
% convolution of the loading routines for the
% various data sets
%
[data,messages] = loading(files,data,messages,p,ctd_lag);


%
% merge LADCP data with NAV and CTD
%

fig8h=sfigure(2);
clf;
[data,p,messages,values] = mergedata(data,p,messages,values);


%
% improve the data quality by removing spikes etc
%
[data,p,values,messages] = improve(data,p,values,messages);
if isempty(data)
    disp('>   Processing is stopped.')
    return
end


%
% extract the bottom track
%
[data,p,messages] = getbtrack(data,p,values,messages);


%
% Find the depth and bottom and surface using ADCP data
%
% This needs to be done twice. First run without sound speed
% correction. Then apply the depth dependent sound speed
% correction. And then recalculate the depths.
%
[data,p,values,messages] = calc_depth(data,p,values,messages);
[data,p,values,messages] = calc_soundsp(data,p,values,messages);
[data,p,values,messages] = calc_depth(data,p,values,messages);
drawnow
set(fig8h,'Visible','off');

%
% cut off the parts before and after the main profile
% i.e. the surface soak and similar parts
%
[data,p,values,messages] = misc_cut_profile(data,p,values,messages);
drawnow

%
% for the real profile time period extract the SADCP data
% and average it
%
[data,messages] = calc_sadcp_av(data,p,values,messages);
drawnow


%
% Plot a summary plot of the raw data
%
plot_rawinfo( data, p, values );
drawnow

%
% apply some editing of the single bins
%
data = edit_data(data,p,values);
drawnow

%
% form super ensembles
%
[p,data,messages] = prepinv(messages,data,p,[],values,0);
[di,p,data] = calc_ens_av(data,p,values,0);
drawnow
if length(di.time_jul)<2
    disp('>   Processing is stopped.')
    return
end


%
% remove super ensemble outliers
%
if ps.outlier>0 | p.offsetup2down>0
    [messages,p,dr,de,der] = lanarrow(messages,values,di,p,ps);
    %  [messages,p,dr1,de1,der1] = lanarrow(messages,values,di1,p,ps);
end


%
% once we have a first guess profile we recompute the super ensemble
%
if (p.offsetup2down>0 & length(data.izu)>0)
    fig16h=sfigure(2);
    [p,data,messages] = prepinv(messages,data,p,dr,values,1);
    %  [p,data1,messages] = prepinv_with_old_rotation_options(messages,data1,p,dr1,values);
    [di,p,data] = calc_ens_av(data,p,values,1);
end


%
%  take advantage of presolve if it existed  ?? GK
%  call the main inversion routine
%
[messages,p,dr,ps,de] = getinv(messages,values,di,p,ps,dr,1,1);
drawnow

%
% check inversion constraints
%
p = checkinv(dr,de,der,p,ps,values);
if isfield(de,'bvel')
    p = checkbtrk(data,di,de,dr,p);
end


%
% Compute 'old fashioned' shear based solution
%  two choices, fisrt us all data
%  second use super ensemble data
%
if ps.shear>0
    if ps.shear==1
        [ds,dr,ps,p,messages] = calc_shear2(data,p,ps,dr,messages);
    else
        [ds,dr,ps,p,messages] = calc_shear2(di,p,ps,dr,messages);
    end
end


%
% Plot final results
%
plot_result(dr,data,p,ps,values)
drawnow

%
% Convert p.warn to one line of text with newline characters
%
p.warnings = [];
for n = 1:size(messages.warnp,1)
    p.warnings = [p.warnings deblank(messages.warnp(n,:)) char(10)];
end

sfigure(2);
clf
% experimental diagnostic of battery voltage
%plot
[p,messages] = calc_battery(p,values,messages);

%
% complete task by repeating the most important warnings
%
if size(messages.warn,1) + size(messages.warnp,1) > 2
    disp(' ')
    disp(messages.warn)
    disp(' ')
    disp(messages.warnp)
    for j=1:size(messages.warn,1)
        text(0,1.1-j/10,messages.warn(j,:),'color','r','fontsize',14,'fontweight','bold')
    end
    for j=1:size(messages.warnp,1)
        text(0,1.1-(size(messages.warn,1)+1+j)/10,messages.warnp(j,:),'color','r','fontsize',14,'fontweight','bold')
    end
    axis off
else
    text(0,1.1-1/10,'LADCP profile OK','color','g','fontsize',30,'fontweight','bold')
    axis off
end

streamer([p.name,' Figure 11']);
img_save(['tmp',filesep,'11'],p.print_formats);


%----------------------------------------------------------------------
% STEP 18: SAVE OUTPUT
%----------------------------------------------------------------------

disp(' ')
disp('SAVING RESULTS')
if length(files.res)>1
    
    %
    % save results to ASCII, MATLAB and NETCDF files
    %
    saveres(data,dr,p,ps,files,values)
    %  da = savearch(values,dr,data,p,ps,f);
    
    %
    % save plots
    %
    % handle newer matlab versions
    if version('-release')>=14
        imac = 0;
    else
        imac = ismac;
    end
    
%    if noplots==0
     %if isempty(findstr(p.print_formats,'none')) %Pedo Pena
     if 0 %Pedo Pena
        %replaced '\' with filesep & modifed mkdir   pedro pena 8.10.2016
        if ~exist(['plots',filesep,int2str0(p.ladcp_station,3)])
            mkdir('plots',int2str0(p.ladcp_station,3));
        end

        if is_octave < 1
            figExt ='fig';
        else
            figExt ='ofig';
        end
        
        for n = 1:length(p.saveplot)
            j = p.saveplot(n);
            if exist(['tmp',filesep,int2str(j),'.',figExt],'file')
                figload(['tmp',filesep,int2str(j),'.',figExt],2);
                %openfig(['tmp',filesep,int2str(j),'.fig']); %Pedro Pena 8.18.16
                
                %% lines added by RHS 03DEC2013
                if j>2
                    orient landscape;
                end
                %% end lines added...
            end
            warning off
            if imac
                if findstr(p.print_formats,'ps')
                    eval(['print -depsc ',files.plots,'_' int2str(j) '.eps '])
                    
                end
            else
                if findstr(p.print_formats,'ps')
                    eval(['print -dpsc2 ',files.plots,'_' int2str(j) '.ps'])
                    %% lines added by RHS 25NOV2013
                    if j==1
                        eval(['print -dpsc2 ',files.plots,'_report.ps'])
                    else
                        eval(['print -dpsc2 -append ',files.plots,'_report.ps'])
                    end
                    %% end lines added...
                end
            end
            if findstr(p.print_formats,'jpg')
                if is_octave < 1
                    eval(['print -djpeg ',files.plots,'_' int2str(j) '.jpg '])
                else
                    eval(['print -djpg ',files.plots,'_' int2str(j) '.jpg '])
                end
                
            end
            warning on
            %close gcf;
        end
    end
    
    %% lines added by RHS 25NOV2013
    if findstr(p.print_formats,'ps')
        %pdf_string = ['! ps2pdf ',files.plots,'_report.ps ',files.plots,'_report.pdf'];
        %eval(pdf_string);
        %pdf_string = ['ps2pdf ',files.plots,'_report.ps ',files.plots,'_report.pdf']; % Pedro Pena 8.18.16
        %system(pdf_string);
        
    end
    
    % save a protocol
    saveprot
    
    % save full information into mat file
    if p.savemat==1
        disp(['    Saving full information to ',files.res,'_full.mat'])
        save6([files.res,'_full.mat'])
    end
    
end

% switch to final result figure
if is_octave && strcmp(graphics_toolkit,'gnuplot')
close all;
graphics_toolkit('qt');
plot_menu(imgFileExt);
plot_controls('1',imgFileExt);
end

if ~is_octave && ~strcmpi(imgFileExt,'ps') && ~strcmpi(imgFileExt,'pdf')
plot_controls(1,imgFileExt);
end

%----------------------------------------------------------------------
% FINAL STEP: CLEAN UP
%----------------------------------------------------------------------



%fclose('all');				%  close all files just to make sure

%join_images;
disp(' ')				% final message
disp(['    Processing took ',int2str(toc),' seconds'])

save(['tmp',filesep,'last_processed.mat']);
