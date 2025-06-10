/* SPDX-License-Identifier: GPL-2.0 */
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <unistd.h>

#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/ipv6.h>
#include <linux/ip.h>
#include <linux/in.h>
#include <linux/icmpv6.h>
#include <stddef.h>

#include <netinet/udp.h>

#include "filter.h"

SEC("xdp")
int  xdp_prog_simple(struct xdp_md *ctx)
{
    int verdict = XDP_DROP;
    // access payload
    unsigned long header_len = sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct udphdr);
	uint8_t *udp_bytes = (uint8_t*)(ctx->data + header_len);

    uint8_t *end = (uint8_t*)(unsigned long)(ctx->data_end);
    if (udp_bytes + 1 < end) {
        if (filter(udp_bytes)) {
            verdict = XDP_PASS;
        }
    }

	return verdict;
}


char _license[] SEC("license") = "GPL";
