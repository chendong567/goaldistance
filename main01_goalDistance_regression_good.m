%% calc goal distance_power regression final determined parameter

clc
clear
close all


%% other fixed parameters

filtdata_path = ''; %% add your path name

save_path = ''; %% add your path name

speed_per = 65;

error = 1500;

target_loc = 'obj';

dis_type = 'central_dist';

stage = 3;

cond = 'good';

shuffle_time = 0;

regression_type = 'goal_dist';


%% %% regression by each chan

subID = 25;

chanID = 95;

retrieval_eopch = dist_pow_reg(filtdata_path,subID,chanID,...
    dis_type,target_loc,stage,cond,error,...
    speed_per,save_path,shuffle_time,regression_type);

disp([save_path ' sub ' num2str(subID) 'chan' num2str(chanID) 'has down'])







            
            
            






































