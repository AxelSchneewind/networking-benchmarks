# XDP benchmarks

This repository provides the benchmarks used in our final project.

It provides a simple filter definition (`filter.h`), which is implemented in XDP (see xdp-filter) and in userspace (see receiver/receiver.c).

To execute the benchmarks, two scripts are provided for sender and receiver side:
 
- bench-recv.sh
- bench-send.sh

These can be used to execute the experiment in a fully automated way.



## Advanced Usage

The Makefile provides targets for compiling and loading xdp programs (namely, the provided xdp-filter program), 
as well as targets for performing a single experiment run.
