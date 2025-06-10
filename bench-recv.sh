#!/bin/sh

sport=0
rport=0

inc_send_port() {
    sport=$((($sport + 1) % 8))
}
inc_recv_port() {
    rport=$((($rport + 1) % 8))
}

for try in 1 2 3 4; do
    # filter
    for size in 8 16 32 64 128 256 512 768 1024 1400; do
    
        inc_send_port && inc_recv_port
        make PACKET_SIZE=$size PORT_SENDER=500${sport} PORT_RECEIVER=501${rport} exp-xdp-filter-recv
    done
    
    for size in 8 16 32 64 128 256 512 768 1024 1400; do
    
    
        inc_send_port && inc_recv_port
        make PACKET_SIZE=$size PORT_SENDER=500${sport} PORT_RECEIVER=501${rport}  exp-def-filter-recv
    done
    
    
    # dropping
    for size in 8 16 32 64 128 256 512 768 1024 1400; do
    
    
        inc_send_port && inc_recv_port
        make PACKET_SIZE=$size PORT_SENDER=500${sport} PORT_RECEIVER=501${rport}  exp-xdp-drop-recv
    done
    
    for size in 8 16 32 64 128 256 512 768 1024 1400; do
    
    
        inc_send_port && inc_recv_port
        make PACKET_SIZE=$size PORT_SENDER=500${sport} PORT_RECEIVER=501${rport}  exp-def-drop-recv
    done

    # accepting
    for size in 8 16 32 64 128 256 512 768 1024 1400; do
    
    
        inc_send_port && inc_recv_port
        make PACKET_SIZE=$size PORT_SENDER=500${sport} PORT_RECEIVER=501${rport}  exp-xdp-accept-recv
    done
    
    for size in 8 16 32 64 128 256 512 768 1024 1400; do
    
    
        inc_send_port && inc_recv_port
        make PACKET_SIZE=$size PORT_SENDER=500${sport} PORT_RECEIVER=501${rport}  exp-def-accept-recv
    done
done
