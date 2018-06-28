function [diff] = sharpeRatioDiff(ret)
% Computes the difference betweeen two Sharpe ratios
% Inputs:
    % ret = T*2 matrix of returns (type double)
% Outputs:
    % diff = difference of the two Sharpe ratios
% Note:
    % returns are assumed to be in excess of the risk-free rate already
    ret1 = ret(:,1);
    ret2 = ret(:,2);
    mu1hat = mean(ret1);
    mu2hat = mean(ret2);
    sig1hat = var(ret1)^0.5;
    sig2hat = var(ret2)^0.5;
    SR1hat = mu1hat/sig1hat;
    SR2hat = mu2hat/sig2hat;
    diff = SR1hat - SR2hat;
end
