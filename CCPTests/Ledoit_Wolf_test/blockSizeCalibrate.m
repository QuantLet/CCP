function [bOpt,bVecWithProbs] = blockSizeCalibrate(ret,bVec,alpha,M,K,bAv,Tstart,seType,pw)
% Computes optimal block size, as described in Algorithm 3.1 
% Inputs:
    % ret = T*2 matrix of returns (type double)
    % bVec = vector of 'candidate' block sizes, must be a column vector;
    %        default is [1,2,4,6,8,10], can be 'reduced' if needed
    % alpha = nominal significance level; default is alpha = 0.05
    % M = number if 'inner' bootstrap repetitions; default is M = 199
    % K = number of 'outer' bootstrap repetitons; default is K = 2000
    % bAv = average block size for stationary bootstrap; default is bAv = 5
    % Tstart = number of 'warm up' observation for VAR generated data;
    %          default is Tstart = 50
    % seType = type of standard error for 'original' test statistic;
    %          default is seType = 'G' (for Parzen-Gallant kernel)
    % pw = logical variable whether to prewhiten or not; default is pw = 1
% Outputs:
    % bOpt = optimal block size
    % bVecWithProbs = vector of candidate block sizes, together with 
    %                 corresponding simulated rejection probabilities
% Note:
    % 
    
    if (nargin < 9)
        pw = 1;
    end
    if (nargin < 8)
        seType = 'G';
    end
    if (nargin < 7)
        Tstart = 50;
    end
    if (nargin < 6)
        bAv = 5;
    end
    if (nargin < 5)
        K = 2000;
    end    
    if (nargin < 4)
        M = 199;
    end  
    if (nargin < 3)
        alpha = 0.05;
    end  
    if (nargin < 2)
        bVec = [1,2,4,6,8,10]';
    end   

    bLen = max(size(bVec));
    empRejectProbs = zeros(bLen,1);
    DeltaHat = sharpeRatioDiff(ret);
    ret1 = ret(:,1);
    ret2 = ret(:,2);
    T = max(size(ret1));
    VarData = zeros(Tstart+T,2);
    VarData(1,:) = ret(1,:);
    y1 = ret1(2:T);
    y2 = ret2(2:T);
    x1 = ret1(1:(T-1));
    x2 = ret2(1:(T-1));
%  Would need statistics toolbox for the following way to fit VAR:       
%     tbl = table(x1,x2,y1,y2,'VariableNames',{'x1','x2','y1','y2'});
%     fit1 = fitlm(tbl,'y1~x1+x2')
%     fit2 = fitlm(tbl,'y2~x1+x2')
%     coef1 = fit1.Coefficients.Estimate
%     coef2 = fit2.Coefficients.Estimate
%     resid1 = fit1.Residuals.Raw;
%     resid2 = fit2.Residuals.Raw;
%
%  In this way, no toolbox is needed:
    X = [ones(T-1,1),x1,x2];
    XprimeX = X'*X;
    coef1 = linsolve(X'*X,X'*y1);
    coef2 = linsolve(XprimeX,X'*y2);
    resid1 = y1-X*coef1;
    resid2 = y2-X*coef2;  
    residMat = [resid1,resid2];
    for (k = 1:K)
        % k
        residMatStar = [zeros(1,2);residMat(sbSequence(T-1,bAv,Tstart+T-1),:)];
        for (t = 2:(Tstart+T))
            VarData(t,1) = coef1(1)+coef1(2)*VarData(t-1,1)+coef1(3)*VarData(t-1,2)+residMatStar(t,1);
            VarData(t,2) = coef2(1)+coef2(2)*VarData(t-1,2)+coef2(3)*VarData(t-1,2)+residMatStar(t,2);
        end
        VarDataTrunc = VarData((Tstart+1):(Tstart+T),:);
        for (j = 1:bLen)
            [pValue,DeltaHatStar,d] = bootInference(VarDataTrunc,bVec(j),M,seType,pw,DeltaHat);
            if (pValue <= alpha)
                empRejectProbs(j) = empRejectProbs(j)+1;
            end
        end
    end
    empRejectProbs = empRejectProbs/K;
    [bSort,bOrder] = sort(abs(empRejectProbs-alpha));
    bOpt = bVec(bOrder(1));
    bVecWithProbs = [bVec,empRejectProbs];
end






















