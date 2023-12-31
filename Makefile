#### changeable variables

# current ROCM
#ROCMVER=5.7.1
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
all: rocmsmi.sh build/rocm_smi.bin prepare

prepare:
	#pip3 install --user nuitka
	#pip3 install --user exodus-bundler
	#echo "export PATH+=$$HOME/.exodus/bin" >> ${HOME}/.bashrc
	mkdir build
	cp -fv run.bash build
	touch prepare

# make the runfile using makeself
rocmsmi.sh: prepare build/load_kernel_modules.bash build/rocm_smi.bin run.bash
	${MAKESELF} ${PWD}/build rocmsmi.sh "ROCm rocm-smi stand alone package" ./run.bash


# compile the python rocm_smi.py script to a binary importing a
# few shared objects/libraries, and using the nuitka compiler.
build/rocm_smi.bin: ${ROCMSMIPATH}/rocm_smi.py prepare
	cp -rv /opt/rocm-${ROCMVER}/libexec/rocm_smi .
	cd rocm_smi ; patch -p1 < ../local_so.patch ; patch -p1 < ../exit_to_sysexit.patch
	cd build ; ${PYTHON3} -m nuitka --follow-imports \
		--standalone --onefile  \
		--include-data-files=/opt/rocm-${ROCMVER}/lib/librocm_smi64.so*=lib/ ../rocm_smi/rocm_smi.py

# make the kmod (kernel module) directory and generate 
# the load_kernel_modules script
build/load_kernel_modules.bash: 
	mkdir -p build/kmod
	cp `/usr/sbin/modprobe --show-depend amdgpu | cut -f2 -d" "` build/kmod
	/usr/sbin/modprobe --show-depend amdgpu | cut -f2 -d" " | ./gen_insmod_script.pl > build/load_kernel_modules.bash
	chmod +x build/load_kernel_modules.bash

# clean everything up
clean:
	rm -rf  prepare run/ build/ rocmsmi.sh rocm_smi/


###################################################
## debugging targets
print-%  : ; @echo $* = $($*)
# use as "make print-VARIABLE_NAME" to see variable name
