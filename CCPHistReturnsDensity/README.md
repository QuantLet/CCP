[<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/banner.png" width="888" alt="Visit QuantNet">](http://quantlet.de/)

## [<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/qloqo.png" alt="Visit QuantNet">](http://quantlet.de/) **CCPHistReturnsDensity_IND** [<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/QN2.png" width="60" alt="Visit QuantNet 2.0">](http://quantlet.de/)

```yaml

Name of QuantLet : CCPHistReturnsDensity

Published in : Risk-based versus target-based portfolio strategies in the cryptocurrency market

Description : 'Plots pdf of top-10 CC returns distributions'

Keywords : crypto, CRIX, cryptocurrency, variance, plot, pdf, returns


See also : 'CCPTests, CCPBootstrap, CCPPerformance_measures, CCPDiversification_measures'

Author : Alla Petukhina

Submitted : June 11 2018 by Alla Petukhina
Datafile : 'CCPData.mat'

Example : 
```

![Picture1](PDF_TOP_10CC.png)

### MATLAB Code
```matlab

clc
clear
load('CCPData.mat')
%% Sort CCs and calculate correlation matrix
[b, ix]           = sort(nanmean(CC_CAP()), 'descend');
CC_RET_MAX        = CC_RET_wins(:,ix(1:11));
CC_TICK_MAX       = CC_TICK(:,ix(1:11));
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
[f_ind,xi_ind] =ksdensity(IND_RET(:,5));
ylabel('Density'), title('Density of Top 10 Cryptos')
hold off
saveas(pfig, strcat('PDF_TOP_10CC','.fig'));
saveas(pfig, strcat('PDF_TOP_10CC','.pdf'))
 ```
automatically created on 2018-06-21
