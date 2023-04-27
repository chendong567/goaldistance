clc
clear
close all

%% parameter

load('/tauRetrieval_good_log65.mat')
load('/right_hippo.mat');

%% thr tau data
knee_thr = 12;
tao_now = tau';
tau_lim = floor(1000/2/pi/knee_thr);
ind = tao_now<tau_lim;

y_now = roi_info(:,5);
sub_now = roi_info(:,1);
chan_now = roi_info(:,2);

tao_now = tao_now(ind);
y_now = y_now(ind);
sub_now = sub_now(ind);
chan_now = chan_now(ind);

%% get beta
suffix = '';
betaCoef = 2;
beta_type = 'raw';
beta_path = '';
roi_beta = extract_beta(beta_path,sub_now,chan_now,beta_type,suffix,betaCoef);
beta_now = roi_beta(:,9);
%% lme statics tau and y

tbl = table(tao_now,beta_now,sub_now,y_now,'Variable',{'tao','beta','sub','y_coord'});

fit_reult = fitlme(tbl,'tao~y_coord+(1|sub)')

[powBeta,powBetanames,powStats] = fixedEffects(fit_reult);
[Beta,Betanames,Stats] = randomEffects(fit_reult);

Z = designMatrix(fit_reult,'random');
tao_fitted = tbl.tao-Z*Beta;

coef = double(fit_reult.Coefficients(2,2));
pval = double(fit_reult.Coefficients(2,6));

% plot data
figure

scatter(tbl.y_coord,tao_fitted)

lsline

sub_num = length(unique(sub_now));
chan_num = size(sub_now,1);
xlabel('y coord'); ylabel(['tao']);
title([ ' sub' num2str(sub_num) ' chan' num2str(chan_num) ])

% label statics
y_lim = ylim; x_lim = xlim;
yt = diff(y_lim)./5*4+y_lim(1);
xt = diff(x_lim)./5*4+x_lim(1);
text(xt,yt,['r = ' num2str(coef) ' p = ' num2str(pval)])
set(gca,'fontsize',12)

%% lme statics tau and beta

fit_reult = fitlme(tbl,'tao~beta+(1|sub)')

[powBeta,powBetanames,powStats] = fixedEffects(fit_reult);
[Beta,Betanames,Stats] = randomEffects(fit_reult);

Z = designMatrix(fit_reult,'random');
tao_fitted = tbl.tao-Z*Beta;

coef = double(fit_reult.Coefficients(2,2));
pval = double(fit_reult.Coefficients(2,6));

% plot data
figure

scatter(tao_fitted,tbl.beta)

lsline

sub_num = length(unique(sub_now));
chan_num = size(sub_now,1);
xlabel('tau'); ylabel(['beta' ]);
title([ ' sub' num2str(sub_num) ' chan' num2str(chan_num) ])

% label statics
y_lim = ylim; x_lim = xlim;
yt = diff(y_lim)./5*4+y_lim(1);
xt = diff(x_lim)./5*4+x_lim(1);
text(xt,yt,['r = ' num2str(coef) ' p = ' num2str(pval)])
set(gca,'fontsize',12)



