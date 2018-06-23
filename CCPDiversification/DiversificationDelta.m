function [H]=DiversificationDelta(AssetReturns)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this funciton computes the Diversification Delta,
% see: Vermorken M.A., Medda F.R., Schroder T. (2012): ”The Diversification Delta: A Higher Moment Measure for Portfolio Diversification”
% and Wallis K.F. (2006): “A note on the calculation of entropy from histograms”
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUTS
%  AssetReturns     : [matrix] (M x N) historical Asset Returns

% OUTPUTS
% H : [vector] (N x 1) entropy of historical distribution of returns

H=zeros(size(AssetReturns,2),1);
for i=1:size(AssetReturns,2)
    [counts,binCenters] = hist(AssetReturns(:,i),100);
    binWidth = diff(binCenters)';
    binWidth = [binWidth(end);binWidth]; % Replicate last bin width for first, which is indeterminate.
    nz = counts>0; % Index to non-zero bins
    frequency = counts(nz)/sum(counts(nz));
    H(i) = -sum(frequency'.*log(frequency'./binWidth(nz)));
end