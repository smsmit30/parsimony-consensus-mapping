#!/usr/bin/python

import os
import sys

if len(sys.argv) != 3:
	print ('usage: python parsimony_wrapper.py [path/to/population/maps/dir] [number of iterations]')
	quit()

maps_dir = os.path.abspath(sys.argv[1])
iterations = int(sys.argv[2])
current_iteration = 1
startdir = os.getcwd()
tree_build_dir =  maps_dir+"/tree_build"

try:
	if not os.path.exists(tree_build_dir):
		os.makedirs(tree_build_dir)
except:
	next

# Parse Maps
os.system('python '+startdir+'/parse_maps.py '+maps_dir)

for i in range (1, iterations+1):
	print 'generating distance matrix (iteration '+str(current_iteration)+' of '+str(iterations)+')...'
	os.system('perl '+startdir+'/awesomeMap2.pl '+maps_dir+'/working_directory/Maps/*.txt > '+tree_build_dir+'/temp.phy')
	# run phyfix_new.pl
	os.system('perl '+startdir+'/phyFix_new2.pl '+tree_build_dir+'/temp.phy > '+tree_build_dir+'/fixed_temp.phy')
	# run rapidnj
	os.system('./rapidnj -i pd '+tree_build_dir+'/fixed_temp.phy > '+tree_build_dir+'/rnjtree_temp'+str(current_iteration)+'.txt')
	#run get tips
	os.system('python '+startdir+'/get_tips.py '+tree_build_dir+'/rnjtree_temp'+str(current_iteration)+'.txt '+maps_dir)
	#run MergeMapOutCollect.py
	os.system('python '+startdir+'/MergeMapOutCollect.py '+maps_dir+'/working_directory/merge_tips/ '+maps_dir+'/working_directory/OUTPUT/ '+startdir+'/MergeMap/')
	#run DetermineSuccess.py
	os.system('python '+startdir+'/DetermineSuccess.py '+maps_dir+'/working_directory')
	#python DetermineSuccess.py <working Dir>
	current_iteration += 1