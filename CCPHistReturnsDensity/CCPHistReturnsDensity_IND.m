clc
clear
load('CCPData.mat')
%% Sort CCs and calculate correlation matrix
[b, ix]           = sort(nanmean(CC_CAP), 'descend');
CC_RET_MAX        = CC_RET_wins(:, ix(1:11));
CC_TICK_MAX       = CC_TICK(:, ix(1:11));
[CORR,P]          = corrcoef([CC_RET_MAX, IND_RET]);
%% Plot of densities of Top-10 CCs vs normal distribution
rainbow = linspecer(10);
r05     = mean(CC_RET_MAX(:,1))+std(CC_RET_MAX(:,1)).*randn(1000000,1);
pfig    = figure
hold on
ylim([0 25]);
xlim([-0.2 0.2]);
set(gca,'FontSize',20)
pfig = histogram(r05, 100, 'FaceColor', 'w', 'Normalization',  'pdf')
 for i = 1:10
[f,xi] = ksdensity(CC_RET_MAX(:,i));
plot(xi,f, 'Color', rainbow(i, :), 'LineWidth', 2)
 end
[f_ind,xi_ind] = ksdensity(IND_RET(:,5));
ylabel('Density'), title('Density of Top 10 Cryptos')
hold off
saveas(pfig, strcat('PDF_TOP_10CC','.fig'));
saveas(pfig, strcat('PDF_TOP_10CC','.pdf'));
%% Plot of densities of Traditional assets vs normal distribution
close all
rainbow = linspecer(30);
F_CC = [];
x_CC = [];
F_IND = [];
x_IND = [];
norm_IND     = mean(IND_RET(:,5))+std(IND_RET(:,5)).*randn(1000000,1);
norm_CC      = mean(CC_RET_MAX(:,1))+std(CC_RET_MAX(:,1)).*randn(1000000,1);
pfig    = figure
subplot(1,2,1)
hold on
%ylim([0 60]);
%xlim([-0.2 0.2]);
set(gca,'FontSize',20)
histogram(norm_IND, 100, 'FaceColor', 'w', 'Normalization',  'pdf' )
 for j = 1:size(IND_RET, 2)
p = gkdeb(IND_RET(:,j))
[f,xi] = ksdensity(IND_RET(:,j),  'function','pdf');
%histogram(IND_RET(:,i), 'FaceColor', rainbow(i, :), 'Normalization',  'probability' )
F_IND = [F_IND; f];
x_IND = [x_IND; xi];
%plot(p.x,p.pdf,'Color', rainbow(i, :), 'LineWidth', 2);
plot(xi,f, 'Color', rainbow(j, :), 'LineWidth', 2)
 end

%[f_ind,xi_ind] = ksdensity(IND_RET(:,5));
ylabel('Density'), title('Density of daily returns 16 traditional assets')

hold off

subplot(1,2,2)
hold on
%ylim([0 600]);
xlim([-0.2 0.2]);
set(gca,'FontSize',20)
 histogram(norm_CC, 100, 'FaceColor', 'w', 'Normalization',  'pdf')
 for i = 1:10
[f,xi] = ksdensity(CC_RET_MAX(:,i), 'function','pdf');
plot(xi,f, 'Color', rainbow(j+i, :), 'LineWidth', 2);
%histogram(CC_RET_MAX(:,i), 'FaceColor', rainbow(i, :), 'Normalization',  'probability' )
F_CC = [F_CC; f];
x_CC = [x_CC; xi];
 end

%[f_ind,xi_ind] = ksdensity(IND_RET(:,5));
ylabel('Density'), title('Density of daily returns Top 10 Cryptos')
hold off
orient(pfig,'landscape')
saveas(pfig, strcat('PDF_INDEX_CC','.fig'));
saveas(pfig, strcat('PDF_INDEX_CC','.png')); 
saveas(pfig, strcat('PDF_INDEX_CC','.eps')); 

%%
rng('default')  % For reproducibility
x = [randn(30,1); 5+randn(30,1)];
%Plot the estimated density.

[f,xi] = ksdensity(x); 
figure
plot(xi,f);