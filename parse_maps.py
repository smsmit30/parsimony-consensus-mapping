#!/usr/bin/python

# import modules
import sys
import os
import glob

maps_dir = os.path.abspath(sys.argv[1])

######### parse population files into individual lg files ###########
dup_maps_dir = maps_dir+'/working_directory/Maps'
if not os.path.exists(dup_maps_dir):
	os.makedirs(dup_maps_dir)

	os.chdir(maps_dir)
	list = glob.glob("*.txt")
	print "duplicated original population maps to:\n",dup_maps_dir
	for map in list:
		mapfile = open(map)
		lgflag = ''
		populationID = map.replace('.txt','')
		newgroup = []
		for line in mapfile:
			lg,marker,dist = line.split("\t")
			if lgflag == '':
				lgflag = lg
				newgroup.append(line)
			elif lg == lgflag:
				newgroup.append(line)
			else:
				lgfile = open(dup_maps_dir+"/"+populationID+'_'+lgflag+".txt","w")
				lgflag = lg
				for line2 in newgroup:
					lgfile.write(line2)
				newgroup = []
				newgroup.append(line)
		lgfile = open(dup_maps_dir+"/"+populationID+'_'+lgflag+".txt","w")
		lgflag = lg
		for line3 in newgroup:
			lgfile.write(line3)
else:
	print "population maps already duplicated"