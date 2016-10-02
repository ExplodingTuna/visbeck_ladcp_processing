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

for the Abaco cast set "cruise_params.cfg" as follows

cruise_id=AB1403
cruise_id_prefix=
cruise_id_suffix=
correct_year=2014
use_mat_for_nav=1
use_sadcp=1
print_formats=jpg
remove_zctd_downcast=1

====================================================
-----------------PROCESS CAST-----------------------
====================================================

To process the cast
-run the "apath" script first to set the paths
apath

-to process  TEST CAST

process_cast(004)

-to process AB1403

process_cast(019)
