function [se,pval,sepw,pvalpw]=varHAC(ret,type)
%This function performs HAC inference on the difference between 2 variances
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
    ret1 = ret(:,1);
    ret2 = ret(:,2);
    var1hat = var(ret1);
    var2hat = var(ret2);
    logvar1hat = log(var1hat);
    logvar2hat = log(var2hat);
    diff = logvar1hat - logvar2hat;
    se = computeSEvar(ret,type);
    sepw = computeSEpwvar(ret,type);
    %calculating normal cdf recursively
    fun= @(x) (1/sqrt(pi*2))*exp(-0.5*x.^2);
    pval = 2 *integral(fun,-1000,-abs(diff)/se);
    pvalpw = 2 * integral(fun,-1000,-abs(diff)/sepw);
    SEs=['HAC Standard error'];
    fprintf('%s \n',SEs)
    disp(se)
    pvals=['HAC p-value'];
    fprintf('%s \n',pvals)
    disp(pval)
    SEspw=['HAC Standard error pre-whitened'];
    fprintf('%s \n',SEspw)
    disp(sepw)
    pvalspw=['HAC p-value pre-whitened'];
    fprintf('%s \n',pvalspw)
    disp(pvalpw)
    
end
