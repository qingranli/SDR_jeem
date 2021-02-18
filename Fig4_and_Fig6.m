% This code creates Figure 4 and Figure 6.
close all; clear; 
% clc

% cd 'C:\Users\NAMEX\Documents\discounting'
figName4_save = 'Fig4_save.png';
figName6_save = 'Fig6_save.png';

%% set parameters for computing SDR (rho*)
rc = 0.03; % consumption rate of return
v_range = 1:0.02:3; % shadow price of capital (SPC)

% define function rho(t), where x = theta0/theta1
rhoT = @(x,tt) (1+rc)*(x).^(1./tt)-1;

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

%% plot Fig 4: undiscounted climate damages
width = 900; height = 500; % set figure size
fontSize = 12; % set font size for figure
fig4 = figure('Name','Fig4','Position',[0 0 width height]);
ax = axes;
h1 = semilogy(year,Dt,'LineWidth',2);
ax.YGrid = 'on';
ax.XMinorTick = 'on';
xlabel('Year','FontSize',fontSize)
ylabel('Undiscounted climate damages ($)','FontSize',fontSize)
xlim([2010 2310])

%% compute upper and lower bound of rho(*) & SC-CO2
rho_star_hi = 0*v_range; % upper bound of rho(*)
rho_star_lo = 0*v_range; % lower bound of rho(*)
scc_hi = 0*v_range; % upper bound of SC-CO2
scc_lo = 0*v_range; % lower bound of SC-CO2

options = optimoptions(@fminunc,'Display','off');

for i = 1:length(v_range)
    % solve rho_star_hi ----------------
    rho_t = rhoT(v_range(i),t);
    npv = sum(Dt./(1+rho_t).^t);
    minObj = @(x) norm(sum(Dt./(1+x).^t)-npv);
    rho_star_hi(i) = fminunc(minObj,rc,options);
    clear rho_t npv
    
    % solve rho_star_lo ----------------
    rho_t = rhoT(1/v_range(i),t);
    npv = sum(Dt./(1+rho_t).^t);
    minObj = @(x) norm(sum(Dt./(1+x).^t)-npv);
    rho_star_lo(i) = fminunc(minObj,rc,options);
    clear rho_t npv
    
    % compute SC-CO2 ($ per metric ton) -------------
    scc_lo(i) = cpiCF*1.102*sum(Dt./(1+rho_star_hi(i)).^t);
    scc_hi(i) = cpiCF*1.102*sum(Dt./(1+rho_star_lo(i)).^t);
    
end % end for i

% gap between upper and lower bounds
rho_star_gap = 100*[rho_star_lo' rho_star_hi'-rho_star_lo'];
scc_gap = [scc_lo' scc_hi'-scc_lo'];

% SC-CO2 when SDR = 3% vs 7%
scc1 = cpiCF*1.102*sum(Dt./(1+0.03).^t);
scc2 = cpiCF*1.102*sum(Dt./(1+0.07).^t);

%% plot part of Fig 5: upper and lower bounds of rho(*)
fig5 = figure('Name','Fig5_SDR_case0','Position',[0 20 width height]);
ax = axes;
hold on
h2 = area(v_range,rho_star_gap,'LineStyle','none');
h2(1).FaceAlpha = 0;
h2(2).FaceAlpha = 0.4;    
plot(v_range,rho_star_hi*100,'k:','LineWidth',1);
plot(v_range,rho_star_lo*100,'k:','LineWidth',1);
ytickformat(ax, 'percentage')
ax.YGrid = 'on';
xlabel('Shadow Price of Capital, v','FontSize',fontSize)
ylabel('Social Discount Rate, \rho*','FontSize',fontSize)

%% generate Fig 6: upper and lower bounds of SC-CO2
fig6 = figure('Name','Fig6_SC-CO2','Position',[0 50 width height]);
ax = axes;
hold on
h2 = area(v_range,scc_gap,'LineStyle','none');
h2(2).FaceColor = [0.3020    0.7451    0.9333];
h2(1).FaceAlpha = 0;
h2(2).FaceAlpha = 0.4;    

plot(v_range,scc_hi,'k:','LineWidth',1);
plot(v_range,scc_lo,'k:','LineWidth',1);

plot(v_range,0*v_range + scc1,'b--','LineWidth',1.7)
plot(v_range,0*v_range + scc2,'b-.','LineWidth',1.7)
ax.YGrid = 'on';
xlabel('Shadow Price of Capital, v','FontSize',fontSize)
ylabel(sprintf('Social Cost of CO2 \n(2020$ per metric ton emission in 2015)'),'FontSize',fontSize)

% gtext(sprintf('SC-CO2(3%%) = $%.f',scc1),'FontSize',fontSize,'Color','b')
% gtext(sprintf('SC-CO2(7%%) = $%.f',scc2),'FontSize',fontSize,'Color','b')

%% save figures
saveas(fig4,figName4_save)
saveas(fig6,figName6_save)
