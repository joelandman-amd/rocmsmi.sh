#### changeable variables

# current ROCM
ROCMVER=6.0.0-12969

# current kernel version
KERNELVER=`uname -r`
# this uses the currently booted kernel, assuming that the system has amdgpu
# already installed

# python3 and pip3 path, same installation that nuitka and exodus compilers 
# are installed with.
PYTHON3=`which python3`
PIP3=`which pip3`
# alter this if you need to pick up a different python3 and pip3

# makeself
# grab the latest version (2.5.0) as of this writing
#   wget https://github.com/megastep/makeself/releases/download/release-2.5.0/makeself-2.5.0.run
#   ./makeself-2.5.0.run
#   cd makeself-2.5.0
#   sudo cp *.sh /usr/local/bin
#   sudo cp *.1  /usr/local/share/man/man1
MAKESELF=`which makeself.sh`
# alter this if you have makeself installed some where else

# exodus :  see  https://github.com/intoli/exodus#
EXODUS=`which exodus`
# alter this if you have exodus installed some where else

#### internal variables, don't change unless you know what each does!
ROCMSMIPATH=/opt/rocm-${ROCMVER}/libexec/rocm_smi



#### actual make file targets
all: build/rocm_smi_so prepare

prepare:
	pip3 install --user nuitka
	pip3 install --user exodus-bundler
	echo "export PATH+=$$HOME/.exodus/bin" >> ${HOME}/.bashrc
	mkdir build
	cp -fv run.bash build
	touch prepare

# make the runfile using makeself
rocmsmi.sh: build ${MAKESELF}
	${MAKESELF} $PWD/build rocmsmi.sh "ROCm rocm-smi stand alone package" ./run.bash

# make the transportable binary with all shared objects/libraries
build/rocm_smi_so: build/rocm_smi.bin prepare build/load_kernel_modules.bash
	. ${HOME}/.bashrc ; cd build ; ${EXODUS} rocm_smi.bin -o rocm_smi_so

# compile the python rocm_smi.py script to a binary importing a
# few shared objects/libraries, and using the nuitka compiler.
build/rocm_smi.bin: ${ROCMSMIPATH}/rocm_smi.py prepare
	cd build ; ${PYTHON3} -m nuitka --follow-imports  ${ROCMSMIPATH}/rocm_smi.py

# make the kmod (kernel module) directory and generate 
# the load_kernel_modules script
build/load_kernel_modules.bash: 
	mkdir -p build/kmod
	cp `/usr/sbin/modprobe --show-depend amdgpu | cut -f2 -d" "` build/kmod
	/usr/sbin/modprobe --show-depend amdgpu | cut -f2 -d" " | ./gen_insmod_script.pl > build/load_kernel_modules.bash
	chmod +x build/load_kernel_modules.bash

# clean everything up
clean:
	rm -rf  prepare run/ build/ rocmsmi.sh


###################################################
## debugging targets
print-%  : ; @echo $* = $($*)
# use as "make print-VARIABLE_NAME" to see variable name
