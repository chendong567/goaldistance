## goaldistance
# Title of Dataset:
---
Multi-scale goal distance representations in human hippocampus during virtual spatial navigation

# Description of the Data and file structure
these code is writen in and run in matlab 2019 and python3.2. when run code in python，please also include a package called FOOOF，which
 can be download in https://fooof-tools.github.io/fooof/

Behav_25.mat is a structure include 5 fields. 
ITIstart is the fixation starttime of each trial.
ITIend is the fixation endtime of each trial. 
move_info record the navigation behave data in maze.the data can be used in this project are:first row is time; second/third row is location position x/y.fourth row is head-direction; 5th row is speed. 10th row is object label.
objLoc is goal location of 8 object
targetSearch record the phase of trial. 1st row is object label; 2nd row is trial phase. 1 denotes time of cue present;2 denotes time of drop time; 3 denotes time of feedback time; 4 denotes time of pick up the object when re-encoding ;
The useful data begin from 17th column. For example, the first trial is 17th-20th column.the trial is retrieve object 6 and  begin at 234.9604s.patient drop the object at 261.9718s and the drop location is in 3rd and 4th row.
 
workflow：
1.run The script "main01_goalDistance_regression_good.m"  to calculating goal distance modulation. 

2.script main01_statics_roiBeta_good_foi.m was used for data statistics of goal distance modulation, employing linear mixed model.

3.script main02_beta_y_lme.m was used to examine the relationship of goal distance modulation and the hippocampal longitudinal axis.

4.script main03_tau_y_lme.m was used to examine the relationship of neural timescales and the hippocampal longitudinal axis.

5.script main04_thetaPeak_y_lme.m was used to examine the relationship of theta peak frequency and the hippocampal longitudinal axis.

# Sharing/access Information

The codes were about estimating the modulation of hippocampal theta activity by goal distance as well as the calculation of time hierarchy. The toolkit fooof for computing temporal hierarchies is also included in the file. The experimental design, including an explanation of metrics of interest, is detailed in Chen et al (2018) Current Biology and Chen et al (2021) Science Advances. EXAMPLE electrode data from the hippocampus are included.
