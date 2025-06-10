#!/bin/python
from matplotlib import pyplot as plt
import pandas as pd
import numpy as np

import sys
import re



def main(args):
    data = list()
    names = list()
    total = 0
    for v in args[1:]:
        d = pd.read_csv(v)
        total = d['total'][0]

        d = d.groupby(by='size').agg({
            'recvd' : ['min', 'max', 'mean'],
            'time'  : ['min', 'max', 'mean'],
            'valid' : ['min', 'max', 'mean'],
            'size'  : 'min',
            'total' : 'max'
        })

        data.append(d)
        names.append(v)

    fig, ax = plt.subplots((1))

    # plot times
    for n, d in zip(names, data):
        label = re.sub('result-', '', n)
        label = re.sub('.csv', '', label)
        label = re.sub('def', 'default', label)
        ax.scatter(d['size'], d['time']['min'], label=label)
        # ax.boxplot([d.get_group(s[0])['time'] for s in d['size'].unique()], positions=d['size'].unique().to_numpy(dtype='float'), label=n, labels=d['size'].unique(), widths=0.8)
        ax.set_xscale('log', base=2)

    ax.set_xlabel('packet size [B]')
    ax.set_ylabel('time[s]')
    ax.set_title(f'time to receive %i packets' % total)
    ax.legend()

    plt.show()

    # new plot
    fig.clf()
    fig, ax = plt.subplots((1))

    # plot packet loss
    for n, d in zip(names, data):
        if 'xdp' not in n:
            ax.scatter(d['size'], d['total']['max'] - d['recvd']['min'], label=n)
            ax.set_xscale('log', base=2)

    ax.set_xlabel('packet size [B]')
    ax.set_ylabel('dropped packets[]')
    ax.set_title(f'lost packets out of %i' % total)
    ax.legend()

    plt.show()



if __name__ == '__main__':
    main(sys.argv)


