# parsimony-consensus-mapping
Construct a genetic consensus map from several diferent population genetic maps using a parsomny clustering algorithm which identiies which linkage groups from each population should be merged.

## Parsimony Consensus Map Construction

### Scripts & Programs

1. parsimony_wrapper.py  (contributed by: Scott Smith)
1. parse_maps.py (contributed by: Scott Smith)
1. awesomeMap2.pl  (contributed by: Shannon Schlueter)
1. phyFix_new2.pl  (contributed by: Shannon Schlueter with edits by Scott Smith)
1. rapidnj (contributed by: Aarhus University)
1. get_tips.py (contributed by: Scott Smith)
1. MergeMapOutCollect.py (contributed by: Shawn Chaffin)
1. MergeMap directory
	1. MergeMap (application)  (contributed by: Yonghui Wu, University of California Riverside)
	1. tomapchart.awk  (contributed by: Steven Blanchard)
	1. tostandard.awk  (contributed by: Steven Blanchard)	
1. Determine Success (contributed by: Scott Smith)
	
### Population files

1. All population files should be held in the same directory. Location of the 
	directory is not important.	
1. The names of the population maps should be the population name only and 
	should include only a-z, A-Z, 0-9. All special characters including 
	_ should be avoided. Example population name: AM.txt (rather than 
	AM_linkage_map.txt)	
1. No .txt files other than the population.txt files should be include in the 
	population directory.	
1. Population.txt file format should be tab delimitated with 3 columns: 
	1. linkage group identifier
	1. marker name
	1. map distance (cumulative map distance rather than relative distance). 
	Any header or footer should be removed.
	
	
### Script Descriptions

1. the parsimony wrapper allows the user to run a single script which will iterate 
through all the other scripts. Running this script will use the input population
map files to create a consensus map
	This script requires 2 additional Arguments. The first is the 
	directory containing the population map files and the second is the number of 
	iterations you would like to cycle through.
	
		python parsimony_wrapper.py <path/to/population/map/directory> <# of iterations>
		example: pyhton parsimony_wrapper.py /Desktop/Sample_population_maps 8

		#NOTE: This script assumes items 1-9 in the above list of scripts are in 
		the same directory and you are executing the scripts from that directory. items 
		a-c are in the MergeMap directory.

		[output]
			tree-build (directory)
				neighbor joining trees for each iteration (newick.txt files)
			working-directory
				Maps (directory)
					linkage group .txt files that represent the final merge 
					results after all iterations are complete. It will also 
					have individual population maps that were never 
					included in any merge.
				Tips.txt
					text file listing merge id and the groups that were 
					merged to create that group
				Used_Maps (directory)
					linkage group .txt files that were used in a merge

1. parse_maps takes the original population files and splits them into individual 
linkage group files.

    python parse_maps.py <path/to/unparsed/population/maps>
	
    [output]
        Maps (directory within the original unparsed population directory)
	contains all the population linkage groups as individual 
	text files

1. awesomeMap does pair wise alignments of all linkage groups and scores each
alignment. The pairwise scores are then used to produce a distance matrix 
which can be used to produce a neighbor joining tree showing which lgs are 
most closely related.
	
	[usage] perl awesomeMap.pl <path/to/parsed/populations/*.txt > <output/file.phy>
	example: awesomeMap.pl /.../Sample_population_maps/Maps/*.txt > temp.phy
	
	[output]
		temp.phy

1. phyFix is used to reformat the distance matrix built by awesomeMap.

	[usage] perl phyFix_new2.pl <path/to/file.phy > <output/fixed_file.phy>
	example: phyFix_new2.pl /.../Desktop/temp.phy > /.../Desktop/fixed_temp.phy
	
	[output]
		fixed_temp.phy
	
1. rapidnj uses the distance matrix produced by awesomeMap to produce a neighbor 
joining tree in newick format.
	
	./rapidnj -i pd fixed_file.phy > rnjtree.txt
	
	[output]
		rnjtree.txt
	
1. get_tips is used to extract the most extreme pairs of linkage groups from the tips 
	of the newick tree. and sets up directories containing the linkage groups 
	corresponding to the tips identified. This directory set up is required by 
	MergeMapOutCollect.py
	
	python get_tips.py <path/to/newicktree.txt> <path/to//un-parsed/pop/map/files>
	example: python get_tips.py rnjtree.txt /Users/ss324/Desktop/Sample_pop_maps
	
	[output]
		merge_tips (directory)
			individual merge (directories)
				orignal format linkage group text files (.txt)
				mergemap (directory)
					reformated linkage group text files (.txt)
					config text file (.txt)
		Tips.txt
		OUTPUT (empty directory)
1. MergeMapOutCollect is a wrapper for running the mergemap application.
	
	python MergeMapOutCollect.py </input/dir/> </output/dir/> </MergeMap/dir/>
	example: MergeMapOutCollect.py /.../mergetips/ /.../OUTPUT/ /.../MergeMap/
	
	[output]
		OUTin (directory)
			*merged linkage maps (.txt)
		OUTPUT (existing directory)
			*merged linkage maps (.txt)
		working_directory/merge_id/mergemap (existing directory)
			several MergeMap output files (.dot and .txt)
		
		* note: the format of these files are the same only the name is 
		different. The naming scheme was important for a different application 
		unrelated to this mapping process. Either of these outputs could be 
		used. DertermineSuccess.py deletes the contents of OUTPUT and renames 
		and uses the contents of OUTIn 
		
1. The MergeMap application is called by the MergeMapOutCollect script.

1. Determine_Success checks each merge to make sure the two linkage groups were merged 
	together successfully resulting in a single linkage group and prepares for the 
	next iteration.
	
	python Determine_Success.py <path/to/working_directory>
	example: Determine_success.py /.../Desktop/Sample_pop_maps/working_directory
	
	[output]
		deletes OUTPUT (has no use for this mapping application)
		if merge is successful:
			moves merge result from OUTIn to Maps (to be used in next 
			iteration)
			moves the individual maps that went into the merge into 
			the Used_Maps 
			directory. (keeps a backup of used lgs)
		if merge failed:
			move individual maps that went into the failed merge back into 
			the Maps directory (to be used in next iteration)
		deletes the merge_tips folder (preparation for next iteration)
		
