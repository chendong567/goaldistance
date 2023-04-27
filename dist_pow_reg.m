function  retrieval_eopch = dist_pow_reg(eegpath,subID,chanID,dis_type,goalLoc_type,stage,cond,error_thr,speed_per,save_path,shuffle_time,regression_type)
%% calc regression before speedseperation

% calculate regression: pow ~ goal_dist for one chan

% 1) sepereate good/bad conditions according to drop error

% 2) remove some trial with big value path (cumulate path/ direct path)

% 3) stage: 3-retrieval, 5-re-encoding

% 4) dist_type: raw_dist/norm_dist/central_dist

pathName = [eegpath 'epoch_' num2str(subID) '_' num2str(chanID)];

load(pathName);

myData = epoch;
%% seperate speed

if length(speed_per)==1
    speed_thr = floor(prctile(myData.move_speed,speed_per));
    cal_epoch.behav = myData.behav(:,myData.behav(5,:)>speed_thr);
    cal_epoch.power = myData.power(:,myData.behav(5,:)>speed_thr);
elseif length(speed_per)==2
    speed_thr_min = floor(prctile(myData.move_speed,speed_per(1)));
    speed_thr_max = floor(prctile(myData.move_speed,speed_per(2)));
    cal_epoch.behav = myData.behav(:,myData.behav(5,:)>speed_thr_min&myData.behav(5,:)<speed_thr_max);
    cal_epoch.power = myData.power(:,myData.behav(5,:)>speed_thr_min&myData.behav(5,:)<speed_thr_max);
end

cal_epoch.m_pow = myData.m_pow;
cal_epoch.std_pow = myData.std_pow;

myData = cal_epoch;
%% remove the trials with big path_value

alltrl = unique(myData.behav(7,:));
alltrl(ismember(alltrl,0)) = [];
path_val.trl_id = alltrl;

error_trl = unique(myData.behav(7,myData.behav(9,:)<=error_thr));
valid_trl = intersect(path_val.trl_id,error_trl);
invalid_trl = setdiff(alltrl,valid_trl)';

%% normalize power

mean_pow = repmat(myData.m_pow,1,size(myData.power,2));
std_pow = repmat(myData.std_pow,1,size(myData.power,2));
normd_pow = (myData.power - mean_pow)./std_pow;

%% select distance and power

% stage: 3-retrieval, 5-re-encoding

load(['behav_' num2str(subID)])

alldist = []; allpow = [];trls = [];all_edge_dist = [];
allspeed = [];alledg = [];alltim = [];allpath = [];
allgoal2edge = [];allacc_speed = [];all_error = [];

switch cond
    case 'good'
        cal_trls = valid_trl;
    case 'bad'
        cal_trls = invalid_trl;
end


switch goalLoc_type
    case 'subj'
        load(['subj_loc' num2str(subID)])
    case 'obj'
        load(['obj_loc' num2str(subID)])
end


for itrl = 1:length(cal_trls)
    
    trl_now = cal_trls(itrl);
    
    % 1) get target loc and now loc
    
    if size(target_loc,1)==4
        
        now_obj = unique(myData.behav(10,ismember(myData.behav(7,:),trl_now)));
        
        temp_tarLoc =  target_loc(3:4,trl_now);
        
        if now_obj~=target_loc(1,trl_now)
            
            errordlg('objects number is not consistent!')
            
        end
        
    else
        now_obj = unique(myData.behav(10,ismember(myData.behav(7,:),trl_now)));
        
        temp_tarLoc =  target_loc(now_obj,:);
    end
    
    time_ind = find(myData.behav(7,:)==trl_now & myData.behav(8,:)==stage);
    
    temp_nowLoc = myData.behav(2:3,time_ind);
    
    %2) calc time
    
    temp_realtime = myData.behav(1,time_ind);
    
    temp_start = behav_info.ITIend(trl_now);
    
    temp_time = temp_realtime - temp_start-2;
    
    % 3) calc distance
    
    temp_dist = sqrt((temp_nowLoc(1,:)-temp_tarLoc(1)).^2+(temp_nowLoc(2,:)-temp_tarLoc(2)).^2);
    
    % 4) cal egocentric direction
    
    x_temp = temp_tarLoc(1)-temp_nowLoc(1,:);
    
    y_temp = temp_tarLoc(2)-temp_nowLoc(2,:);
    
    goal_dir = angle(x_temp+y_temp*1i);
    
    head_dir = myData.behav(11,time_ind);
    
    edg_temp = abs(rad2deg(mod(head_dir-goal_dir+pi,2*pi)-pi));
    
    % 5) cal path dist
    
    temp_path = myData.behav(12,time_ind);

    % 6) cal edge dist
    
    temp_edge_dist = myData.behav(14,time_ind);
    
    % 7) cal goal to dist
    
    temp_goal2edge = [4750-sqrt(temp_tarLoc(1).^2+temp_tarLoc(2).^2)];
    temp_goal2edge = repmat(temp_goal2edge,1,length(time_ind));
    
    % 8) calc acc speed
    
    tempacc_speed = myData.behav(15,time_ind);
     
    % 9) error
    
    temp_error =  myData.behav(9,time_ind);
    
    % 10) combine things together
    
    alldist = [alldist temp_dist];
    allpow = [allpow normd_pow(:,time_ind)];    
    trls = [trls repmat(trl_now,1,length(temp_dist))];
    allspeed = [allspeed myData.behav(5,time_ind)];    
    alledg = [alledg edg_temp];    
    alltim = [alltim temp_time];
    allpath = [allpath temp_path];
    all_edge_dist = [all_edge_dist temp_edge_dist];
    allgoal2edge = [allgoal2edge temp_goal2edge];
    allacc_speed = [allacc_speed tempacc_speed];
    all_error = [all_error temp_error];
end


%% rescale x varaibles
switch dis_type
    
    case 'raw_dist'  
        
        alldist = alldist./100;
        
    case 'norm_dist'
        
        alldist = zscore(alldist);  
        
    case 'central_dist'
        
        alldist = (alldist-min(alldist))./(max(alldist)-min(alldist));
        alledg = alledg./180;        
        alltim = (alltim-min(alltim))./(max(alltim)-min(alltim));
        allpath = (allpath-min(allpath))./(max(allpath)-min(allpath));
        all_edge_dist = (all_edge_dist-min(all_edge_dist))./(max(all_edge_dist)-min(all_edge_dist));
        allgoal2edge = (allgoal2edge-min(allgoal2edge))./(max(allgoal2edge)-min(allgoal2edge));
        allspeed = (allspeed-min(allspeed))./(max(allspeed)-min(allspeed));
%         allacc_speed = (allacc_speed-min(allacc_speed))./(max(allacc_speed)-min(allacc_speed));
        all_error = (all_error-min(all_error))./(max(all_error)-min(all_error));

end


%% fitglm

all_beta = [];
all_z= [];
all_shuf = [];
all_beta_name = [];

switch regression_type
    
    case 'goal_dist'
        X = alldist';
        func_exp = 'reg_goal(X,glm_y,shuffle_time)';
        
    case 'goal_edg'
        X = alledg';
        func_exp = 'reg_goal(X,glm_y,shuffle_time)'; 
        
    case 'dist_orient_full'
        X = [alldist' alledg'];
        func_exp = 'twoFactor_full(X,glm_y,shuffle_time)';

    case 'dist_orient_linear'
        X = [alldist' alledg'];
        func_exp = 'twoFactor_linear(X,glm_y,shuffle_time)';
        
    case 'dist_speed_linear'
        X = [alldist' allspeed'];
        func_exp = 'twoFactor_linear(X,glm_y,shuffle_time)';
        
    case 'dist_orient_interaction'
        X = [alldist' alledg'];
        func_exp = 'twoFactor_interact(X,glm_y,shuffle_time)';
        
    case 'time'
        X = alltim';
        func_exp = 'reg_goal(X,glm_y,shuffle_time)';
        
    case 'path_dist'
        X = allpath';
        func_exp = 'reg_goal(X,glm_y,shuffle_time)';   
        
    case 'dist_time_linear'
        X = [alldist' alltim'];
        func_exp = 'twoFactor_linear(X,glm_y,shuffle_time)';
        
    case 'goaldist_egdedist'        
         X = [alldist' all_edge_dist'];
        func_exp = 'twoFactor_full(X,glm_y,shuffle_time)';      
        
    case 'egdedist'
        X = [all_edge_dist'];        
        func_exp = 'reg_goal(X,glm_y,shuffle_time)';
        
    case 'goaldist_egdedist_linear'
        X = [alldist' all_edge_dist'];
        func_exp = 'twoFactor_linear(X,glm_y,shuffle_time)';     
        
    case 'goaldist_goal2egde'        
        X = [alldist' allgoal2edge'];
        func_exp = 'twoFactor_full(X,glm_y,shuffle_time)';  
        
    case 'speed'
        X = allspeed';
        func_exp = 'reg_goal(X,glm_y,shuffle_time)';    
        
    case 'goaldist_accspeed_linear'
        X = [alldist' allacc_speed'];
        func_exp = 'twoFactor_linear(X,glm_y,shuffle_time)';   
        
    case 'goaldist_error_linear'
        X = [alldist' all_error'];
        func_exp = 'twoFactor_linear(X,glm_y,shuffle_time)'; 
        
     case  'goaldist_pathdist_linear'
       X = [alldist' allpath'];         
       func_exp = 'twoFactor_linear(X,glm_y,shuffle_time)'; 

     case 'goal2egde'        
        X = [ allgoal2edge'];
        func_exp = 'twoFactor_full(X,glm_y,shuffle_time)';  
end


for ifreq = 1:size(allpow,1)
    
    glm_y = zscore(allpow(ifreq,:))';
    
    [beta,shuf_data,z_data,~,beta_name] = eval(func_exp);
    
    all_beta(ifreq,:) = beta;
    
    all_shuf{ifreq} = shuf_data;
    
    all_z = [all_z; z_data];
    
    all_beta_name{ifreq} = beta_name; 
    
end

%% make saves

retrieval_eopch.beta = all_beta;retrieval_eopch.z = all_z;
retrieval_eopch.shuf_beta = all_shuf;
retrieval_eopch.betaName = all_beta_name;
retrieval_eopch.pow = allpow;
retrieval_eopch.alltrl = trls;
retrieval_eopch.allspeed = allspeed;
retrieval_eopch.alledg = alledg;
retrieval_eopch.dist = alldist;
retrieval_eopch.alltim = alltim;
retrieval_eopch.allpath = allpath;
retrieval_eopch.all_edge_dist = all_edge_dist;
retrieval_eopch.allgoal2edge = allgoal2edge;
retrieval_eopch.allacc_speed = allacc_speed;

cfg.dis_type = dis_type;
cfg.goalLoc = goalLoc_type;
cfg.stage = stage;
cfg.cond = cond;
cfg.error_thr = error_thr;
cfg.regression_type = regression_type;
cfg.shuffle_time = shuffle_time;

if ~exist(save_path,'dir')
    
    mkdir(save_path)
    
end

save([save_path '/' 'sub' num2str(subID) '_' num2str(chanID) ],'retrieval_eopch','cfg','-v7.3')

end