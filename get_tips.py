#!/usr/bin/python

# import modules
import sys
# sys allows us to call system functions
import re
# re allows us to use regular expression
import os
from random import randint
import shutil
import glob

# only allow the correct number of arguments to be given (3)
# argument [0] = get_tips.py
# argument [1] = map file in newick format
# argument [2] = directory containing the population genetic maps
# if more or less than 3 args is given print a 'usage' message and quit
if len(sys.argv) != 3:
	print ('usage: python get_tips.py [path/to/newick/tree.txt] [linkag/maps/dir]')
	quit()

# create variables to hold the arguments (probably unnecessary  but makes for easier readability)	
startdir = os.getcwd()
newick = os.path.abspath(sys.argv[1])
maps_dir = os.path.abspath(sys.argv[2])
working_dir = maps_dir+'/working_directory'
tips_dir = working_dir+'/merge_tips'
output_dir = working_dir+'/OUTPUT'
dup_maps_dir = working_dir+'/Maps'
#create a working directory to hold the output files and directories
try:
	if not os.path.exists(working_dir):
		os.makedirs(working_dir)
	if not os.path.exists(tips_dir):
		os.makedirs(tips_dir)
	if not os.path.exists(output_dir):
		os.makedirs(output_dir)
except:
	next
	
########### find tips ###########

# create random number to act as the iteration ID
iteration_ID = randint(10000,99999)

# create a counter to use as part of the merge ID for each set of tips within the current iteration
counter = 1

# dump contents of tree file into variable 'tree'
tree = open(newick).read()
# open(newick) opens the file
#.read() reads it into the variable

# use regular expression to find tips and store matches in the variable 'Tips'
Tips = re.finditer(r"\(\'(\w+)\':(\d+\.?\d*),\'(\w+)\':(\d+\.?\d*)\)", tree)
#re.finditer creates an object that holds all the match info that can be iterated through
# what we want to match... ('word or number':number.number,'word or number':number.number)
# ( ) ' . all need to be proceeded by a backslash (\) in order to match its actual character
	# \( matches (
	# \) matches )
	# \. matches .
	# \' matches '
# parentheses without a \ in front are used to group portions of the regex allowing them to be extracted from the overall match
# linkage group name match:
	# \w+ matches 1 or more word characters [A-Z, _, 0-9]
# distance match
	# \d+ matches 1 or more digit character [0-9] 
	# \.? matches 0 or 1 decimal point(.) 
	# \d* matches 0 or more digits 
	# this allows a match to a number that may or may not contain a decimal

### iterate through the Tips object and print just the parts of the match we want ###

# open a file to write the tip pairs and their tip ID (must be opened and closed outside the loop or it gets overwritten and you only gen the last tip.
with open(working_dir+"/Tips.txt", "a") as tips_out:
	# write a header line for the tip file
	os.chdir(maps_dir)
	poplist = glob.glob('*.txt')
	poplist = [pop.replace('.txt', '') for pop in poplist]
	tips_out.write('##### merge_ID\ttip1\ttip2 #####\n')
	# for each tip in the Tips object...
	for match in Tips:
		#set up directories
		new_tip_dir = tips_dir+"/"+str(iteration_ID)+"_"+str(counter)
		try:
			if not os.path.exists(new_tips_dir):
				os.makedirs(new_tip_dir)
		except:
			next
			
		mergemap_dir = new_tip_dir+"/mergemap"
		try:	
			if not os.path.exists(mergemap_dir):
				os.makedirs(mergemap_dir)
		except:
			next
	
		
		# get tip info from Tips object
		tip1 = match.group(1)
		tip2 = match.group(3)
	
		# write the tip info to the output file Tips.txt (tips_out)
		out_line = str(iteration_ID)+'_'+str(counter)+'\t'+tip1+'\t'+tip2+'\n'
		tips_out.write(out_line)
		
		# print the tip pairs to the screen just as a check so you can see it working (not needed)
		print tip1,'\t', tip2
		
		## set up config file and move maps ##
		config_file = open(mergemap_dir+"/mergemap_config.txt",'w')
#		
		#create config file in mergemap folder containing the linkage group file names
		config_file.write ("M1 1 "+tip1+".mergemap.txt\n"+"M2 1 "+tip2+".mergemap.txt")
#	
#		# move files from Maps dir to merge dir
		shutil.move(dup_maps_dir+"/"+tip1+".txt",new_tip_dir)
		shutil.move(dup_maps_dir+"/"+tip2+".txt",new_tip_dir)
#		# increase the counter 
		counter += 1
		
### convert file from original format to mergemap format ###

		# convert tip 1 file
		t1_file = open(new_tip_dir+"/"+tip1+".txt").readlines()
		group1 = ''
#		try:
#			tip1_lg = t1_file[0]
#			group1,junk1,junk2 = tip1_lg.split("\t")
#		except:
#			"****** found error in ", tip1
#			next
		title = "group " + group1+"\n"
		of = open(mergemap_dir+'/'+tip1+".mergemap.txt","w")
		of.write(title)
		of.write(";BEGINOFGROUP\n")
		for line in t1_file:
			content = line.strip().split('\t')
			string = content[1]+"\t"+content[2]+"\n"
			of.write(string)
	
		of.write(";ENDOFGROUP\n")
		of.close()
		
		# convert tip 2 file
		t2_file = open(new_tip_dir+"/"+tip2+".txt").readlines()
		
		group2 = ''
#		try:
#			tip2_lg = t2_file[0]
#			group2,junk1,junk2 = tip2_lg.split("\t")
#		except:
#			print "****** found error in ",tip2
#			next
		title = "group " + group2+"\n"
		of = open(mergemap_dir+'/'+tip2+".mergemap.txt","w")
		of.write(title)
		of.write(";BEGINOFGROUP\n")
		for line in t2_file:
			content = line.strip().split('\t')
			string = content[1]+"\t"+content[2]+"\n"
			of.write(string)
	
		of.write(";ENDOFGROUP\n")
		of.close()
	
#########################################################