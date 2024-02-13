###############################################################################

global dir_source1, dir_source2, dir_out1, dir_out2, log_path

# Source files Windows
# dir_source1 = 'C://Users//christian.saiz//Documents//NOAA//1_NOAA_work//PNE//myScripts//CTD_cnv_cleaner//PNE2021b_profile_'
# dir_source2 = 'C://Users//christian.saiz//Documents//NOAA//1_NOAA_work//PNE//myScripts//CTD_cnv_cleaner//PNE2021b_time_'
# Source files Linux
dir_source1 = '/home/user/data/ladcp_proc/data/raw_ctdprof/PNE2021b_profile_'
dir_source2 = '/home/user/data/ladcp_proc/data/raw_ctdtime/PNE2021b_time_'

# Destination files Windows
# dir_out1 = 'C://Users//christian.saiz//Documents//NOAA//1_NOAA_work//PNE//myScripts//CTD_cnv_cleaner//PNE2021b_profile_clean_'
# dir_out2 = 'C://Users//christian.saiz//Documents//NOAA//1_NOAA_work//PNE//myScripts//CTD_cnv_cleaner//PNE2021b_time_clean_'
# Destination files Linux
dir_out1 = '/home/user/data/ladcp_proc/data/raw_ctdprof/temp_PNE2021b_profile_'
dir_out2 = '/home/user/data/ladcp_proc/data/raw_ctdtime/temp_PNE2021b_time_'

# log cleaning process Windows
# log_path = 'C://Users//christian.saiz//Documents//NOAA//1_NOAA_work//PNE//myScripts//CTD_cnv_cleaner//cnv_cleaner.log'
# log cleaning process Linux
log_path = '/home/user/data/ladcp_proc/data/PNE2021bcnv_cleaner.log'

# Replacement values 
global first_val, rval
first_val = '0.0000' # for -9.990e-29 only in the first line
rval = '-9.990e-29' # value to be replaced throughout the file
# Extension names
global ext1, ext2
ext1 = '_backup' # before starting the process it creates a copy with the extension *.cnv_backup
ext2 = '_ORIGINAL' # original will be renamed with this extension *.cnv_ORIGINAL
###############################################################################



import os
import shutil
import datetime


def num2digit(num):
	n = ''
	if num < 1:
		n = '00'
	elif num < 10:
		n = '0' + str(num)
	else:
		n = str(num)
	
	return n


def date_time():

	now = datetime.datetime.now()
	return num2digit(now.month)+'-'+num2digit(now.day)+'-'+str(now.year)+'  '+num2digit(now.hour)+':'+num2digit(now.minute)+':'+num2digit(now.second)


def num3digit(num):
    num = int(num)
    if num == 0:
        n = '000'
    elif num < 10:
        n = '00' + str(num)
    elif num < 100:
        n = '0' + str(num)
    elif num < 1000:
        n = str(num)
    else:
        print('Station out of range [0 - 999]')

    return n


def get_station():
    print('** CTD .cnv cleaner **\n\n')
    ctd_station = 99999
    while ctd_station < 0 or ctd_station > 999:
        ctd_station = int(raw_input('Enter CTD station [000-999]:'))
        if ctd_station < 0 or ctd_station > 999:
            print('Station number out of range')        
    #print(type(ctd_station))	
    return ctd_station 

def append_to_file(line, fout):
    global pline
    f = open(fout, 'a')
    f.write(line)
    f.close()
    pline = line

def read_total_lines(path):
    n = 0
    fin = open(path, 'r')
    for line in fin:
        n = n + 1
    fin.close()
    return n
    

def get_new_line(line):
    
    # remove \n from end
    line.replace('\n','')
    pline.replace('\n','')
    # split by space
    pline_ls = pline.split(' ')
    line_ls = line.split(' ')
    # remove spaces
    pline_ls = list(filter(None,pline_ls))
    line_ls = list(filter(None,line_ls))
    
    for n in range(0,len(line_ls)):
        # print(n, "-", line_ls[n])
        if line_ls[n] == rval: # if item is -9.990e-29
            print("Replace " + line_ls[n] + " position " + str(n) + " by " + pline_ls[n])
            line_ls[n] = pline_ls[n] # replace by value from previous line
            
    new_line = '  '
    for item in line_ls:
        new_line = new_line + "   " + item

    new_line = new_line + '\n'
    # print("New line:")
    # print(new_line)

    return new_line


def copy_line(line, fout):
    
    if ( line.startswith('#') or line.startswith('*') ):
        append_to_file(line,fout)

        return 0

    else:
        if rval in line:
            if '*END*' in pline: # if *END* in previous line
                new_line = line.replace(rval,first_val) # use this for first line only
            else:
                new_line = get_new_line(line)
                append_to_file(new_line,fout)
                #print('Writing line' + new_line + '\n to' + get_filename(fout))
            return 1

        else:
            append_to_file(line,fout)
            
            return 0



def replace_line(fin, fout):
    n = 0 # num of lines replaced
    x = 0 # num of lines in file
    total_lines = read_total_lines(fin)
    f = open(fin, 'r')
    
    if f:
        # print("File opened")
	while x < total_lines:
        #for line in f:
	    line = f.readline()
            if not line:
                #Print('End of input file', get_filename(fin))
                break
            n = copy_line(line,fout) + n
            x = x + 1
        f.close()
    else:
        print("File couldn't be opened")

    return n


def get_dir(file):
    filename = file.split('/')[-1]
    mydir = file.replace(filename,'')

    return mydir

def get_filename(path):
    return path.split('/')[-1]

def find_file(path):
    mydir = get_dir(path)
    fname = path.split('/')[-1]
    list_files = os.listdir(mydir)
    print('Looking for ' + fname + ' in ' + mydir)
    

    if fname in list_files:
        return True
    else:
        return False

def backup_original(path, ext1):
    shutil.copy(path, path + ext1)
    print(get_filename(path) + " backed up as " + get_filename(path+ext1))


def save2log(text):
    flog = open(log_path, 'a')
    flog.write(text + '\n')
    flog.close()

def rename2process(original, clean): # original file and *_clean_xxx.cnv
    if  os.path.exists(original):
        os.rename(original, original + ext2) # rename as path1 as *_ORIGINAL
        print(get_filename(original) + " renamed as " + get_filename(original+ext2))
        if os.path.exists(original + ext2): 
            os.rename(clean, original) # rename _clean as path1
            print(get_filename(clean) + " renamed as " + get_filename(original))
        else:
            return False
    else:
        return False

    return True



def main():


    ctd_station = num3digit(get_station())
    
    save2log('-----------------------------------------------------------------------------------------------' )
    save2log(date_time() + ' STATION [' + ctd_station + '] - CNV cleaner initiated' )
    # Source files / This could be from the science server
    path1 = dir_source1 + ctd_station + '.cnv'
    path2 = dir_source2 + ctd_station + '.cnv'
    # Destination files / Where ADCP takes the files from
    path3 = dir_out1 + ctd_station + '.cnv'
    path4 = dir_out2 + ctd_station + '.cnv'
    # Save a copy of the original file
    backup_original(path1, ext1)
    backup_original(path2, ext1)
    print(' ')

    if os.path.exists(path1+ext2):
        print(get_filename(path1+ext2) + ' already exists ' + get_filename(path1) + ' is not the original')
    else:
        n1 = replace_line(path1, path3)
        txt = str(n1) + ' lines were replaced in ' + get_filename(path1)
        print(txt + '\n')
        save2log(txt)

        if rename2process(path1,path3): # make sure back up is there before changing names
            print(get_filename(path1) + " processed\n\n")
        else:
            print(get_filename(path1) + " couldn't be processed\n")


    if os.path.exists(path2+ext2):
        print(get_filename(path2+ext2) + ' already exists ' + get_filename(path2) + ' is not the original')
    else:
        n2 = replace_line(path2, path4)
        txt = str(n2) + ' lines were replaced in ' + get_filename(path2) 
        print(txt + '\n')
        save2log(txt)

        if rename2process(path2,path4):
            print(get_filename(path2) + " processed\n\n")
        else:
            print(get_filename(path2) + " couldn't be processed\n")


    print('\n\n** Process finished **\n')
    print("Proceed with process_cast xxx\n")
    save2log('-----------------------------------------------------------------------------------------------' )


# Bottom code
if __name__ == "__main__":
    main()
