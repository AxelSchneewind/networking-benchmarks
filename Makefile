#!/bin/bash

.phony: setup
setup: xdp-tutorial
	
.phony: help
help:
	@echo 'This repository provides code to benchmark different network mechanism in linux'
	@echo 'First, use "make setup" to initialize everything'
	@echo ''
	@echo 'COMPILATION:'
	@echo 'XDP-programs:     compile using e.g. "make xdp-compile-xdp-filter" for xdp-filter'
	@echo 'DPDK-programs:    TODO'
	@echo 'default programs: TODO'
	@echo '                       '
	@echo 'EXECUTION: Receiver'
	@echo 'XDP-programs:     load an xdp-program using e.g. "make xdp-load-xdp-filter" for xdp-filter'
	@echo 'DPDK-programs:    '
	@echo 'default programs: '
	@echo 'EXECUTION: Sender'
	@echo '                  simply "make run-sender"'

# get source code
xdp-tutorial:
	@git clone --recurse-submodules https://github.com/xdp-project/xdp-tutorial.git&&\
	cd xdp-tutorial && ./testenv/setup-env.sh && make

# if make does not succeed, try 
# ./testenv/testenv.sh

# copy subproject into xdp-tutorials to allow compilation using its Makefile
xdp-tutorial/%: %/* xdp-tutorial 
	@echo 'copying $* to xdp-tutorial/$*'
	@cp -rf $* xdp-tutorial/

# compile an xdp-program
xdp-compile-%: %/* xdp-tutorial/%
	@echo 'compiling program $*'
	@make -C xdp-tutorial/$*

.phony: xdp-compile-xdp-filter xdp-compile-basic01-xdp-pass
xdp-compile: xdp-compile-xdp-filter xdp-compile-basic01-xdp-pass

# view the bpf-byte-code binary
xdp-view-objdump-%:
	@llvm-objdump -S xdp-tutorial/$*/*_kern.o

# the output should look something like this:
# xdp_pass_kern.o:        file format elf64-bpf
# 
# Disassembly of section xdp:
# 
# 0000000000000000 <xdp_prog_simple>:
# ;       return XDP_PASS;
#        0:       b7 00 00 00 02 00 00 00 r0 = 0x2
#        1:       95 00 00 00 00 00 00 00 exit

# so, not much going on. simply setting the return value and exiting.


# load xdp program using ip and check if it now still responds to ping packets
# With XDP_PASS this should still work
# When replacing XDP_PASS in xdp_pass_kern.c with XDP_DROP,recompile and reload.
# Ping again, now there is no response. Packets are dropped.

xdp-load-%: xdp-compile-%
	sudo ip link set  dev lo xdpgeneric obj $(wildcard xdp-tutorial/$*/*_kern.o) sec xdp
	sudo ip link show dev lo
	sudo ip add show dev lo
	ping -c 1 -W 2 127.0.0.1
	@echo 'successfully loaded program $*'
	@echo 'unload using "make unload"'

xdp-unload:
	sudo ip link set  dev lo xdpgeneric off





DEVNAME=wlp4s0
DEFAULTDRIVER=ath10k_pci
DEVUUID=0000:04:00.0

# to find out device name
ifndef DEVNAME
dpdk-check:
	 ip link
	 echo 'u need to set DEVNAME to the interface name from ip link'
	 @exit 1
endif

ifndef DEVUUID
dpdk-check:
	 dpdk-devbind.py --status
	 echo 'u need to set DEVUUID to the interface id from dpdk-devbind status'
	 echo 'u need to set DEFAULT_DRIVER to the interface id from dpdk-devbind status'
	 @exit 1
endif

ifdef DEVNAME
ifdef DEFAULTDRIVER
ifdef DEVUUID

dpdk-check:

dpdk-bind: dpdk-check
	sudo modprobe vfio_pci
	sudo ip link set down ${DEVNAME}
	sudo dpdk-devbind.py --bind=vfio-pci ${DEVUUID}
	sudo ip link set up ${DEVNAME}

dpdk-unbind:
	sudo ip link set down ${DEVNAME}
	sudo dpdk-devbind.py --unbind ${DEVUUID}
	sudo dpdk-devbind.py --bind=${DEFAULTDRIVER} ${DEVUUID}
	sudo ip link set up ${DEVNAME}

endif
endif
endif



# compilation for sender side of benchmark
sender/cmdline.c: sender/cmdline.ggo
	gengetopt -i sender/cmdline.ggo --output-dir=sender

sender/sender: sender/sender.c sender/cmdline.c
	gcc sender/*.c -o sender/sender

run-sender: sender/sender
	./sender/sender 



