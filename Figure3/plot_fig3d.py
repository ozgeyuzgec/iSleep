"""Fig. 3d: confusion matrix of the general model (60-s windows, all participants pooled, 5-fold cross-validation).

Data: fig3d_confusion_counts.csv (window counts; rows = AASM-scored stage, columns = predicted stage).
Each row is normalised to 1 for plotting. Requires numpy, pandas and matplotlib.
"""
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

here = os.path.dirname(os.path.abspath(__file__))
counts = pd.read_csv(os.path.join(here, 'fig3d_confusion_counts.csv'), index_col=0).to_numpy(float)
P = counts / counts.sum(1, keepdims=True)
names = ['NREM 1', 'NREM 2', 'NREM 3', 'REM', 'Wake']


def fmt(v):
    s = '%.2f' % v
    return '0' if s == '0.00' else s


plt.rcParams.update({'font.family': 'Arial', 'font.size': 11})
fig, ax = plt.subplots(figsize=(4.8, 3.6))
im = ax.imshow(P, cmap='Reds', vmin=0, vmax=1)
for i in range(5):
    for j in range(5):
        ax.text(j, i, fmt(P[i, j]), ha='center', va='center', color='white' if P[i, j] > 0.5 else 'black')
ax.set_xticks(range(5)); ax.set_yticks(range(5))
ax.set_xticklabels([n.replace(' ', '\n') for n in names], fontsize=10); ax.set_yticklabels(names)
ax.set_xlabel('Predicted labels'); ax.set_ylabel('AASM scored labels')
ax.set_xticks(np.arange(-.5, 5), minor=True); ax.set_yticks(np.arange(-.5, 5), minor=True)
ax.grid(which='minor', color='0.35', linewidth=0.8); ax.tick_params(which='both', length=0)
for s in ax.spines.values():
    s.set_visible(False)
cb = fig.colorbar(im, ax=ax, ticks=[0, 0.5, 1], fraction=0.046, pad=0.04)
cb.outline.set_visible(False); cb.ax.set_yticklabels(['0', '0.5', '1'])
fig.tight_layout()
for ext in ('png', 'svg', 'pdf'):
    fig.savefig(os.path.join(here, 'fig3d.' + ext), dpi=300 if ext == 'png' else None, bbox_inches='tight')
