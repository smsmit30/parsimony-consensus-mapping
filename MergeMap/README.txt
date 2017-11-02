- Double-click on 'mapping-1.0.jar' to start application.  Drag folder[s] that you wish to convert to MergeMap format on to the window.  The program will create a 'mergemap' directory in each input folder.

- A log file of warnings and errors will appear on your Desktop.  You may have to close the mapping application to view the log.

- Edit the resulting mergemap_config.txt file[s] in the 'mergemap' folder[s] to you liking

- Open a Terminal and cd to the mergemap directory.

- Run MergeMap on files.  You may need to put the full path to MergeMap on the command line

	$ MergeMap mergemap_config.txt

- Convert the linear_map_chart to a format suitable for input into cmap (tostandard.awk) or a format suitable for MergeMap or MapChart (tomapchart.awk).

	$ awk -f tostandard.awk linear_map_chart.txt > standard.txt
	$ awk -f tomapchart.awk linear_map_chart.txt > mapchart.txt


Various MergeMap errors & their meanings:


MergeMap: single_population_linearize_dag.cpp:127: void consensus_map::linkage_group_graph_representation::impute_missing_distance(): Assertion `(common_parents.size() > 0)or (common_children.size() > 0)' failed.

-> "Lightning-bolt" syndrome


Assertion failed: (dist2 > dist1), function read_from_file, file single_population.cpp, line 613.

-> distances on a linkage group decreased


??? -> marker appears multiple times on a single linkage group





for dir in MM*; do awk -f /Users/smsmit30/Desktop/MergeMap/tostandard.awk $dir/mergemap/linear_map_chart.txt > ../foo/Oat_mergemap_${dir/\./-}.txt; done