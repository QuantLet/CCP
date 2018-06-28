function [se]=computeSE(ret,type) 

    ret1 = ret(:,1);
    ret2 = ret(:,2);
    T = size(ret1,1);
    mu1hat = mean(ret1);
    mu2hat = mean(ret2);
    gamma1hat = mean(ret1.^2);
    gamma2hat = mean(ret2.^2);
    gradient = zeros(4,1);
    gradient(1) = gamma1hat/(gamma1hat - mu1hat^2)^1.5;
    gradient(2) = -gamma2hat/(gamma2hat - mu2hat^2)^1.5;
    gradient(3) = -0.5 * mu1hat/(gamma1hat - mu1hat^2)^1.5;
    gradient(4) = 0.5 * mu2hat/(gamma2hat - mu2hat^2)^1.5;
    Vhat = computeVhat(ret);
    PsiHat = computePSI(Vhat,type);
    se = sqrt((gradient'*PsiHat*gradient)/T);
end
   
