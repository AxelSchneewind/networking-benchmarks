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

#include "time.h"

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
	servaddr.sin_addr.s_addr = inet_addr(args.target_ip_arg); 
	servaddr.sin_port = htons(args.target_port_arg); 
	servaddr.sin_family = AF_INET; 
	
	// create datagram socket 
	sockfd = socket(AF_INET, SOCK_DGRAM, 0); 
	
	// connect to server 
	if(connect(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr)) < 0) 
	{ 
		printf("\n Error : Connect Failed \n"); 
		exit(0); 
	} 

    printf("sending %i messages of size %i to %s:%i\n", args.msg_count_arg, args.msg_size_arg, args.target_ip_arg, args.target_port_arg);


    // 
    struct timespec tp_before, tp_after;

    clock_gettime(CLOCK_MONOTONIC_COARSE, &tp_before);

    // iteratively send messages
    for (int i = 0; i < msg_count; i++) {
        message[0] = 'a' + (i % 26);

	    // request to send datagram 
	    // no need to specify server address in sendto 
	    // connect stores the peers IP and port 
	    sendto(sockfd, message, msg_size, 0, (struct sockaddr*)NULL, sizeof(servaddr)); 
    }

    clock_gettime(CLOCK_MONOTONIC_COARSE, &tp_after);

	// waiting for response 
	// recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr*)NULL, NULL); 
	// puts(buffer); 

	// close the descriptor 
	close(sockfd); 

    unsigned seconds = tp_after.tv_sec - tp_before.tv_sec;
    unsigned long us = (tp_after.tv_nsec - tp_before.tv_nsec) / 1000;
    printf("done, took %i.%.6lis\n", seconds, us);
} 

