function [se,pval,sepw,pvalpw]=CEQHAC(ret1,ret2,gamma, type)
%This function performs HAC inference on the difference between 2 sharpe
%ratios. 
%Inputs:
    %ret= T*2 matrix of returns (type double).
    %type= (optional) specifies the kernel to be used to calculate Psi hat
    %2 options are available 'G' for the Parzen-Gallant kernel (default) and 'QS'
    %for the Quadratic Spectral kernel(type string).
%Outputs:
    %se= HAC standard error
    %pval= HAC p-value
    %sepw= HAC standard error pre-whitened
    %pvalpw= HAC p-value pre-whitened
   if not(ismember('type',who)), type='G'; end;
   if not(ismember('gamma',who)), gamma=1; end;
%     Defaults = {1,'G'};
%     Defaults(1:nargin) = varargin;
    ret1 = ret1;
    ret2 = ret2;
    mu1hat = mean(ret1);
    mu2hat = mean(ret2);
    var1hat = var(ret1);
    var2hat = var(ret2);
    CEQ1hat = mu1hat - gamma/2*var1hat;
    CEQ2hat = mu2hat - gamma/2*var2hat;
    diff = CEQ1hat - CEQ2hat;
    se = computeSEceq([ret1,ret2],gamma,type);
    sepw = computeSEpwceq([ret1,ret2],gamma,type);
    %calculating normal cdf recursively
    fun= @(x) (1/sqrt(pi*2))*exp(-0.5*x.^2);
    pval = 2 *integral(fun,-1000,-abs(diff)/se);
    pvalpw = 2 * integral(fun,-1000,-abs(diff)/sepw);   
end
