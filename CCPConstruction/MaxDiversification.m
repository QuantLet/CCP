function [Div]=MaxDiversification(w,Eps,LogRet,DiversificationFunction)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function computes the Maximum Diversification portfolio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUTS
%  w     : [vector] (N x 1) weights distribution
%  Eps     : [matrix] N x N variance covariance matrix
%  LogRet    : [matrix] (M x N) matrix of historical asset returns (M is the
%  number of observations)
%  DiversificationFunction : [string] diversification measure to be
%  optimized
%  OUTPUTS
%  Div : [scalar] negative of diversification attained 

pd=PortfolioDiversification('PortfolioWeights',w,'AssetCovar',Eps,'AssetReturns',LogRet,'DiversificationFunction',DiversificationFunction);
pd=MeasureDiversification(pd);
switch pd.DiversificationFunction{1}
    case 'Weights'
        Div=-pd.WeightsDistributionEntropy;
    case 'Marginal Risk Contributions'
        Div=-pd.MarginalRiskContributionsEntropy;
    case 'ENB_PCA'
        Div=-pd.ENB_PCA;
    case 'ENB_MT'
        Div=-pd.ENB_MT;
    case 'Diversification Delta'
        Div=-pd.Diversification_Delta;
    case 'Diversification Return'
        Div=-pd.N_Eff_DiversificationReturn;
    case 'Portfolio Variance'
        Div=-pd.N_Eff_PortfolioVariance;
    case 'Diversification Ratio'
        Div=-pd.DiversificationRatio;
    case 'Portfolio Diversification Index'
        Div=-pd.PDI;
end

end