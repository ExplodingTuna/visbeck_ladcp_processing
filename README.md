# visbeck_ladcp_processing
A modified version of the visbeck ladcp processing script that can also run under Octave 4.02. 
This version has been modified to be compiled as a standalone program with Matlab.<br>

When compiled as a stand alone program, one only needs to modify "cruise_params.cfg".
This text file contains all the variables needed to configure the program for
processing a cast.<br>

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


The "cruise_params.cfg" file is preconfigured to process cast 004 of the "TEST_CAST" cruise.<br>

To quickly test the script, open Matlab or Octave and enter the directory that contains "process_cast.m".<br>
run apath by typing "apath" <--this will add the paths that contain the files needed for processing<br>
and it will load the nan package if run under Octave.<br>


type "process_cast 004"


<h3>CONFIGURATION</h3>


Configure to use for a cruise.
Edit the configuration file "cruise_params.cfg" located in the "cfg" folder.
The following are the typical values to modify to quickly use the program

for the TEST CAST set "cruise_params.cfg" as follows

cruise_id=TEST_CAST<br>
cruise_id_prefix=<br>
cruise_id_suffix=<br>
correct_year=2015<br>
use_mat_for_nav=0<br>
use_sadcp=0<br>
print_formats=jpg<br>
remove_zctd_downcast=0<br>
use_master_only=0<br>

for the Abaco cast set "cruise_params.cfg" as follows

cruise_id=AB1403<br>
cruise_id_prefix=<br>
cruise_id_suffix=<br>
correct_year=2014<br>
use_mat_for_nav=1<br>
use_sadcp=1<br>
print_formats=jpg<br>
remove_zctd_downcast=1<br>
use_master_only=0<br>


<h3>PROCESS CAST</h3>


To process the cast
-firs trun the "apath" script to set the paths and load the nan package<br>
apath<br>

Make sure the following files are in the correct folders.<br>
Keep in mind that case matters and that sometimes a space in your filename can <br>
go undetected and drive you crazy when the filenames seem to be named correctly.<br>

For cast 4 of cruise_id=TEST_CAST, the files will be named in the following way.<br>


-Raw CTD profile

    $DATADIR/raw_ctdprof/TEST_CAST_profile_004.cnv

-Raw CTD time

    $DATADIR/raw_ctdtime/TEST_CAST_time_004.cnv


-Raw LADCP

    $DATADIR/raw_ladcp/cut/TEST_CAST_004_01m.000    --master adcp file<br>
    $DATADIR/raw_ladcp/cut/TEST_CAST_004_01s.000    --slave  adcp file<br>

-Raw nav

    $DATADIR/raw_nav/TEST_CAST_nav.vis  (or TEST_CAST_nav.mat if use_mat_for_nav=1)


-Raw SADCP

    $DATADIR/raw_sadcp/TEST_CAST_codas3_sadcp.mat  (if use_sadcp=1)



-to process  TEST CAST

process_cast(004)

-to process AB1403

process_cast(019)



Make sure the nav file has three columns in it.<br>
column 1 is time in decimal year day<br>   
column 2 is lat in decimal degrees<br>
coulmn 3 is lon in decimal degrees<br>

example

37.5001464   25.713988   -80.179005



<h3>DELETE CAST FILES</h3>


To remove previously processed cast files, just run process cast  with a minus sign "-"<br>
in front of the cast number.

For example, to remove processed files for cast 004 of cruise_id=TEST_CAST, simply type.<br>

process_cast(-004)




