#!/bin/sh

waittime=2

sport=0
rport=0

inc_send_port() {
    sport=$((($sport + 1) % 8))
}
inc_recv_port() {
    rport=$((($rport + 1) % 8))
}

for try in 1 2 3 4; do
    # filtering
    for size in 8 16 32 64 128 256 512 768 1024 1400; do
        # echo "press enter to start"
        # read
        sleep $waittime
        inc_send_port && inc_recv_port
        make PACKET_SIZE=$size PORT_SENDER=500${sport} PORT_RECEIVER=501${rport} exp-filter-send
    done
    
    for size in 8 16 32 64 128 256 512 768 1024 1400; do
        # echo "press enter to start"
        # read
        sleep $waittime
        inc_send_port && inc_recv_port
        make PACKET_SIZE=$size PORT_SENDER=500${sport} PORT_RECEIVER=501${rport} exp-filter-send
    done
    
    
    # dropping
    for size in 8 16 32 64 128 256 512 768 1024 1400; do
        # echo "press enter to start"
        # read
        sleep $waittime
        inc_send_port && inc_recv_port
        make PACKET_SIZE=$size PORT_SENDER=500${sport} PORT_RECEIVER=501${rport} exp-drop-send
    done
    
    for size in 8 16 32 64 128 256 512 768 1024 1400; do
        # echo "press enter to start"
        # read
        sleep $waittime
        inc_send_port && inc_recv_port
        make PACKET_SIZE=$size PORT_SENDER=500${sport} PORT_RECEIVER=501${rport} exp-drop-send
    done


    # accepting
    for size in 8 16 32 64 128 256 512 768 1024 1400; do
        # echo "press enter to start"
        # read
        sleep $waittime
        inc_send_port && inc_recv_port
        make PACKET_SIZE=$size PORT_SENDER=500${sport} PORT_RECEIVER=501${rport} exp-accept-send
    done
    
    for size in 8 16 32 64 128 256 512 768 1024 1400; do
        # echo "press enter to start"
        # read
        sleep $waittime
        inc_send_port && inc_recv_port
        make PACKET_SIZE=$size PORT_SENDER=500${sport} PORT_RECEIVER=501${rport} exp-accept-send
    done

done
