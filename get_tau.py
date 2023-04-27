#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 14 22:16:36 2023

@author: jialiliu
"""

import matplotlib.pyplot as plt
plt.close("all")    # 相当于 Matlab 中的 close all, 即关闭所有图片

import numpy as np
import scipy.io as scio
import pandas as pd
import h5py
import os
import pdb
from fooof import FOOOFGroup
from fooof.utils.params import compute_knee_frequency
from fooof.utils.params import compute_time_constant

## scio for normal.mat
## h5py for -v7.3

dropfile='rightHippo_retrieval_good_log65.mat'
ffile='f_log.mat'
roifile = 'right_hippo.mat'

dropdata=scio.loadmat(dropfile)
fdata=scio.loadmat(ffile)
rdata=scio.loadmat(roifile)

d=dropdata['powspctrm_good']
f=fdata['f']
r = rdata['roi_info']

f=f.reshape(np.size(f),)

## control range of knee freq
lower_knee_freq=12
upper_knee_freq=150
ap_bounds=((-np.inf,lower_knee_freq,-np.inf),(np.inf,upper_knee_freq,np.inf))
fm=FOOOFGroup(aperiodic_mode='knee')
fm._ap_bounds=ap_bounds
fm._ap_guess=[None,(upper_knee_freq-lower_knee_freq)/2,None]

freq_range=[12,150]
fm.add_data(f,d)
fm.report(f,d,freq_range,progress='tqdm')

print(fm.freq_res)

offset=fm.get_params('aperiodic_params','offset')
exponent=fm.get_params('aperiodic_params','exponent')
knee=fm.get_params('aperiodic_params','knee')

tau=(1./(2*np.pi*knee))*1000

scio.savemat('tauRetrieval_good_log65.mat',{'tau':tau,'knee_freq':knee})    

