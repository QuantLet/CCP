function [diff] = CEQRatioDiff(ret1,ret2,gamma)
% Computes the difference betweeen two CEQ ratios
% Inputs:
    % ret = T*2 matrix of returns (type double)
% Outputs:
    % diff = difference of the two Sharpe ratios
% Note:
    % returns are assumed to be in excess of the risk-free rate already
    if not(ismember('gamma',who)), gamma=1; end;
        ret1 = ret1;
    ret2 = ret2;
    mu1hat = mean(ret1);
    mu2hat = mean(ret2);
    var1hat = var(ret1);
    var2hat = var(ret2);
    CEQ1hat = mu1hat - gamma/2*var1hat;
    CEQ2hat = mu2hat - gamma/2*var2hat;
    diff = CEQ1hat - CEQ2hat;
end
