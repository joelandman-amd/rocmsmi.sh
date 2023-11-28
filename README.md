# rocmsmi.sh
Workflow to build a portable rocmsmi.sh file for installing just enough of ROCm to run rocm-smi w/o needing network access

## Summary

This repository and make file will generate a single run file that will contain everything you need to run rocm-smi on a system without a full network connection to install the rocm/amdgpu toolchain and modules.

You use this to build the single runfile of a specific ROCm installation you have on a particular node.  See the Makefile for adjustable variables to specify the ROCm version.

## Synopsis
	(install dependencies Makeself, Python3)

		make

	# about 2 minutes later, you will have a file "rocmsmi.sh" that you can move to another host and run as 

		sudo sh ./rocmsmi.sh

## Dependencies

	- Makeself (https://makeself.io/).  You can grab and install the latest verion with

		wget https://github.com/megastep/makeself/releases/download/release-2.5.0/makeself-2.5.0.run
		sh ./makeself-2.5.0.run
		cd makeself-2.5.0
		sudo cp *.sh /usr/local/bin
		sudo cp *.1  /usr/local/share/man/man1

		# sanity check
		which makeself.sh

	- Python3 .  You can use the distribution version as long as it is >= 3.8.  Check with 

		python3 --version

	- nuitka (https://github.com/Nuitka/Nuitka).  You can install the latest version with

		pip3 install --user nuitka

	  or it will be installed during the prepare target of the makefile

	- exodus (https://github.com/intoli/exodus).  You can install the latest version with

		pip3 install --user exodus-bundler

	  or it will be installed during the prepare target of the makefile

		
## Notes

The makefile assumes you have a build machine with

	- same kernel as you will have on the target machines

	- a working install of ROCm.  You need to specify the version of rocm, as in /opt/rocm-$ROCMVERSION, we need the $ROCMVERSION specifier.

	- (gnu) make installed

	- a working and relatively modern python3 (3.8+)

	- a working Perl (3.20+ will be fine)

	- network access for the nuitka and exodus installation (you can comment those out if you have already installed them)


