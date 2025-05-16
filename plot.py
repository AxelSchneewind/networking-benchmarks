from matplotlib import pyplot as plt
import pandas as pd
import numpy as np

import sys



def main(args):
    data = list()
    names = list()
    total = 0
    for v in args[1:]:
        d = pd.read_csv(v)
        data.append(d)
        names.append(v)
        total = d['total'][0]

    fix, ax = plt.subplots((1))

    for n, d in zip(names, data):
        ax.scatter(d['size'], d['time'], label=n)
        ax.set_xscale('log', base=2)

    ax.set_xlabel('packet size []')
    ax.set_ylabel('time[s]')
    ax.set_title(f'time to receive %i packets' % total)
    ax.legend()

    plt.show()



if __name__ == '__main__':
    main(sys.argv)


