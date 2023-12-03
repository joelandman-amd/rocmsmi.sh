#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run script as root user.  sudo ..."
  exit
fi

# 1st insert the modules into the kernel
./load_kernel_modules.bash

# 3rd run the rocm_smi.bin 
./rocm_smi.bin
