% %% CCP Bootstrap 
clc
clear
load('CCP_liquidity_constraint_no_wins_yesrebal_monthly26101-Jan-2015_29-Dec-2017_55.mat')
%load('CCP_liquidity_constraint_yes_wins_yesrebal_monthly26101-Jan-2015_29-Dec-2017_55.mat')

B    = 100; %number of monthly bootstraped returns
r_dd = []; 
tic
for n = 1:length(CC_IND_RET_IN)%number of moving windows
    cc_ind_ret_in = CC_IND_RET_IN{n};  
    cc_ind_ret_in(isnan(cc_ind_ret_in)) = 0;
    RetB = {};%number of bootstraps 
    D    = length(cc_ind_ret_in); %number of daily bootstraped returnes
for a=1:length([CC_TICK, IND_TICK])%bootstrap for every asset 
    RetA = cc_ind_ret_in(:,a);% 
    
q   = opt_block_length_REV_dec07(RetA); % algorithm for choosing a block-length 
q_a = q(1,1);% Loop over B bootstraps
Ret = zeros(D,B);

parfor b = 1:B
   l = [];
r_d = zeros(D,1);
    d = zeros(D,1);
    l(1) = ceil(length(RetA)/2*rand);
for d=2:D   
if rand<1/q_a %probability of a new block 
l(d) = ceil(length(RetA)/2*rand);
else l(d) = l(d-1) + 1;
    if   l(d)>length(RetA)
         l(d) = ceil(length(RetA)/2*rand);
    else l(d) = l(d-1) + 1; 
end
end
r_d = RetA(l);

%r_dd = [r_dd,r_d] 

end
%Ret(:,b) = r_d;
RetB{b}(:,a) = r_d;
end


end
RetBootstrap(n).CC_IND_RET_IN = RetB;
end
toc
% Save variables to the file
save(strcat('CCPData_Bootstrap_','rebal',rebal_freq,num2str(insample_width), datestr(date_begin),'_',datestr(date_end),'.mat'))
%% Calculation of weights
%load('CCP_liquidity_constraint_no_wins_yesrebal_monthly26101-Jan-2015_29-Dec-2017_55.mat')
load('CCP_liquidity_constraint_yes_wins_yesrebal_monthly26101-Jan-2015_29-Dec-2017_55.mat')
load('CCPData_Bootstrap_rebalmonthly26101-Jan-2015_29-Dec-2017.mat')
N = length(rebal_dates(1:end))-1;
nshift = 0;

clear WeightsBootstrap
WeightsBootstrap(N)=struct('AWT',[],'SWT',[],'PWT',[],'RPWT',[],'MDWT',[],'AWT_CVAR',[],...
    'PWT_CVAR',[], 'IWT',[], 'CC_IND_RET_EW', [], 'CC_IND_RET_MAXRET', [],...
    'CC_IND_RET_MINVAR', [], 'CC_IND_RET_MAXSHARPE', [], 'CC_IND_RET_RP',...
    [], 'CC_IND_RET_IV', [], 'CC_IND_RET_MINVAR_CVAR', [], 'CC_IND_RET_MD',...
    [], 'CC_IND_RET_MAXRET_CVAR', [], 'CC_IND_RET_EW_IN', [], 'CC_IND_RET_MAXRET_IN',...
    [], 'CC_IND_RET_MINVAR_IN', [], 'CC_IND_RET_MAXSHARPE_IN', [], 'CC_IND_RET_RP_IN',...
    [], 'CC_IND_RET_IV_IN', [], 'CC_IND_RET_MINVAR_CVAR_IN', [], 'CC_IND_RET_MD_IN', [], 'CC_IND_RET_MAXRET_CVAR_IN', []);
for b =1:B
CC_IND_RET_EW          = [];
CC_IND_RET_MAXRET      = [];
CC_IND_RET_MINVAR      = [];
CC_IND_RET_MAXSHARPE   = [];
CC_IND_RET_RP          = [];
CC_IND_RET_IV          = [];
CC_IND_RET_MINVAR_CVAR = [];
CC_IND_RET_MD          = [];
CC_IND_RET_MAXRET_CVAR = [];


CC_IND_RET_EW_IN          = [];
CC_IND_RET_MAXRET_IN      = [];
CC_IND_RET_MINVAR_IN      = [];
CC_IND_RET_MAXSHARPE_IN   = [];
CC_IND_RET_RP_IN          = [];
CC_IND_RET_IV_IN          = [];
CC_IND_RET_MINVAR_CVAR_IN = [];
CC_IND_RET_MD_IN          = [];
CC_IND_RET_MAXRET_CVAR_IN = [];
parfor n =1:N
 
cc_ind_ret_out = CC_IND_RET_OUT{n};
cc_ind_ret_in  = RetBootstrap(n).CC_IND_RET_IN{b};
cc_ind_ret_out(isnan(cc_ind_ret_out))=0;
cc_vol = CC_VOL_WINDOW{n};
cc_vol_mean = nanmean(cc_vol);
% if n ==1
in_index = [1:size(cc_ind_ret_in,1)];
% else
% in_index = [size(cc_ind_ret_in,1)-(rebal_dates(n)-rebal_dates(n-1))+1:size(cc_ind_ret_in,1)];    
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Bounds for a liquidity constraint
    if strcmpi(liquidity_const, 'yes') == 0
       upbound = ones(1, size(cc_vol_mean,2)+length(IND_TICK));%for VaR and CVaR-optimization
    else
       upbound = [cc_vol_mean/invest,ones(1,length(IND_TICK))];
    end 

%%% Portfolios: traditional assets + CC
%  Portfolio with equal weights - EW
ewt = ones(size(cc_ind_ret_in, 2),1)./(size(cc_ind_ret_in, 2));
ret_EW   = cc_ind_ret_out*ewt;
CC_IND_RET_EW = [CC_IND_RET_EW; ret_EW];
ret_EW_IN = cc_ind_ret_in(in_index,:)*ewt;
CC_IND_RET_EW_IN  = [CC_IND_RET_EW_IN; ret_EW_IN];
% Mean and Cov with NaN
%[ECMMean, ECMCovar] = ecmnmle(top_portfolio);
%Efficient frontier: MV optimization
portf       = Portfolio('AssetMean', nanmean(cc_ind_ret_in),'AssetCovar', nancov(cc_ind_ret_in),...
                        'LowerBudget', 1, 'UpperBudget', 1, 'LowerBound', ...
                        zeros(1, size(cc_ind_ret_in,2)), 'UpperBound', upbound);

swt        = round(estimateMaxSharpeRatio(portf)*10^5)/10^5; 
[risk, ret] = estimatePortMoments(portf, swt);
wt = estimateFrontier(portf, 30);

pret = estimatePortReturn(portf,wt);
prsk = estimatePortRisk(portf, wt);
pstd = estimatePortStd(portf, wt);

PRSK = [PRSK, prsk];
PRET = [PRET, pret];

%
% MAX RET - Portfolio with max return (on the efficient frontier) 
awt = round(wt(:,end-1)*10^5)/10^5;%estimateFrontierByReturn(portf, pret(end)); 
ret_MAXRET   = cc_ind_ret_out*awt;
CC_IND_RET_MAXRET  = [CC_IND_RET_MAXRET; ret_MAXRET];
ret_MAXRET_IN = cc_ind_ret_in(in_index,:)*awt;
CC_IND_RET_MAXRET_IN  = [CC_IND_RET_MAXRET_IN; ret_MAXRET_IN];
%MIN Risk - Portfolio with min variance (Global Min-risk on the efficient frontier) 
pwt = round(wt(:,1)*10^5)/10^5;%estimateFrontierByRisk(portf, prsk(1));
ret_MINVAR   = cc_ind_ret_out*pwt;
CC_IND_RET_MINVAR  = [CC_IND_RET_MINVAR; ret_MINVAR];
ret_MINVAR_IN = cc_ind_ret_in(in_index,:)*pwt;
CC_IND_RET_MINVAR_IN  = [CC_IND_RET_MINVAR_IN; ret_MINVAR_IN];
%MAX SHARPE - Portfolio with maximized Sharpe Ratio (the tangent portfolio)
swt                   = round(estimateMaxSharpeRatio(portf)*10^5)/10^5;
ret_MAXSHARPE   = cc_ind_ret_out*swt;
CC_IND_RET_MAXSHARPE  = [CC_IND_RET_MAXSHARPE; ret_MAXSHARPE];
ret_MAXSHARPE_IN = cc_ind_ret_in(in_index,:)*swt;
CC_IND_RET_MAXSHARPE_IN  = [CC_IND_RET_MAXSHARPE_IN; ret_MAXSHARPE_IN];
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

% Inverse volatility - IV
iwt = ones(1,size(cc_ind_ret_in,2))./nanstd(cc_ind_ret_in)./sum(ones(1,size(cc_ind_ret_in,2))./nanstd(cc_ind_ret_in));
iwt = round(iwt*10^5)/10^5;
ret_IV = cc_ind_ret_out*iwt';
CC_IND_RET_IV = [CC_IND_RET_IV; ret_IV];
ret_IV_IN =cc_ind_ret_in(in_index,:)*iwt';
CC_IND_RET_IV_IN  = [CC_IND_RET_IV_IN; ret_IV_IN];
 
% Efficient frontier: Mean-CVAR optimization
portf_cvar = PortfolioCVaR('AssetList', [CC_TICK, IND_TICK] );
portf_cvar = simulateNormalScenariosByData(portf_cvar, cc_ind_ret_in, 1000 );
portf_cvar = PortfolioCVaR(portf_cvar, 'UpperBudget', 1,  'LowerBudget', 1,...
                           'LowerBound', zeros(1, size(cc_ind_ret_in,2)),...
                           'UpperBound', upbound, 'ProbabilityLevel', 0.95);
wt_cvar = estimateFrontier(portf_cvar, 30);
pret_cvar = estimatePortReturn(portf_cvar, wt_cvar);
prsk_cvar = estimatePortRisk(portf_cvar, wt_cvar);
pstd_cvar = estimatePortStd(portf_cvar, wt_cvar);
PRSK_CVAR = [PRSK_CVAR, prsk_cvar];
PRET_CVAR = [PRET_CVAR, pret_cvar];

% MAX RET - CVAR: Portfolio with maximized return (on the  Mean-CVaR  efficient frontier) 
awt_cvar           = round(wt_cvar(:,end-1)*10^5)/10^5;%estimateFrontierByReturn(portf_cvar, pret_cvar(end));
ret_MAXRET_CVAR    = cc_ind_ret_out*awt_cvar;
CC_IND_RET_MAXRET_CVAR  = [CC_IND_RET_MAXRET_CVAR; ret_MAXRET_CVAR];
ret_MAXRET_CVAR_IN = cc_ind_ret_in(in_index,:)*awt_cvar;
CC_IND_RET_MAXRET_CVAR_IN  = [CC_IND_RET_MAXRET_CVAR_IN; ret_MAXRET_CVAR_IN];

% Portfolio with minimized variance (on the efficient frontier) 
pwt_cvar         = round(wt_cvar(:, 1)*10^5)/10^5;%estimateFrontierByRisk(portf_cvar, prsk_cvar(1));
ret_MINVAR_CVAR   = cc_ind_ret_out*pwt_cvar;
CC_IND_RET_MINVAR_CVAR  = [CC_IND_RET_MINVAR_CVAR; ret_MINVAR_CVAR];
ret_MINVAR_CVAR_IN = cc_ind_ret_in(in_index,:)*pwt_cvar;
CC_IND_RET_MINVAR_CVAR_IN  = [CC_IND_RET_MINVAR_CVAR_IN; ret_MINVAR_CVAR_IN];

%Maximum Diversification portfolios - MD with PDI
 pd = PortfolioDiversification('PortfolioWeights',ewt,'AssetCovar',nancov(cc_ind_ret_in),...
     'AssetReturns',cc_ind_ret_in,'DiversificationFunction', ...
     {'Portfolio Diversification Index'});

[pd] = MeasureDiversification(pd);

% Calculate Maximum Diversification Portfolio
[pd,mdwt] = MaxDiversificationPortfolio(pd, upbound);
mdwt = round(mdwt*10^5)/10^5;
ret_MD  = cc_ind_ret_out*mdwt;
CC_IND_RET_MD  = [CC_IND_RET_MD; ret_MD];
ret_MD_IN = cc_ind_ret_in(in_index,:)*mdwt;
CC_IND_RET_MD_IN  = [CC_IND_RET_MD_IN; ret_MD_IN]




% Weights 
WeightsBootstrap(n).AWT{b}                = awt;
WeightsBootstrap(n).SWT{b}                = swt;
WeightsBootstrap(n).PWT{b}                = pwt;
WeightsBootstrap(n).RPWT{b}               = rpwt;
WeightsBootstrap(n).PWT_CVAR{b}           = pwt_cvar;
WeightsBootstrap(n).AWT_CVAR{b}           = awt_cvar;
WeightsBootstrap(n).MDWT{b}               = mdwt;
WeightsBootstrap(n).IWT{b}                = iwt';


%Returns
WeightsBootstrap(n).CC_IND_RET_EW{b}             = ret_EW; 
WeightsBootstrap(n).CC_IND_RET_MAXRET{b}         = ret_MAXRET; 
WeightsBootstrap(n).CC_IND_RET_MINVAR{b}         = ret_MINVAR; 
WeightsBootstrap(n).CC_IND_RET_MAXSHARPE{b}      = ret_MAXSHARPE; 
WeightsBootstrap(n).CC_IND_RET_RP{b}             = ret_RP; 
WeightsBootstrap(n).CC_IND_RET_IV{b}             = ret_IV; 
WeightsBootstrap(n).CC_IND_RET_MINVAR_CVAR{b}    = ret_MINVAR_CVAR; 
WeightsBootstrap(n).CC_IND_RET_MD{b}             = ret_MD; 
WeightsBootstrap(n).CC_IND_RET_MAXRET_CVAR{b}    = ret_MAXRET_CVAR; 

WeightsBootstrap(n).CC_IND_RET_EW_IN{b}          = ret_EW_IN;
WeightsBootstrap(n).CC_IND_RET_MAXRET_IN{b}      = ret_MAXRET_IN;
WeightsBootstrap(n).CC_IND_RET_MINVAR_IN{b}      = ret_MINVAR_IN;
WeightsBootstrap(n).CC_IND_RET_MAXSHARPE_IN{b}   = ret_MAXSHARPE_IN;
WeightsBootstrap(n).CC_IND_RET_RP_IN{b}          = ret_RP_IN;
WeightsBootstrap(n).CC_IND_RET_IV_IN{b}          = ret_IV_IN;
WeightsBootstrap(n).CC_IND_RET_MINVAR_CVAR_IN{b} = ret_MINVAR_CVAR_IN;
WeightsBootstrap(n).CC_IND_RET_MD_IN{b}          = ret_MD_IN;
WeightsBootstrap(n).CC_IND_RET_MAXRET_CVAR_IN{b} = ret_MAXRET_CVAR_IN;
% RetBootstrap(n).CC_IND_RET_OUT{b}     = cc_ind_ret_out;
% RetBootstrap(n).CC_IND_RET_IN{b}      = cc_ind_ret_in;
% RetBootstrap(n).CC_VOL_WINDOW{b}      = cc_vol;


%Cumulative returns

WeightsBootstrap(n).CC_IND_CUMRET_EW{b}             = sum(ret_EW); 
WeightsBootstrap(n).CC_IND_CUMRET_MAXRET{b}         = sum(ret_MAXRET); 
WeightsBootstrap(n).CC_IND_CUMRET_MINVAR{b}         = sum(ret_MINVAR); 
WeightsBootstrap(n).CC_IND_CUMRET_MAXSHARPE{b}      = sum(ret_MAXSHARPE); 
WeightsBootstrap(n).CC_IND_CUMRET_RP{b}             = sum(ret_RP); 
WeightsBootstrap(n).CC_IND_CUMRET_IV{b}             = sum(ret_IV); 
WeightsBootstrap(n).CC_IND_CUMRET_MINVAR_CVAR{b}    = sum(ret_MINVAR_CVAR); 
WeightsBootstrap(n).CC_IND_CUMRET_MD{b}             = sum(ret_MD); 
WeightsBootstrap(n).CC_IND_CUMRET_MAXRET_CVAR{b}    = sum(ret_MAXRET_CVAR);

WeightsBootstrap(n).CC_IND_CUMRET_EW_IN{b}          = sum(ret_EW_IN);
WeightsBootstrap(n).CC_IND_CUMRET_MAXRET_IN{b}      = sum(ret_MAXRET_IN);
WeightsBootstrap(n).CC_IND_CUMRET_MINVAR_IN{b}      = sum(ret_MINVAR_IN);
WeightsBootstrap(n).CC_IND_CUMRET_MAXSHARPE_IN{b}   = sum(ret_MAXSHARPE_IN);
WeightsBootstrap(n).CC_IND_CUMRET_RP_IN{b}          = sum(ret_RP_IN);
WeightsBootstrap(n).CC_IND_CUMRET_IV_IN{b}          = sum(ret_IV_IN);
WeightsBootstrap(n).CC_IND_CUMRET_MINVAR_CVAR_IN{b} = sum(ret_MINVAR_CVAR_IN);
WeightsBootstrap(n).CC_IND_CUMRET_MD_IN{b}          = sum(ret_MD_IN);
WeightsBootstrap(n).CC_IND_CUMRET_MAXRET_CVAR_IN{b} = sum(ret_MAXRET_CVAR_IN);


% Define winning strtegies for weights based on max ret
CUMRETMAT = [sum(ret_EW); sum(ret_MAXRET); sum(ret_MINVAR); sum(ret_MAXSHARPE); 
             sum(ret_RP); sum(ret_IV); sum(ret_MINVAR_CVAR); sum(ret_MD); 
              sum(ret_MAXRET_CVAR)];
WeightsBootstrap(n).CUMRETMAT{b} = CUMRETMAT;
WeightsBootstrap(n).COMBWT{b}    = (CUMRETMAT==max(CUMRETMAT));


CUMRETMAT_IN = [sum(ret_EW_IN); sum(ret_MAXRET_IN); sum(ret_MINVAR_IN); sum(ret_MAXSHARPE_IN); sum(ret_RP_IN); sum(ret_IV_IN); sum(ret_MINVAR_CVAR_IN); sum(ret_MD_IN); sum(ret_MAXRET_CVAR_IN)];
WeightsBootstrap(n).CUMRETMAT_IN{b} = CUMRETMAT_IN;
WeightsBootstrap(n).COMBWT_IN{b}    = (CUMRETMAT_IN==max(CUMRETMAT_IN));



CEQ_EW             = mean(ret_EW)             - 0.5*var(ret_EW);
CEQ_MAXRET         = mean(ret_MAXRET)         - 0.5*var(ret_MAXRET);
CEQ_MINVAR         = mean(ret_MINVAR)         - 0.5*var(ret_MINVAR);
CEQ_MAXSHARPE      = mean(ret_MAXSHARPE)      - 0.5*var(ret_MAXSHARPE);
CEQ_RP             = mean(ret_RP)             - 0.5*var(ret_RP);
CEQ_IV             = mean(ret_IV)             - 0.5*var(ret_IV);
CEQ_MINVAR_CVAR    = mean(ret_MINVAR_CVAR)    - 0.5*var(ret_MINVAR_CVAR);
CEQ_MD             = mean(ret_MD)             - 0.5*var(ret_MD);
CEQ_MAXRET_CVAR    = mean(ret_MAXRET_CVAR)    - 0.5*var(ret_MAXRET_CVAR);

CEQ_EW_IN          = mean(ret_EW_IN)          - 0.5*var(ret_EW);
CEQ_MAXRET_IN      = mean(ret_MAXRET_IN)      - 0.5*var(ret_MAXRET_IN);
CEQ_MINVAR_IN      = mean(ret_MINVAR_IN)      - 0.5*var(ret_MINVAR_IN);
CEQ_MAXSHARPE_IN   = mean(ret_MAXSHARPE_IN)   - 0.5*var(ret_MAXSHARPE_IN);
CEQ_RP_IN          = mean(ret_RP_IN)          - 0.5*var(ret_RP_IN);
CEQ_IV_IN          = mean(ret_IV_IN)          - 0.5*var(ret_IV_IN);
CEQ_MINVAR_CVAR_IN = mean(ret_MINVAR_CVAR_IN) - 0.5*var(ret_MINVAR_CVAR_IN);
CEQ_MD_IN          = mean(ret_MD_IN)          - 0.5*var(ret_MD_IN);
CEQ_MAXRET_CVAR_IN = mean(ret_MAXRET_CVAR_IN) - 0.5*var(ret_MAXRET_CVAR_IN);

CUMRETMAT_CEQ = [CEQ_EW ; CEQ_MAXRET ; CEQ_MINVAR ; CEQ_MAXSHARPE ; CEQ_RP ; CEQ_IV ; CEQ_MINVAR_CVAR; CEQ_MD ];
WeightsBootstrap(n).CUMRETMAT_CEQ{b} = CUMRETMAT_CEQ;
WeightsBootstrap(n).COMBWT_CEQ{b}    = (CUMRETMAT_CEQ==max(CUMRETMAT_CEQ));

CUMRETMAT_CEQ_IN = [CEQ_EW_IN; CEQ_MAXRET_IN; CEQ_MINVAR_IN; CEQ_MAXSHARPE_IN; CEQ_RP_IN; CEQ_IV_IN ; CEQ_MINVAR_CVAR_IN; CEQ_MD_IN ; CEQ_MAXRET_CVAR_IN];
WeightsBootstrap(n).CUMRETMAT_CEQ_IN{b} = CUMRETMAT_CEQ_IN;
WeightsBootstrap(n).COMBWT_CEQ_IN{b}    = (CUMRETMAT_CEQ_IN==max(CUMRETMAT_CEQ_IN));

WeightsBootstrap(n).CEQ_EW{b}          = CEQ_EW;
WeightsBootstrap(n).CEQ_MAXRET{b}      = CEQ_MAXRET;
WeightsBootstrap(n).CEQ_MINVAR{b}      = CEQ_MINVAR;
WeightsBootstrap(n).CEQ_MAXSHARPE{b}   = CEQ_MAXSHARPE;
WeightsBootstrap(n).CEQ_RP{b}          = CEQ_RP;
WeightsBootstrap(n).CEQ_IV{b}          = CEQ_IV;
WeightsBootstrap(n).CEQ_MINVAR_CVAR{b} = CEQ_MINVAR_CVAR;
WeightsBootstrap(n).CEQ_MD{b}          = CEQ_MD;
WeightsBootstrap(n).CEQ_MAXRET_CVAR{b} = CEQ_MAXRET_CVAR;

WeightsBootstrap(n).CEQ_EW_IN{b}          = CEQ_EW_IN;
WeightsBootstrap(n).CEQ_MAXRET_IN{b}      = CEQ_MAXRET_IN;
WeightsBootstrap(n).CEQ_MINVAR_IN{b}      = CEQ_MINVAR_IN;
WeightsBootstrap(n).CEQ_MAXSHARPE_IN{b}   = CEQ_MAXSHARPE_IN;
WeightsBootstrap(n).CEQ_RP_IN{b}          = CEQ_RP_IN;
WeightsBootstrap(n).CEQ_IV_IN{b}          = CEQ_IV_IN;
WeightsBootstrap(n).CEQ_MINVAR_CVAR_IN{b} = CEQ_MINVAR_CVAR_IN;
WeightsBootstrap(n).CEQ_MD_IN{b}          = CEQ_MD_IN;
WeightsBootstrap(n).CEQ_MAXRET_CVAR_IN{b} = CEQ_MAXRET_CVAR_IN;

end
 nshift = nshift+1
end

% Returns for all strategies for bootstrapped scenarios
COMBWT_CEQ_ALL = []; 
COMBWT_ALL = [];
COMBWT_CEQ_ALL_IN = []; 
COMBWT_ALL_IN = [];
for n = 1:length(WeightsBootstrap)
    COMBWT_CEQ_ALL = [COMBWT_CEQ_ALL, sum(cell2mat(WeightsBootstrap(n).COMBWT_CEQ),2)/B];  
    COMBWT_ALL = [COMBWT_ALL, sum(cell2mat(WeightsBootstrap(n).COMBWT),2)/B];
     COMBWT_CEQ_ALL_IN = [COMBWT_CEQ_ALL_IN, sum(cell2mat(WeightsBootstrap(n).COMBWT_CEQ_IN),2)/B];  
    COMBWT_ALL_IN = [COMBWT_ALL_IN, sum(cell2mat(WeightsBootstrap(n).COMBWT_IN),2)/B];
end

% Short without max returns
for b = 1:B
    for n = 1:length(WeightsBootstrap)
CUMRETMAT_RISK_CEQ = WeightsBootstrap(n).CUMRETMAT_CEQ{b}; %[CEQ_EW ;  CEQ_MINVAR ; CEQ_MAXSHARPE ; CEQ_RP ; CEQ_IV ; CEQ_MINVAR_CVAR; CEQ_MD ];
CUMRETMAT_RISK_CEQ = CUMRETMAT_RISK_CEQ([1,3:end-1], :);%[CEQ_EW ; CEQ_MINVAR ; CEQ_MAXSHARPE ; CEQ_RP ; CEQ_IV ; CEQ_MINVAR_CVAR; CEQ_MD ];
WeightsBootstrap(n).COMBWT_RISK_CEQ{b}    = (CUMRETMAT_RISK_CEQ==max(CUMRETMAT_RISK_CEQ));

CUMRETMAT_RISK_CEQ_IN = WeightsBootstrap(n).CUMRETMAT_CEQ_IN{b}; 
CUMRETMAT_RISK_CEQ_IN = CUMRETMAT_RISK_CEQ_IN([1,3:end-1], :);
WeightsBootstrap(n).COMBWT_RISK_CEQ_IN{b}    = (CUMRETMAT_RISK_CEQ_IN==max(CUMRETMAT_RISK_CEQ_IN));


CUMRETMAT_RISK = WeightsBootstrap(n).CUMRETMAT{b}; 
CUMRETMAT_RISK = CUMRETMAT_RISK([1,2:end-1], :);
WeightsBootstrap(n).COMBWT_RISK{b}    = (CUMRETMAT_RISK==max(CUMRETMAT_RISK));

CUMRETMAT_RISK_IN = WeightsBootstrap(n).CUMRETMAT_IN{b}; 
CUMRETMAT_RISK_IN = CUMRETMAT_RISK_IN([1,2:end-1], :);
WeightsBootstrap(n).COMBWT_RISK_IN{b}    = (CUMRETMAT_RISK_IN==max(CUMRETMAT_RISK_IN));
    end
end
% Returns for all strategies for bootstrapped scenarios
COMBWT_RISK_CEQ_ALL = []; 
COMBWT_RISK_ALL = [];
COMBWT_RISK_CEQ_ALL_IN = []; 
COMBWT_RISK_ALL_IN = [];
for n = 1:length(WeightsBootstrap)
    COMBWT_RISK_CEQ_ALL = [COMBWT_RISK_CEQ_ALL, sum(cell2mat(WeightsBootstrap(n).COMBWT_RISK_CEQ),2)/B];  
    COMBWT_RISK_ALL = [COMBWT_RISK_ALL, sum(cell2mat(WeightsBootstrap(n).COMBWT_RISK),2)/B];
    COMBWT_RISK_CEQ_ALL_IN = [COMBWT_RISK_CEQ_ALL_IN, sum(cell2mat(WeightsBootstrap(n).COMBWT_RISK_CEQ_IN),2)/B];  
    COMBWT_RISK_ALL_IN = [COMBWT_RISK_ALL_IN, sum(cell2mat(WeightsBootstrap(n).COMBWT_RISK_IN),2)/B];
end

%Save variables to the file
save(strcat('CCP_Bootstrap_weights_liquidity_const_',liquidity_const, '_rebal_',rebal_freq,num2str(insample_width), datestr(date_begin),'_',datestr(date_end),'.mat'))
