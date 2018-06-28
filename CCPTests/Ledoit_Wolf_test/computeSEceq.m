function [se]=computeSEceq(ret,gamma,type) 

    ret1 = ret(:,1);
    ret2 = ret(:,2);
    T = size(ret1,1);
    mu1hat = mean(ret1);
    mu2hat = mean(ret2);
    gamma1hat = mean(ret1.^2);
    gamma2hat = mean(ret2.^2);
    gradient = zeros(4,1);
    gradient(1) =   1+gamma*mu1hat;
    gradient(2) = -(1+gamma * mu2hat);
    gradient(3) = -gamma/2;
    gradient(4) =  gamma/2;
    Vhat = computeVhat(ret);
    PsiHat = computePSI(Vhat,type);
    se = sqrt((gradient'*PsiHat*gradient)/T);
end
   
