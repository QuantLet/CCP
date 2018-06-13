%% Spanning tests -  Condacts all Mean-variance tests from Kan, Zhou (2012)

W_all   = [];
LR_all  = [];
LM_all  = [];
pw_all  = [];
plr_all = [];
plm_all = [];
Ftest_all  = [];
Ftest1_all = [];
Ftest2_all = [];
pval_all   = [];
pval1_all  = [];
pval2_all  = [];
alpha_all  = [];
delta_all  = [];
for n=1:size(CC_RET_wins,2)
    [W,LR,LM,pw,plr,plm] = span(IND_RET(end-261:end,:), CC_RET_wins(end-261:end,n));
    [Ftest,Ftest1,Ftest2,pval,pval1,pval2,alpha,delta] = stepdown(IND_RET(end-261:end,:), CC_RET_wins(end-261:end,n));
    W_all   = [W_all  , W ];
    LR_all  = [LR_all , LR ];
    LM_all  = [LM_all , LM ];
    pw_all  = [pw_all , pw ];
    plr_all = [plr_all, plr ];
    plm_all = [plm_all, plm ];
    Ftest_all  = [Ftest_all, Ftest ];
    Ftest1_all = [Ftest1_all, Ftest1];
    Ftest2_all = [Ftest2_all, Ftest2];
    pval_all   = [pval_all, pval  ];
    pval1_all  = [pval1_all, pval1 ];
    pval2_all  = [pval2_all, pval2 ];
    alpha_all  = [alpha_all, alpha ];
    delta_all  = [delta_all, delta ];
end   
 [W,LR,LM,pw,plr,plm] = span(IND_RET, CC_RET_wins(:,pval_all<0.05)); %Display only significant results
 [Ftest,Ftest1,Ftest2,pval,pval1,pval2,alpha,delta] = stepdown(IND_RET, CC_RET_wins(:,pval_all<0.05));
%% Save results to tex tables 
input.data                      = [W,LR,LM,Ftest,Ftest1,Ftest2;pw,plr,plm,pval,pval1,pval2]';
input.tableColLabels            = {'Test-stat', 'P-value'};
input.tableRowLabels            = {'Wald', 'LR', 'LM','F-test', 'F-test1', 'F-test2'};
input.transposeTable            = 0;
input.dataFormatMode            = 'column'; 
input.dataNanString             = '-';
input.tableColumnAlignment      = 'r';
input.tableBorders              = 0;
input.tableCaption              = strcat('Diversification measures: rebalancing_', rebal_freq, '_liquidity constraint_',liquidity_const);
input.makeCompleteLatexDocument = 0;
latex                           = latexTable(input);
%% Save results to tex tables Spanning tests for all cryptos separately
input.data                      = [Ftest_all;Ftest1_all;Ftest2_all;pval_all;pval1_all;pval2_all]';
input.tableColLabels            = {'F-Test', 'F-Test1','F-Test2', 'P-value', 'P-value 1',  'P-value 2'};
input.tableRowLabels            = CC_TICK;
input.transposeTable            = 0;
input.dataFormatMode            = 'column'; 
input.dataFormat                = {'%.2f'};
input.dataNanString             = '-';
input.tableColumnAlignment      = 'r';
input.tableBorders              = 0;
input.tableCaption              = strcat('Diversification measures: rebalancing_', rebal_freq, '_liquidity constraint_',liquidity_const);
input.makeCompleteLatexDocument = 0;
latex                           = latexTable(input);
%% Tests of Sharpe and CEQ difference significance according  Wolf, Ledoit  (2008)
RET_ALL = [IND_RET(end-size(CC_IND_RET_EW,1)+1:end,4), IND_RET_EW, ...                                                                                                                                                         
           CC_IND_RET_EW,  CC_IND_RET_MAXRET, CC_IND_RET_MAXSHARPE, ...
           CC_IND_RET_MINVAR, CC_IND_RET_RP, ...
           CC_IND_RET_MINVAR_CVAR, CC_IND_RET_MD,...
           CC_IND_RET_ALL_COMB_NAIVE, CC_IND_RET_ALL_COMB_CEQ];
STR_COMB   = nchoosek(1:size(RET_ALL, 2), 2);       
PVAL       = [];
PVALPW     = [];
PVAL_CEQ   = [];
PVALPW_CEQ = [];
PVAL_Bootstrap       = [];
PVALPW_Bootstrap     = [];
PVAL_CEQ_Bootstrap   = [];
PVALPW_CEQ_Bootstrap = [];
bstar = 5; %length of block for bootstrap inference
M = 1000; %number of resamplings
gamma = 1; %risk-averse
for n = 1: size(STR_COMB, 1)
    [se, pval,sepw,pvalpw]         = sharpeHACnoOut(RET_ALL(:,STR_COMB (n,1)),RET_ALL(:,STR_COMB (n,2)));
    [seCE, pvalCE,sepwCE,pvalpwCE] = CEQHACnoOut(RET_ALL(:,STR_COMB (n,1)),RET_ALL(:,STR_COMB (n,2)),2);
    PVAL                           = [PVAL; pval];
    PVALPW                         = [PVALPW; pvalpw];
    PVAL_CEQ                       = [PVAL_CEQ; pvalCE];
    PVALPW_CEQ                     = [PVALPW_CEQ; pvalpwCE];

end
%% Save results to tex tables 
STR_NAME                       =  {'INDEX','IND-EW', 'EW', 'MV - max ret', ...
                                   'MV - max Sharpe','Min Var','ERC',...
                                    'MCVaR - min risk',  'MD', 'COMB NAIVE', 'COMB'}

input2.data                    = [PVAL, PVAL_CEQ];

input2.tableColLabels          = {'P-Value Sharpe', 'P-Value CEQ'};
input2.tableRowLabels          = {};
for n = 1:size(PVAL_CEQ,1)
    input2.tableRowLabels(n) = strcat(STR_NAME(STR_COMB(n,1)),' - ',STR_NAME(STR_COMB(n,2)));
end

input2.transposeTable           = 0;
input2.dataFormatMode           = 'column'; 
input2.dataNanString             = '-';
input2.tableColumnAlignment      = 'r';
input2.tableBorders              = 0;
input2.tableCaption              = strcat('P-value_', rebal_freq, '_liquidity constraint_',liquidity_const);
input2.makeCompleteLatexDocument = 0;
latex                           = latexTable(input2);


%% T-stat results to tex tables 
[H,P,CI,STATS] = ttest(repmat(CC_IND_RET_EW,[1,8]),[CC_IND_RET_MAXRET, CC_IND_RET_MAXSHARPE, CC_IND_RET_MINVAR, CC_IND_RET_RP, CC_IND_RET_MINVAR_CVAR, CC_IND_RET_MD, CC_IND_RET_ALL_COMB_NAIVE,CC_IND_RET_ALL_COMB_CEQ]);
STR_NAME                       =  {  'RR - Max Ret', ...
                                   'MV -S','MinVar','ERC',...
                                    'MinCVaR',  'MD', 'COMB NA\"IVE', 'COMB'}

input2.data                    = [STATS.tstat;P]';

input2.tableColLabels          = {'t-stat', 'P-Value'};
input2.tableRowLabels          = STR_NAME;
input2.dataFormat                = {'%.2f'};
input2.transposeTable           = 0;
input2.dataFormatMode           = 'column'; 
input2.dataNanString             = '-';
input2.tableColumnAlignment      = 'r';
input2.tableBorders              = 0;
input2.tableCaption              = strcat('P-value_', rebal_freq, '_liquidity constraint_',liquidity_const);
input2.makeCompleteLatexDocument = 0;
latex                           = latexTable(input2);