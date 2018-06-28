function [pValue,DeltaHat,d,b] = bootInference(ret,b,M,seType,pw,DeltaNull)
% Carries out bootstrap test for equality of Sharpe ratios
% Inputs: 
    % ret = [T,2] matrix of returns (in excess of the risk-free rate)
    % b = block size of circular bootstrap; 
    %     of not specified by user, `optimal' block size will be 
    %     computed by the routine blockSizeCalibrate
    % M = number of bootstrap repetitions; the default is M = 4999
    % seType = type of HAC standard error for 'original' test statistic
    %          use 'G' for Parzen-Gallant or 'QS' for Quadratic-Spectral;
    %          the default is seType = 'G'
    % pw = logical variable of whether to use prewhitended HAC standard
    %      error or not; the default is pw = 1
    % DeltaNull = the hypothesized value for Delta; 
    %             the default is DeltaNull = 0
% Outputs:
    % pValue = bootstrap p-value for H_0: Delta = DeltaNull
    % DeltaHat = observed difference in Sharpe ratios
    % d = 'original' test statistic
% Note:
    % 
    if (nargin < 6)
        DeltaNull = 0;
    end
    if (nargin < 5)
        pw = 1;
    end
    if (nargin < 4)
        seType = 'G';
    end    
    if (nargin < 3)
        M = 4999;
    end  
    if (nargin < 2)
        b = blockSizeCalibrate(ret);
    end  
    % compute observed difference in Sharpe ratios
    DeltaHat = sharpeRatioDiff(ret);
    % compute HAC standard error (prewhitended if desired)
    [se,pval,sePw,pvalPw] = sharpeHACnoOut(ret,seType);
    if (pw)
        se = sePw;
    end
    % compute 'original' test statistic
    d = abs(DeltaHat-DeltaNull)/se;
    bRoot = b^0.5;
    [T,N] = size(ret);
    l = floor(T/b);
    % adjusted sample size for block bootstrap (using a multiple of the block size)
    Tadj = l*b;
    pValue = 1;
    for (m = 1:M)
        % bootstrap pseudo data and various bootstrap statistics
        retStar = ret(cbbSequence(Tadj,b),:);
        DeltaHatStar = sharpeRatioDiff(retStar);
        ret1Star = retStar(:,1);
        ret2Star = retStar(:,2);
        mu1HatStar = mean(ret1Star);
        mu2HatStar = mean(ret2Star);
        gamma1HatStar = mean(ret1Star.^2);
        gamma2HatStar = mean(ret2Star.^2);
        gradient = zeros(4,1);
        gradient(1) = gamma1HatStar/(gamma1HatStar-mu1HatStar^2)^1.5;
        gradient(2) = -gamma2HatStar/(gamma2HatStar-mu2HatStar^2)^1.5;   
        gradient(3) = -0.5*mu1HatStar/(gamma1HatStar-mu1HatStar^2)^1.5;
        gradient(4) = 0.5*mu2HatStar/(gamma2HatStar-mu2HatStar^2)^1.5;
        yStar = [ret1Star-mu1HatStar,ret2Star-mu2HatStar,ret1Star.^2-gamma1HatStar,ret2Star.^2-gamma2HatStar];
        % compute bootstrap standard error
        PsiHatStar = zeros(4,4);
        for (j = 1:l)
            zetaStar = bRoot*mean(yStar(((j-1)*b+1):(j*b),:),1)
            % the following command does not work when b = 1
            % zetaStar = bRoot*mean(yStar(((j-1)*b+1):(j*b),:));
            PsiHatStar = PsiHatStar+zetaStar'*zetaStar;
        end
        PsiHatStar = PsiHatStar/l;
        seStar = sqrt(gradient'*PsiHatStar*gradient/Tadj);
        % compute bootstrap test statistic (and update p-value accordingly)
        dStar = abs(DeltaHatStar-DeltaHat)/seStar;
        if (dStar >= d)
            pValue = pValue+1;
        end
    end
    pValue = pValue/(M+1);
end
