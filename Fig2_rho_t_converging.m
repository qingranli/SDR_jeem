% This code creats Figure 2
% Range of possible social discount rates versus time horizon
close all; clear
% clc

% cd 'C:\Users\NAMEX\Documents\discounting'
figName_save = 'Fig2_save.png';

%% set parameters 
rc = 0.03; % consumption rate
% shadow price of capital (SPC)
v1 = 1.44; % SPC (low)
v2 = 2.33; % SPC (high)

% time horizon
t = 1:0.5:100; t = t(:);

% define function rho(t), where x = theta0/theta1
rhoT = @(x,tt) (1+rc)*(x).^(1./tt)-1; 

% compute lower bound of rho(t) 
rho1_lo = rhoT(1/v1, t);
rho2_lo = rhoT(1/v2, t);

% compute upper bound of rho(t)
rho1_hi = rhoT(v1, t);
rho2_hi = rhoT(v2, t);

%% generate figure
fontSize = 12; % set font size in figure
y_lim = 50; x_lim = 50;
figure('Name','Fig2','Position',[0 0 900 500])
ax = axes;
hold on
h1 = plot(t,rho1_hi*100,'r-','LineWidth',2);
h2 = plot(t,rho2_hi*100,'r-.','LineWidth',2);
h3 = plot(t,rho1_lo*100,'b-','LineWidth',2);
h4 = plot(t,rho2_lo*100,'b-.','LineWidth',2);

lgd = legend([h1 h2 h3 h4],...
    '\theta_0/\theta_t = v = 1.44',...
    '\theta_0/\theta_t = v = 2.33',...
    '\theta_0/\theta_t = 1/v = 1/1.44',...
    '\theta_0/\theta_t = 1/v = 1/2.33',...
    'FontSize',fontSize,'EdgeColor','w');
set(ax,'YLim',[-y_lim, y_lim],'XLim',[0 x_lim])
ytickformat(ax, 'percentage')
ax.YGrid = 'on';
xlabel('Time horizon to realized benefits, t','FontSize',fontSize)
ylabel('Social Discount Rate, \rho_t','FontSize',fontSize)

%% save figure
saveas(gcf,figName_save)