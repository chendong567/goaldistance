%% calculate the statstics of beta

% 17-left hippo
% 53- right hippo

% 2006-right enterhinal
% 1006-left enterhinal

% 18-left amygdala
% 54-right amygdala

clc
close all
clear


%% parameters

foi_name = {'beta','low_theta','high_theta','gamma','high_gamma2'};

foi_ind = [23 19 9 26 31];

data_path = '';

beta_type = 'raw';

suffix = '';

betaCoef = [2];

[~,bandNames] = get_freq_name('bandpass');

region_now = 'right_hippo';

%% statics

for ifreq = 1:length(foi_name)
    
    freq_now = foi_ind(ifreq);
    
    freq_band = bandNames{freq_now};
    
    load([region_now])
       
    sub_info = roi_info(:,1);
    
    contact_info = roi_info(:,2);
    
    roi_beta = extract_beta(data_path,sub_info,contact_info,beta_type,suffix,betaCoef);
    
    % t test
    sub_beta = average_chan(roi_beta,sub_info);
    
    sub_beta = sub_beta(:,freq_now);

    subplot(1,2,1)

    barwitherr(std(sub_beta)./sqrt(length(sub_beta)),mean(sub_beta))
    
    [h,p,ci,stats] = ttest(sub_beta)
    
    xlabel([freq_band 'hz'])

    % lme statics
    data_good = roi_beta(:,freq_now);
    
    tbl = table(data_good,sub_info,'variable',{'beta','sub'});
    
    tbl.sub = nominal(tbl.sub);
    
    fit_reult = fitlme(tbl,'beta~1+(1|sub)')
    
    [powBeta,powBetanames,powStats] = fixedEffects(fit_reult);

    [Beta,Betanames,Stats] = randomEffects(fit_reult);

    Z = designMatrix(fit_reult,'random');

    Ycorr_bad = tbl.beta-Z*Beta;
    
    subplot(1,2,2)
    
    barwitherr(std(Ycorr_bad)./sqrt(length(Ycorr_bad)),mean(Ycorr_bad))

    xlabel([freq_band 'hz'])
    
end