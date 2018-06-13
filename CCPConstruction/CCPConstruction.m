%% Data loading
clc
clear
%load('CCP_Bootstrap_weights_liquidity_const_no_rebal_monthly26101-Jan-2015_29-Dec-2017.mat')
%load('CCP_Bootstrap_weights_liquidity_const_yes_rebal_monthly26101-Jan-2015_29-Dec-2017.mat')
%load('CCPData.mat')
%% Parameters setting

options      = optimoptions('fmincon', 'Display', 'off', ...
               'Algorithm','interior-point','TolFun',1e-6,'MaxFunEvals',...
                10^5,'MaxIter',10000);

insample_end_date = busdays(date_begin, datenum('31-Dec-2015'), 'annual');
insample_width    = length(DATE(1:find(DATE == insample_end_date))); %length of moving window or in-sample width
outsample_width   = length(DATE(find(DATE == insample_end_date)+1:end)); %

% Setting a liquidity constraint
liquidity_const = 'no';
invest = 10^6;

% Rebalancing scheme
rebal_freq = 'monthly'
if strcmpi(rebal_freq , 'once') == 1 
  rebal_dates = insample_width + 1;
elseif strcmpi(rebal_freq , 'daily') == 1 
    rebal_dates = insample_width+1+find(DATE(insample_width+2:end)==DATE(insample_width+2:end));
    rebal_dates = [insample_width  + 1;rebal_dates;rebal_dates(end)+1];
else rebal_dates = insample_width  + 1+  find(ismember(DATE(insample_width+1:end),busdays(insample_end_date+1, date_end, rebal_freq)));
    rebal_dates = [insample_width  + 1;rebal_dates];
end
% Rebalancing setting: extending window or moving window
setting = 1;% 1 -moving window static 2-extending window static

%% Portfolios from all cryptos and traditional assets 
clc 

disp(strcat('CRYPTOS_portfolios_liquidity_constr_',liquidity_const,'_', ...
     num2str(invest),'_', rebal_freq, '_', num2str(length(IND_TICK)), ...
     '_traditional assests_',datestr(DATE(1)),'_', datestr(DATE(end))))
%Weights' for all indices
AWT                = {};
SWT                = {};
AWT_IND            = {};
SWT_IND            = {};
PWT                = {};
RPWT               = {};
PWT_CVAR           = {};
AWT_CVAR           = {};
MDWT               = {};
IWT                = {};
CWT                = {};
NWT                = {};
EWT                = {};
EWT_IND            = {};

AWT_END                = {};
SWT_END                = {};
AWT_IND_END            = {};
SWT_IND_END            = {};
PWT_END                = {};
RPWT_END               = {};
PWT_CVAR_END           = {};
AWT_CVAR_END           = {};
MDWT_END               = {};
IWT_END                = {};
CWT_END                = {};
NWT_END                = {};
EWT_END                = {};
EWT_IND_END            = {};

CC_RET_WINDOW       = {};
CC_RET_OUT          = {};
CC_RET_IN           = {};
CC_VOL_WINDOW       = {};
CC_IND_RET_WINDOW   = {};
CC_IND_RET_OUT      = {};
CC_IND_RET_IN       = {};
IND_RET_WINDOW      = {};
IND_RET_OUT         = {};
IND_RET_IN          = {};
DATE_WINDOW         = {};
DATE_IN             = {};
DATE_OUT            = {};

%TS of out-of-sample returns
IND_RET_EW                   = [];
IND_RET_MAXRET               = [];
IND_RET_MAXSHARPE            = [];
IND_RET_MAXRET_CVAR          = [];
CC_IND_RET_EW                = [];
CC_IND_RET_MAXSHARPE         = [];
CC_IND_RET_MAXRET            = [];
CC_IND_RET_MINVAR            = [];
CC_IND_RET_CF                = [];
CC_IND_RET_MAXRET_CVAR       = [];
CC_IND_RET_MINVAR_CVAR       = [];
CC_IND_RET_RP                = [];
CC_IND_RET_IV                = [];
CC_IND_RET_ALL_WEIGHTS_NAIVE = [];
CC_IND_RET_MD                = [];


%TS of in-sample returns
IND_RET_EW_IN                   = [];
IND_RET_MAXRET_IN               = [];
IND_RET_MAXRET_CVAR_IN          = [];
IND_RET_MAXSHARPE_IN            = [];
CC_IND_RET_EW_IN                = [];
CC_IND_RET_MAXSHARPE_IN         = [];
CC_IND_RET_MAXRET_IN            = [];
CC_IND_RET_MINVAR_IN            = [];
CC_IND_RET_CF_IN                = [];
CC_IND_RET_MAXRET_CVAR_IN       = [];
CC_IND_RET_MINVAR_CVAR_IN       = [];
CC_IND_RET_RP_IN                = [];
CC_IND_RET_IV_IN                = [];
CC_IND_RET_ALL_WEIGHTS_NAIVE_IN = [];
CC_IND_RET_MD_IN                = [];
CC_IND_RET_ALL_COMB_NAIVE       = [];
CC_IND_RET_ALL_COMB_CEQ         = [];

%Risk-returns for efficient frontiers
PRSK_IND_CVAR = [];
PRET_IND_CVAR = [];
PRSK_IND      = [];
PRET_IND      = [];

PRSK_CVAR     = [];
PRET_CVAR     = [];
PRSK          = [];
PRET          = [];

tic

parfor n =1:length(rebal_dates(1:end))-1
 if setting == 1

%  if n == 1
% cc_ret  = CC_RET_wins(1:rebal_dates(n+1)-1, :); % matrix of Cryptos' returns;
% ind_ret =  IND_RET(1:rebal_dates(n+1)-1, :);
% cc_vol = CC_VOL(2:rebal_dates(n+1)-1, :); 
% Date       = DATE(2:rebal_dates(n+1)-2);
%ind_ret = IND_RET(1:rebal_dates(n+1)-2, :);
% if  n==length(rebal_dates(1:end))
% cc_ret  = CC_RET_wins(rebal_dates(n-1)+1:end,:);
% ind_ret =   IND_RET(rebal_dates(n-1)+1:end,:);% matrix of Cryptos' prices;
% cc_vol = CC_VOL(rebal_dates(n-1)+1:end, :); 
% Date       = DATE(rebal_dates(n-1)+1:end);
% else
cc_ret  = CC_RET_wins(rebal_dates(n)-rebal_dates(1)+1:rebal_dates(n+1)-2,:); % matrix of Cryptos' prices;
ind_ret = IND_RET(rebal_dates(n)-rebal_dates(1)+1:rebal_dates(n+1)-2,:);
cc_vol = CC_VOL(rebal_dates(n)-rebal_dates(1)+2:rebal_dates(n+1)-1, :); 
Date       = DATE(rebal_dates(n)-rebal_dates(1)+2:rebal_dates(n+1)-2);

%  end
%
elseif setting == 2
cr_tick_short = CR_TICK_short;
cc_ret  = cc_ret(2:rebal_dates(n+1)-2, :); % matrix of Cryptos' prices;
ind_ret =  IND_RET(2:rebal_dates(n+1)-2, :);
cc_vol = CC_VOL(2:rebal_dates(n+1)-2, :); 
Date       = DATE(2:rebal_dates(n+1)-2);

 end
Date_out = DATE(rebal_dates(n):rebal_dates(n+1)-1,:);
cc_ret_out = cc_ret(end-length(Date_out)+1:end,:);
ind_ret_out = ind_ret(end-length(Date_out)+1:end,:);
cc_ret_in =cc_ret(1:end-length(Date_out),:);

cc_vol =cc_vol(1:end-length(Date_out),:);
ind_ret_in = setdiff(ind_ret, ind_ret_out, 'rows');
cc_ind_ret     = [cc_ret, ind_ret];
cc_ind_ret_out = [cc_ret_out, ind_ret_out];
cc_ind_ret_in   =[cc_ret_in, ind_ret_in];
cc_ind_ret_out(isnan(cc_ind_ret_out))=0;
cc_ind_ret(isnan(cc_ind_ret))=0;
cc_vol_mean = nanmean(cc_vol);
if n ==1
in_index =  [1:size(cc_ret_in,1)];
else
in_index = [size(cc_ret_in,1)-(rebal_dates(n)-rebal_dates(n-1))+1:size(cc_ret_in,1)];    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Bounds for a liquidity constraint
    if strcmpi(liquidity_const, 'yes') == 0
       upbound = ones(1, size(cc_vol_mean,2)+length(IND_TICK));%for VaR and CVaR-optimization
    else
       upbound = [cc_vol_mean/invest,ones(1,length(IND_TICK))];
    end 

%%%%Benchmarks - Portfolios from  traditional assets only
% EW - trad assets
ewt_ind = ones(length(IND_TICK),1)./(length(IND_TICK));
ret_INDEX_EW = ind_ret_out*ewt_ind;
IND_RET_EW  = [IND_RET_EW; ret_INDEX_EW];
ewt_ind_end    = ewt_ind .*sum(ind_ret_out,1)'./sum(ind_ret_out*ewt_ind);
ewt_ind_end = round(ewt_ind_end*10^5)/10^5;
ret_INDEX_EW_IN = ind_ret_in(in_index,:)*ewt_ind;
IND_RET_EW_IN  = [IND_RET_EW_IN; ret_INDEX_EW_IN];

% Max return - trad assets
portf_index       = Portfolio('AssetMean', mean(ind_ret_in),'AssetCovar', ...
                              cov(ind_ret_in),...
                               'LowerBudget', 1, 'UpperBudget', 1, 'LowerBound', ...
                               zeros(1, size(ind_ret_in,2)));
spwt_ind        = round(estimateMaxSharpeRatio(portf_index)*10^5)/10^5;
[risk_index, ret_index] = estimatePortMoments(portf_index, spwt_ind);
spwt_ind_end    = spwt_ind .*sum(ind_ret_out,1)'./sum(ind_ret_out*spwt_ind);
spwt_ind_end = round(spwt_ind_end*10^5)/10^5;
ret_IND_MAXSHARPE   = ind_ret_out*spwt_ind;
IND_RET_MAXSHARPE  = [IND_RET_MAXSHARPE; ret_IND_MAXSHARPE];
ret_IND_MAXSHARPE_IN = ind_ret_in(in_index,:)*spwt_ind;
IND_RET_MAXSHARPE_IN  = [IND_RET_MAXSHARPE_IN; ret_IND_MAXSHARPE_IN];
pwt_index = estimateFrontier(portf_index, 30);
pret_index = estimatePortReturn(portf_index, pwt_index);
prsk_index = estimatePortRisk(portf_index, pwt_index);
pstd_index = estimatePortStd(portf_index, pwt_index);
PRSK_IND = [PRSK_IND, prsk_index];
PRET_IND = [PRET_IND, pret_index];

% Portfolio with maximized return (on the MV efficient frontier) 
%awt_index = estimateFrontierByReturn(portf_index, pret_index(end)); 
awt_ind = round(pwt_index(:,end-1)*10^5)/10^5;
ret_IND_MAXRET   = ind_ret_out*awt_ind;
IND_RET_MAXRET  = [IND_RET_MAXRET; ret_IND_MAXRET];
ret_IND_MAXRET_IN = ind_ret_in(in_index,:)*awt_ind;
IND_RET_MAXRET_IN  = [IND_RET_MAXRET_IN; ret_IND_MAXRET_IN];
awt_ind_end    = awt_ind .*sum(ind_ret_out,1)'./sum(ind_ret_out*awt_ind);
awt_ind_end = round(awt_ind_end*10^5)/10^5;
%
portf_index_cvar = PortfolioCVaR('AssetList', IND_TICK);
portf_index_cvar = simulateNormalScenariosByData(portf_index_cvar, ind_ret_in, 1000 );
portf_index_cvar = PortfolioCVaR(portf_index_cvar, 'UpperBudget', 1,  'LowerBudget', 1,...
                           'LowerBound', zeros(1, size(ind_ret_in,2)),...
                           'UpperBound', ones(1, size(ind_ret_in,2)), 'ProbabilityLevel', 0.95);
pwt_index_cvar = estimateFrontier(portf_index, 30);
pret_index_cvar = estimatePortReturn(portf_index, pwt_index_cvar);
prsk_index_cvar = estimatePortRisk(portf_index, pwt_index_cvar);
pstd_index_cvar = estimatePortStd(portf_index, pwt_index_cvar);

PRSK_IND_CVAR = [PRSK_IND_CVAR, prsk_index_cvar];
PRET_IND_CVAR = [PRET_IND_CVAR, pret_index_cvar];

% Portfolio with max return (on the efficient frontier) - max ret
awt_ind_cvar     = round(pwt_index_cvar(:,end-1)*10^5)/10^5;%estimateFrontierByReturn(portf_index_cvar, pret_index_cvar(end));
ret_ind_MAXRET_cvar    = ind_ret_out*awt_ind_cvar;
IND_RET_MAXRET_CVAR  = [IND_RET_MAXRET_CVAR; ret_ind_MAXRET_cvar];
ret_IND_MAXRET_cvar_IN = ind_ret_in(in_index,:)*awt_ind_cvar;
IND_RET_MAXRET_CVAR_IN  = [IND_RET_MAXRET_CVAR_IN; ret_IND_MAXRET_cvar_IN];

%%% Portfolios: traditional assets + CC
%  Portfolio with equal weights - EW
ewt = ones(size(cc_ind_ret, 2),1)./(size(cc_ind_ret, 2));
ret_EW   = cc_ind_ret_out*ewt;
CC_IND_RET_EW = [CC_IND_RET_EW; ret_EW];
ret_EW_IN = cc_ind_ret_in(in_index,:)*ewt;
CC_IND_RET_EW_IN  = [CC_IND_RET_EW_IN; ret_EW_IN];
ewt_end    = ewt .*sum(cc_ind_ret_out,1)'./sum(cc_ind_ret_out*ewt);
ewt_end = round(ewt_end*10^5)/10^5;
% Mean and Cov with NaN
%[ECMMean, ECMCovar] = ecmnmle(top_portfolio);
%Efficient frontier: MV optimization
portf       = Portfolio('AssetMean', nanmean(cc_ind_ret_in),'AssetCovar', nancov(cc_ind_ret_in),...
                        'LowerBudget', 1, 'UpperBudget', 1, 'LowerBound', ...
                        zeros(1, size(cc_ind_ret_in,2)), 'UpperBound', upbound);
%[risk, ret] = estimatePortMoments(portf, spwt);
wt = estimateFrontier(portf, 30);

pret = estimatePortReturn(portf,wt);
prsk = estimatePortRisk(portf, wt);
pstd = estimatePortStd(portf, wt);

PRSK = [PRSK, prsk];
PRET = [PRET, pret];

%
% MAX RET - Portfolio with max return (on the efficient frontier) 
awt = round(wt(:,end)*10^5)/10^5;%estimateFrontierByReturn(portf, pret(end)); 
ret_MAXRET   = cc_ind_ret_out*awt;
CC_IND_RET_MAXRET  = [CC_IND_RET_MAXRET; ret_MAXRET];
ret_MAXRET_IN = cc_ind_ret_in(in_index,:)*awt;
CC_IND_RET_MAXRET_IN  = [CC_IND_RET_MAXRET_IN; ret_MAXRET_IN];
awt_end    = awt .*sum(cc_ind_ret_out,1)'./sum(cc_ind_ret_out*awt);
awt_end = round(awt_end*10^5)/10^5;
%MIN Risk - Portfolio with min variance (Global Min-risk on the efficient frontier) 
pwt = round(wt(:,1)*10^5)/10^5;%estimateFrontierByRisk(portf, prsk(1));
ret_MINVAR   = cc_ind_ret_out*pwt;
CC_IND_RET_MINVAR  = [CC_IND_RET_MINVAR; ret_MINVAR];
ret_MINVAR_IN = cc_ind_ret_in(in_index,:)*pwt;
CC_IND_RET_MINVAR_IN  = [CC_IND_RET_MINVAR_IN; ret_MINVAR_IN];
pwt_end    = pwt .*sum(cc_ind_ret_out,1)'./sum(cc_ind_ret_out*pwt);
pwt_end = round(pwt_end*10^5)/10^5;
%MAX SHARPE - Portfolio with maximized Sharpe Ratio (the tangent portfolio)
spwt                   = round(estimateMaxSharpeRatio(portf)*10^5)/10^5;
ret_MAXSHARPE   = cc_ind_ret_out*spwt;
CC_IND_RET_MAXSHARPE  = [CC_IND_RET_MAXSHARPE; ret_MAXSHARPE];
ret_MAXSHARPE_IN = cc_ind_ret_in(in_index,:)*spwt;
CC_IND_RET_MAXSHARPE_IN  = [CC_IND_RET_MAXSHARPE_IN; ret_MAXSHARPE_IN];
spwt_end    = spwt .*sum(cc_ind_ret_out,1)'./sum(cc_ind_ret_out*spwt);
spwt_end = round(spwt_end*10^5)/10^5;
%  Risk-parity portfolio (ERC)                                
lowerbound = zeros(length(ewt'),1);%  wlb
aeq       = ones(1,length(ewt'));
beq       = 1;
Ht        = nancov(cc_ind_ret_in); 
[rpwt, fval, sqpExit] = fmincon(@(x) fm_fitnessERC(Ht, x), ewt, ...
                        [], [], aeq, beq, lowerbound, upbound, [], ...
                        options) ;
rpwt =  round(rpwt*10^5)/10^5;                   
ret_RP   = cc_ind_ret_out*rpwt;
CC_IND_RET_RP  = [CC_IND_RET_RP; ret_RP];
ret_RP_IN =cc_ind_ret_in(in_index,:)*rpwt;
CC_IND_RET_RP_IN  = [CC_IND_RET_RP_IN; ret_RP_IN];
rpwt_end    = rpwt .*sum(cc_ind_ret_out,1)'./sum(cc_ind_ret_out*rpwt);
rpwt_end = round(rpwt_end*10^5)/10^5;

% Inverse volatility - IV
iwt = ones(1,size(cc_ind_ret_in,2))./nanstd(cc_ind_ret_in)./sum(ones(1,size(cc_ind_ret_in,2))./nanstd(cc_ind_ret_in));
iwt = round(iwt*10^5)/10^5;
ret_IV = cc_ind_ret_out*iwt';
CC_IND_RET_IV = [CC_IND_RET_IV; ret_IV];
ret_IV_IN =cc_ind_ret_in(in_index,:)*iwt';
CC_IND_RET_IV_IN  = [CC_IND_RET_IV_IN; ret_IV_IN];
iwt_end    = iwt' .*sum(cc_ind_ret_out,1)'./sum(cc_ind_ret_out*iwt');
iwt_end = round(iwt_end*10^5)/10^5;

 
% Efficient frontier: Mean-CVAR optimization
portf_cvar = PortfolioCVaR('AssetList', [CC_TICK, IND_TICK] );
%portf_cvar = simulateNormalScenariosByData(portf_cvar, cc_ind_ret_in, 1000 );
portf_cvar = PortfolioCVaR(portf_cvar, 'Scenarios', cc_ind_ret_in, 'UpperBudget', 1,  'LowerBudget', 1,...
                           'LowerBound', zeros(1, size(cc_ind_ret_in,2)),...
                           'UpperBound', upbound, 'ProbabilityLevel', 0.95);
wt_cvar   = estimateFrontier(portf_cvar, 30);
pret_cvar = estimatePortReturn(portf_cvar, wt_cvar);
prsk_cvar = estimatePortRisk(portf_cvar, wt_cvar);
pstd_cvar = estimatePortStd(portf_cvar, wt_cvar);
PRSK_CVAR = [PRSK_CVAR, prsk_cvar];
PRET_CVAR = [PRET_CVAR, pret_cvar];

% MAX RET - CVAR: Portfolio with maximized return (on the  Mean-CVaR  efficient frontier) 
awt_cvar           = round(wt_cvar(:,end)*10^5)/10^5;%estimateFrontierByReturn(portf_cvar, pret_cvar(end));
ret_MAXRET_CVAR    = cc_ind_ret_out*awt_cvar;
CC_IND_RET_MAXRET_CVAR  = [CC_IND_RET_MAXRET_CVAR; ret_MAXRET_CVAR];
ret_MAXRET_CVAR_IN = cc_ind_ret_in(in_index,:)*awt_cvar;
CC_IND_RET_MAXRET_CVAR_IN  = [CC_IND_RET_MAXRET_CVAR_IN; ret_MAXRET_CVAR_IN];
awt_cvar_end    = awt_cvar .*sum(cc_ind_ret_out,1)'./sum(cc_ind_ret_out*awt_cvar);
awt_cvar_end = round(awt_cvar_end*10^5)/10^5;


% Portfolio with minimized variance (on the efficient frontier) 
pwt_cvar         = round(wt_cvar(:, 1)*10^5)/10^5;%estimateFrontierByRisk(portf_cvar, prsk_cvar(1));
ret_MINVAR_CVAR   = cc_ind_ret_out*pwt_cvar;
CC_IND_RET_MINVAR_CVAR  = [CC_IND_RET_MINVAR_CVAR; ret_MINVAR_CVAR];
ret_MINVAR_CVAR_IN = cc_ind_ret_in(in_index,:)*pwt_cvar;
CC_IND_RET_MINVAR_CVAR_IN  = [CC_IND_RET_MINVAR_CVAR_IN; ret_MINVAR_CVAR_IN];
pwt_cvar_end    = pwt_cvar .*sum(cc_ind_ret_out,1)'./sum(cc_ind_ret_out*pwt_cvar);
pwt_cvar_end = round(pwt_cvar_end*10^5)/10^5;

%Maximum Diversification portfolios - MD with PDI
 pd = PortfolioDiversification('PortfolioWeights',ewt,'AssetCovar',nancov(cc_ind_ret_in),...
     'AssetReturns',cc_ind_ret_in,'DiversificationFunction', ...
     {'Portfolio Diversification Index'});%

[pd] = MeasureDiversification(pd);

% Calculate Maximum Diversification Portfolio
[pd,mdwt] = MaxDiversificationPortfolio(pd, upbound);
mdwt = round(mdwt*10^5)/10^5;
ret_MD  = cc_ind_ret_out*mdwt;
CC_IND_RET_MD  = [CC_IND_RET_MD; ret_MD];
ret_MD_IN = cc_ind_ret_in(in_index,:)*mdwt;
CC_IND_RET_MD_IN  = [CC_IND_RET_MD_IN; ret_MD_IN];
mdwt_end    = mdwt .*sum(cc_ind_ret_out,1)'./sum(cc_ind_ret_out*rpwt);
mdwt_end = round(mdwt_end*10^5)/10^5;
%COmbinations of portfolios Risk-based strategies only

% %NAive combination
% 
wt_comb_naive = 1/7*sum([ewt, pwt, awt, spwt, rpwt , pwt_cvar, mdwt],2);%[CEQ_EW ; CEQ_MINVAR ;  CEQ_MAXRET; CEQ_MAXSHARPE ; CEQ_RP ; CEQ_IV ; CEQ_MINVAR_CVAR; CEQ_MD ];
%wt_comb_naive = round(wt_comb_naive*10^5)/10^5;
ret_ALL_NAIVE   = cc_ind_ret_out*wt_comb_naive;
CC_IND_RET_ALL_COMB_NAIVE  = [CC_IND_RET_ALL_COMB_NAIVE; ret_ALL_NAIVE];
wt_comb_naive_end    = wt_comb_naive .*sum(cc_ind_ret_out,1)'./sum(cc_ind_ret_out*wt_comb_naive);
wt_comb_naive_end = round(wt_comb_naive_end*10^5)/10^5;

% %Combinations based on boostraped shares
wt_comb = [ewt, pwt, awt, spwt, rpwt , pwt_cvar, mdwt]*COMBWT_CEQ_ALL_IN(:,n);%[CEQ_EW ; CEQ_MINVAR ;  CEQ_MAXRET; CEQ_MAXSHARPE ; CEQ_RP ; CEQ_IV ; CEQ_MINVAR_CVAR; CEQ_MD ];
%wt_comb = round(wt_comb*10^5)/10^5;
ret_ALL_COMB_CEQ   = cc_ind_ret_out*wt_comb;
CC_IND_RET_ALL_COMB_CEQ  = [CC_IND_RET_ALL_COMB_CEQ; ret_ALL_COMB_CEQ];
wt_comb_end    = wt_comb .*sum(cc_ind_ret_out,1)'./sum(cc_ind_ret_out*wt_comb);
wt_comb_end = round(wt_comb_end*10^5)/10^5;

% Weights 
AWT{n}                = awt;
SWT{n}                = spwt;
EWT{n}                = ewt;
EWT_IND{n}            = ewt_ind;
AWT_IND{n}            = awt_ind;
SWT_IND{n}            = spwt_ind;
PWT{n}                = pwt;
RPWT{n}               = rpwt;
PWT_CVAR{n}           = pwt_cvar;
AWT_CVAR{n}           = awt_cvar;
MDWT{n}               = mdwt;
IWT{n}                = iwt';
CWT{n}                = wt_comb;
NWT{n}                = wt_comb_naive;

AWT_END{n}                = awt_end;
SWT_END{n}                = spwt_end;
EWT_END{n}                = ewt_end;
EWT_IND_END{n}            = ewt_ind_end;
AWT_IND_END{n}            = awt_ind_end;
SWT_IND_END{n}            = spwt_ind_end;
PWT_END{n}                = pwt_end;
RPWT_END{n}               = rpwt_end;
PWT_CVAR_END{n}           = pwt_cvar_end;
AWT_CVAR_END{n}           = awt_cvar_end;
MDWT_END{n}               = mdwt_end;
IWT_END{n}                = iwt_end;
CWT_END{n}                = wt_comb_end;
NWT_END{n}                = wt_comb_naive_end;
%
CC_RET_WINDOW{n} = cc_ret;
CC_RET_IN{n} = cc_ret_in;
CC_RET_OUT{n} = cc_ret_out;
IND_RET_IN{n} =ind_ret_in;
IND_RET_OUT{n} =ind_ret_out;
CC_IND_RET_WINDOW{n} = cc_ind_ret;
CC_IND_RET_OUT{n} = cc_ind_ret_out;
CC_IND_RET_IN{n} = cc_ind_ret_in;
CC_VOL_WINDOW{n} = cc_vol;
DATE_IN{n} = setdiff(Date,Date_out);
DATE_OUT{n} = Date_out;
DATE_IN_OUT{n} = Date;
end
toc
%% Cumulative returns
cumretIND                             = 1 + cumsum(IND_RET(end-size(CC_IND_RET_EW,1)+1:end,4))';
cumretIND_EW                          = 1+cumsum(IND_RET_EW)';
IND_RET_MAXRET(isnan(IND_RET_MAXRET)) = 0;
cumretIND_MAXRET                      = 1+ cumsum(IND_RET_MAXRET)';
cumretIND_MAXSHARPE                    = 1+ cumsum(IND_RET_MAXSHARPE)';
cumretEW                              = 1+cumsum(CC_IND_RET_EW)';
CC_IND_RET_MAXRET(isnan(CC_IND_RET_MAXRET)) = 0;
cumretMAXRET                          = 1+ cumsum(CC_IND_RET_MAXRET)';
cumretMINVAR                          = 1+ cumsum(CC_IND_RET_MINVAR)';
cumretMAXSHARPE                       = 1+cumsum(CC_IND_RET_MAXSHARPE)';
cumretRP                              = 1+cumsum(CC_IND_RET_RP)';
cumretIV                              = 1+cumsum(CC_IND_RET_IV)';
cumretMINVAR_CVAR                     = 1+ cumsum(CC_IND_RET_MINVAR_CVAR)';
cumretMD                              = 1+cumsum(CC_IND_RET_MD, 1)';
cumretMAXRET_CVAR                     = 1+ cumsum(CC_IND_RET_MAXRET_CVAR)';
cumretCOMBNAIVE                       = 1+ cumsum(CC_IND_RET_ALL_COMB_NAIVE)';
cumretCOMB                            = 1+ cumsum(CC_IND_RET_ALL_COMB_CEQ)';

cumretIND_IN                                    = 1+cumsum(IND_RET(1:size(CC_IND_RET_EW,1),4))';
IND_RET_IND_MAXRET_IN(isnan(IND_RET_MAXRET_IN)) = 0;
cumretIND_MAXRET_IN                             = 1+ cumsum(IND_RET_MAXRET_IN)';
cumretEW_IN                                     = 1+cumsum(CC_IND_RET_EW_IN)';
cumretMAXRET_IN                                 = 1+ cumsum(CC_IND_RET_MAXRET_IN)';
cumretMINVAR_IN                                 = 1+ cumsum(CC_IND_RET_MINVAR_IN)';
cumretMAXSHARPE_IN                              = 1+cumsum(CC_IND_RET_MAXSHARPE_IN)';
cumretRP_IN                                     = 1+cumsum(CC_IND_RET_RP_IN)';
cumretIV_IN                                     = 1+cumsum(CC_IND_RET_IV_IN)';
cumretMINVAR_cvar_IN                            = 1+ cumsum(CC_IND_RET_MINVAR_CVAR_IN)';
cumretMD_IN                                     = 1+cumsum(CC_IND_RET_MD,1);
cumretMAXRET_cvar_IN                            = 1+ cumsum(CC_IND_RET_MAXRET_CVAR_IN)';



%% Save variables to working the file
save(strcat('CCP_liquidity_constraint_',liquidity_const,'_wins_',wins, 'rebal_',rebal_freq,num2str(insample_width), datestr(date_begin),'_',datestr(date_end),'_',num2str(length(CC_TICK)),'newCVAR.mat'))