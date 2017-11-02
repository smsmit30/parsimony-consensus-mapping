#!/usr/bin/python
#!/usr/bin/awk

from __future__ import print_function
import sys
import re
import os
import errno

#########################

# RepairMergeMapOutput function: reassigns the lg0 created for the linear map of the merged LGs to the mergename so as to build a paper trail for LG merges

def RepairMergeMapOutput(MergeOutFolder, folder):

    mergeOutfile = (MergeOutFolder + 'Oat_' + folder + 'out.txt')
    lgfile = open(mergeOutfile, 'r')

    MergeInFolder = MergeOutFolder
    MergeInFolder = MergeInFolder[0:-4]
    MergeInFolder = (MergeInFolder + 'In/')
 #   print('Merge_In Directory: ' + MergeInFolder)
    try:
        os.makedirs(MergeInFolder)
    except OSError:
        if not os.path.isdir(MergeInFolder):
            raise
    mergeInFilename = (MergeInFolder + folder + 'in.txt')
#    print(mergeInFilename)
    outfile = open(mergeInFilename, 'w')
#    print(outfile)
    while True:
        print('entered loop')
        line = lgfile.readline()
        if not line: break
        parseline = re.split('\t', line)
        parseline[0] = (folder)
        print(parseline)
        outfile.write( '\t'.join(parseline))

#    print('exit loop')
    outfile.close
    lgfile.close

#########################

# MergeMapConfigCollect function: 

def MergeMapConfigCollect():
    MergeInFolderPath = sys.argv[1]
    MergeOutFolderPath = sys.argv[2]
    MergeMapPath = sys.argv[3]
    DirList = os.walk(MergeInFolderPath).next()[1] # takes the MergeInFolderPath as builds a list of the folders in that directory
#    print(DirList)
#    print(type(DirList))
    for folder in DirList: # for each folder in the MergeInFolderPath directory
#        print(folder)

        ContigFilePath = (MergeInFolderPath + folder + '/mergemap/') # set the ContigFilePath to include the MergeInfolderPath/MergeLGfolder/mergemap/
#       print(ContigFilePath)

        os.chdir(ContigFilePath) # change directories into the path set in ContifFilePath
#        print(os.getcwd())

        Files = os.listdir(ContigFilePath) # create a list of files within the directory for display/test purposes only
#        print(Files)

        MergeMapCommand = (MergeMapPath + 'MergeMap ' + ContigFilePath + 'mergemap_config.txt') # build the MergeMap command line for execution
#        print(MergeMapCommand)

        os.system(MergeMapCommand) # execute the MergeMapCommand

        AwkCommand = ('awk -f ' + MergeMapPath + 'tostandard.awk linear_map_chart.txt > ' + MergeOutFolderPath + 'Oat_' + folder + 'out.txt') # build the Awk command line for execution
#        print(AwkCommand)

        os.system(AwkCommand) # execute the AwkCommand

        RepairMergeMapOutput(MergeOutFolderPath, folder) # call the RepaiMergeMapOutput function

#######################

MergeMapConfigCollect()
