# visbeck_ladcp_processing
A modified version of the visbeck ladcp processing script that can also run under Octave 4.02. 
This version has been modified to be compiled as a standalone program with Matlab.

When compiled as a stand alone program, one only needs to modify "cruise_params.cfg".
This text file contains all the variables needed to configure the program for
processing a cast.


================================
----------OCTAVE----------------
================================

Octave doesn't yet have a mature JIT compiler so this script will run about 3 to 4
times faster in Matlab.

if running under octave make sure you install the nan package.
you can do this from octave by running 

"pkg -forge install nan"

Debian systems like Ubuntu, might complain about "liboctave-dev"

"pkg: please install the Debian package "liboctave-dev" to get the mkoctfile command"

to install liboctave-dev open a terminal and type
sudo apt-get install liboctave-dev

================================
----------QUICK START-----------
================================

The "cruise_params.cfg" file is preconfigured to process cast 004 of the "TEST_CAST" cruise.

To quickly test the script, open Matlab or Octave and enter the directory that contains "process_cast.m".
run apath by typing "apath" <--this will add the paths that contain the files needed for processing
and it will load the nan package if run under Octave.


type "process_cast 004"




================================
---------CONFIGURATION----------
================================

Configure to use for a cruise.
Edit the configuration file "cruise_params.cfg" located in the "cfg" folder.
The following are the typical values to modify to quickly use the program

for the TEST CAST set "cruise_params.cfg" as follows

cruise_id=TEST_CAST
cruise_id_prefix=
cruise_id_suffix=
correct_year=2015
use_mat_for_nav=0
use_sadcp=0
print_formats=jpg
remove_zctd_downcast=0
use_master_only=0

for the Abaco cast set "cruise_params.cfg" as follows

cruise_id=AB1403
cruise_id_prefix=
cruise_id_suffix=
correct_year=2014
use_mat_for_nav=1
use_sadcp=1
print_formats=jpg
remove_zctd_downcast=1
use_master_only=0

================================
----------PROCESS CAST----------
================================

To process the cast
-run the "apath" script first to set the paths and load the nan package
apath

Make sure the following files are in the correct folders.
Keep in mind that case matters and that sometimes a space in your filename can 
go undetected and drive you crazy when the filenames seem to be named correctly.

For cast 4 of cruise_id=TEST_CAST, the files will be named in the following way.


-Raw CTD profile

    $DATADIR/raw_ctdprof/TEST_CAST_profile_004.cnv

-Raw CTD time

    $DATADIR/raw_ctdtime/TEST_CAST_time_004.cnv


-Raw LADCP

    $DATADIR/raw_ladcp/cut/TEST_CAST_004_01m.000    --master adcp file
    $DATADIR/raw_ladcp/cut/TEST_CAST_004_01s.000    --slave  adcp file

-Raw nav

    $DATADIR/raw_nav/TEST_CAST_nav.vis  (or TEST_CAST_nav.mat if use_mat_for_nav=1)


-Raw SADCP

    $DATADIR/raw_sadcp/TEST_CAST_codas3_sadcp.mat  (if use_sadcp=1)



-to process  TEST CAST

process_cast(004)

-to process AB1403

process_cast(019)



Make sure the nav file has three columns in it.
column 1 is time in decimal year day   
column 2 is lat in decimal degrees
coulmn 3 is lon in decimal degrees

example

37.5001464   25.713988   -80.179005


================================
-------DELETE CAST FILES--------
================================

To remove previously processed cast files, just run process cast  with a minus sign "-"
in front of the cast number.

For example, to remove processed files for cast 004 of cruise_id=TEST_CAST, simply type.

process_cast(-004)




