# visbeck_ladcp_processing
A modified version of the visbeck ladcp processing script that can also run under Octave 4.02. 
This version has been modified to be compiled as a standalone program with Matlab.<br>

When compiled as a stand alone program, one only needs to modify "cruise_params.cfg".
This text file contains all the variables needed to configure the program for
processing a cast.<br>


Disclaimer
==========
This repository is a scientific product and is not official communication of the National Oceanic and
Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is
provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the Department of
Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed
by all applicable Federal law. Any reference to specific commercial products, processes, or services by service
mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or
favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a
DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by
DOC or the United States Government.

<h3>OCTAVE</h3>


Octave doesn't yet have a mature JIT compiler so this script will run about 3 to 4
times faster in Matlab.<br>
if running under octave make sure you install the nan package.
you can do this from octave by running<br>

"pkg -forge install nan"<br>

Debian systems like Ubuntu, might complain about "liboctave-dev"<br>

"pkg: please install the Debian package "liboctave-dev" to get the mkoctfile command"<br>

to install liboctave-dev open a terminal and type<br>
sudo apt-get install liboctave-dev<br>


<h3>QUICK START</h3>


The "cruise_params.cfg" file is preconfigured to process cast 004 of the "AB1705" cruise. <br>

To quickly test the script, open Matlab or Octave and enter the directory that contains "process_cast.m". <br>
run apath by typing "apath" <--this will add the paths that contain the files needed for processing <br>
and it will load the nan package if run under Octave. <br>


type "process_cast 004"


<h3>CONFIGURATION</h3>


Configure to use for a cruise. <br>
Edit the configuration file "cruise_params.cfg" located in the "cfg" folder. <br>
The following are the typical values to modify to quickly use the program <br>

for the AB1705 set "cruise_params.cfg" as follows <br>

cruise_id=AB1705<br>
cruise_id_prefix=<br>
cruise_id_suffix=<br>
correct_year=2017<br>
use_mat_for_nav=0<br>
make_nav=1<br>
use_sadcp=0<br>
print_formats=psc<br>
remove_zctd_downcast=1<br>
use_master_only=0<br>


<h3>PROCESS CAST</h3>


To process the cast
-first run the "apath" script to set the paths and load the nan package<br>
apath<br>

Make sure the following files are in the correct folders.<br>
Keep in mind that case matters and that sometimes a space in your filename can <br>
go undetected and drive you crazy when the filenames seem to be named correctly.<br>

For cast 4 of cruise_id=AB1705, the files will be named in the following way.<br>


-Raw CTD profile

    ./data/raw_ctdprof/AB1705_profile_004.cnv

-Raw CTD time

    ./data/raw_ctdtime/AB1705_time_004.cnv


-Raw LADCP

    ./data/raw_ladcp/cut/AB1705_004_01m.000    <------master adcp file
    ./data/raw_ladcp/cut/AB1705_004_01s.000    <------slave  adcp file

-Raw nav

    ./data/raw_nav/AB1705_nav_004.vis  (or AB1705_nav_004.mat if use_mat_for_nav=1)


-Raw SADCP

    ./data/raw_sadcp/AB1705_codas3_sadcp.mat  (if use_sadcp=1)



-to process  AB1705

process_cast(004)

Make sure the nav file has three columns in it.<br>
column 1 is time in decimal year day<br>   
column 2 is lat in decimal degrees<br>
coulmn 3 is lon in decimal degrees<br>

example

37.5001464   25.713988   -80.179005



<h3>DELETE CAST FILES</h3>


To remove previously processed cast files, just run process cast  with a minus sign "-"<br>
in front of the cast number.

For example, to remove processed files for cast 004 of cruise_id=AB1705, simply type.<br>

process_cast(-004)




