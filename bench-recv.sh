#!/bin/sh


for size in 8 16 32 64 128 256 1024 1400; do


    make PACKET_SIZE=$size exp-xdp-filter-recv
done

for size in 8 16 32 64 128 256 1024 1400; do


    make PACKET_SIZE=$size exp-def-filter-recv
done
