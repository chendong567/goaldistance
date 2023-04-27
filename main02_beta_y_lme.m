%% cal the relationship of beta and y coord using lme

clear
close all
clc
% 17-left hippo
% 53- right hippo

%% extract contact

roi_name_all = {'right_hippo','left_hippo','right_hippo','left_hippo'};

data_path_all = {};

ylabels = {'right good obj','left good obj','right bad obj','left bad obj'};

for iregion = 1:length(roi_name_all)
    
roi_name = roi_name_all{iregion};    

data_path = data_path_all{iregion};

load([roi_name])

sub_info = roi_info(:,1);

contact_info = roi_info(:,2);

freq_ind = 9;

%% extract beta

beta_type = 'raw';

roi_name_fig = strrep(roi_name,'_','-');

suffix = '';

betaCoef = [2];

[~,bandNames] = get_freq_name('bandpass');

roi_beta = extract_beta(data_path,sub_info,contact_info,beta_type,suffix,betaCoef);


%% lme

tbl = table(roi_beta(:,freq_ind),roi_info(:,1),roi_info(:,5),'Variable',{'beta','sub','y_coord'});

fit_reult = fitlme(tbl,'beta~y_coord+(1|sub)')

coef = round(1000*double(fit_reult.Coefficients(2,2)))./1000;

p_val= round(1000*double(fit_reult.Coefficients(2,6)))./1000;

[powBeta,powBetanames,powStats] = fixedEffects(fit_reult);

[Beta,Betanames,Stats] = randomEffects(fit_reult);

%% plot fitted effect

Z = designMatrix(fit_reult,'random');

Ycorr = tbl.beta-Z*Beta;

load('example4UsePyCMap/PyCMap.mat')

my_color = PyCMap.Qualitative.my_color;

[b,m,n] = unique(tbl.sub);

figure

for ii = 1:length(m)
    
    indivi_beta = Ycorr(n==ii);
    
    y = roi_info(n==ii,5);
    
    scatter(y,indivi_beta,10,my_color(ii,:),'filled');
    
    hold on
    
    xlabel('y coord')
    
    ylabel('beta')
    
end

title([' beta = ' num2str(coef) ' p = ' num2str(p_val)])

ylabel([ylabels{iregion} ' beta'])

end