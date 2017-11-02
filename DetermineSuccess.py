#!/usr/bin/python

import sys
import glob
import os
import re
import shutil
def Mkdir(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)
    else:
        print "%s already exist!" %directory
def DetermMergeSucess(dir):
    filelist = glob.glob(dir+"/*.dot")
    if len(filelist)==3:
        FLAG = True
    else:
        FLAG = False
    return FLAG


def MoveMergeGroup(merge):
    filelist = glob.glob("*.mergemap.txt")
    for f in filelist:
		NaGroup = re.match(r"(\w+)\.mergemap\.txt",f)
		Name = NaGroup.group(1)
		shutil.move(merge_tips_dir+"/"+merge+"/"+Name+".txt",workingdir+"/Maps")
#		print Name
#		Group = NaGroup.group(2)
#		print Group
#		os.chdir(workingdir+'/Maps')
#		filename = Name+".txt"
#		fin = open(filename)
#		fout = open(filename+'_out.txt','w')
#		for line in fin:
#			linlist = line.split('\t')
#			if linlist[0]!=Group:
#				fout.write(line)
#			else:
#				continue
#		fin.close()
#		fout.close()
#		os.remove(filename)
#		os.rename(filename+'_out.txt',filename)

def MoveMerge(merge):
	os.rename(merge+'in.txt',merge+'.txt')
	shutil.move(merge+'.txt', workingdir+'/Maps')
def cleanup():
	shutil.rmtree(workingdir+'/merge_tips')
	shutil.rmtree(workingdir+'/OUTIn')
	shutil.rmtree(workingdir+'/OUTPUT')
		
                
def main():
	os.chdir(merge_tips_dir)
	merge_list = glob.glob("*")
	for merge in merge_list:
		dir = merge_tips_dir+'/'+merge+'/mergemap'
		Flg = DetermMergeSucess(dir)
		os.chdir(dir)
		print merge,"\t",Flg
		if Flg:
			os.chdir(workingdir+"/OUTIn")
			MoveMerge(merge)
		else:
			MoveMergeGroup(merge)
	cleanup()

workingdir = os.path.abspath(sys.argv[1])
merge_tips_dir = workingdir+"/merge_tips"
if __name__=="__main__":
    main()
