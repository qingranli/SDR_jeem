% This code computes values in Table 3.
% conditional on rc and tau
% climate profile using NAS (2017)
% convert to $2020 per mt emission in 2015

close all; clear; clc
% cd 'C:\Users\NAMEX\Documents\discounting'

%% set parameters and functions
rc = 0.05; % consumption rate of return
% choices of tax rate
Tax = [0.35 0.45 0.57];

% parameters in the Ramsey model
g = 0.022; % growth rate of productivity
n = 0.01; % growth rate of labor
mu = 0.1; % capital deprecitation rate
a = 0.3; % output elasticity of capital

% investment rate = function of rc and tax
iRate = @(tau) rc./(1-tau);
% savings out of gross income = function of investment rate
sRate = @(r) ((mu+g+n)*a)./(mu + r); % equilibrium
% shadow price of capital = function of savings rate
spc = @(s) (1-s).*(mu+g+n).*a./(s.*(rc+mu-(mu+g+n).*a)); % equilibrium

% define function rho(t), where x = theta0/theta1
rhoT = @(rc,x,tt) (1+rc).*(x).^(1./tt)-1; % function of rho(t)

%% import climate damages
load 'climate_damages_TS.mat'
% select data NAS(2017)
year_s = NAS_case.year;
Dt_s = NAS_case.SCN0;  % 2007$/ton CO2 emission in 2015

% compute damages between years via linear interpolation
year = linspace(year_s(1),year_s(end), year_s(end)-year_s(1)+1);
Dt = interp1(year_s,Dt_s,year); % linear interpolation

t = year-2015; % time index (year 2015 as t=0)
cpiCF = 1.2536; % 100$ in 2007 = 125.36$ in 2020
options = optimoptions(@fminunc,'Display','off');

%% print results on screen
for i = 1:length(Tax)
    tau = Tax(i);
    fprintf('rc = %.2f %%\n',100*rc)
    fprintf('tax: tau = %.f %%\n',100*tau)
    
    ri = iRate(tau);
    fprintf('.....ri = %.1f %%\n',100*ri)
    
    ss = sRate(ri);
    fprintf('.....s* = %.2f \n',ss)
    
    vv = spc(ss);
    fprintf('.....v* = %.2f \n',vv)
    
    % solve rho_star (high) & SCC (low) ----------------
    rho_t = rhoT(rc,vv,t);
    npv = sum(Dt./(1+rho_t).^t);
    minObj = @(x) norm(sum(Dt./(1+x).^t)-npv);
    rho_star_hi = fminunc(minObj,rc,options);
    scc_lo = cpiCF*1.102*sum(Dt./(1+rho_star_hi).^t);
    
    % solve rho_star (low) & SCC (high) -------------
    rho_t = rhoT(rc,1/vv,t);
    npv = sum(Dt./(1+rho_t).^t);
    minObj = @(x) norm(sum(Dt./(1+x).^t)-npv);
    rho_star_lo = fminunc(minObj,rc,options);
    scc_hi =  cpiCF*1.102*sum(Dt./(1+rho_star_lo).^t);
    
    fprintf('.....rho* = %.2f%% -- %.2f%% \n',...
        100*rho_star_lo, 100*rho_star_hi)
    
    fprintf('.....SCC* = %.1f -- %.1f \n\n',...
        scc_lo, scc_hi)
end