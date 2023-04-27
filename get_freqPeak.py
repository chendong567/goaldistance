#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 14 22:10:13 2023

@author: jialiliu
"""

#!/usr/bin/env python
# coding: utf-8

# In[15]:

import numpy as np
import scipy.io as scio
import pandas as pd
import h5py
import os
import pdb
from fooof import FOOOFGroup
from fooof.analysis import get_band_peak_fg
from scipy import stats
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import spearmanr
from scipy.io import savemat

dropfile='rightHippo_retrieval_good_linear65.mat'
ffile='f_lowFreq_linear.mat'
yfile='right_hippo.mat'


dropdata=scio.loadmat(dropfile)
fdata=scio.loadmat(ffile)
ydata=scio.loadmat(yfile)

d=dropdata['powspctrm_good']
f=fdata['f']
ydata=ydata['roi_info']
ydata=ydata[:,4]

f=f.reshape(np.size(f),)

fm=FOOOFGroup(aperiodic_mode='fixed',peak_width_limits=[1,6],peak_threshold=1.5)
freq_range=[2,30]

fm.add_data(f,d)

fm.report(f,d,freq_range)
peaks = fm.get_params('peak_params')

selec_freq=[4,12]
selec_freq_name='4-12Hz'

sf=selec_freq
results=get_band_peak_fg(fm,sf)

scio.savemat('',{'peak_freq':results})    




