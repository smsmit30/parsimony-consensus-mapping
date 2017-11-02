#!/usr/bin/perl

while(<>){
	if(/\.txt::/){
		@row = split("\t",$_);
		($map,$lg) = $row[0] =~ /([\w]+)\.txt::(.+)$/;
		if ($map eq $lg){
    		$row[0] = "$map";
    		print join("\t",@row);
    	}else{
    		$row[0] = "$map";
    		print join("\t",@row);
		}
	}else{
    	print;
    }
}
