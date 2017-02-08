# visbeck_ladcp_processing
Modified  version of the visbeck ladcp processing script, modified to be compiled as a standalone

Configure to use for a cruise.
Edit the configuration file "cruise_params.cfg" located in the "cfg" folder.
The following are the typical values to modify to quickly use the program
====================================================
----------------CONFIGURATION-----------------------
====================================================
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

====================================================
-----------------PROCESS CAST-----------------------
====================================================

To process the cast
-run the "apath" script first to set the paths
apath

Make sure the follwoing files are in the correct folders.
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


====================================================
----------------DELETE CAST FILES-------------------
====================================================

To remove previously processed cast files, just run process cast  with a minus sign "-"
in front of the cast number.

For example, to remove processed files for cast 004 of cruise_id=TEST_CAST, simply type.

process_cast(-004)




