% This code creates Figure 7
% plot rho(*) with different IAM damage profiles
close all; clear; 
% clc

% cd 'C:\Users\NAMEX\Documents\discounting'
figName_save = 'Fig7_save.png';

%% set parameters and import climate damages profiles
rc = 0.03; % consumption rate
v = 1.44; % shadow price of capital (SPC)

% define function rho(t), where x = theta0/theta1
rhoT = @(x,tt) (1+rc)*(x).^(1./tt)-1;

options = optimoptions(@fminunc,'Display','off');

% import climate damages
load 'climate_damages_TS.mat'

width = 900; height = 500; % set figure size
fontSize = 12; % set font size for figure

%% NAS (2017) scenario
% linear interpolation (NAS, DICE, FUND)
year_s = NAS_case.year; Dt_s = NAS_case.SCN0;
year = linspace(year_s(1),year_s(end), year_s(end)-year_s(1)+1);
Bt = interp1(year_s,Dt_s,year); % linear interpolation
t = year-2015; % time index (year 2015 as t=0)

rho_t = rhoT(v,t);
npv = sum(Bt./(1+rho_t).^t); % compute npv with rho(t)
minObj = @(x) norm(sum(Bt./(1+x).^t)-npv);% solve rho_star
rho_star_hi = fminunc(minObj,rc,options);   % upper bound of rho(*)

rho_t = rhoT(1/v,t);
npv = sum(Bt./(1+rho_t).^t);
minObj = @(x) norm(npv - sum(Bt./(1+x).^t));
rho_star_lo = fminunc(minObj,rc,options);% lower bound of rho(*)

fprintf('\n=== NAS (2017), t=0 for year 2015 ====\n')
fprintf('rho(*) low = %.2f%%  high = %.2f%%\n',100*rho_star_lo,100*rho_star_hi)

% ============ plot rho(*) range for v ============================%
fig1 = figure('Name','SDR ranges','Position',[10 50 width height]);
hold on
h = rectangle('Position',[2 100*rho_star_lo 1 100*(rho_star_hi-rho_star_lo)]);
h.EdgeColor = [0.8510 0.3255 0.0980];
h.LineWidth = 3;
h.FaceColor = 'w';
hold off

%% DICE 2020 scenarios
for usg = 1:5
    year_s = DICE_2020.year;
    Dt_s = DICE_2020{:,usg+1}; % MD for selected USG
    % linear interpolation (NAS, DICE, FUND)
    year = linspace(year_s(1),year_s(end), year_s(end)-year_s(1)+1);
    Bt = interp1(year_s,Dt_s,year); % linear interpolation
    t = year-2020;  % time index (year 2020 as t=0)
    
    rho_t = rhoT(v,t);
    npv = sum(Bt./(1+rho_t).^t); % compute npv with rho(t)
    minObj = @(x) norm(sum(Bt./(1+x).^t)-npv);% solve rho_star
    rho_star_hi = fminunc(minObj,rc,options);   % upper bound of rho(*)
    
    rho_t = rhoT(1/v,t);
    npv = sum(Bt./(1+rho_t).^t);
    minObj = @(x) norm(npv - sum(Bt./(1+x).^t));
    rho_star_lo = fminunc(minObj,rc,options);% lower bound of rho(*)
    
    fprintf('\n=== DICE 2020 (USG %.f), t=0 for year 2020 ====\n',usg)
    fprintf('rho(*) low = %.2f%%  high = %.2f%%\n',100*rho_star_lo,100*rho_star_hi)
    
    % ============ plot rho(*) range for v ============================%
    eColor = [0  0  1];
    fColor = [0    0.4471    0.7412];
    figure(fig1)
    hold on
    h = rectangle('Position',[(3+2*usg) 100*rho_star_lo 1 100*(rho_star_hi-rho_star_lo)]);
    h.EdgeColor = eColor;
    h.LineWidth = 3;
    h.FaceColor = fColor;
    h.FaceColor(4) = 1-0.2*(usg-1);
    hold off
    
end
%% FUND 2020 scenarios
for usg = 1:5
    year_s = FUND_2020.year;
    Dt_s = FUND_2020{:,usg+1}; % MD for selected USG
    % linear interpolation (NAS, DICE, FUND)
    year = year_s; % one-year interval
    Bt = Dt_s;
    t = year-2020;  % time index (year 2020 as t=0)
    
    rho_t = rhoT(v,t);
    npv = sum(Bt./(1+rho_t).^t); % compute npv with rho(t)
    minObj = @(x) norm(sum(Bt./(1+x).^t)-npv);% solve rho_star
    rho_star_hi = fminunc(minObj,rc,options);   % upper bound of rho(*)
    
    rho_t = rhoT(1/v,t);
    npv = sum(Bt./(1+rho_t).^t);
    minObj = @(x) norm(npv - sum(Bt./(1+x).^t));
    rho_star_lo = fminunc(minObj,rc,options);% lower bound of rho(*)
    
    fprintf('\n=== FUND 2020 (USG %.f), t=0 for year 2020 ====\n',usg)
    fprintf('rho(*) low = %.2f%%  high = %.2f%%\n',100*rho_star_lo,100*rho_star_hi)
    
    % ============ plot rho(*) range for v ============================%
    eColor = [0.4941    0.1843    0.5569];
    fColor = [0.7176    0.2745    1.0000];
    figure(fig1)
    hold on
    h = rectangle('Position',[(14+2*usg) 100*rho_star_lo 1 100*(rho_star_hi-rho_star_lo)]);
    h.EdgeColor = eColor;
    h.LineWidth = 3;
    h.FaceColor = fColor;
    h.FaceColor(4) = 1-0.2*(usg-1);
    hold off
end
%% PAGE 2020 scenarios
for usg = 1:5
    year_s = PAGE_2020.year; 
    len_s = [10;10;10;10;20;20;100;55;50]; 
    Dt_s = PAGE_2020{:,usg+1}; % MD for selected USG
    % no need for linear interpolation
    year = year_s;  Bt = Dt_s.*len_s;  
    t = year-2020;  % time index (year 2020 as t=0)
    
    rho_t = rhoT(v,t);
    npv = sum(Bt./(1+rho_t).^t); % compute npv with rho(t)
    minObj = @(x) norm(sum(Bt./(1+x).^t)-npv);% solve rho_star
    rho_star_hi = fminunc(minObj,rc,options);   % upper bound of rho(*)
    
    rho_t = rhoT(1/v,t);
    npv = sum(Bt./(1+rho_t).^t);
    minObj = @(x) norm(npv - sum(Bt./(1+x).^t));
    rho_star_lo = fminunc(minObj,rc,options);% lower bound of rho(*)
    
    fprintf('\n=== PAGE 2020 (USG %.f), t=0 for year 2020 ====\n',usg)
    fprintf('rho(*) low = %.2f%%  high = %.2f%%\n',100*rho_star_lo,100*rho_star_hi)
    
    % ============ plot rho(*) range for v ============================%
    eColor = [0.4667    0.6745    0.1882];
    fColor = [0.3922    0.8314    0.0745];
    figure(fig1)
    hold on
    h = rectangle('Position',[(25+2*usg) 100*rho_star_lo 1 100*(rho_star_hi-rho_star_lo)]);
    h.EdgeColor = eColor;
    h.LineWidth = 3;
    h.FaceColor = fColor;
    h.FaceColor(4) = 1-0.2*(usg-1);
    hold off
    
end
%% format figure
figure(fig1) 
hold on
ylim([2 4])
line([0 40],100*[rc rc],...
    'LineWidth',1.5,'LineStyle',':','Color','k')
set(gca,'xtick',[2 5 7 9 11 13 16 18 20 22 24 27 29 31 33 35])
set(gca,'xticklabel',[])
ytickformat(gca, 'percentage');
ylabel('Social Discount Rate, \rho*','FontSize',fontSize)
title(sprintf('Shadow Price of Capital v = %.2f',v),...
    'FontSize',fontSize)

f = 1.95; % position of text labels
text(2,f,'NAS','Color',[0.8510 0.3255 0.0980],'FontSize',fontSize,'FontWeight','Bold')
text(9,f,'DICE','Color',[0  0  1],'FontSize',12,'FontWeight','Bold')
text(20,f,'FUND','Color',[0.4941 0.1843 0.5569],'FontSize',12,'FontWeight','Bold')
text(31,f,'PAGE','Color',[0.4667 0.6745 0.1882],'FontSize',12,'FontWeight','Bold')
hold off

%% save figure
saveas(fig1,figName_save)