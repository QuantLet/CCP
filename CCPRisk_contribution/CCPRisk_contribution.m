%run('CCPConstruction.m')
%% Plots of risk contributions (measured by variance) for different portfolio strategies
close all

%Risk contribution of assets
awt_risk      = [];
pwt_risk      = [];
swt_risk      = [];
iwt_risk      = [];
rpwt_risk     = [];
mdwt_risk     = [];
awt_cvar_risk = [];
pwt_cvar_risk = [];
cwt_risk      = [];
nwt_risk      = [];
DATE_OUT_MAT      = [];
ind               = length(IND_TICK);

tic    
 for n = 1:length(MDWT)
awt = AWT{n} ;
swt  = SWT{n};
awt_index = AWT_IND{n} ;
swt_index  = SWT_IND{n};
pwt =PWT{n};
rpwt = RPWT{n};
pwt_cvar = PWT_CVAR{n};
awt_cvar = AWT_CVAR{n} ;
mdwt =MDWT{n};
iwt =IWT{n};
cwt       = CWT{n};
nwt       = NWT{n};
 
Data = CC_IND_RET_IN{n}; 
date_out = DATE_OUT{n}' ; 
awt_risk      = [awt_risk, repmat(awt.*(nancov(Data)*awt/(awt'*nancov(Data)*awt)),1,length(date_out))];
pwt_risk      = [pwt_risk, repmat(pwt.*(nancov(Data)*pwt/(pwt'*nancov(Data)*pwt)),1,length(date_out))];
swt_risk      = [swt_risk,repmat( swt.*(nancov(Data)*swt/(swt'*nancov(Data)*swt)),1,length(date_out))];
iwt_risk      = [iwt_risk, repmat(iwt.*(nancov(Data)*iwt/(iwt'*nancov(Data)*iwt)),1,length(date_out))];
rpwt_risk     = [rpwt_risk, repmat(rpwt.*(nancov(Data)*rpwt/(rpwt'*nancov(Data)*rpwt)),1,length(date_out))];
mdwt_risk     = [mdwt_risk, repmat(mdwt.*(nancov(Data)*mdwt/(mdwt'*nancov(Data)*mdwt)),1,length(date_out))];
awt_cvar_risk = [awt_cvar_risk,repmat( awt_cvar.*(nancov(Data)*awt_cvar/(awt_cvar'*nancov(Data)*awt_cvar)),1,length(date_out))];
pwt_cvar_risk = [pwt_cvar_risk,repmat( pwt_cvar.*(nancov(Data)*pwt_cvar/(pwt_cvar'*nancov(Data)*pwt_cvar)),1,length(date_out))];
cwt_risk      = [cwt_risk,repmat( cwt.*(nancov(Data)*cwt/(cwt'*nancov(Data)*cwt)),1,length(date_out))];
nwt_risk      = [nwt_risk,repmat( nwt.*(nancov(Data)*nwt/(nwt'*nancov(Data)*nwt)),1,length(date_out))];

 end


toc
%% Create a figure: Daily returns
RISK_MAT       = {awt_risk, swt_risk, pwt_risk, rpwt_risk,   pwt_cvar_risk,  mdwt_risk, };
STRATRGY_TITLE = {'RR - Max ret', 'MV - S', 'MinVar', 'ERC', 'MinCVaR', 'MD'};
pfig = figure
for n =1:length(RISK_MAT)
    risk = RISK_MAT{n};
subplot(3,2,n)
area(cell2mat(DATE_OUT'),risk', 'LineStyle','none')
hold on 
ylim([0 1])
xlim([DATE(end-outsample_width+1) DATE(end)])
datetick('x','mmmyy','keeplimits')
area(cell2mat(DATE_OUT'), [sum(risk(1:end-ind,:)); sum(risk(end-ind +1:end,:))]','FaceAlpha',0, 'LineStyle','-')
colormap parula(72)
colorbar('EastOutside')
title(STRATRGY_TITLE{n})
end

%Save Figure in .fig and.pdf formats
savefig(pfig, strcat('Risk_contribution_liquidity_constraint_',liquidity_const,rebal_freq,num2str(insample_width),'_',num2str(length(CC_TICK)),'.fig'));
orient(pfig,'landscape'); 
pfig.PaperPositionMode = 'auto'
pfig_pos = pfig.PaperPosition;
pfig.PaperSize = [pfig_pos(3) pfig_pos(4)];
saveas(pfig, strcat('Risk_contribution_liquidity_constraint_',liquidity_const,rebal_freq,num2str(insample_width),'_',num2str(length(CC_TICK)),'.pdf'))


%% Create a figure: Monthly returns
RISK_MAT       = {awt_risk, swt_risk, pwt_risk, rpwt_risk,   pwt_cvar_risk,  mdwt_risk, nwt_risk, cwt_risk};
STRATRGY_TITLE = {'RR - Max ret', 'MV - S', 'MinVar', 'ERC', 'MinCVaR', 'MD', 'COMB NAIVE', 'COMB'};

pfig = figure
for n =1:length(RISK_MAT)
    risk = RISK_MAT{n};
subplot(4,2,n)
area(cell2mat(DATE_OUT'),risk', 'LineStyle','none')
hold on 
ylim([0 1])
xlim([DATE(end-outsample_width+1) DATE(end)])
datetick('x','mmmyy','keeplimits')
area(cell2mat(DATE_OUT'), [sum(risk(1:end-ind,:)); sum(risk(end-ind +1:end,:))]','FaceAlpha',0, 'LineStyle','-')
colormap parula(72)
colorbar('EastOutside')
title(STRATRGY_TITLE{n})
end

%Save Figure in .fig and.pdf formats
savefig(pfig, strcat('Risk_contribution_liquidity_constraint_',liquidity_const,rebal_freq,num2str(insample_width),'_',num2str(length(CC_TICK)),'.fig'));
orient(pfig,'landscape'); 
pfig.PaperPositionMode = 'auto'
pfig_pos = pfig.PaperPosition;
pfig.PaperSize = [pfig_pos(3) pfig_pos(4)];
saveas(pfig, strcat('Risk_contribution_liquidity_constraint_',liquidity_const,rebal_freq,num2str(insample_width),'_',num2str(length(CC_TICK)),'.pdf'))
