%% Plots of surfaces of efficient frontiers

load('CCP_liquidity_constraint_yes_wins_yesrebal_daily26101-Jan-2015_29-Dec-2017_55_newCVAR.mat')
 PRSK_LIBRO = PRSK;
 PRET_LIBRO = PRET;
 PRSK_CVAR_LIBRO = PRSK_CVAR;
 PRET_CVAR_LIBRO = PRET_CVAR;
load('CCP_liquidity_constraint_no_wins_yesrebal_daily26101-Jan-2015_29-Dec-2017_55_newCVAR.mat')
close all
DATE_mat = repmat(DATE(end-outsample_width+1:end)',30,1);
retlim = 0.03
risklim = 0.2
pfig = figure
colormap('jet')



subplot(2,3,1)

surf( PRSK_IND,  DATE_mat, PRET_IND,  'EdgeColor', 'none' )%; hold on%blue

colorbar('EastOutside')
title('MV-traditional assets')
datetick('y','mmmyy')
grid off
xlabel('Risk')
ylabel('Date')
zlabel('Return')
 xlim([0 risklim])
 zlim([0 retlim])
 caxis([0 retlim])


subplot(2,3,4)
surf( PRSK_IND_CVAR,  DATE_mat, PRET_IND_CVAR,  'EdgeColor', 'none' ); hold on%blue
xlabel('Risk')
ylabel('Date')
zlabel('Return')

 xlim([0 risklim])
 zlim([0 retlim])
 caxis([0 retlim])
datetick('y','mmmyy')
title('MCVaR-traditional assets')
colorbar('EastOutside')
grid off

subplot2 = subplot(2,3,2)

surf(  PRSK,   DATE_mat,  PRET, 'EdgeColor', 'none'); hold on
xlabel('Risk')
ylabel('Date')
zlabel('Return')

 xlim([0 risklim])
 zlim([0 retlim])
 caxis([0 retlim])
datetick('y','mmmyy')

caxis([0 retlim])


title('MV-traditional assets & Cryptos')
colorbar('EastOutside')
grid off


subplot3 = subplot(2,3,5) 
surf(  PRSK_CVAR,   DATE_mat,  PRET_CVAR, 'EdgeColor', 'none' );hold on 

%ylim([0 0.2])
xlabel('Risk')
ylabel('Date')
zlabel('Return')
 xlim([0 risklim])
 zlim([0 retlim])
 caxis([0 retlim])
%zlim([0 max(max(PRET_CVAR))])
 title('MCVaR-traditional assets & Cryptos')
colorbar('EastOutside')
datetick('y','mmmyy')
grid off


subplot(2,3,3)
surf(  PRSK_LIBRO,   DATE_mat,  PRET_LIBRO,'EdgeColor', 'none' ); 
xlim([0 0.2])
ylim([0 0.2])
xlabel('Risk')
ylabel('Date')
zlabel('Return')
zlim([0 retlim])
caxis([0 retlim])
%zlim([0 max(max(PRET_CVAR))])
xlim([0 risklim])
 title('MV-traditional assets & Cryptos 10 mln investmented')
datetick('y','mmmyy')
grid off
colorbar('EastOutside')



subplot(2,3,6)
surf(PRSK_CVAR_LIBRO,   DATE_mat,  PRET_CVAR_LIBRO,'EdgeColor', 'none' );
xlim([0 0.2])
ylim([0 0.2])
xlabel('Risk')
ylabel('Date')
zlabel('Return')
zlim([0 retlim])
caxis([0 retlim])
%zlim([0 max(max(PRET_CVAR))])
xlim([0 risklim])
colorbar('EastOutside')
datetick('y','mmmyy')
grid off
title('MCVaR-traditional assets & Cryptos 10 mln invested')
orient(pfig,'landscape'); 
saveas(pfig, strcat('Efficient_frontiers_surfaces',rebal_freq,num2str(insample_width),'.png'))
saveas(pfig, strcat('Efficient_frontiers_surfaces',rebal_freq,num2str(insample_width),'.eps'))