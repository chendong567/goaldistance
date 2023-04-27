clc
clear
close all

%% parameter

load('all_peaks.mat')
load('tauRetrieval_good_log65.mat')
load('right_hippo.mat');

%%

ind = ~isnan(all_theta_peak);

y_now = roi_info(:,5);
sub_now = roi_info(:,1);
chan_now = roi_info(:,2);

theta_peak = all_theta_peak(ind);
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

tbl = table(theta_peak,beta_now,sub_now,y_now,'Variable',{'theta_peak','beta','sub','y_coord'});

fit_reult = fitlme(tbl,'theta_peak~y_coord+(1|sub)')

[powBeta,powBetanames,powStats] = fixedEffects(fit_reult);
[Beta,Betanames,Stats] = randomEffects(fit_reult);

Z = designMatrix(fit_reult,'random');
theta_peak_fitted = tbl.theta_peak-Z*Beta;

coef = double(fit_reult.Coefficients(2,2));
pval = double(fit_reult.Coefficients(2,6));

% plot data
figure

scatter(y_now,theta_peak_fitted)

lsline

sub_num = length(unique(sub_now));
chan_num = size(sub_now,1);
xlabel('y coord'); ylabel(['theta peak']);
title([ ' sub' num2str(sub_num) ' chan' num2str(chan_num) ])

% label statics
y_lim = ylim; x_lim = xlim;
yt = diff(y_lim)./5*4+y_lim(1);
xt = diff(x_lim)./5*4+x_lim(1);
text(xt,yt,['r = ' num2str(coef) ' p = ' num2str(pval)])
set(gca,'fontsize',12)

%% lme statics tau and beta

fit_reult = fitlme(tbl,'theta_peak~beta+(1|sub)')

[powBeta,powBetanames,powStats] = fixedEffects(fit_reult);
[Beta,Betanames,Stats] = randomEffects(fit_reult);

Z = designMatrix(fit_reult,'random');
theta_peak_fitted = tbl.theta_peak-Z*Beta;

coef = double(fit_reult.Coefficients(2,2));
pval = double(fit_reult.Coefficients(2,6));

% plot data
figure

scatter(theta_peak_fitted,beta_now)

lsline

sub_num = length(unique(sub_now));
chan_num = size(sub_now,1);
xlabel('theta peak'); ylabel(['beta' ]);
title([ ' sub' num2str(sub_num) ' chan' num2str(chan_num) ])

% label statics
y_lim = ylim; x_lim = xlim;
yt = diff(y_lim)./5*4+y_lim(1);
xt = diff(x_lim)./5*4+x_lim(1);
text(xt,yt,['r = ' num2str(coef) ' p = ' num2str(pval)])
set(gca,'fontsize',12)
