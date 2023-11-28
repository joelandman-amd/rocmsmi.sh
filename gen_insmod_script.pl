#!/usr/bin/env perl

use strict;

# Lead each line from STDIN, and output an appropriate insmod command
# given the name of the kernel module, but from the kmod directory.
#

print("#!/bin/bash\n");
my ($line,@fullpath,$module_name);
while ( $line = <> ) {
  chomp($line);                     # remove the newline from the end of the line
  @fullpath   = split(/\//,$line);  # split the lines based on '/'
  $module_name= pop @fullpath;      # return the last element of the path 
                                    # (module_name)
  printf("insmod kmod/%s\n",$module_name);
}

