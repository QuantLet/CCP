[<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/banner.png" width="888" alt="Visit QuantNet">](http://quantlet.de/)

## [<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/qloqo.png" alt="Visit QuantNet">](http://quantlet.de/) **CCPDiversification** [<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/QN2.png" width="60" alt="Visit QuantNet 2.0">](http://quantlet.de/)

```yaml

Name of QuantLet : CCPDiversification

Published in : Risk-based versus target-based portfolio strategies in the cryptocurrency market

Description : 'Calculates diversification measures: diversification ratio, PDI and Effective N for 8 portfolios, constructed from cryptocurrencies and 16 traditional assets'

Keywords : crypto, CRIX, cryptocurrency, portfolio, variance, plot, time-series, returns


See also : 'CCPTests, CCPBootstrap, CCPPerformance_measures, CCPConstruction'

Author : Alla Petukhina

Submitted : June 11 2018 by Alla Petukhina
Datafile : 'CCPData.mat'

Example : 
```

### MATLAB Code
```matlab

%run('CCPConstruction.m')

%% Diversification measures
divers_measures = {'Diversification Ratio', 'Portfolio Diversification Index'};  

diversificationMAXRET_IND    = [];
diversificationMAXRET        = [];
diversificationMINVAR        = [];
diversificationMAXSHARPE_IND = [];
diversificationMAXSHARPE     = [];
diversificationMAXRET_CVAR   = [];
diversificationMINVAR_CVAR   = [];
diversificationMD            = [];
diversificationRP            = [];
diversificationIV            = [];
diversificationCOMBNAIVE  = [];
diversificationCOMB        = [];


pdiMAXRET        = [];
pdiMAXRET_IND    = [];
pdiMINVAR        = [];
pdiMAXSHARPE     = [];
pdiMAXSHARPE_IND = [];
pdiMAXRET_CVAR   = [];
pdiMINVAR_CVAR   = [];
pdiMD            = [];
pdiRP            = [];
pdiIV            = [];
pdiCOMBNAIVE  = [];
pdiCOMB       = [];
 
effectiveNMAXRET        = [];
effectiveNMAXRET_IND    = [];
effectiveNMINVAR        = [];
effectiveNMAXSHARPE     = [];
effectiveNMAXSHARPE_IND = [];
effectiveNMAXRET_CVAR   = [];
effectiveNMINVAR_CVAR   = [];
effectiveNMD            = [];
effectiveNRP            = [];
effectiveNIV            = [];
effectiveNCOMBNAIVE  = [];
effectiveNCOMB       = [];




tic    
for n = 1:length(MDWT)
awt       = AWT{n} ;
swt       = SWT{n};
awt_index = AWT_IND{n} ;
swt_index = SWT_IND{n};
pwt       = PWT{n};
rpwt      = RPWT{n};
pwt_cvar  = PWT_CVAR{n};
awt_cvar  = AWT_CVAR{n} ;
mdwt      = MDWT{n};
iwt       = IWT{n};
% cwt       = CWT{n};
% nwt       = NWT{n};
Data      = CC_IND_RET_IN{n}; 
ind_ret   = IND_RET_IN{n};

% maxret          = MeasureDiversification(PortfolioDiversification('PortfolioWeights', awt,...
%                                  'AssetCovar',cov(Data),'AssetReturns',Data, ...
%                                  'DiversificationFunction', divers_measures));
minvar          = MeasureDiversification(PortfolioDiversification('PortfolioWeights', pwt,...
                                  'AssetCovar',cov(Data),'AssetReturns',Data, ...
                                  'DiversificationFunction', divers_measures));
maxsharpe       = MeasureDiversification(PortfolioDiversification('PortfolioWeights', swt,...
                                  'AssetCovar',cov(Data),'AssetReturns',Data, ...
                                  'DiversificationFunction', divers_measures));
% maxret_index   = MeasureDiversification(PortfolioDiversification('PortfolioWeights', awt_index,...
%                               'AssetCovar',cov(ind_ret),'AssetReturns',ind_ret, ...
%                                  'DiversificationFunction', divers_measures));
maxsharpe_index = MeasureDiversification(PortfolioDiversification('PortfolioWeights',swt_index,... 
                                  'AssetCovar',cov(ind_ret),'AssetReturns',ind_ret, ...
                                  'DiversificationFunction', divers_measures));
%maxret_cvar     = MeasureDiversification(PortfolioDiversification('PortfolioWeights',awt_cvar,...
 %                                 'AssetCovar',cov(Data),'AssetReturns',Data, ...
  %                                'DiversificationFunction', divers_measures));
md              = MeasureDiversification(PortfolioDiversification('PortfolioWeights', mdwt,...
                                  'AssetCovar',cov(Data),'AssetReturns',Data, ...
                                  'DiversificationFunction', divers_measures));
rp              = MeasureDiversification(PortfolioDiversification('PortfolioWeights', rpwt,...
                                  'AssetCovar',cov(Data),'AssetReturns',Data, ...
                                  'DiversificationFunction', divers_measures));
minvar_cvar     = MeasureDiversification(PortfolioDiversification('PortfolioWeights', pwt_cvar,...
                                  'AssetCovar',cov(Data),'AssetReturns',Data, ...
                                  'DiversificationFunction', divers_measures));
iv              = MeasureDiversification(PortfolioDiversification('PortfolioWeights', iwt,...
                                  'AssetCovar',cov(Data),'AssetReturns',Data, ...
                                  'DiversificationFunction', divers_measures));
%  comb             = MeasureDiversification(PortfolioDiversification('PortfolioWeights', cwt,...
%                                   'AssetCovar',cov(Data),'AssetReturns',Data, ...
%                                   'DiversificationFunction', divers_measures));
% comb_naive       = MeasureDiversification(PortfolioDiversification('PortfolioWeights', nwt,...
%                                   'AssetCovar',cov(Data),'AssetReturns',Data, ...
%                                  'DiversificationFunction', divers_measures));

%Diversification ratio
%diversificationMAXRET_IND    = [diversificationMAXRET_IND, maxret_index.DiversificationRatio];
diversificationMAXSHARPE_IND = [diversificationMAXSHARPE_IND, maxsharpe_index.DiversificationRatio];
diversificationMAXRET        =  repmat(1,[1 n]);% [diversificationMAXRET, maxret.DiversificationRatio];%
diversificationMINVAR        = [diversificationMINVAR, minvar.DiversificationRatio];
diversificationMAXSHARPE     = [diversificationMAXSHARPE, maxsharpe.DiversificationRatio];
%diversificationMAXRET_CVAR  = [diversificationMAXRET_CVAR, maxret_cvar.DiversificationRatio];
diversificationMINVAR_CVAR   = [diversificationMINVAR_CVAR, minvar_cvar.DiversificationRatio];
diversificationMD            = [diversificationMD, md.DiversificationRatio];
diversificationRP            = [diversificationRP, rp.DiversificationRatio];
diversificationIV            = [diversificationIV, iv.DiversificationRatio];
%  diversificationCOMB          = [diversificationCOMB, comb.DiversificationRatio];
%  diversificationCOMBNAIVE     = [diversificationCOMBNAIVE, comb_naive.DiversificationRatio];

%PDI
%pdiMAXRET_IND                = [pdiMAXRET_IND, maxret_index.PDI];
pdiMAXSHARPE_IND             = [pdiMAXSHARPE_IND, maxsharpe_index.PDI];
pdiMAXRET                    = repmat(1,[1 n]);%[pdiMAXRET, maxret.PDI];
pdiMINVAR                    = [pdiMINVAR, minvar.PDI];
pdiMAXSHARPE                 = [pdiMAXSHARPE, maxsharpe.PDI];
%pdiMAXRET_CVAR              = [pdiMAXRET_CVAR, maxret_cvar.PDI];
pdiMINVAR_CVAR               = [pdiMINVAR_CVAR, minvar_cvar.PDI];
pdiMD                        = [pdiMD, md.PDI];
pdiRP                        = [pdiRP, rp.PDI];
pdiIV                        = [pdiIV, iv.PDI];
% pdiCOMB                      = [pdiCOMB, comb.PDI];
% pdiCOMBNAIVE                 = [pdiCOMBNAIVE, comb_naive.PDI];

% Effective N
effectiveNMAXRET             = [effectiveNMAXRET, 1/sum(power(awt,2))];
%effectiveNMAXRET_IND         = [effectiveNMAXRET_IND, 1/sum(power(awt_index,2))];
effectiveNMINVAR             = [effectiveNMINVAR, 1/sum(power(pwt,2))];
effectiveNMAXSHARPE_IND      = [effectiveNMAXSHARPE_IND, 1/sum(power(swt_index,2))];
effectiveNMAXSHARPE          = [effectiveNMAXSHARPE, 1/sum(power(swt,2))];
effectiveNMAXRET_CVAR        = [effectiveNMAXRET_CVAR, 1/sum(power(awt_cvar,2))];
effectiveNMINVAR_CVAR        = [effectiveNMINVAR_CVAR, 1/sum(power(pwt_cvar,2))];
effectiveNMD                 = [effectiveNMD, 1/sum(power(mdwt(:,end),2))];
effectiveNRP                 = [effectiveNRP, 1/sum(power(rpwt,2))];
effectiveNIV                 = [effectiveNIV, 1/sum(power(iwt,2))];
%  effectiveNCOMB               = [effectiveNCOMB, 1/sum(power(cwt,2))];
% effectiveNCOMBNAIVE          = [effectiveNCOMBNAIVE, 1/sum(power(nwt,2))];

end    
toc

%% Average diversification measures for the period

EFFECTIVE_N     = nanmean([ effectiveNMAXSHARPE_IND;...
                           effectiveNMAXRET; effectiveNMINVAR;  effectiveNRP; ...
                           effectiveNMAXSHARPE;  ...
                           effectiveNMINVAR_CVAR; effectiveNMD]')';%   ;effectiveNIV;  effectiveNCOMBNAIVE; effectiveNCOMB]')';%
DIVERSIFICATION = nanmean([  diversificationMAXSHARPE_IND; ...
                           diversificationMAXRET; diversificationMINVAR;  ...
                           diversificationRP;  diversificationMAXSHARPE; ...
                           diversificationMINVAR_CVAR; ...
                           diversificationMD]')';% ; diversificationIV; ...                
                           %diversificationCOMBNAIVE; diversificationCOMB]')';%
PDI             = nanmean([  pdiMAXSHARPE_IND; pdiMAXRET; ...
                           pdiMINVAR;  pdiRP;  pdiMAXSHARPE;  ...
                           pdiMINVAR_CVAR; pdiMD]')';% pdiIV;  pdiCOMBNAIVE; pdiCOMB]')';%
%% Save results to tex tables 
input.data                      = [DIVERSIFICATION.^2, EFFECTIVE_N, PDI];
input.tableColLabels            = {'Diversification ratio', 'Effective N', 'PDI'};
input.tableRowLabels            = { 'MV - S Trad Assets', ...
                                   'RR - Max ret','MinVar', 'ERC', 'MV -S',...
                                   'MinCVaR',  'MD'};%,'IV','COMB NA\"IVE', 'COMB'};
input.transposeTable            = 0;
input.dataFormatMode            = 'column'; 
input.dataFormat                = {'%.2f'};
input.dataNanString             = '-';
input.tableColumnAlignment      = 'r';
input.tableBorders              = 0;
input.tableCaption              = strcat('Diversification measures: rebalancing_', rebal_freq, '_liquidity constraint_',liquidity_const);
input.makeCompleteLatexDocument = 0;
latex                           = latexTable(input);


```

automatically created on 2018-06-26