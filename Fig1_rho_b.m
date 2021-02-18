% This code creats Figure 1
% social discount rate in Bradford’s two-period model
close all; clear
% clc

% cd 'C:\Users\NAMEX\Documents\discounting'
figName_save = 'Fig1_rho_b.png';

%% set parameters
rc = 0.03; % consumption rate of return
v = 1.44; % shadow price of capital

% ratio of theta0/theta1
theta_ratio = linspace(1/v,v,1000);

% compute rho_b
rho_b = (1+rc).*theta_ratio - 1;

%% generate figure
fontSize = 12; % set font size in figure
y_lim = 60;
figure('Name','Fig1','Position',[0 0 900 500])
ax = axes;
hold on
h1 = area(theta_ratio,rho_b*100,...
    'FaceColor','c','FaceAlpha',0.2,'EdgeAlpha',0);
h2 = plot(theta_ratio,rho_b*100,...
    'LineWidth',2,'Color',[0 0.4471 0.7412]);
set(ax,'YLim',[-y_lim, y_lim],'XLim',[1/v, v],'XTick',(0.7:0.1:v))
ytickformat(ax, 'percentage')
ax.YGrid = 'on';
ax.YMinorTick = 'on';
xlabel('value of \theta_0/\theta_1','FontSize',fontSize)
ylabel('Social Discount Rate, \rho_b','FontSize',fontSize)

%% save figure
saveas(gcf,figName_save)
