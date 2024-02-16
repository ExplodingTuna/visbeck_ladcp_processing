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

# Setup Instructions for Debian Bookworm

This guide provides step-by-step instructions to set up the visbeck_ladcp_processing environment on Debian Bookworm.

## Installation Steps 
### 1. Install libncurses5

Update your package list and install `libncurses5` which is required for the processing environment.

```bash
sudo apt-get update
sudo apt-get install libncurses5
```

## 2. Clone the Repository

```bash
git clone https://github.com/pedrolpena/visbeck_ladcp_processing.git
```

### 3. Download MATLAB Runtime R2014b

MATLAB Runtime R2014b is essential to run compiled MATLAB applications.

- Download from MathWorks: [MCR R2014b Installer](https://ssd.mathworks.com/supportfiles/downloads/R2014b/deployment_files/R2014b/installers/glnxa64/MCR_R2014b_glnxa64_installer.zip)
- Follow the provided instructions on the MathWorks website to install the MATLAB Runtime R2014b.

### 4. Update System Path

Append your `bin` directory to the PATH variable in `.bashrc` to easily run scripts:

```bash
mkdir -p $HOME/bin
source ~/.bashrc
sudo nano .bashrc
```
Type the following at the bottom:
```bash 
PATH=$HOME/bin:$PATH
```
Then, copy the files from the repository's bin into the bin you just created.

### 5. Modify File Permissions
Adjust file permissions to make certain scripts executable.
```bash
mv visbeck_ladcp_processing/visbeck_process_ladcp_cast ~/
chmod +x ~/bin/process_cast
chmod +x ~/visbeck_process_ladcp_cast/process_ladcp_cast
chmod +x ~/visbeck_process_ladcp_cast/run_process_ladcp_cast.sh
```

### 6. Running the Application
With the setup complete, you can process a data cast by running:
```bash
process_cast 004
```


# Octave Setup Instructions
Octave doesn't yet have a mature JIT compiler so this script will run about 3 to 4
times faster in Matlab. If running under octave make sure you install the nan package.
you can do this from octave by running:

## Install Dependencies

```bash
pkg -forge install nan
```

Debian systems like Ubuntu, might need "liboctave-dev" to be installed. To install liboctave-dev open a terminal and type:
```bash
sudo apt-get install liboctave-dev
```

## QUICK START
Jumpstart your processing with the pre-configured `cruise_params.cfg` for cast 004 of the "AB1705" cruise.

1. Open Octave or MATLAB: Navigate to the directory containing process_cast.m.
2. Initialize Path Settings: Execute apath to include necessary file paths and load the nan package for Octave users:

```bash
apath
```

## CONFIGURATION

Tailor the processing script to fit your cruise by editing cruise_params.cfg located within the cfg folder.
The following are the typical values to modify to quickly use the program. For the AB1705 set "cruise_params.cfg" as follows:

```bash
cruise_id=AB1705
cruise_id_prefix=
cruise_id_suffix=
correct_year=2017
use_mat_for_nav=0
make_nav=1
use_sadcp=0
print_formats=psc
remove_zctd_downcast=1
use_master_only=0
```

## PROCESS CAST

To process the cast
-First run the `apath` script to set the paths and load the nan package.
```bash
apath
```

Make sure the following files are in the correct folders. Keep in mind that case matters and that sometimes a space in your filename can go undetected and drive you crazy when the filenames seem to be named correctly.
For cast 4 of cruise_id=AB1705, the files will be named in the following way:


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
Column 1 is time in decimal year day<br>   
Column 2 is lat in decimal degrees<br>
Coulmn 3 is lon in decimal degrees<br>

Example:

37.5001464   25.713988   -80.179005



## DELETE CAST FILES

To remove previously processed cast files, just run process cast  with a minus sign "-" in front of the cast number.
For example, to remove processed files for cast 004 of cruise_id=AB1705, simply type:

```bash
process_cast(-004)
```



