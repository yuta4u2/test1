
clc
clear all
close all

% load the data
startdate = '01/01/1994';
enddate = '01/01/2019';
f = fred
Y_jp = fetch(f,'JPNRGDPEXP',startdate,enddate)
y_jp = log(Y_jp.Data(:,2));
q = Y_jp.Data(:,1);

Y_uk = fetch(f,'NGDPRSAXDCGBQ',startdate,enddate)
y_uk = log(Y_uk.Data(:,2));

T = size(y_jp,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

trend_jp = A\y_jp;
trend_uk = A\y_uk;

% detrended GDP
cycle_jp = y_jp-trend_jp;
cycle_uk = y_uk-trend_uk;

% plot detrended GDP
dates = 1954:1/4:2022.1/4; zerovec = zeros(size(y_jp));
figure
title('Detrended log(real GDP) 1954Q1-2022Q1'); hold on
plot(q, cycle_jp,'r')
plot(q, cycle_uk,'b')
datetick('x', 'yyyy-qq')
legend({'JP','UK'},'Location','southwest')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
ysd_jp = std(cycle_jp)*100;
ysd_uk = std(cycle_uk)*100;
corryc = corrcoef(cycle_jp(1:T),cycle_uk(1:T)); corryc = corryc(1,2);

disp(['Percent standard deviation of detrended log real GDP for Japan: ', num2str(ysd_jp),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP for Great Britain: ', num2str(ysd_uk),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP for Japan and Great Britain: ', num2str(corryc),'.']);



