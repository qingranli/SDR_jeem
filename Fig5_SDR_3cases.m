% This code creates Figure 5 with different rc.
close all; clear; 
% clc

% cd 'C:\Users\NAMEX\Documents\discounting'
figName_save = 'Fig5_save.png';

%% set parameters
rc_choice = [0.05 0.03 0.02]; % consumption rate
v_range = 1:0.02:2.4; % shadow price of capital (SPC)

% define function rho(t), where x = theta0/theta1
rhoT = @(rc,x,tt) (1+rc).*(x).^(1./tt)-1;

rho_star_hi = zeros(length(v_range), length(rc_choice)); % upper bound of rho(*)
rho_star_lo = zeros(length(v_range), length(rc_choice)); % lower bound of rho(*)
gap = zeros(length(v_range),2,length(rc_choice));

%% import climate damages
load 'climate_damages_TS.mat'

% select data NAS(2017)
% NAS (2017) plots damages ($2007) from 1 ton CO2 emission in 2015.
year_s = NAS_case.year;
Dt_s = NAS_case.SCN0; % $/ton CO2

% compute marginal damages between years via linear interpolation
year = linspace(year_s(1),year_s(end), year_s(end)-year_s(1)+1);
Dt = interp1(year_s,Dt_s,year); % linear interpolation

t = year-2015; % time index (year 2015 as t=0)
cpiCF = 1.2536; % 100$ in 2007 = 125.36$ in 2020

%% For each rc {...compute rho(*)...}
options = optimoptions(@fminunc,'Display','off');

for k = 1:length(rc_choice)
    rc = rc_choice(k); % set consumer rate    
    
    for i = 1:length(v_range)
        % solve rho_star_hi ----------------
        rho_t = rhoT(rc,v_range(i),t);
        npv = sum(Dt./(1+rho_t).^t);
        minObj = @(x) norm(sum(Dt./(1+x).^t)-npv);
        rho_star_hi(i,k) = fminunc(minObj,rc,options);
        clear rho_t npv
        
        % solve rho_star_lo ----------------
        rho_t = rhoT(rc,1/v_range(i),t);
        npv = sum(Dt./(1+rho_t).^t);
        minObj = @(x) norm(sum(Dt./(1+x).^t)-npv);
        rho_star_lo(i,k) = fminunc(minObj,rc,options);
        clear rho_t npv

    end % end for i
    
    gap(:,:,k) = 100*[rho_star_lo(:,k) rho_star_hi(:,k)-rho_star_lo(:,k)];
end
fprintf('for each rc completed ...\n')

%% generate Fig 5: SDR* depending on rc
width = 900; height = 500; % set figure size
fontSize = 12; % set font size for figure

lgd_label = ["r_c = 5%", "r_c = 3%", "r_c = 2%"];
lgd_h_save = [];

figure('Position',[0 0 width height]);
ax = axes;
hold on
for k = 1:length(rc_choice)
    h = area(v_range,gap(:,:,k),'LineStyle','none');
    h(1).FaceAlpha = 0;
    h(2).FaceAlpha = 0.4;
    h(2).DisplayName = lgd_label(k);
    
    plot(v_range,rho_star_hi(:,k)*100,'k:','LineWidth',1);
    plot(v_range,rho_star_lo(:,k)*100,'k:','LineWidth',1);
    
    lgd_h_save(k) =h(2); % save object for legend
end
set(ax,'YLim',[1, 9]) % set ylimit
ytickformat(ax, 'percentage')
ax.YGrid = 'on';
xlabel('Shadow Price of Capital, v','FontSize',fontSize)
ylabel('Social Discount Rate, \rho*','FontSize',fontSize)

lgd = legend(lgd_h_save,'Location','Northwest');
set(lgd,'NumColumns',1,'FontSize',fontSize);
title(lgd,'Consumer Rate');

%% save figure
saveas(gcf,figName_save)