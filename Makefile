#!/bin/bash

.phony: setup
setup: xdp-tutorial dpdk

##################################### XDP #####################################

# get source code
xdp-tutorial:
	@[ -d xdp-tutorial ] && exit
	@git clone --recurse-submodules https://github.com/xdp-project/xdp-tutorial.git&&\
	cd xdp-tutorial && ./testenv/setup-env.sh && make

# copy subproject into xdp-tutorials to allow compilation using its Makefile
xdp-tutorial/%: %/ xdp-tutorial filter.h
	echo 'copying $* to xdp-tutorial/$*'
	cp filter.h $*
	rm -rf xdp-tutorial/$*
	cp -rf $* xdp-tutorial/$*

# compile an xdp-program
xdp-compile-%: xdp-tutorial/% %/ filter.h
	echo 'compiling program $*'
	@cp -rf $* xdp-tutorial/
	make -C xdp-tutorial/$*

.phony: xdp-compile-xdp-filter
xdp-compile: xdp-compile-xdp-filter

# view the bpf-byte-code binary
xdp-view-objdump-%:
	@llvm-objdump -S xdp-tutorial/$*/*_kern.o

xdp-load-%: xdp-compile-% xdp-unload
	sudo ip link set  dev lo xdpgeneric obj $(wildcard xdp-tutorial/$*/*_kern.o) sec xdp
	@echo 'successfully loaded program $*'
	@echo 'unload using "make unload"'

xdp-show:
	sudo ip add show dev lo
	sudo ip link show dev lo
	ping -c 1 -W 2 127.0.0.1 || exit 0

xdp-unload:
	sudo ip link set  dev lo xdpgeneric off || exit 0





################################### SENDER ####################################

# compilation for sender side of benchmark
sender/cmdline.c: sender/cmdline.ggo
	gengetopt -i sender/cmdline.ggo --output-dir=sender

sender/sender: sender/sender.c sender/cmdline.c
	gcc sender/*.c -I. -o sender/sender

run-sender: sender/sender
	./sender/sender -m 6000


receiver/cmdline.c: receiver/cmdline.ggo
	gengetopt -i receiver/cmdline.ggo --output-dir=receiver

receiver/receiver: receiver/receiver.c receiver/cmdline.c
	gcc receiver/*.c -I. -o receiver/receiver

run-receiver: receiver/receiver
	./receiver/receiver -m 6000



################################## EXPERIMENTS ##################################
IP_SENDER=127.0.0.1
PORT_SENDER=5005
IP_RECEIVER=127.0.0.1
PORT_RECEIVER=5006

PACKETS_SENT=100000
PACKETS_RECEIVED=100000
PACKET_SIZE=20


# send side targets (filter for mix of valid/invalid packets, drop for invalid and accept for valid ones)
exp-filter-send: sender/sender 
	./sender/sender --msg-size $(PACKET_SIZE) --msg-count $(PACKETS_SENT) --my-ip $(IP_SENDER) --my-port $(PORT_SENDER) --peer-ip $(IP_RECEIVER) --peer-port $(PORT_RECEIVER)

exp-drop-send: sender/sender 
	./sender/sender --all-invalid --msg-size $(PACKET_SIZE) --msg-count $(PACKETS_SENT) --my-ip $(IP_SENDER) --my-port $(PORT_SENDER) --peer-ip $(IP_RECEIVER) --peer-port $(PORT_RECEIVER)

exp-accept-send: sender/sender 
	./sender/sender --all-valid --msg-size $(PACKET_SIZE) --msg-count $(PACKETS_SENT) --my-ip $(IP_SENDER) --my-port $(PORT_SENDER) --peer-ip $(IP_RECEIVER) --peer-port $(PORT_RECEIVER)



# receive side targets (identical for each experiment, apart from result file)
# for each experiment, one target for xdp and one for the kernel stack is provided
exp-xdp-filter-recv: xdp-load-xdp-filter receiver/receiver 
	./receiver/receiver --msg-size $(PACKET_SIZE) --msg-count $(PACKETS_RECEIVED) --my-ip $(IP_RECEIVER) --my-port $(PORT_RECEIVER) --peer-ip $(IP_SENDER) --peer-port $(PORT_SENDER) --csv result-filter-xdp.csv

exp-def-filter-recv: xdp-unload receiver/receiver 
	./receiver/receiver --msg-size $(PACKET_SIZE) --msg-count $(PACKETS_RECEIVED) --my-ip $(IP_RECEIVER) --my-port $(PORT_RECEIVER) --peer-ip $(IP_SENDER) --peer-port $(PORT_SENDER) --csv result-filter-def.csv

exp-xdp-drop-recv: xdp-load-xdp-filter receiver/receiver 
	./receiver/receiver --msg-size $(PACKET_SIZE) --msg-count $(PACKETS_RECEIVED) --my-ip $(IP_RECEIVER) --my-port $(PORT_RECEIVER) --peer-ip $(IP_SENDER) --peer-port $(PORT_SENDER) --csv result-drop-xdp.csv

exp-def-drop-recv: xdp-unload receiver/receiver 
	./receiver/receiver --msg-size $(PACKET_SIZE) --msg-count $(PACKETS_RECEIVED) --my-ip $(IP_RECEIVER) --my-port $(PORT_RECEIVER) --peer-ip $(IP_SENDER) --peer-port $(PORT_SENDER) --csv result-drop-def.csv


exp-xdp-accept-recv: xdp-load-xdp-filter receiver/receiver 
	./receiver/receiver --msg-size $(PACKET_SIZE) --msg-count $(PACKETS_RECEIVED) --my-ip $(IP_RECEIVER) --my-port $(PORT_RECEIVER) --peer-ip $(IP_SENDER) --peer-port $(PORT_SENDER) --csv result-accept-xdp.csv

exp-def-accept-recv: xdp-unload receiver/receiver 
	./receiver/receiver --msg-size $(PACKET_SIZE) --msg-count $(PACKETS_RECEIVED) --my-ip $(IP_RECEIVER) --my-port $(PORT_RECEIVER) --peer-ip $(IP_SENDER) --peer-port $(PORT_SENDER) --csv result-accept-def.csv







########################## DPDK (not working currently) ############################

# variables for DPDK
DEVNAME=
DEFAULTDRIVER=
DEVUUID=

# default, checks passed, overwritten if any of the above variables undefined
dpdk-check:

# 
ifndef DEVNAME
dpdk-check:
	 ip link
	 echo 'you need to set DEVNAME (in the Makefile) to the interface name from ip link'
	 @exit 1
endif

ifndef DEVUUID
dpdk-check:
	 dpdk-devbind.py --status
	 echo 'you need to set DEVUUID (in the Makefile) to the interface id from dpdk-devbind status'
	 @exit 1
endif

ifndef DEFAULTDRIVER
dpdk-check:
	 dpdk-devbind.py --status
	 echo 'you need to set DEFAULT_DRIVER (in the Makefile) to the interface id from dpdk-devbind status'
	 @exit 1
endif

dpdk-status: 
	dpdk-devbind.py --status

# for binding/unbinding dpdk driver to a network interface
# sudo modprobe vfio enable_unsafe_noiommu_mode=1
dpdk-bind: dpdk-check
	sudo modprobe vfio-pci
	sudo ip link set down ${DEVNAME} || echo 'interface could not be set down'
	sudo dpdk-devbind.py --bind=vfio-pci ${DEVUUID} && sleep 1
	sudo ip link set up ${DEVNAME} || echo 'interface cannot be set up'

dpdk-unbind:
	sudo ip link set down ${DEVNAME} || echo 'interface could not be set down'
	sudo dpdk-devbind.py --unbind ${DEVUUID}
	sudo dpdk-devbind.py --bind=${DEFAULTDRIVER} ${DEVUUID} && sleep 1
	sudo ip link set up ${DEVNAME} || echo 'interface could not be set up'

# copy subproject into dpdk-exampels to allow compilation using its build system
dpdk/examples/%: %/* dpdk 
	@echo 'copying $* to dpdk/examples/$*'
	@cp -rf $* dpdk/examples/

# compile an xdp-program
dpdk-compile-%: %/* dpdk/examples/%
	@echo 'compiling program $*'
	@make -C dpdk/examples/$*

dpdk-run-%: dpdk-check dpdk-compile-% %/*
	./dpdk/examples/dpdk-filter/build/filter --no-huge

.phony: dpdk-compile-dpdk-filter 
dpdk-compile: dpdk-compile-dpdk-filter 

