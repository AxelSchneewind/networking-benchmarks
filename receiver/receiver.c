// adapted from https://www.geeksforgeeks.org/udp-client-server-using-connect-c-implementation/


// udp client driver program 
#include <stdio.h> 
#include <strings.h> 
#include <sys/types.h> 
#include <arpa/inet.h> 
#include <sys/socket.h> 
#include<netinet/in.h> 
#include<unistd.h> 
#include<stdlib.h> 

#include "cmdline.h"

#include "filter.h"
#include "time.h"


void write_csv(char* fname, unsigned long size, int total, int recvd, int valid, long seconds, unsigned long ns) {
    FILE* fd = fopen(fname, "a");
    fprintf(fd, "size,total,recvd,valid,time\n");
    fprintf(fd, "%lu,%i,%i,%i,%u.%9.9lu\n", size, total, recvd, valid, seconds, ns % 1000000000);
}




int main(int argc, char **argv) 
{ 
    // parse arguments
    struct gengetopt_args_info args;
    int ret = cmdline_parser(argc, argv, &args); 
    if (ret) {
        cmdline_parser_print_help();
        return 1;
    }

    //
    unsigned msg_count = args.msg_count_arg;
    unsigned msg_size = args.msg_size_arg;
    if (msg_size == 0 || msg_size > 10000 || msg_count > 1000000) {
        return 1;
    }
    // allocate buffer for message
    char* message = malloc(msg_size);

    fflush(stdout);

    // setup connection
	int sockfd, n; 
	struct sockaddr_in servaddr; 
	
	bzero(&servaddr, sizeof(servaddr)); 
	servaddr.sin_addr.s_addr = inet_addr(args.my_ip_arg); 
	servaddr.sin_port = htons(args.my_port_arg); 
	servaddr.sin_family = AF_INET; 
	
	// create datagram socket 
	sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP); 

    printf("binding to %s:%i\n", args.my_ip_arg, args.my_port_arg);
	
	// connect to server 
    socklen_t addr_len;
	if(bind(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr)) < 0) 
	{ 
		printf("\n Error : Connect Failed \n"); 
		exit(0); 
	} 

    printf("receiving %i messages of size %i from %s:%i\n", args.msg_count_arg, args.msg_size_arg, args.peer_ip_arg, args.peer_port_arg);

    // 
    struct timespec tp_before, tp_after;

    socklen_t addr_size = 0;
    struct sockaddr sender_addr;

    // iteratively send messages
    int valid_packets = 0, seq_no = 0;
    int i; 
    for (i = 0; seq_no < msg_count - 1; i++) {
	    // request to recv datagram 
	    // no need to specify server address in recvfrom 
	    // connect stores the peers IP and port 
	    recvfrom(sockfd, message, msg_size, 0, &sender_addr, &addr_size); 

        // start timer after first packet
        if (i == 0)
            clock_gettime(CLOCK_MONOTONIC_COARSE, &tp_before);

        if (filter(message))
            valid_packets++;

        // get sequence number of packet from payload
        seq_no = *(int*)(&message[4]);
    }
    clock_gettime(CLOCK_MONOTONIC_COARSE, &tp_after);

	// close the descriptor 
	close(sockfd); 

    printf("got %i(valid)/%i(received in userspace)/%i(sent)\n", valid_packets, i, seq_no + 1);

    unsigned      seconds = tp_after.tv_sec - tp_before.tv_sec;
    unsigned long ns = (tp_after.tv_nsec - tp_before.tv_nsec) % 1000000000;
    printf("took %i.%9.9lus\n", seconds, ns);

    if (args.csv_given) {
         write_csv(args.csv_arg, msg_size, seq_no + 1, i, valid_packets, seconds, ns);
    }
} 

