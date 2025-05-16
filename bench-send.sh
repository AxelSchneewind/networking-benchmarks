#!/bin/sh


for size in 8 16 32 64 128 256 1024 1400; do
    echo "press enter to start"
    read
    make PACKET_SIZE=$size exp-xdp-filter-send
done

for size in 8 16 32 64 128 256 1024 1400; do
    echo "press enter to start"
    read
    make PACKET_SIZE=$size exp-def-filter-send
done
