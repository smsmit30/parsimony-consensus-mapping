#!/usr/bin/perl

$DEBUG_LEVEL = 0; # a modifier to trigger debug messages printed to the standard error output

$LOCAL_BIN_THRESHOLD = 30; # set Local Bin Threshold distance range
$GAPOPEN = -10; # set gap open penalty
$GAPEXT = -2; # set gap extension penalty
$MISMATCH = -5; # set mismatch penaly
$MATCH = 50; # set match score

$NORM_MARKER_GROUPS = 1; # non-zero: attempts to normalize scoring function by 
			  # reducing the score contribution of markers in marker groups based on the number of markers in each position group

$ZERO_SAME_POP_LG_ALIGNMENT = 1; # Zeroes the alignment score for LGs from the same population map by setting their distance value to 1

$matchpts = $MATCH / $LOCAL_BIN_THRESHOLD; # fraction of points for matches made with nearby markers. Initialize the matchpts to 50/30 = 1.6667

%maps = (); # initialize maps as empty hash table

while ( $fn = shift(@ARGV) ) { # while there are argument files, files fed to program from commandline, to shift through
    print stderr "Argument: ", $fn, "\n" if($DEBUG_LEVEL > 0);
    open( INF, "$fn" ); # open the current argument file in the array
    $maps{$fn} = {}; # create an unnamed hash reference, keyed by the argument filename in the maps hash table
    $currLG = ""; # initialize currLG, current linkage group, variable to empty string
    while (<INF>) { # while there are lines in the opened file from the argument array
        @mapInfo = split( /\s+/, $_ ); # current line of argument file is split, by whitespace, into an array mapInfo
        print stderr "Initial Map Info line: @mapInfo\n" if($DEBUG_LEVEL > 0);
	next if($mapInfo[0] !~ /\w/); # skip line if the first element of array is not made of A-Za-z0-9 or _
        if ( $mapInfo[0] eq $currLG ) {# if the first element of the current line is the same linkage group as what has been defined in currLG
	    print stderr "Entered loop where MapInfoLG = currLG: " . $currLG . "\n" if($DEBUG_LEVEL > 0);
            if ( $mapInfo[1] =~ /\[([^\]]+)/ ) { # if marker name (mapInfo[1]) is bracketed group name between brackets
                print stderr "Current LG: ", $currLG, "\n" if($DEBUG_LEVEL > 0);
		$mapInfo[1] = $1; # mapInfo[1] is assigned the marker name without brackets (one or more not brackets after bracket from regex capture)
                print stderr "UnBracketedMarker: ", $mapInfo[1] if($DEBUG_LEVEL > 0);
		$mapInfo[2] = $marks[$#marks]->[1]; # the second element (map CM position) of the most recently added (last) marker/position array
		                                    # in the marks array is assigned to mapInfo[2] 
							## ***seems unneccessary*** 
							## Ahhh, but its not! The original map files that are being read as argument files don't include CM positions
							## for any bracketed markers.
		print stderr " Position: ", $mapInfo[2], "\n" if($DEBUG_LEVEL > 0);
            }
            for ( $x = 0 ; $x <= $#marks ; $x++ ) { # for every array element in the marks array 
                $markerAR = $marks[$x]; # create a reference markerAR for the current array element from the marks array
		$y = $x + 1;
		print stderr "markerAR(" . $y ."): " . $$markerAR[0] . ":" . $markerAR->[0] . "\n" if($DEBUG_LEVEL > 0); # dereference of markerAR through use of $$m[0] or $m->[0] 
                $delta = $mapInfo[2] - $markerAR->[1]; # calculates the change in map position (delta) from the current marker to every other marker
		                                       # in the marks array
		print stderr "Delta: " . $mapInfo[2] . " - " . $$markerAR[1] . " = " . $delta, "\n" if($DEBUG_LEVEL > 0);
                next if ( $delta > $LOCAL_BIN_THRESHOLD ); # ignores markers that are seperated from current marker by more than 
		                                           # LOCAL_BIN_THRESHOLD (30cM)  
                ( $m1, $m2 ) = sort ( $markerAR->[0], $mapInfo[1] ); # build input for markSub hash keys based on a sorted comparison of the marker
		                                                     # names. sort avoids duplication of marker pair as key with names in reverse order
		print stderr '$m1: ' . $m1 . "\n" if($DEBUG_LEVEL > 0);
		print stderr '$m2: ' . $m2 . "\n\n" if($DEBUG_LEVEL > 0);

                if ( exists( $markSub{ $m1 . ":+:" . $m2 } ) ) {        # if the sorted/combined marker name key already exists in the markSub hash
                    push( @{ $markSub{ $m1 . ":+:" . $m2 } }, $delta ); # the newest delta calculation between the markers is pushed onto the
		                                                        # array reference for that sorted marker pair key ($m1:+:$m2)
                }
                else {
                    $markSub{ $m1 . ":+:" . $m2 } = [$delta]; # otherwise the marker pair key is given the value of an unnamed array reference 
								# with the delta calculated as the sole array element
                }
            }
            push( @marks, [ $mapInfo[1], $mapInfo[2] ] ); # an unnamed array containing the current marker and map position is pushed onto the marks array
            push( @{$maps{$fn}->{$currLG}}, [ $mapInfo[1], $mapInfo[2] ] ); # and also pushed onto the values array for that specific linkage group
	                                                                    # correlated to its population consensus file (array of hash within hash)
        }
        else {
	    print stderr "Entered New currLG loop\n" if($DEBUG_LEVEL > 0);
            $currLG = $mapInfo[0]; # reset currLG as the linkage group of the current marker, i.e. first element in mapInfo array
            @marks = ( [ $mapInfo[1], $mapInfo[2] ] ); # initialize marks array, erasing markers from previous linkage group.
							# assign marker name and map position from mapInfo[1]&[2] as an unnmaed array within the marks array
            $maps{$fn}->{$currLG} = [[$mapInfo[1], $mapInfo[2] ]]; # building a hash table based on the input consensus files arguments as keys
	                                                           # and value as another hash with the LG (currLG) as the key to an array of
	                                                           # arrays containing the marker names and positions for the specified LG
	    
            if(DEBUG_LEVEL > 0){
	    my @keys = keys %maps; ################################# used to print the hash data being generated #########################
	    print join (",", @keys) . "\n";
	    foreach $item (keys %maps) {
		print "Hash maps key: $item\n";
		foreach $iteminitem (keys %{$maps{$item}}) {
		    print "Hash maps value (hash): LG $iteminitem = ( ";
		    my @values = @{$maps{$item}{$iteminitem}};
		    for ( $x = 0 ; $x <= $#values ; $x++ ) {
			print $values[$x][0] . ":" . $values[$x][1] . " ";
		    }
		    print ")\n";
		}
		print "\n";
	    }
	    print "Current LG: ", $currLG, "\n";
	    print "# of elements in marks array: " . @marks . "\n";
	    for ( $x = 0 ; $x <= $#marks ; $x++ ) {
		print "Last elements in marks array: " . $#marks . "\n";
		print '$marks[' .  $x .  "]: ";
		print $marks[$x][0];
		print " : ";
		print $marks[$x][1];
		print "\n\n"; ############################################
	    }
            }
        }

        $mark2markGrp{ $fn . ":+:" . $mapInfo[1] } = $fn . ":+:" . $currLG . ":+:" . $mapInfo[2]; # assigning markers to a marker group reference based on map positions
        $markGrpCnt{$fn . ":+:" . $currLG . ":+:" . $mapInfo[2]}++; # count of markers assigned to marker groups so as to partition/normalize score contribution by group
    }
}

#### UNIT TEST (input) ####                                                                                 
#foreach my $map ( sort keys %maps){                                                                        
#  foreach my $lg (sort keys %{$maps{$map}}){                                                               
#    foreach my $markAR (@{$maps{$map}->{$lg}}){                                                            
#      print STDERR "$map\t$lg\t$markAR->[0]\t$markAR->[1]\n";                                              
#    }                                                                                                      
#  }                                                                                                        
#}                                                                                                          
####                                                                                                        

foreach $key ( keys %markSub ) { # for every marker pair built within the markSub hash
    $sum = $cnt = 0; # intialize sum and cnt to 0
    foreach $delta ( @{ $markSub{$key} } ) { # keep running sum of each delta in the values array for that marker pair key
        $sum += $delta; # sums the delta values <30 for all paiwaise comparisons for the marker pair in the markSub hash key
        $cnt++; # keeps count of number of delta values in the array for that marker pair
    }
    $markSubMatrix{$key} = $sum / $cnt; # creates another hash markSubMatrix which uses the same marker pairs as the key
                                        # and the average delta value as the value to the key
}

#### UNIT TEST (substitution matrix) ####                                                                   
#foreach my $markerPair (sort keys %markSub){                                                               
#  print STDERR "$markerPair -> [" . join(',',@{$markSub{$markerPair}}) . "] => $markSubMatrix{$markerPair}\\n"; 
#}                                                                                                          
####                                                                                                        

@imaps = sort keys %maps; # creates an array of the sorted population consensus file (keys) in the maps hash table
open(SIMSCORE, ">similarityScore.csv");

for($x=0;$x<=$#imaps;$x++){ # for each element in the imaps array
  foreach $lgm1 (keys %{$maps{$imaps[$x]}}){ # for each linkage group (key of hash within the population consensus file hash value)
    $njm{"$imaps[$x]::$lgm1"} = {} if(!exists($njm{"$imaps[$x]::$lgm1"})); # initializing new keys in njm hash to empty hash within the njm hash
    for($y=$x;$y<=$#imaps;$y++){
      foreach $lgm2 (keys %{$maps{$imaps[$y]}}){

        if($DEBUG_LEVEL > 0){
        my @values1 = @{$maps{$imaps[$x]}{$lgm1}}; ####### used to print data that is being used as input to the align2lgs subroutine #########
	my @values2 = @{$maps{$imaps[$y]}{$lgm2}};
	print "Input to align2lgs subroutine (2 arrays): ( Key1 = " . $imaps[$x] . ": LG" . $lgm1 . " - (";
	for ( $a = 0 ; $a <= $#values1 ; $a++ ) {
	    print $values1[$a][0] . ":" . $values1[$a][1] . " ";
	}
	print "); Key2 = " . $imaps[$y] . ": LG" .  $lgm2 . " - (";
	for ( $b = 0 ; $b <= $#values2 ; $b++ ) {
	    print $values2[$b][0] . ":" . $values2[$b][1] . " ";
	}
	print ")\n"; ##########################################################################################################################
	}

        $njm{"$imaps[$x]::$lgm1"}->{"$imaps[$y]::$lgm2"} = ($ZERO_SAME_POP_LG_ALIGNMENT && ($x==$y)) ? 1 : align2lgs($maps{$imaps[$x]}->{$lgm1},$maps{$imaps[$y]}->{$lgm2},$imaps[$x],$imaps[$y]);

	print SIMSCORE join(',',$imaps[$x],$lgm1,$imaps[$y],$lgm2,$njm{"$imaps[$x]::$lgm1"}->{"$imaps[$y]::$lgm2"}) , "\n";
	print SIMSCORE join(',',$imaps[$y],$lgm2,$imaps[$x],$lgm1,$njm{"$imaps[$x]::$lgm1"}->{"$imaps[$y]::$lgm2"}) , "\n";

        if(exists($njm{"$imaps[$y]::$lgm2"})){
	    $njm{"$imaps[$y]::$lgm2"}->{"$imaps[$x]::$lgm1"} = $njm{"$imaps[$x]::$lgm1"}->{"$imaps[$y]::$lgm2"};
        }
	else{
	    $njm{"$imaps[$y]::$lgm2"} = {"$imaps[$x]::$lgm1"=>$njm{"$imaps[$x]::$lgm1"}->{"$imaps[$y]::$lgm2"}};
        }
      }
    }
    $lgcnt++; # counts the number of LGs
  }
}

print stderr "LG count: $lgcnt\n" if(DEBUG_LEVEL > 0);
print "$lgcnt\n";
foreach $lgm1 (sort keys %njm){
    print "$lgm1";
    foreach $lgm2 (sort keys %{$njm{$lgm1}}){
	printf("\t%.4f",$njm{$lgm1}->{$lgm2});
    }
    print "\n";
}

##########################                                                                                           

sub align2lgs{
    my ($lg1AR,$lg2AR,$fn1,$fn2) = @_; # inputs are in form of the array of arrays which are the values from hash within maps hash
			## inputs are array references containing [markers and positions] of 2 linkage groups to be compared
    print stderr "Entered align2lgs subroutine:\n\n" if($DEBUG_LEVEL > 0);
    if($DEBUG_LEVEL > 0){
    print stderr "Input Array1: ( "; ######### used to verify input arrays lg1AR and lg2AR #############
    for( $a=0 ; $a<=$#$lg1AR ; $a++){
	print stderr "[" . $a . "]" . $$lg1AR[$a][0] . ":" . $lg1AR->[$a][1] . " "; # optional ways to dereference array pointer
    }
    print stderr ")\nInput Array2: ( ";

    for( $b=0 ; $b<=$#$lg2AR ; $b++){
	print stderr "[" . $b . "]" . $$lg2AR[$b][0] . ":" . $$lg2AR[$b][1] . " ";
    }
    print stderr ")\n\n"; ##############################################################################
    }
    print stderr "Last element in Array1: " . $#$lg1AR . "\n" if($DEBUG_LEVEL > 0);
    print stderr "Last element in Array2: " . $#$lg2AR . "\n\n" if($DEBUG_LEVEL > 0);

    for(my $y=0;$y<=$#$lg2AR;$y++){ 
	for(my $x=0;$x<=$#$lg1AR;$x++){
	    if(($x==0) && ($y==0)){
		print stderr 'align2lgs loop x=0 & y=0: x=' . $x . ' y=' . $y . "\n" if($DEBUG_LEVEL > 0);
		$mSA[$x] = mscore($lg1AR->[$x]->[0],$lg2AR->[$y]->[0],$fn1,$fn2); # calls mscore subroutine to return a score for matching these two markers
		print stderr '$mSA[' . $x . '] = ' . $mSA[$x] . "\n" if($DEBUG_LEVEL > 0);
		$vSA[$x] = $hSA[$x] = $GAPOPEN;
		print stderr '$vSA[' . $x . '] = ' . $vSA[$x] . "\n" if($DEBUG_LEVEL > 0);
		print stderr '$hSA[' . $x . '] = ' . $hSA[$x] . "\n\n" if($DEBUG_LEVEL > 0);
		    
	    }elsif($x==0){
		print stderr 'align2lgs loop x=0 & y!=0: x=' . $x . ' y=' . $y . "\n" if($DEBUG_LEVEL > 0);
		$mSA[$x] = ($GAPOPEN + ($GAPEXT * ($y-1)) + mscore($lg1AR->[$x]->[0],$lg2AR->[$y]->[0],$fn1,$fn2));
		print stderr '$mSA[' .$x . '] = ' . $mSA[$x] . "\n" if($DEBUG_LEVEL > 0);
		$vSA[$x] = $vSA[$x] + $GAPEXT;
		print stderr '$vSA[' . $x . '] = ' . $vSA[$x] . "\n" if($DEBUG_LEVEL > 0);
		$hSA[$x] = $GAPOPEN;
		print stderr '$hSA[' . $x . '] = ' . $hSA[$x] . "\n\n" if($DEBUG_LEVEL > 0);
	    }elsif($y==0){
		print stderr 'align2lgs loop x!=0 & y=0: x=' . $x . ' y=' . $y . "\n" if($DEBUG_LEVEL > 0);
		$mSA[$x] = ($GAPOPEN + ($GAPEXT * ($x-1)) + mscore($lg1AR->[$x]->[0],$lg2AR->[$y]->[0],$fn1,$fn2));
		print stderr '$mSA[' .$x . '] = ' . $mSA[$x] . "\n" if($DEBUG_LEVEL > 0);
		$vSA[$x] = $GAPOPEN;
		print stderr '$vSA[' . $x . '] = ' . $vSA[$x] . "\n" if($DEBUG_LEVEL > 0);
		$hSA[$x] = $GAPOPEN + ($GAPEXT * ($x-1));
		print stderr '$hSA[' . $x . '] = ' . $hSA[$x] . "\n\n" if($DEBUG_LEVEL > 0);
	    }else{
		print stderr 'align2lgs loop x!=0 & y!=0: x=' . $x . ' y=' . $y . "\n" if($DEBUG_LEVEL > 0);
		$vSA[$x] = max(($mSA[$x] + $GAPOPEN),($vSA[$x] + $GAPEXT));
		print stderr '$vSA[' . $x . '] = ' . $vSA[$x] . "\n" if($DEBUG_LEVEL > 0);
		$mSA[$x] = $workingSA[$x - 1] + mscore($lg1AR->[$x]->[0],$lg2AR->[$y]->[0],$fn1,$fn2);
		print stderr '$mSA[' .$x . '] = ' . $mSA[$x] . "\n" if($DEBUG_LEVEL > 0);
		$hSA[$x] = max(($mSA[$x - 1] + $GAPOPEN), ($hSA[$x-1] + $GAPEXT));
		print stderr '$hSA[' . $x . '] = ' . $hSA[$x] . "\n\n" if($DEBUG_LEVEL > 0);
	    }
	}
####### DO U NEED TO BE CONCERNED THAT THE ELEMENTS OF lg1AR COULD BE LONGER OR SHORTER THAN lg2AR??? MAYBE NOT #######
## Nope, the dynamic programing matrix doesn't have to be and most often won't be square. ##

	print stderr "Entered loop to calculate workingSA\n" if($DEBUG_LEVEL > 0);
	for(my $x=0;$x<=$#$lg1AR;$x++){
	    print stderr '$mSA[' . $x . '] = ' . $mSA[$x] . "\n" if($DEBUG_LEVEL > 0);
	    print stderr '$hSA[' . $x . '] = ' . $hSA[$x] . "\n" if($DEBUG_LEVEL > 0);
	    print stderr '$vSA[' . $x . '] = ' . $vSA[$x] . "\n" if($DEBUG_LEVEL > 0);
	    $workingSA[$x] = max($vSA[$x], max($mSA[$x],$hSA[$x]));
	    print stderr '$workingSA[' . $x . '] = ' . $workingSA[$x] . "\n\n" if($DEBUG_LEVEL > 0);
	}

    }

    $fullGapPenalty = ($GAPOPEN * 2) + ($GAPEXT * ($#$lg1AR + $#$lg2AR + 2)); ## calculating the worst-case score ##
    $maxAlignScore = ((min(($#$lg1AR + 1),($#$lg2AR + 1)) * $MATCH) - $fullGapPenalty); ## normalize to positive scores by shifting by the worst-case score

    $sc = min(1,($workingSA[$#$lg1AR] - $fullGapPenalty)/$maxAlignScore);

    ## Now we look at reverse alignment by reversing the order of lg2 markers. ie. aligning from last marker to first in the 2nd linkage group ##
    for(my $y=0;$y<=$#$lg2AR;$y++){
	for(my $x=0;$x<=$#$lg1AR;$x++){
	    if(($x==0) && ($y==0)){
		$mSA[$x] = mscore($lg1AR->[$x]->[0],$lg2AR->[$#$lg2AR - $y]->[0],$fn1,$fn2);
		$vSA[$x] = $hSA[$x] = $GAPOPEN;
	    }elsif($x==0){
		$mSA[$x] = ($GAPOPEN + ($GAPEXT * ($y-1)) + mscore($lg1AR->[$x]->[0],$lg2AR->[$#$lg2AR - $y]->[0],$fn1,$fn2));
		$vSA[$x] = $vSA[$x] + $GAPEXT;
		$hSA[$x] = $GAPOPEN;
	    }elsif($y==0){
		$mSA[$x] = ($GAPOPEN + ($GAPEXT * ($x-1)) + mscore($lg1AR->[$x]->[0],$lg2AR->[$#$lg2AR - $y]->[0],$fn1,$fn2));
		$vSA[$x] = $GAPOPEN;
		$hSA[$x] = $GAPOPEN + ($GAPEXT * ($x-1));
	    }else{
		$vSA[$x] = max(($mSA[$x] + $GAPOPEN),($vSA[$x] + $GAPEXT));
		$mSA[$x] = $workingSA[$x - 1] + mscore($lg1AR->[$x]->[0],$lg2AR->[$#$lg2AR - $y]->[0],$fn1,$fn2);
		$hSA[$x] = max(($mSA[$x - 1] + $GAPOPEN), ($hSA[$x-1] + $GAPEXT));
	    }
	}
	for(my $x=0;$x<=$#$lg1AR;$x++){
	    $workingSA[$x] = max($vSA[$x], max($mSA[$x],$hSA[$x]));
	}
    }

    $sc = max($sc, min(1,($workingSA[$#$lg1AR] - $fullGapPenalty)/$maxAlignScore));
    return sqrt(1 - $sc);
}

########################                                                                                             

sub mscore{
    my ($mark1,$mark2,$fn1,$fn2) = @_; 
    my ($m1,$m2) = sort ($mark1, $mark2); # inputs are markers from the arrays within the input arrays in align2lgs. sorted to match keys of markSubMatrix
    print stderr "Entered mscore subroutine:\n" if($DEBUG_LEVEL > 0);
    print stderr "Comparing sorted markers: $m1 to $m2\n" if($DEBUG_LEVEL > 0);
    if($m1 eq $m2){ # if marker1 is the same as marker2
        if($NORM_MARKER_GROUPS){
		return $MATCH / min($markGrpCnt{$mark2markGrp{$fn1 . ":+:" . $mark1}},$markGrpCnt{$mark2markGrp{$fn2 . ":+:" . $mark2}});
	}else{
		return $MATCH; # return MATCH score (50) to $mSA[$x]
	}
    }elsif(exists($markSubMatrix{$m1 . ":+:" . $m2})){ # if markers not the same and marker pair exist as a key within
                                                       # the markSubMatrix hash calculate the score using the LOCAL_BIN_THRESHOLD
	                                               # minus the average delta value for that marker pair multiplied by the matchpts
	                                               # scale boost of 1.6667
	if($NORM_MARKER_GROUPS){
		return (($LOCAL_BIN_THRESHOLD - $markSubMatrix{$m1 . ":+:" . $m2}) * $matchpts) / min($markGrpCnt{$mark2markGrp{$fn1 . ":+:" . $mark1}},$markGrpCnt{$mark2markGrp{$fn2 . ":+:" . $mark2}});
	}else{
		return (($LOCAL_BIN_THRESHOLD - $markSubMatrix{$m1 . ":+:" . $m2}) * $matchpts); # return the calculated score to $mSA[$x]
	}
    }else{
	return $MISMATCH; # if the marker pair does not exist as a key in the markSubMatrix hash return the MISMATCH score (-5) to $mSA[$x]
    }
}

########################                                                                                             

sub min{
    my($a,$b) = @_;
    return ($a < $b)?$a:$b; # return the minimum value in comparison of $a and $b 
}

########################                                                                                             

sub max{
    my($a,$b) = @_;
    return ($a > $b)?$a:$b; # return the greatest (maximum) value in comparison of $a and $b
}
